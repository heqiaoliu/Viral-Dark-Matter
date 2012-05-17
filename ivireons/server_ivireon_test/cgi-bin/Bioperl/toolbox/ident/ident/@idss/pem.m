function m = pem(data,m0,varargin)
%PEM	Computes the prediction error estimate of a general linear model.
%   M = PEM(Z,Mi)
%
%   M : returns the estimated model in the IDSS object format
%   along with estimated covariances and structure information.
%   For the exact format of M see also help IDSS.
%
%   Z :  The estimation data in IDDATA object format. See help IDDATA
%
%   Mi: An IDSS model object that defines the model structure.
%	 The minimization is initialized at the parameters given in Mi.
%
%   By M = pem(Z,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See help IDSS or help IDPOLY for a list of
%   Property/Value pairs.

%	L. Ljung 10-1-86, 7-25-94
%	Copyright 1986-2010 The MathWorks, Inc.
%	$Revision: 1.32.4.23 $  $Date: 2010/04/11 20:32:38 $

% 1. Parse the input arguments, and set data and model properties
% 1.1 Fix the data object
if isa(m0,'iddata') || isa(m0,'idfrd') || isa(m0,'frd')% forgive order confusion
    datn = inputname(2);
    z=m0;
    m0 = data;
    data = z;
else
    datn = inputname(1);
end
if isa(data,'frd')
    data = idfrd(data);
end
if isa(data,'idfrd')
    data = iddata(data);
end
% 1.2 Special test for focus filter:
if ~isa(m0,'idss')  % then there must be an IDSS focus filter in varargin
    for kk = 1:length(varargin)
        try
            if strcmpi('fo',varargin{kk}(1:2))
                filt = varargin{kk+1};
                [a,b,c,d] = ssdata(filt);
                filt = {a,b,c,d,pvget(filt,'Ts')};
                varargin{kk+1} = filt;
            end
        end
    end
    m = pem(data,m0,varargin{:});
    m = setdatid(m,getid(data),[]);
    es = pvget(m,'EstimationInfo');
    es.DataName = datn;
    m = pvset(m,'EstimationInfo',es);
    return
end
if isa(data,'iddata')
    iddataflag = 1;
    dom = pvget(data,'Domain');
    data = setid(data);
    %try % todo: why try-catch?
    data = estdatch(data,pvget(m0,'Ts'));
    %end
else
    dom = 'Time';
end

ftdom = lower(dom(1));
[ny,nu] = size(m0);
%Ts = pvget(m0,'Ts');
if  ~isa(data,'iddata')
    iddataflag = 0;
    if ~isa(data,'double')
        ctrlMsgUtils.error('Ident:estimation:invalidData')
    end
    nz = size(data,2);
    if nz~=ny+nu
        ctrlMsgUtils.error('Ident:estimation:doubleDataOrderMismatch')
    end
    data = iddata(data(:,1:ny),data(:,ny+1:end));
end

[Ncap,nyd,nud,Ne] = size(data);
if nyd~=ny || nud~=nu
    ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
end

% If Data properties are set in the input arguments, set these to data
% first:
[varargin,datarg] = pnsortd(varargin);
if ~isempty(datarg)
    data = pvset(data,datarg{:});
end

if isempty(pvget(data,'Name'))
    data = pvset(data,'Name',datn);
end

Tsdata = pvget(data,'Ts');
Tsdata = Tsdata{1}; % all sampling intervals assumed to be the same.

% 1.3  Set model properties:
if ~isempty(varargin)
    if (~ischar(varargin{1}) ||...
            (strcmpi(varargin{1},'trace') &&...
            fix(length(varargin)/2)~=length(varargin)/2)) % old syntax
        
        npar=length(pvget(m0,'ParameterVector'));
        [Tss,varargin] = transf(varargin,npar);
        if ~isempty(Tss) && ~iddataflag
            data = pvset(data,'Ts',Tss);
        end
        
    end
    set(m0,varargin{:})
end
% This finishes the input parsing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%2. Extract Model Info
Ts = pvget(m0,'Ts');
if ~iddataflag
    % double data Ts update
    if Ts~=0
        data.Ts = Ts;
        Tsdata = Ts;
    else
        Tsdata = 1;
    end
end

%es = pvget(m0,'EstimationInfo');
%ut = pvget(m0,'Utility');
algorithm = pvget(m0,'Algorithm');
Zstab = algorithm.Advanced.Threshold.Zstability;
Sstab = algorithm.Advanced.Threshold.Sstability;
par = pvget(m0,'ParameterVector');
if ischar(algorithm.MaxSize)
    algorithm.MaxSize = idmsize(max(Ncap),length(par));
end
foc = algorithm.Focus;
if nu == 0 && ~strcmpi(foc,'Prediction')
   ctrlMsgUtils.warning('Ident:estimation:timeSeriesFocus')
   Warn = ctrlMsgUtils.SuspendWarnings('Ident:estimation:timeSeriesFocus'); %#ok<NASGU>
   foc = 'Prediction';
end

if ischar(foc) && any(strcmpi(foc,{'Stability','Simulation'}))
    stabenf = 1;
else
    stabenf = 0;
end
intd = pvget(data,'InterSample');
if isempty(intd) % Time series data
    intd = 'zoh';
else
    intd = intd{1,1}; % Assuming this be the same for all experiments and inputs
end

dm = pvget(m0,'DisturbanceModel');
sspar = m0.SSParameterization;
nk = pvget(m0,'nk');
wasFree = false;

if Ts==0 && any(nk>1)
    ctrlMsgUtils.warning('Ident:estimation:CTModelNkVal')
    nk = min(nk,1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3. Checks and warnings
[A,B,C,D,K] = ssdata(m0);

if (ftdom =='f')
    if ~strcmp(dm,'None')
        ctrlMsgUtils.warning('Ident:estimation:freqDataNoDistModel')
        dm = 'None';
        m0 = pvset(m0,'DisturbanceModel','None');
    end
    if isempty(B)
        ctrlMsgUtils.error('Ident:estimation:freqDataTimeSeriesModel')
    end
    algorithm.LimitError = 0; % no robustification for FD data
end

if nu==0 && ~strcmp(dm,'Estimate')
   % Must estimate disturbance model for time series data
   ctrlMsgUtils.error('Ident:estimation:n4sidCheck7')
end

%nx = size(A,1);
if ftdom == 't'
    ei = eig(A-K*C);
    if  ~isempty(ei) && ...
            ((Ts==0 && max(real(ei))>Sstab) || (Ts>0 && max(abs(ei))>Zstab))
        ctrlMsgUtils.warning('Ident:estimation:unstableInitialPredictor',...
            sprintf('%g',Ts))
        %todo: why not stabilize the model?
    end
end
if stabenf
    ei = eig(A);
    if ~isempty(ei) && ...
            ((Ts==0 && max(real(ei))>Sstab && norm(K)==0) ||...
            (Ts>0 && max(abs(ei))>Zstab))
        ctrlMsgUtils.warning('Ident:estimation:unstableInitialModel',...
            sprintf('%g',Ts))
        % todo: why not stabilize the model even though stabenf=1?
    end
    
end

if Ts>0
    if abs(Ts-Tsdata)>1e4*eps
        ctrlMsgUtils.warning('Ident:general:dataModelTsMismatch',...
            sprintf('%g',Ts),sprintf('%g',Tsdata));
        m0 = pvset(m0,'Ts',Tsdata);
    end
    
    if (strcmpi(intd,'foh') || strcmpi(intd,'bl')),
        ctrlMsgUtils.warning('Ident:estimation:dataInterSampDTModel')
    end
elseif ~iddataflag
    ttes = pvget(m0,'Utility');
    try
        Tsdata = ttes.Tsdata;
        data = pvset(data,'Ts',Tsdata);
    catch
        ctrlMsgUtils.error('Ident:estimation:doubleDataForCTModel')
    end
end
if ~isempty(algorithm.FixedParameter) && strcmpi(sspar,'Free')
    ctrlMsgUtils.warning('Ident:estimation:fixedParWithFreeSSPar')
    
    algorithm.FixedParameter = [];
    m0 = pvset(m0,'FixedParameter',[]);
end

% Kill old hidden models in starting model
ut = pvget(m0,'Utility');
if isfield(ut,'Pmodel')
    ut.Pmodel = [];
end

if isfield(ut,'Idpoly')
    ut.Idpoly = [];
end

m0 = uset(m0,ut);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Set initial noise variance
was = warning('off'); [lw,lwid] = lastwarn;
[e,xi] = pe(data,m0);
warning(was), lastwarn(lw,lwid)
e = pvget(e,'OutputData');
e = cat(1,e{:}); % vector of errors
lam = e'*e/length(e); % first estimate of lambda
if realdata(data)
    lam = real(lam);
end

was = warning('off','Ident:idmodel:indefiniteNoi');
m0 = pvset(m0,'NoiseVariance',lam);
warning(was)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Fix LimitError
if algorithm.LimitError~=0
    Ns = size(e,1);
    algorithm.LimitError = ...
        median(abs(e-ones(Ns,1)*median(e)))*algorithm.LimitError/0.7;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Shift Data if necessary
Inpd = pvget(m0,'InputDelay');
if Ts==0
    if Tsdata>0
        Inpd = Inpd/Tsdata;
        if any(abs(Inpd - round(Inpd))>1e4*eps)
            ctrlMsgUtils.error('Ident:idmodel:inputDelayCTModel')
        end
        Inpd = round(Inpd);
    end
    if strcmp(m0.SSParameterization,'Free') && (ftdom=='t')
        ctrlMsgUtils.error('Ident:estimation:SSFreeForCTModel')
    end
end

% Also take out demanded time-delays for free parameterization:
if strcmp(m0.SSParameterization,'Free')
    dkx = [0,0,0];
    if nu>0
        if any(nk==0)
            dkx(1)=1;
        end
        nks = max(nk-1,zeros(size(nk)));
        if any(nks>0)
            m0 = pvset(m0,'nk',nk>0);
        end
    else
        nks = 0;
    end
else
    nks = zeros(size(nk));
end
if ~isempty(Inpd) % To avoid problems for time series
    shift = Inpd' + nks;
    dats = nkshift(data,shift);
else
    dats = data;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7. Deal with Focus
foccase = false;
if ~ischar(foc) || (strcmp(foc,'Simulation') && ~strcmp(dm,'None'))
    foccase = true;
end

if foccase
    m0 = pvset(m0,'InputDelay',zeros(nu,1)); % not to shift again
    m = pemfocus(dats,m0,foc);
    if strcmp(m.SSParameterization,'Free') && any(nks>0)
        m = pvset(m,'nk',nk);
    end
    es = pvget(m,'EstimationInfo');
    es.DataName = data.Name;
    m = pvset(m,'EstimationInfo',es,'InputDelay',Inpd);
    m = setdatid(m,getid(data),[]);
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 8. Deal with InitialState
init = m0.InitialState;

% Overrides 1: FRD data must have INIT = 'Zero'
frdflag = 0;
utd = pvget(data,'Utility');

if isfield(utd,'idfrd') && utd.idfrd
    frdflag = 1;
end

if frdflag
    switch init
        case {'Estimate','Model','Backcast'}
            ctrlMsgUtils.warning('Ident:estimation:X0EstForIDFRD1')
            init = 'Zero';
            
        case 'Auto'
            init = 'Zero';
    end
end

% Overrides 2: Multi-experiment data cannot have INIT = 'Estimate'
autoflag = 0;
if Ne>1
    switch init
        case 'Estimate'
            ctrlMsgUtils.warning('Ident:estimation:X0EstMultiExp2')
            init = 'Backcast'; 
            m0 = pvset(m0,'InitialState','Backcast');
            %m0 = pvset(m0,'X0s',zeros(size(m0.X0s))); % changes sspar to structured 
            m0.X0s = zeros(size(m0.X0s));
        case 'Auto'
            init = 'Backcast';
            autoflag = 1;
            %PVSET changes sspar to structured which is not desired 
            %m0 = pvset(m0,'X0s',zeros(size(m0.X0s)));
            m0 = pvset(m0,'InitialState','Backcast'); %required to reconcile parameter vector size (see idss/pvset)
            m0.X0s = zeros(size(m0.X0s));
        case 'Fixed'
            ctrlMsgUtils.warning('Ident:estimation:X0FixedMultiExp')
    end
end

% Choose in Auto case
if strcmpi(init,'Auto') % Then it comes with X0s = 0
    autoflag = 1;
    if algorithm.MaxIter == -1
        init = 'Zero';
        
    elseif any(strcmpi(m0.SSParameterization,{'Structured','Canonical'}))
        if any(isnan(m0.X0s))
            init = 'Estimate';
        elseif norm(m0.X0s)==0
            init = 'Zero';
        else
            init = 'Fixed';
        end
    else
        ez = pe(data,m0,'z');
        ez = pvget(ez,'OutputData');
        ez = cat(1,ez{:}); % vector or errors
        nor1 = norm(ez);
        nor2 = norm(e);
        if nor1/nor2>algorithm.Advanced.Threshold.AutoInitialState
            init = 'Estimate';
            m0 = pvset(m0,'InitialState','Estimate');
            %par = [par;xi]; %todo: this is unnecessary; par is changed to [] later
        else
            init = 'Zero';
            m0 = pvset(m0,'InitialState','Zero');
        end
    end
end

%--------------------------------------------------------------------------
% 9. Prepare data for estimation
realflag = realdata(dats);
if (ftdom == 't')
    [z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag,ynorm] = idprep(dats,0,datn);
else
    dats = complex(dats);
    [z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag] = idprep_f(dats,0,datn);
    ynorm = [];
end
if ~isempty(errflag.message), error(errflag), end
if ~isempty(Name), dats.Name = Name; end


% If search method is 'lsqnonlin' and sspar is 'free', change sspar to
% 'structured' since lsqnonlin cannot handle changing parameter list
if strncmpi(algorithm.SearchMethod,'ls',2) && strncmpi(sspar,'fr',2)
    ctrlMsgUtils.warning('Ident:estimation:freeSSParNotSupported')
    sspar = 'Structured';
    m0 = pvset(m0,'SSParameterization',sspar);
    wasFree = true;
end

% Set part of EstimationInfo now so that optimizer can use it to set struc
estinfo = pvget(m0,'EstimationInfo');
estinfo.InitialState = init;
estinfo.DataDomain = dom;
estinfo.DataTs = Tsdata;
estinfo.Misc = struct('nk',nk,'nks',nks,'autoflag',autoflag,...
    'realflag',realflag,'intd',intd,'wasFree',wasFree);
m0 = pvset(m0,'EstimationInfo',estinfo);

% Set parameter names if fixed by name
fixp = pvget(m0,'FixedParameter');
if ~isempty(fixp)
    %fixflag = 1;
    if (iscell(fixp) || ischar(fixp)) && isempty(pvget(m0,'PName'))
        m0 = setpname(m0);
    end
end

%---%
Estimator = createEstimator(m0,z,algorithm);

% check data sufficiency
nDat = sum(Estimator.Options.DataSize)*ny;
nPar = length(Estimator.Info.Value);

if nDat<=nPar
    ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
end

OptimInfo = minimize(Estimator);

% update the model with the set of new values for states and parameters
m = updatemodel(m0, dats, OptimInfo, Estimator);
%---%

m = setdatid(m,getid(data),ynorm);
m = timemark(m);

%--------------------------------------------------------------------------
function m = pemfocus(data,m0,foc)
% If focus = an LTI filter, or focus = 'sim' with disturbance model to be
% estimated (not 'none').

ts = pvget(data,'Ts');ts = ts{1};
dom = pvget(data,'Domain');
foc = foccheck(foc,ts,[],lower(dom(1)),pvget(data,'Name'));
zf = data;
if ~isa(foc,'char')
    zf = idfilt(data,foc);
end

[a0,~,~,~,k0] = ssdata(m0);

% Stabilize initial model:
algorithm = pvget(m0,'Algorithm');
Zstab = algorithm.Advanced.Threshold.Zstability;
Sstab = algorithm.Advanced.Threshold.Sstability;

if pvget(m0,'Ts')>0
    stablim = Zstab;
else
    stablim = Sstab;
end

[a0,flag] = stab(a0,pvget(m0,'Ts'),stablim);
if flag
    ws = ctrlMsgUtils.SuspendWarnings('Ident:utility:IncompatibleStructureMatrix');
    m0 = pvset(m0,'A',a0);
    delete(ws)
    %todo: A changes automatically to conform to m0's ssparam, so m0.A ~= a0 (test) 
end

%ny = size(d0,1);
m1 = pvset(m0,'Focus','Prediction','DisturbanceModel','None');
tr = pvget(m0,'Display');
if ~strcmp(tr,'Off')
    fprintf('\n   *** Finding the dynamics model ... ***\n')
end

m1 = pem(zf,m1);
if strcmp(m1.SSParameterization,'Free')
    ut = pvget(m1,'Utility');
    try
        idm = ut.Pmodel;
        cov1 = pvget(idm,'CovarianceMatrix');
        numx = sum(sum(isnan(idm.X0s))');
        cov1 = cov1(1:end-numx,1:end-numx);
        excov = 1;
    catch
        cov1 =[];
        excov = 0;
    end
    
else
    cov1 = pvget(m1,'CovarianceMatrix');
    if ischar(cov1) || isempty(cov1)
        excov = 0;
    else
        numx = sum(sum(isnan(m1.X0s))');
        cov1 = cov1(1:end-numx,1:end-numx);
        excov = 1;
    end
end
if any(any(isnan(m0.Ks))')
    [a,b,c,d,k,x0] = ssdata(m1);
    ak0c = eig(a-k0*c);
    if ~isempty(ak0c) && ((pvget(m1,'Ts')>0 && max(abs(ak0c))>1) ||...
            (pvget(m1,'Ts')==0 && max(real(ak0c))>0))
        
        % To secure a stable initial predictor
        if any(strcmp(m0.SSParameterization,{'Free','Canonical'})) && pvget(m1,'Ts')
            %eval('k0 = ssssaux(''kric'',a,c,k0*k0'',eye(ny),k0);','');
            ny = size(m1,1);
            try
                k0 = ssssaux('kric',a,c,k0*k0',eye(ny),k0);
            catch
                % do nothing (accept old k0 value)
            end
        else
            k0 = zeros(size(c))';
        end
    end
    
    m1 = pvset(m1,'As',a,'Bs',b,'Cs',c,'Ds',d,'Ks',m0.Ks,'K',k0);
    
    if ~strcmp(tr,'Off')
        fprintf('\n   *** Finding the noise model ... ***\n')
    end
    m = pem(data,m1);
    if excov
        cov2 = pvget(m,'CovarianceMatrix');
        if ischar(cov2)
            cov2 = [];
        end
        cov = [[cov1,zeros(size(cov1,1),size(cov2,2))];...
            [zeros(size(cov2,1),size(cov1,2)),cov2]];
    else
        cov = 'none';
    end
    if strcmp(m0.SSParameterization,'Free') && excov
        m = pvset(m,'SSParameterization','Free','CovarianceMatrix',[]);
        [a,b,c,d,k,x0] = ssdata(idm);
        idm1 = pvset(idm,'As',a,'Bs',b,'Cs',c,'Ds',d,'Ks',NaN*ones(size(k)));
        
        if ~strcmpi(tr,'off')
            fprintf(['\n   *** Finding the noise model ',...
                'for the canonical parameterization ... ***\n'])
        end
        
        idm1 = pem(data,idm1,'MaxIter',pvget(m0,'MaxIter'));
        
        %This is redone since idm has another parameterization
        if ~isempty(cov1)
            cov2 = pvget(idm1,'CovarianceMatrix');
            if isempty(cov2)
                cov = [];
            else
                cov = [[cov1,zeros(size(cov1,1),size(cov2,2))];...
                    [zeros(size(cov2,1),size(cov1,2)),cov2]];
            end
        else
            cov = [];
        end
        idm = pvset(idm,'Ks',idm1.Ks,'K',pvget(idm1,'K'));
        idm = pvset(idm,'CovarianceMatrix',cov);
        ut.Pmodel = idm;
        m.idmodel = pvset(m.idmodel,'Utility',ut);%gsutil(m.idmodel,ut,'s');
    else
        m = pvset(m,'As',m0.As,'Bs',m0.Bs,'Cs',m0.Cs,'Ds',m0.Ds);
        m = pvset(m,'CovarianceMatrix',cov);
    end
else
    m = m1;
end
m = pvset(m,'Focus',foc);
es = pvget(m,'EstimationInfo');
es.Status = 'Estimated model (PEM with focus)';
es.Method = 'PEM with focus';
es.DataName = pvget(data,'Name');
m.idmodel = pvset(m.idmodel,'EstimationInfo',es);

%--------------------------------------------------------------------------
function [As,flag] = stab(A,T,thresh)
flag = 0;
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
[V,D] = eig(A);
if cond(V)>10^8
    [V,D] = schur(A);
    [V,D] = rsf2csf(V,D);
end

if isempty(D) || ((T~=0 && max(abs(diag(D)))<thresh) ||...
        (T==0 && max(real(diag(D)))<thresh))
    As = A;
    return
end
flag = 1;
[n,n] = size(D);

for kk=1:n
    if T~=0
        if abs(D(kk,kk))>thresh
            D(kk,kk) = thresh^2/D(kk,kk);
        end
    else
        if real(D(kk,kk))>thresh
            D(kk,kk) = 2*thresh-real(D(kk,kk))+1i*imag(D(kk,kk));
        end
    end
end

As = V*D*inv(V);
if isreal(A)
    As = real(As);
end
