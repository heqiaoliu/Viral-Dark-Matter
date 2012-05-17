function [m,bestchoice,nchoice,failflag] = n4sid_f(dat,order,varargin)
% n4sid subroutine for for Domain='Frequency'; only to be called from n4sid.

%function [sys,x0] = n4sid_f(w,y,u,n,q,mode);

% Copyright 2002-2010 The MathWorks, Inc.
% $Revision: 1.13.4.13 $  $Date: 2010/02/08 22:34:50 $

% Size requirements:
%
%      N_eff >= nx + q*m_eff
% where N_eff = 2*times complex data and 1*times real data
% and  m_eff = nu if no initial condition is estimated
%            = nu+1 if initial condition is estimated
%
% A sligthly conservative bound is then
%  2N - 2 >= nx + q(nu+1)

%mode.alg = 'wproj'; % In this version mode.alg is always 'auto'

maxfscale = 0.4;  %Scaling of frequencies (continuous time)
XIDplotw = varargin{end};
arg = varargin{end-1};
varargin = varargin(1:end-2);
realflag = realdata(dat);
% Assume data is iddata object and only "new" syntax

[N,ny,nu]=size(dat);
if nu == 0
    ctrlMsgUtils.error('Ident:estimation:n4sidTimeSeriesFreqData');
end

if nargin<2
    order=[];
end
if isempty(order)
    order='best';
end
nkset = 0;
nk = ones(nu,1)';
imatch = strmatch('nk',lower(varargin(1:2:end)));
if ~isempty(imatch)
    nk = varargin{2*imatch};
    nk=nk(:)';
    if length(nk)~=nu
        ctrlMsgUtils.error('Ident:estimation:n4sidcheck4')
    end
    varargin = varargin([1:2*imatch-2,2*imatch+1:end]);
    nkset = 1;
end
Tsdata = pvget(dat,'Ts');
Tsdat = Tsdata{1};
if Tsdat==0 && any(nk>1)
    ctrlMsgUtils.warning('Ident:estimation:CTDataNkVal')
    nk = min(nk,1);
end
inters = pvget(dat,'InterSample');
inters = inters{1,1}; %%LL same for all
def_order = 0;
if isa(order,'idss')
    mprel=order;order=size(mprel,'nx');
    if ~nkset
        nk = pvget(mprel,'nk');
    else
        mprel =pvset(mprel,'nk',nk);
    end
    if length(varargin)>1
        set(mprel,varargin{:});
    end
    [nmy,nmu]=size(mprel);
    if nmy~=ny || nmu~=nu
        ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
    end
else
    if ischar(order)
        order=1:10;
        def_order = 1;
    end
    
    nxx = min(order);
    
    if nxx<=0 || floor(nxx)~=nxx
        ctrlMsgUtils.error('Ident:estimation:n4sidInvalidModelOrder')
    end
    c = [eye(ny),zeros(ny,nxx)];
    c = c(:,1:nxx);
    mprel=idss(randn(nxx,nxx),ones(nxx,nu),c,zeros(ny,nu),zeros(nxx,ny),...
        zeros(nxx,1),'Ks',NaN*ones(nxx,ny),'X0s',NaN*ones(nxx,1));
    mprel = pvset(mprel,'SSParameterization','Free');%'Ks',NaN*ones(1,ny));
    
    mprel =pvset(mprel,'nk',nk);
    mprel = pvset(mprel,'Ts',Tsdat); %%LL
    if nargin>2 && ~isempty(varargin)
        try
            set(mprel,varargin{:}) % should skip 'Canonical' here
            % Here is a question of InitialState = 'auto'.
        catch E
            throw(E)
        end
    end
end
if strcmp(pvget(mprel,'SSParameterization'),'Structured')
    ctrlMsgUtils.error('Ident:estimation:n4sidStrucPar')
end

%initial state for EstimationInfo (todo: G454681)
switch mprel.InitialState
    case {'Auto','Estimate'}
        init = 'Estimate';
    case 'Backcast'
        init = 'Zero';
    otherwise
        init = mprel.InitialState;
end

algorithm = pvget(mprel,'Algorithm');
Tsm = pvget(mprel,'Ts');
if Tsdat~=Tsm
    if Tsm == 0 % then this has been set in the arguments
        % say something perhaps
    end
    if Tsdat == 0
        ctrlMsgUtils.error('Ident:estimation:DTModelCTData')
    end
end
%delayu=find(nk>1);
nks = max(nk-1,zeros(size(nk)));
idmod=pvget(mprel,'idmodel');
inpd = pvget(idmod,'InputDelay');

