function m = pem(data,m0,varargin)
%IDGREY/PEM	Computes the prediction error estimate of a general linear model.
%   MODEL = PEM(DATA,Mi)
%
%   MODEL: returns the estimated model in IDGREY object format
%   along with estimated covariances and structure information.
%   For the exact format of MODEL type IDPROPS IDGREY.
%
%   DATA:  The estimation data in IDDATA object format. See help IDDATA.
%
%   Mi: A IDGREY object that defines the model structure. See help IDGREY.
%
%  By MODEL = PEM(DATA,Mi,Property_1,Value_1, ...., Property_n,Value_n)
%  all properties associated with the model structure and the algorithm
%  can be affected. Type IDPROPS IDGREY and IDPROPS IDMODEL ALGORITHM for a
%  list of Property/Value pairs. Note in particular that the properties
%  'InitialState' and 'DisturbanceModel' can be set to values that
%  extend or override the parameterization in the MATLAB file.

%	L. Ljung 10-1-86, 7-25-94
%	Copyright 1986-2010 The MathWorks, Inc.
%	$Revision: 1.23.4.19 $ $Date: 2010/03/22 03:48:47 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Parse the input arguments, and set data and model properties
if isa(m0,'iddata') || isa(m0,'idfrd') || isa(m0,'frd') % forgive order confusion
    z = m0;
    m0 = data;
    data = z;
    datn = inputname(2);
else
    datn = inputname(1);
end

if isa(data,'frd')
    data = idfrd(data);
end

if isa(data,'idfrd')
    data = iddata(data);
end

if isa(data,'iddata')
    dom = pvget(data,'Domain');
    data = setid(data);
    data = estdatch(data,pvget(m0,'Ts'));
    iddataflag = 1;
else
    iddataflag = 0;
    dom = 'Time';
end

ftdom = lower(dom(1));
[ny,nu] = size(m0);

if  ~iddataflag
    if ~isa(data,'double')
        ctrlMsgUtils.error('Ident:estimation:invalidData')
    end
    nz = size(data,2);
    if nz ~= ny+nu
        ctrlMsgUtils.error('Ident:estimation:doubleDataOrderMismatch')
    end
    data = iddata(data(:,1:ny),data(:,ny+1:end));
    %{
    ctrlMsgUtils.warning('Ident:estimation:doubleDataTs',...
        ['The sampling interval is assumed to be 1 because data was specified using a double matrix.\n'...
        'To use a different sampling interval, there are two options:\n'...
        '(1) Specify data using an IDDATA object with the desired sampling interval (Ts): data = IDDATA(Output, Input, Ts).\n'...
        '(2) Set the value of the "Ts" property using a property-value pair in the call to the "pem" command.'])
    %}
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

% Set model properties:
if ~isempty(varargin)
    if ~ischar(varargin{1}) ||...
            (strcmpi(varargin{1},'trace') &&...
            fix(length(varargin)/2)~=length(varargin)/2)% old syntax
        
        npar = length(pvget(m0,'ParameterVector'));
        varargin = transf(varargin,npar);
    end
    set(m0,varargin{:})
end

% This finishes the input parsing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

es = pvget(m0,'EstimationInfo');
%ut = pvget(m0,'Utility');
algorithm = pvget(m0,'Algorithm');
Zstab = algorithm.Advanced.Threshold.Zstability;
Sstab = algorithm.Advanced.Threshold.Sstability;
par = pvget(m0,'ParameterVector');

%{
if ischar(algorithm.MaxSize)
    algorithm.MaxSize = idmsize(max(Ncap),length(par));
end
%}

foc = algorithm.Focus;
if ischar(foc) && any(strcmp(foc,{'Stability','Simulation'}))
    stabenf = 1;
else
    stabenf = 0;
end

intd = pvget(data,'InterSample');
if isempty(intd) % Time series data
    intd = 'zoh';
else
    %todo: why?
    intd = intd{1,1}; % Assuming this be the same for all experiments and inputs
end

if strcmp(m0.MfileName,'procmod')
    dm = m0.FileArgument{3};
else
    dm = pvget(m0,'DisturbanceModel');
end
%% if iscell(dm), dm = dm{1};end %procmodel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3. Checks and warnings
[A,B,C,D,K] = ssdata(m0);

if ftdom =='f'
    if ~strcmp(dm,'None')
        ctrlMsgUtils.warning('Ident:estimation:freqDataNoDistModel');
        dm = 'None';
        m0.DisturbanceModel = 'None';
    end
    if isempty(D)
        ctrlMsgUtils.error('Ident:estimation:freqDataTimeSeriesModel')
    end
    algorithm.LimitError = 0; % no robustification for FD data
    % check for integrations and zero frequency
    mcheck = pvset(m0,'ParameterVector',randn(size(pvget(m0,'ParameterVector'))));
    data = zfcheck(data,mcheck);
    
