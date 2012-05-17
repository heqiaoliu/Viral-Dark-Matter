function m = pem(data,m0,varargin)
%IDPOLY/PEM	Estimate of a general linear polynomial model.
%
%   M = PEM(Z,Mi)
%
%   Mi = [na nb nc nd nf nk] gives a general polynomial model:
%	  A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%     with the indicated orders (For multi-input data nb, nf and
%     nk are row vectors of lengths equal to the number of input channels.)
%     An alternative syntax is MODEL = PEM(DATA,'na',na,'nb',nb,...) with
%     omitted orders taken as zero.
%
%   CONTINUOUS TIME MODEL ORDERS: If Z is continuous time frequency domain
%   data, then continuous time Output Error models (na = nc = nd = 0) can be
%   estimated directly. Nf then denotes the number of denominator
%   coefficients and nb the number of numerator coefficients. Nk is then of no
%   consequence and should be omitted. In this case it is easier to use OE.
%   Example: Mi = [0 2 0 0 3 0] gives a model
%   (b1*s + b2)/(s^3 + f1*s^2 + f2*s + f3)
%
%   M : returns the estimated model in the IDPOLY  object format
%   along with estimated covariances and structure information.
%   For the exact format of M see also help IDPOLY.
%
%   Z :  The estimation data in IDDATA object format. See help IDDATA.
%
%   Mi: An IDPOLY model ("initial model") object that defines the model structure.
%	 The minimization is initialized at the parameters given in Mi.
%
%   By M = pem(Z,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See help IDSS or help IDPOLY for a list of
%   Property/Value pairs.
%
%   See also OE, ARX, BJ, ARMAX, AR, N4SID, ETFE, SPA, RESID, COMPARE,
%   NLARX, NLHW.

%	L. Ljung 10-1-86, 7-25-94
%	Copyright 1986-2010 The MathWorks, Inc.
%	$Revision: 1.32.4.21 $  $Date: 2010/04/21 21:26:09 $

ni = nargin;
error(nargchk(2,Inf,ni,'struct'))
ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF');
[m0,data,order] = pemdecod('pem',data,m0,varargin{:},inputname(1));

if isa(data,'iddata')
    dom = pvget(data,'Domain');
    data = setid(data);
else
    dom = 'Time';
end

if ~isa(m0,'idpoly')  % then there must be an IDPOLY focus filter in varargin
    for kk = 1:length(varargin)
        try
            if strncmpi(varargin{kk},'fo',2)
                filt = varargin{kk+1};
                [a,b,c,d] = ssdata(filt);
                filt = {a,b,c,d,pvget(filt,'Ts')};
                varargin{kk+1} = filt;
            end
        catch
            % todo: why try/catch?
        end
    end

    m = pem(data,order,varargin{:});
    %m = setdataid(m,getid(data),ynorm);
    es = pvget(m,'EstimationInfo');
    es.DataName = data.Name;
    m = pvset(m,'EstimationInfo',es);
    return
end

if strncmpi(dom,'f',1)
    m = pem_f(data,m0,varargin{:});
    %m = setdatid(m,getid(data),[]);
    es = pvget(m,'EstimationInfo');
    es.Status = 'Estimated model (PEM)';
    m = pvset(m,'EstimationInfo',es);
    m = timemark(m);
    return
end

%
% Now the input parsing is finished.
% First check if the data should be shifted.
%idm=m0.idmodel;

Ts = pvget(m0,'Ts');
[ny,nu] = size(m0);
if Ts == 0
    ctrlMsgUtils.error('Ident:estimation:idpolyCTModelWithTimeData')
end
if  ~isa(data,'iddata')
    if ~isa(data,'double')
        ctrlMsgUtils.error('Ident:estimation:invalidData')
    end

    data = iddata(data(:,1),data(:,2:end),Ts);
else
    %utd = pvget(data,'Utility');
    %try
    %   dataid = getid(data);
    %catch
    %dataid = 0;
    %end
    [N,nyd,nud] = size(data);
    if nyd~=1 || nud~=nu
        ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
    end
end

Inpd = pvget(m0,'InputDelay');
dats = nkshift(data,Inpd);

% Check if sufficient amount of data is supplied
testo = m0.na+m0.nd + sum(m0.nf)+1;
testo = max(testo,m0.nb-m0.nf+sum(m0.nf) +m0.nk);
testo = max([testo,3,max(m0.nk+2)]);

Nc = size(dats,'N');
testd = find(Nc+1-testo<1);
if length(Nc)==length(testd)
    ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
end

if ~isempty(testd)
    dats = getexp(dats,find(Nc+1-testo>0));
    ctrlMsgUtils.warning('Ident:estimation:multiExpTooFewSamples',int2str(testd));
end

[ze,Ne,ny,nu,Tsdata,Name,Ncaps,errflag,ynorm] = idprep(dats,0,inputname(1));
if ~isempty(errflag.message), error(errflag), end
if ~isempty(Name), dats.Name = Name; end

if abs(Ts-Tsdata)>10*eps
    ctrlMsgUtils.warning('Ident:estimation:modelDataTsMismatch',...
        sprintf('%f',Ts),sprintf('%f',Tsdata),sprintf('%f',Tsdata))
    m0 = pvset(m0,'Ts',Tsdata);
end

algorithm = pvget(m0,'Algorithm');
foc = algorithm.Focus;
if nu == 0 && ~any(strcmpi(foc,{'Prediction','Stability'}))
    ctrlMsgUtils.warning('Ident:estimation:timeSeriesFocus')
    foc = 'Prediction';
end

if ~ischar(foc) || (strcmpi(foc,'Simulation') && sum([m0.na,m0.nc,m0.nd])~=0)
    m = pemfocus(data,m0,foc); % Data not shifted
    m = setdatid(m,getid(data),ynorm);
    es = pvget(m,'EstimationInfo');
    es.Status = 'Estimated model (PEM with focus)';
    es.DataName = dats.Name;
    m = pvset(m,'EstimationInfo',es);
    return
end

par = pvget(m0.idmodel,'ParameterVector');
parempt = false;
if isempty(par)
    parempt = true;
    m0 = inival(ze,m0);
    par = pvget(m0.idmodel,'ParameterVector');
end

%parini = par;
fixflag = false;
fixp = pvget(m0,'FixedParameter');
if ~isempty(fixp)
    fixflag = true;
    if (iscell(fixp)|| ischar(fixp)) && isempty(pvget(m0,'PName'))
        m0 = setpname(m0);
        %idm = pvget(m0,'idmodel');
        fixp = pnam2num(fixp,pvget(m0,'PName'));
    end
end

if fixflag && parempt
    par(fixp) = zeros(length(fixp),1); % todo: why zero out fixed pars?
    m0 = parset(m0,par);
    N = norm(pvget(m0,'b'));
    if ~isfinite(N) || N==0
        ctrlMsgUtils.warning('Ident:estimation:allZeroB')
    end
end

try
    [A,~,C,~,K] = ssdata(m0);
catch E
    if strcmp(E.identifier,'Ident:analysis:ssdataImproperModel')
        ctrlMsgUtils.error('Ident:estimation:ImproperCTModel')
    else
        rethrow(E)
    end
end

% todo: Is there a faster way of determining instability? ssdata is
% expensive
AKC = A-K*C;
if ~isempty(AKC) && max(abs(eig(AKC))) > algorithm.Advanced.Threshold.Zstability
    msg = sprintf(['The initial model has an unstable predictor.\n'...
        'If an initial model was specified, check that the C and F polynomials of the initial model are stable.\n',...
        'The "fstab" command may be used for stabilization.']);
    wid = 'Ident:estimation:unstableInitialPredictor1';
    if fixflag
        msg1 = sprintf('The instability of the predictor may be caused by fixing a parameter in the C or F polynomial to zero, which could make the initial model unstable.');
        wid = 'Ident:estimation:unstableInitialPredictor2';
        msg = sprintf('%s\n%s',msg,msg1);
    else
        m0 = pvset(m0,'c',fstab(pvget(m0,'c')));
        %par=pvget(m0.idmodel,'ParameterVector');
    end
    warning(wid,msg);
end

if ~isempty(A) && max(abs(eig(A)))>algorithm.Advanced.Threshold.Zstability &&...
        strcmp(pvget(m0,'Focus'),'Stability')
    m0 = pvset(m0,'a',fstab(pvget(m0,'a')));
    %par=pvget(m0.idmodel,'ParameterVector');
end

%---%
Estimator = createEstimator(m0,dats); %use data shifted for input delay
OptimInfo = minimize(Estimator);

% update the model with the set of new values for states and parameters
m = updatemodel(m0, dats, OptimInfo, Estimator);
%---%

m = setdatid(m,getid(data),ynorm);
m = timemark(m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = pemfocus(data,m0,foc)

nu = size(m0.nb,2);
if nu>1 && m0.na>0
    m = misoarm(data,m0,foc);
    return
    % error('For multi-input ARMAX models with a focus, use state-space models.')
    % The reason is that OE cannot enforce all F-polynomials to be the same
end

if isempty(pvget(m0,'ParameterVector'))
    m1 = m0;
    m1.na = 0;
    m1.nb = m0.nb;
    m1.nc = 0;
    m1.nd = 0;
    m1.nf = m0.na+m0.nf;
else
    if nu>1
        f = pvget(m0,'f');
    else
        f = conv(pvget(m0,'a'),pvget(m0,'f'));
    end
    m1 = pvset(m0,'a',1,'c',1,'d',1,'f',f);
end

if m0.na>0 && any(m0.nf)>0
    ctrlMsgUtils.error('Ident:estimation:idpolycheck1')
end

%if isa(foc,'idmodel')|isa(foc,'lti')|iscell(foc)
ts = pvget(data,'Ts');
ts = ts{1};
dom = pvget(data,'Domain');
foc = foccheck(foc,ts,[],lower(dom(1)),pvget(data,'Name'));
zf = data;
if ~ischar(foc)
    zf = idfilt(data,foc);
end

m1 = pvset(m1,'Focus','Prediction');
tr = pvget(m0,'Display');
if ~strcmpi(tr,'Off')
    disp('Finding the model dynamics ...')
end
m1 = pem(zf,m1);
if m0.nc + m0.nd == 0
    m = m1;
    m = pvset(m,'Focus',pvget(m0,'Focus'));

    return
end
cov1 = pvget(m1,'CovarianceMatrix');
f = pvget(m1,'f');
w = pe(data,m1,'e'); % No split between A and F here
try %todo: why try with no catch?
    if all(m0.nf==0)
        wfilt = idpoly(1,f);
        [a,b,c,d] = ssdata(wfilt);
        wfilt = {a,b,c,d};
        w = idfilt(w,wfilt);
    end
end
if ~strcmpi(tr,'Off')
    disp('Finding the noise model ...')
end
mts = armax(w,[m0.nd m0.nc],'Display',tr);
cov2 = pvget(mts,'CovarianceMatrix');
if isempty(cov2),cov1=[];end

m = m1;

%ind2 = [m0.nd+1:m0.nd+m0.nd,1:m0.nc]+m0.na+sum(m0.nb);
ind2 = [m0.nd+1:m0.nd+m0.nd,1:m0.nc]+sum(m1.nf)+sum(m0.nb);

cov = cov1;
if ~ischar(cov)&&~isempty(cov)
    cov = [[cov1,zeros(size(cov1,1),size(cov2,2))];...
        [zeros(size(cov2,1),size(cov1,2)),cov2]];
end

if m0.nf==0
    a = f(1,:); f = ones(nu,1);
    if ~ischar(cov)&&~isempty(cov)
        % ind1 = [sum(m0.nb)+1:sum(m0.nb)+m0.na,1:sum(m0.nb)];
        ind1 = [sum(m0.nb)+1:sum(m0.nb)+sum(m1.nf),1:sum(m0.nb)];

        cov = cov([ind1,ind2],[ind1,ind2]);
    end
else
    a = 1;
    if ~ischar(cov) && ~isempty(cov)
        ind = [1:sum(m0.nb),sum(m0.nb)+sum(m0.nf)+m0.nd+1:length(cov),...
            sum(m0.nb)+sum(m0.nf)+1:sum(m0.nb)+sum(m0.nf)+m0.nd,...
            sum(m0.nb)+1:sum(m0.nb)+sum(m0.nf)];
        cov = cov(ind,ind);
    end
end

m = pvset(m,'a',a,'c',pvget(mts,'c'),'d',pvget(mts,'a'),'f',f);
e = pe(m,data); ee = pvget(e,'OutputData');
ee = cat(1,ee{:});
V = ee'*ee/length(ee);
m = pvset(m,'CovarianceMatrix',cov,'Focus',pvget(m0,'Focus'),'NoiseVariance',V);
es = pvget(m,'EstimationInfo');
es.LossFcn = V;
Nobs = size(data,'N'); Nobs = sum(Nobs);
npar = size(cov,1);
es.FPE = V*(1+2*npar/Nobs);
es.Status = 'Estimated model (PEM with focus)';
es.DataName = pvget(data,'Name');
m.idmodel = pvset(m.idmodel,'EstimationInfo',es);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = misoarm(data,m0,foc)
% handle MISO models with na>0

nu = size(data,'nu');
foc0 = foc;
Inpd = pvget(m0,'InputDelay');
mp = pem(data,m0,'foc','prediction','InputDelay',zeros(nu,1));
a = pvget(mp,'a');
if ischar(foc) && strcmpi(foc,'Stability')
    a = pvget(m0,'a');
    alg = pvget(m0,'Algorithm');
    if any(abs(roots(a))>alg.Advanced.Threshold.Zstability)
        a = fstab(a);
        %m0 = pvset(m0,a);
        y = data(:,:,[]);
        yt = idfilt(y,{a,1});
        datat = data;
        datat(:,:,[]) = yt;
        m1 = armax(datat,m0,'na',0);
        m = pvset(m1,'a',a,'InputDelay',Inpd);
        es = pvget(m,'EstimationInfo');
        es.Method = 'ARMAX (Stabilized)';
        m = pvset(m,'EstimationInfo',es,'Focus',foc0);
    else
        m = pvset(mp,'Focus',foc0,'InputDelay',Inpd);
    end
    return
end

if isa(foc,'idmodel') || isa(foc,'lti') || iscell(foc)
    ts = pvget(data,'Ts');ts=ts{1};
    foc = foccheck(foc,ts,a);
elseif strcmp(foc,'Simulation')
    foc = foccheck({1,1},1,a);
end

zf = idfilt(data,foc);
m = pem(zf,m0,'focus','stability');
es = pvget(m,'EstimationInfo');
es.Method = 'PEM with focus';

m = pvset(m,'EstimationInfo',es,'InputDelay',Inpd,'Focus',foc0);