if pvget(idmod,'Ts') == 0 && any(inpd ~= 0)
    if Tsdat==0
        dat = nkshift(dat,inpd);%%%LL080517
        inpd= zeros(size(inpd));
        idmod= pvset(idmod,'InputDelay',inpd);
        vud = strncmpi('ud',varargin(1:2:end),2)+strncmpi('inputd',varargin(1:2:end),5);
        nr = find(vud);
        varargin=varargin(1:nr-1:nr+1:end);
        % Remove InputDelay from Varargin
        %then tsdat is in seconds
    else
        inpd = inpd/Tsdat;
        if any(abs(inpd-round(inpd))>1e4*eps)
            ctrlMsgUtils.error('Ident:idmodel:inputDelayCTModel')
        else
            inpd = round(inpd);
        end
    end
    
end
if ~strcmp(pvget(idmod,'CovarianceMatrix'),'None') && ...
        (2*ny+nu)*max(order)>200 % more than 100 canonical parameters
    ctrlMsgUtils.warning('Ident:estimation:highOrderWithCovariance')
end
% Here nks and inpd are given as a multiple of the sampling interval
if Tsdat==0
    dats = nkshift(dat,inpd');
else
    dats = nkshift(dat,inpd'+nks);
end
mode.nk = (nk>0);
if any(strcmpi(pvget(mprel,'Focus'),{'stability'}))
    mode.stab = 'stable';
end
if ~strcmpi(pvget(mprel,'InitialState'),'zero')
    mode.x0 = 'estim'; %Auto case
    estx0 = 1;
else
    mode.x0 = 'noestim';
    estx0 = 0;
end

% Catch focus case
foc = algorithm.Focus;
stabenf = 0;
if ~isempty(foc)
    if ischar(foc)
        if strcmpi(foc,'stability') || strcmpi(foc,'simulation')
            stabenf=1;
        end
    else
        foc = foccheck(foc,Tsdat,[],'f');
        dats = idfilt(dats,foc); % exceptional case of cellarray of length==Ne=2=4
    end
end

% Catch Time continuous data (Laplace domain)
if Tsdat == 0
    % Fix any InputDelay before prewarping
    nexp = length(pvget(dats,'InputData'));
    Freqs = pvget(dats,'Radfreqs');
    InD = pvget(dats,'InputData');
    OutD = pvget(dats,'OutputData');
    %inters = pvget(dats,'InterSample');
    %inters = inters{1}; % We assume same for all inputs
    maxf = -realmax;
    for kexp = 1:nexp
        maxf = max(max(maxf,Freqs{kexp}));
    end
    for kexp=1:nexp,
        Freqs{kexp} = 2*atan(Freqs{kexp}/maxf/maxfscale); % Prewarp frequencies (Tustin)
    end
    
    dat1 = iddata(OutD,InD,'Domain','Frequency','Freq',Freqs);
    
    %mp = pvset(mprel,'Ts',1); %Change to Discrete time;
    %mp = pvset(mp, 'nk', zeros(1,nu)); %Always estimate a D
    if def_order
        order = 'best';
    end
    [m1,bestchoice,nchoice,failflag] = n4sid_f(dat1,order,varargin{:},'Focus','Prediction',...
        'Covariance','None','nk',zeros(1,nu),arg,XIDplotw);
    
    if isempty(m1)
        m = m1;
        return;
    end
    nx = size(m1.As,1);
    npar = nx*(ny+nu);
    if any(nk==0), npar = npar+nu*ny;end
    if estx0, npar = npar + nx;end
    a = pvget(m1,'A');
    b = pvget(m1,'B');
    c = pvget(m1,'C');
    d = pvget(m1,'D');
    k = pvget(m1,'K');
    x0 = pvget(m1,'X0');
    [a,b,c,d,x0] = md2c(a,b,c,d,x0,1/maxf*2/maxfscale);
    if stabenf
        a = stab(a,0,algorithm.Advanced.Threshold.Sstability);
    end
    
    d(pvget(mprel,'Ds')==0) = 0;
    warn1 = ctrlMsgUtils.SuspendWarnings;
    m = pvset(mprel,'A',a,'B',b,'C',c,'D',d,'K',k,'X0',x0);
    delete(warn1)
    
    d = pvget(m,'D');
    dcolidx = find(nk>0);
    for k=dcolidx,
        d(:,k)= zeros(ny,1); %Force to zero for inputs with relative
    end
    m = pvset(m,'DisturbanceModel','None');
    m = pvset(m,'D',d);
    
    warn2 = ctrlMsgUtils.SuspendWarnings;
    e=pe(dats,m,'e');
    delete(warn2)
    e = pvget(e,'OutputData');
    e = cat(1,e{:});
    
    Ncaps = length(e);
    lambda=e'*e/(length(e)-npar/ny);
    if realflag, lambda = real(lambda);end
    %V=real(det(lambda));
    %% Some post-estimate fixes and assignments
    idmod = pvget(m,'idmodel');
    if ~strcmp(pvget(idmod,'CovarianceMatrix'),'None')
        try
            m2=m;
            m2 = pvset(m2,'SSParameterization','Canonical');
            idmod=pvget(m2,'idmodel');
            maxi = pvget(idmod,'MaxIter');
            tr = pvget(idmod,'Display');
            idmod=pvset(idmod,'MaxIter',-1,'Display','Off');
            m2=pvset(m2,'idmodel',idmod,'NoiseVariance',lambda);
            m2=pem(dat,m2);
            m2 = pvset(m2,'MaxIter',maxi,'Display',tr);
            if strcmp(pvget(mprel,'SSParameterization'),'Canonical')
                m = m2;
            else
                idmod=pvget(m,'idmodel');
                uti = pvget(idmod,'Utility');
                uti.Pmodel=m2;
                idmod=pvset(idmod,'Utility',uti);
                m=pvset(m,'idmodel',idmod);
            end
        catch
            ctrlMsgUtils.warning('Ident:estimation:n4sidCovarFailure')
            m = pvset(m,'CovarianceMatrix','None');
        end
    elseif strcmp(pvget(mprel,'SSParameterization'),'Canonical')
        m = pvset(m,'SSParameterization','Canonical');
    end
    
    est=pvget(idmod,'EstimationInfo');
    est.N4Horizon = bestchoice;
    est.N4Weight = 'Not Applicable';
    est.DataLength=sum(Ncaps);
    est.DataTs=Tsdat;
    est.LossFcn = real(det(lambda));
    est.FPE = real(det(lambda))*(1+2*npar/sum(Ncaps));
    dn = pvget(dat,'Name');
    if isempty(dn)
        dn = inputname(1);
    end
    est.DataName = dn;
    est.DataInterSample=pvget(dat,'InterSample');%'Zero order hold';
    est.Status = 'Estimated model (N4SID)';
    est.Method = 'N4SID';
    est.InitialState = init;
    idmod = pvget(m,'idmodel');
    idmod = pvset(idmod,'EstimationInfo',est,'NoiseVariance',lambda);
    idmod = idmname(idmod,dat);
    m = pvset(m,'idmodel',idmod);
    return
end


% Beyond this point we assume discrete time data without lti focus

% Prepare data

nexp = length(pvget(dats,'InputData'));
Freqs = pvget(dats,'Radfreqs');
InD = pvget(dats,'InputData');
OutD = pvget(dats,'OutputData');
if ~iscell(Freqs),
    Freqs = {Freqs};
end

if nexp>1,
    estx0 = 0;
end
Ts = pvget(dats,'Ts');
if ~iscell(Ts)
    Ts = {Ts};
end
if length(Ts)~=nexp,
    for kexp=1:nexp,
        Ts{kexp} = Ts{1};
    end
end
for kexp=1:nexp,
    Freqs{kexp} = Freqs{kexp}*Ts{kexp}; % Normalize frequencies to [0,pi]
end

% Here determine appropriate values for q
horiz  = pvget(mprel,'N4Horizon');
if ischar(horiz), % use default q
    q = ceil(max(order)*1.5);  %%TM fix a better choice?
else
    q = horiz(:,1); %first column (max prediction horizon)
    if any(q<max(order)+1)
        q = max(max(order)+1,q);
        ctrlMsgUtils.warning('Ident:estimation:n4HorizonChange2',mat2str(q))
    end
end
mode.realflag = realflag;
bestV = Inf;
if length(q)>1 && length(order)>1
    ctrlMsgUtils.error('Ident:estimation:n4sidVariableOrderAndN4H')
end
for qidx = 1:length(q)
    n = order(1);
    [a,b,c,d,x0,V0,E,K,S] = fsub_estim(Freqs,OutD,InD,n, q(qidx),mode,[]);
    if length(order)>1
       bestchoice = []; nchoice = []; failflag = 0;      
       n = idordch(S,order,arg,def_order,ny,q(qidx),nu,N,{E,K},XIDplotw,nk);
        % {
        if isempty(n),
            m=[]; 
            return
        end
        %}
        [a,b,c,d,x0,V0] = fsub_estim(Freqs,OutD,InD,n, q(qidx),mode,[],E,K);
    end
    
    if stabenf
        a = stab(a,1,algorithm.Advanced.Threshold.Zstability);
    end
    if V0<bestV,
        bss = {a,b,c,d,x0};
        bestV = V0;
        bestq = q(qidx);
        bestn = n;
    end
    
end

m = mprel;
m = pvset(m,'nk',zeros(1,nu));
if norm(pvget(m,'X0s'))==0
    bss{5} = zeros(size(bss{5}));
end
was = ctrlMsgUtils.SuspendWarnings;
m = pvset(m,'A',bss{1},'B',bss{2},'C',bss{3},'D',bss{4}, ...
    'K',zeros(n,ny),'X0',bss{5},'InputDelay',inpd,'Ts',Ts{1});
m = pvset(m,'nk',nk);
delete(was)

%% Some post-estimate fixes and assignments

e=pe_f(dat,m,'e');
e = pvget(e,'OutputData');
if iscell(e),
    e = cat(1,e{:});
end
nx = size(m.As,1);
npar = nx*(ny+nu);
if any(nk==0),
    npar = npar+nu*ny;
end
%  if dkx(2), npar = npar + ny*nx;end: K disabled
if estx0,
    npar = npar + nx;
end

Ncaps = length(e);
lambda=e'*e/(length(e)-npar/ny);
if realflag, lambda = real(lambda); end
lambda = (lambda+lambda')/2;
%V=real(det(lambda));

m = pvset(m,'DisturbanceModel','None');
if pvget(mprel,'Ts')==0
    if any(inpd~=0)
        m = pvset(m,'InputDelay',inpd); % To set it right for discrete time
    end
    m = d2c(m,inters);
end
idmod = pvget(m,'idmodel');
wtxt = '';
if ~strcmp(pvget(idmod,'CovarianceMatrix'),'None')
    try
        m2=m;
        m2 = pvset(m2,'SSParameterization','Canonical');
        idmod=pvget(m2,'idmodel');
        maxi = pvget(idmod,'MaxIter');
        tr = pvget(idmod,'Display');
        idmod=pvset(idmod,'MaxIter',-1,'Display','Off');
        m2=pvset(m2,'idmodel',idmod,'NoiseVariance',lambda);
        m2=pem(dat,m2);
        m2 = pvset(m2,'MaxIter',maxi,'Display',tr);
        if strcmp(pvget(mprel,'SSParameterization'),'Canonical')
            m = m2;
        else
            idmod=pvget(m,'idmodel');
            uti = pvget(idmod,'Utility');
            uti.Pmodel=m2;
            idmod=pvset(idmod,'Utility',uti);
            m=pvset(m,'idmodel',idmod);
        end
    catch
        ctrlMsgUtils.warning('Ident:estimation:n4sidCovarFailure')
        m = pvset(m,'CovarianceMatrix','None');
        wtxt = 'Covariance matrix estimate unreliable. Not stored.';
    end
elseif strcmp(pvget(mprel,'SSParameterization'),'Canonical')
    m = pvset(m,'SSParameterization','Canonical');
end

est=pvget(idmod,'EstimationInfo');
%bestchoice = bestq;
est.N4Horizon = horiz(qidx,:);%bestchoice;
est.N4Weight = 'Not Applicable';
est.DataLength=sum(Ncaps);
est.DataDomain = 'Frequency';
Tsdat = pvget(dat,'Ts');
Tsdat = Tsdat{1};
est.DataTs = Tsdat;
est.LossFcn = real(det(lambda));
est.FPE = real(det(lambda))*(1+2*npar/sum(Ncaps));
dn = pvget(dat,'Name');
if isempty(dn)
    dn = inputname(1);
end
est.DataName = dn;
est.DataInterSample = pvget(dat,'InterSample');%'Zero order hold';
est.Status = 'Estimated model (N4SID)';
est.Method = 'N4SID';
if ~isempty(wtxt)
    est.Warning = wtxt;
end
est.InitialState = init;
idmod = pvget(m,'idmodel');
idmod = pvset(idmod,'EstimationInfo',est,'NoiseVariance',lambda);
idmod = idmname(idmod,dat);
m = pvset(m,'idmodel',idmod);

bestchoice = bestq;
nchoice = bestn;
failflag = 0;

%%% End main function  %%%%%

%--------------------------------------------------------------------------
function As = stab(A,T,thresh)
% stabilize A matrix by reflecting unstable poles across stability boundary

if nargin<2
    T = 1;
end
if nargin<3
    if T
        thresh = 1;
    else
        thresh = 0;
    end
end
[V,D]=eig(A);
if cond(V)>10^8
    [V,D] = schur(A);
    [V,D] = rsf2csf(V,D);
end
if (T~=0 && max(abs(diag(D)))<thresh) || (T==0 && max(real(diag(D)))<thresh)
    As = A;
    return,
end
[n,n] = size(D);
for kk = 1:n
    if T~=0
        if abs(D(kk,kk))>thresh
            D(kk,kk) = thresh^2/D(kk,kk);
        end
    else
        if real(D(kk,kk))>thresh
            D(kk,kk) = 2*thresh-real(D(kk,kk))+i*imag(D(kk,kk));
        end
    end
end
As = V*D*inv(V);
if isreal(A)
    As = real(As);
end