end
nx = size(A,1);
if ~strcmp(m0.MfileName,'procmod')
    % process models cannot be unstable by construction
    if ftdom == 't'
        ei = eig(A-K*C);
        if  ~isempty(ei) && ((Ts==0 && max(real(ei))>Sstab+1e4*eps) || (Ts>0 && max(abs(ei))>Zstab))
            ctrlMsgUtils.warning('Ident:estimation:unstableInitialPredictor',...
                sprintf('%g',Ts))
        end
    end
    
    if stabenf
        ei = eig(A);
        if ~isempty(ei) && ((Ts==0 && max(real(ei))>Sstab && norm(K)==0) ||...
                (Ts>0 && max(abs(ei))>Zstab))
            ctrlMsgUtils.warning('Ident:estimation:unstableInitialModel',...
                sprintf('%g',Ts))
        end
    end
end

if Ts>0
    if Ts~=Tsdata
        ctrlMsgUtils.warning('Ident:general:dataModelTsMismatch',...
            sprintf('%g',Ts),sprintf('%g',Tsdata));
        m0 = pvset(m0,'Ts',Tsdata);
    end
end

if strcmp(m0.CDmfile,'d') && (strcmp(intd,'foh') || strcmp(intd,'bl'))
    ctrlMsgUtils.warning('Ident:estimation:dataInterSampDTModel')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 4. Deal with Focus
foccase = 0;
if ~ischar(foc)
    foccase = 1;
elseif strcmp(foc,'Simulation') %Stability?
    if strcmp(dm,'Model') || strcmp(dm,'Fixed')
        m0ktest = parset(m0,randn(size(par)));
        if norm(pvget(m0ktest,'K')) > 0
            foccase = 1;
        end
    elseif strcmp(dm,'Estimate')
        foccase = 1;
    end
end
if foccase && isempty(B)
    ctrlMsgUtils.warning('Ident:estimation:timeSeriesFocus')
    foccase = 0;
end

if foccase
    m0ktest = parset(m0,randn(size(par)));
    if (any(strcmp(dm,{'Model','Fixed'})) && norm(pvget(m0ktest,'K'))==0)...
            || strcmpi(dm,'None')% first the simple filtering
        
        foc = foccheck(foc,Tsdata);
        data = idfilt(data,foc,'causal');
        if stabenf
            algorithm.Focus = 'Simulation';
        else
            algorithm.Focus = 'Prediction';
        end
    else
        m = pemfocus(data,m0,foc);
        m = setdatid(m,getid(data));
        return
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[e,xi] = pe(data,m0);
e = pvget(e,'OutputData');
e = cat(1,e{:}); % vector or errors
lam = e'*e/length(e); % first estimate of lambda
if realdata(data), lam = real(lam); end
m0 = pvset(m0,'NoiseVariance',lam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Fix LimitError

if algorithm.LimitError~=0
    Ns = size(e,1);
    algorithm.LimitError = ...
        median(abs(e-ones(Ns,1)*median(e)))*algorithm.LimitError/0.7;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Shift Data if necessary

Inpd = pvget(m0,'InputDelay');
if Ts==0
    if Tsdata>0
        Inpd = Inpd/Tsdata;
        %%%%%%end
        if any(Inpd ~= fix(Inpd))
            ctrlMsgUtils.error('Ident:idmodel:inputDelayCTModel')
        end
    end%%%%
end
dats = nkshift(data,Inpd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 7. Deal with InitialState
init = m0.InitialState;
% Overrides:
frdflag = 0;
utd = pvget(data,'Utility');

if isfield(utd,'idfrd') && utd.idfrd
    frdflag = 1;
end

if frdflag
    switch m0.InitialState
        case {'Estimate','Model','Backcast'}
            ctrlMsgUtils.warning('Ident:estimation:X0EstForIDFRD1');
            init = 'Zero';
            
        case 'Auto'
            init = 'Zero';
    end
end

if Ne>1
    switch init
        case 'Estimate'
            ctrlMsgUtils.warning('Ident:estimation:X0EstMultiExp2');
            init = 'Backcast';
            
        case 'Auto'
            init = 'Backcast';
        case {'Model','Fixed'}
            ctrlMsgUtils.warning('Ident:estimation:X0ModelFixedMultiExp')
    end
end

if strcmp(init,'Auto')
    % todo: use dats?
    ez = pe(data,m0,'z');
    ez = pvget(ez,'OutputData');
    nor1 = norm(e);
    norz = norm(cat(1,ez{:}));%e2{1});
    if norz/nor1>algorithm.Advanced.Threshold.AutoInitialState
        if strcmp(m0.MfileName,'procmod')
            init = 'BackCast';
        else
            init = 'Estimate';
        end
    else
        init = 'Model';
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%8. Prepare for minimization

% 8.1 Fix modifications in case of X0 and/or K estimation
ut = pvget(m0,'Utility');
if strcmpi(dm,'Estimate')% for internal use during minimization
    m0.DisturbanceModel = 'K';
    try
        Ki = ut.K;
    catch
        Ki = zeros(nx,ny);
    end
    par = [par;Ki(:)];
    m0 = parset(m0,par);
end

if strcmpi(init,'Estimate') % for internal use during minimization
    % Here protection is required in case xi=[] (CT data/model)
    if isempty(xi), xi = pvget(m0,'X0'); end
    m0.InitialState = 'x0';
    
    par = [par;xi];
    m0 = parset(m0,par);
end

realflag = realdata(dats);
if ftdom=='t'
    [z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag,ynorm] = idprep(dats,0,datn);
else
    %struc.realflag = realdata(dats);
    dats = complex(dats);
    [z,Ne,ny,nu,Tsdata,Name,Ncaps,errflag] = idprep_f(dats,0,datn);
    ynorm = [];
end
if ~isempty(errflag.message), error(errflag), end
if ~isempty(Name), dats.Name = Name; end

% set part of EstimationInfo now so that optimizer can use it to set struc
es.InitialState = init;
es.DataDomain = dom;
es.DataTs = Tsdata;
es.Misc = struct('realflag',realflag,'intd',intd,'nx',nx);
m0 = pvset(m0,'EstimationInfo',es);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 9. Minimize the prediction error criterion ***
Estimator = createEstimator(m0,z,algorithm);
OptimInfo = minimize(Estimator);

% update the model with the set of new values for states and parameters
m = updatemodel(m0, dats, OptimInfo, Estimator);
%---%

m = setdatid(m,getid(data),ynorm);
m = timemark(m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = pemfocus(data,m0,foc)
% estimation with focus

%if isa(foc,'idmodel')|isa(foc,'lti') |iscell(foc)
ts = pvget(data,'Ts');ts = ts{1};
dom = pvget(data,'Domain');
foc = foccheck(foc,ts,[],lower(dom(1)),pvget(data,'Name'));
zf = data;
if ~isa(foc,'char')
    zf = idfilt(data,foc);
end
% First test if K has common parameters with A,B,C,D:
par = pvget(m0,'ParameterVector');
m0test = parset(m0,randn(size(par)));
par0 = pvget(m0test,'ParameterVector');
[a,b,c,d,k] = ssdata(m0test);
dynpar = zeros(size(par));
kpar = zeros(size(par));
for kp = 1:length(par)
    par = par0;
    par(kp) = randn;
    m1 = parset(m0test,par);
    [a1,b1,c1,d1,k1] = ssdata(m1);
    if norm([a1(:);b1(:);c1(:);d1(:)]-[a(:);b(:);c(:);d(:)])>0
        dynpar(kp) = 1;
    end
    if norm(k1(:)-k(:))>0
        kpar(kp) = 1;
    end
end
if norm(kpar.*dynpar)>0
    ctrlMsgUtils.warning('Ident:estimation:idgreycheck1')
end
% Now for the dynamics model:
m1 = pvset(m0,'Focus','Prediction','DisturbanceModel','None');
tr = pvget(m0,'Display');
if ~strcmp(tr,'Off')
    fprintf('\n   *** Finding the dynamics model ... ***\n')
end
m1 = pem(zf,m1);
cov1 = pvget(m1,'CovarianceMatrix');

% Now to estimate K:
Kcase = pvget(m0,'DisturbanceModel');
if strcmp(Kcase,'Model') && (norm(k)==0 || ~any(kpar==1))
    Kcase = 'None';
end
fixedpar0 = [];
switch Kcase
    case 'Estimate' % make an independent estimate of K
        [a,b,c,d,k] = ssdata(m1);
        ts = pvget(m1,'Ts');
        mk = idss(a,b,c,d,k,'Ts',ts,'As',a,'Bs',b,'Cs',c,'Ds',d,'Ks',NaN*ones(size(k)),...
            'InputDelay',pvget(m1,'InputDelay'),'Display',pvget(m1,'Display'));
        
        if ~strcmp(tr,'Off')
            fprintf('\n   *** Finding the noise model ... ***\n')
        end
        mk =  pem(data,mk);
        K  =  pvget(mk,'K');
        m  =  pvset(m1,'DisturbanceModel','Estimate');
        m  =  pvset(m,'K',K);
    case 'None'
        m = m1;
    case 'Model'
        fixedpar0 = pvget(m1,'FixedParameter');
        dparnr = find(dynpar==1);
        m1 = pvset(m1,'FixedParameter',dparnr,'DisturbanceModel','Model');
        if ~strcmp(tr,'Off')
            fprintf('\n   *** Finding the noise model ... ***\n')
        end
        m1 = pem(data,m1);
        m = m1;
        cov2 = pvget(m1,'CovarianceMatrix');
        if isempty(cov2) || ischar(cov2)
            cov1 = [];
        end
        if ~(ischar(cov1) || isempty(cov1))
            cov = zeros(length(par),length(par));
            cov(dparnr,dparnr) = cov1(dparnr,dparnr);
            Ind1 = kpar==1;
            cov(Ind1,Ind1) = cov2(Ind1,Ind1);
            m = pvset(m1,'CovarianceMatrix',cov);
        end
end
m = pvset(m,'Focus',foc,'FixedParameter',fixedpar0);

es          =  pvget(m,'EstimationInfo');
es.Status   =  'Estimated model (PEM with focus)';
es.Method   =  'PEM with focus';
es.DataName =  pvget(data,'Name');
m.idmodel   =  pvset(m.idmodel,'EstimationInfo',es);
