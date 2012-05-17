function sys = nlarx(data, varargin)
%NLARX Estimate Nonlinear ARX model.
%
%   M = NLARX(DATA, ORDERS, NONLINEARITY) estimates an IDNLARX model.
%
%   M: the estimated model, returned as an IDNLARX object.
%   DATA: a Time Domain IDDATA object containing input-output data. See Help IDDATA.
%   ORDERS = [na nb nk] meaning that a predictor model of the kind
%      ypred = F(y(t-1),..y(t-na),u(t-nk),...,u(t-nk-nb+1)) is estimated.
%
%   NONLINEARITY: the function F implemented by one of the following
%   nonlinearity estimator objects:
%      sigmoidnet, wavenet, treepartition, customnet, neuralnet, linear
%   See "help sigmoidnet" etc. for more details. See "idprops idnlestimators" for
%   an overview of nonlinearity estimators. These objects have properties
%   that can be set at the time of estimation as in:
%
%   M = NLARX(DATA,[2 2 1],sigmoidnet('num',15)) % use sigmoid network with 15 units
%
%   For default property settings an (abbreviated) string can be used as in
%   M = NLARX(DATA,[2 2 1],'sigmoidnet') or M = NLARX(DATA,[2 2 1],'sig')
%
%   MULTIVARIABLE MODELS:
%   For multi-input/multi-output systems na, nb and nk are interpreted as
%   row vectors or matrices, just as in the linear case. See "help arx" for
%   more information on configuration of these matrices. Different
%   nonlinearity estimators can be used in different output channels by
%   letting NONLINEARITY be an object array, as in:
%   M = NLARX(DATA,[[2 1; 0 1] [2;1] [1;1]], [wavenet; sigmoidnet('num',7)])
%   which uses wavelet network for first output channel and sigmoid network
%   with 7 units for the second output channel of 2-input, 2-output model
%   M.
%
%   A single nonlinearity estimator as in:
%   M = NLARX(DATA,[[2 1; 0 1] [2;1] [1;1]], sigmoidnet('num',7)) or
%   M = NLARX(DATA,[[2 1; 0 1] [2;1] [1;1]], 'sig')
%   is automatically duplicated for all the outputs.
%
%   PROPERTY-VALUE PAIRS:
%   M = NLARX(DATA, ORDERS, NL, 'Property',Value,..) allows to specify extra
%   property values, including estimation algorithm options such as the
%   maximum number of iterations:
%       M = NLARX(DATA,[2 2 1],'sig','maxiter','10')
%   custom regressor definitions:
%       M = NLARX(DATA,[2 2 1],'lin','CustomReg',{'y1(t-1).^3',u1(t-1)*u1(t-2)'}
%   or other properties such as NonlinearRegressors:
%       M = NLARX(DATA, [2 2 1], 'wavenet', 'nlr', 'standard'), using "nlr"
%       as shortcut for "NonlinearRegressors".
%
%   See "idprops idnlarx" and "idprops idnlarx algorithm" for settable
%   properties.
%
%   INITIALIZATION WITH A LINEAR MODEL:
%   You can initialize the linear component of the IDNLARX model using a
%   linear model of ARX structure by replacing ORDERS with a linear model.
%   The linear model must be a discrete-time IDPOLY model of ARX structure
%   (nc=nd=nf=0) or an IDARX model. For example, M = NLARX(DATA,LINMOD,
%   'sigmoidnet') computes the orders of the nonlinear model M using LINMOD
%   and also initializes its linear term using A and B polynomials
%   of LINMOD before estimation. The linear term initilization happens only
%   if the model's nonlinearity estimator uses a linear term; this includes
%   wavenet, sigmoidnet and treepartition nonlinearity estimators.
%
%   MODEL REFINEMENT:
%   For nonlinearity estimators that require iterative search, the search
%   can be continued by successive calls of NLARX, like:
%       M0 = NLARX(DATA,[2 2 1],'sig')
%       M1 = NLARX(DATA,M0)
%   An estimate can be reinitialized to avoid being trapped in local minima
%   by M = INIT(M), M = NLARX(DATA,M). See IDNLARX/INIT for more details.
%   The iterative search for best fit is affected by Property/Value pairs like
%   NLARX(...,'MaxIter',N,'Tolerance',tol,'LimitError',lim,'Display','on')
%
%   The resulting estimate can be examined by COMPARE, PLOT, RESID, SIM,
%   PREDICT, LINEARIZE etc.
%
%   See also IDNLARX, GETREG, ADDREG, IDNLARX/INIT, PEM,
%   IDNLARX/FINDSTATES, NLHW, IDPROPS.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.16 $ $Date: 2009/12/05 02:04:22 $

% Author(s): Qinghua Zhang

%   Technology created in colloboration with INRIA and University Joseph
%   Fourier of Grenoble - FRANCE

ni = nargin;
error(nargchk(2, inf, ni, 'struct'))

% The case of m=nlarx(m,data,...) working as pem
sys = [];

if isa(data, 'idnlarx') && (isa(varargin{1}, 'iddata') || (isreal(varargin{1}) && ndims(varargin{1})==2))
    sys = data;
    data = varargin{1};
elseif isa(varargin{1}, 'idnlarx') && (isa(data, 'iddata') || (isreal(data) && ndims(data)==2))
    sys = varargin{1};
end

if isa(sys, 'idnlarx')
    if rem(ni,2)~=0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','nlarx','nlarx')
    end
    sys = pem(sys, data, varargin{2:end});
    ei = pvget(sys,'EstimationInfo');
    % ei.Status = 'Estimated by NLARX';
    ei.DataName = inputname(1);
    sys = pvset(sys, 'EstimationInfo', ei);
    return
end

% flag double data
if isa(data,'double') && ~isempty(data) && isreal(data) && ndims(data)==2
    doubleData = true; %sample time should be inherited from linear model
    Tsdat = 1;
elseif isa(data,'iddata')
    doubleData = false;
    Tsdat = pvget(data,'Ts'); Tsdat = Tsdat{1};
else
    ctrlMsgUtils.error('Ident:estimation:nlestDataRequired','nlarx')
end

if ~(isa(data, 'iddata') || (~isempty(data) && isreal(data) && ndims(data)==2))
    ctrlMsgUtils.error('Ident:estimation:nlestDataRequired','nlarx')
end

varg1 = varargin{1};

% Linear Model Extension part 1/3 (argument checks)
LmdlExtFlag = true;
if isa(varg1, 'idmodel') && ~(isa(varg1, 'idpoly') || isa(varg1, 'idarx'))
    ctrlMsgUtils.error('Ident:estimation:nlarxLinearModelType')
end

if isa(varg1, 'idpoly')
    if any(varg1.nc(:)) || any(varg1.nd(:)) || any(varg1.nf(:))
        ctrlMsgUtils.error('Ident:idnlmodel:IdnlarxLinearModelForm')
    end
end

if isa(varg1, 'idpoly') || isa(varg1, 'idarx')
    linmod = varg1;
    varg1 = [varg1.na, varg1.nb, varg1.nk];
else
    linmod = [];
    LmdlExtFlag = false;
end

% Catch the case ORDERS = {na nb nk} (using cell array)
if iscell(varg1) && numel(varg1)==3 && all(cellfun(@isnonnegintmat, varg1))
    ctrlMsgUtils.error('Ident:estimation:nlarxOrdersFormat')
end

nabk = {'na','nb','nk'};
nlIndInPvlist = 0;

if isnonnegintmat(varg1)
    % The case of M = NLARX(DATA, ORDERS, NL, 'Property',Value,..)
    
    if ni>2 && rem(ni,2)==0  % ni>2 to allow M = NLARX(DATA, ORDERS)
        ctrlMsgUtils.error('Ident:general:InvalidSyntax','nlarx','nlarx')
    end
    
    nn = varg1;
    [ny, ncn] = size(nn);
    nu = (ncn-ny)/2;
    if ~nu==round(nu)
        ctrlMsgUtils.error('Ident:estimation:nlarxOrdersFormat')
    end
    
    if ni>2
        nlobj = varargin{2};
    else % M = NLARX(DATA, ORDERS) for default NL (WAVENET)
        nlobj = wavenet;
    end
    
    if ~iscellstr(varargin(3:2:end))
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Algorithm properties short-hand handling
    [fnames, fvalues, pvlist] = algoshortcut(varargin(3:end));
    
    pvlist(1:2:end) = lower(pvlist(1:2:end));
    
    % Check if na, nb, nk are also specified in PV-pairs
    for kp=1:3
        ind = strmatch(nabk{kp}, pvlist(1:2:end), 'exact');
        if ~isempty(ind)
            ctrlMsgUtils.error('Ident:estimation:nlestOrdersMultiSpec','nlarx')
        end
    end
    
    % Check if Nonlinearity is also specified in PV-pairs
    nlflag = false;
    for kp=1:2:numel(pvlist)
        if (length(pvlist{kp})>1 && ~isempty(strmatch(pvlist{kp}, 'nlity'))) || ...
                (length(pvlist{kp})>9 && ~isempty(strmatch(pvlist{kp}, 'nonlinearity')))
            nlflag = true;
            break
        end
    end
    if nlflag
        ctrlMsgUtils.error('Ident:estimation:nlarxCheck2')
    end
    
elseif ischar(varg1)
    % The case of M = NLARX(DATA, 'Property',Value,..)
    
    if rem(ni,2)==0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','nlarx','nlarx')
    end
    
    if ~iscellstr(varargin(1:2:end))
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Algorithm properties short-hand handling
    [fnames, fvalues, pvlist] = algoshortcut(varargin);
    pvlist(1:2:end) = lower(pvlist(1:2:end));
    
    % Check if na, nb, nk are specified
    for kp=1:3
        ind = strmatch(nabk{kp}, pvlist(1:2:end), 'exact');
        if isempty(ind)
            ctrlMsgUtils.error('Ident:estimation:nlestMissingOrders','nlarx',nabk{kp},'nlarx')
        elseif length(ind)>1
            ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp',nabk{kp})
        end
    end
    
    % Check if Nonlinearity is specified
    nlkp = 0;
    for kp=1:2:numel(pvlist)
        if (length(pvlist{kp})>1 && ~isempty(strmatch(pvlist{kp}, 'nlity'))) || ...
                (length(pvlist{kp})>9 && ~isempty(strmatch(pvlist{kp}, 'nonlinearity')))
            if ~nlkp
                nlkp = kp;
            else
                ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','Nonlinearity')
            end
        end
    end
    if nlkp
        nlIndInPvlist = nlkp+1;
        nlobj = pvlist{nlIndInPvlist};
    else
        ctrlMsgUtils.error('Ident:estimation:nlarxMissingNL')
    end
    
else
    ctrlMsgUtils.error('Ident:estimation:nlarxSyntax')
end

% Handle InitialState
ind = strmatch('init', pvlist(1:2:end));
if ~isempty(ind)
    for ki=1:length(ind)
        if isempty(strmatch(pvlist{ind(ki)*2-1}, 'initialstate'))
            ind(ki) = 0;
        end
    end
    ind = ind(ind>0);
    if ~isempty(ind)
        pvlist([ind*2-1  ind*2]) = [];
    end
end

if isa(nlobj, 'idnlfun')
    % Do nothing
elseif isempty(nlobj)
    nlobj = linear;
elseif ischar(nlobj)
    [nlobj, msg] = strchoice(idnlfunclasses, nlobj, 'Nonlinearity');
    if isempty(msg)
        nlobj = feval(nlobj);
    else
        ctrlMsgUtils.error('Ident:estimation:invalidEstimator',nlobj)
    end
else
    ctrlMsgUtils.error('Ident:estimation:idnlarxNLobjFormat')
end

% Extract CustomRegressors from pvlist in order to feed it in pem.
% This is to use the data channel names in customreg
% Note: only the first character 'c' is searched for. In case of multiple
% hits, they will be handled in PEM.
ind = strmatch('c', lower(pvlist(1:2:end)));
if isempty(ind)
    custregpv = {};
else
    indpv = [ind(:)'*2-1;ind(:)'*2];
    indpv = indpv(:);
    custregpv = pvlist(indpv);
    pvlist(indpv) = [];
end
if ~isempty(custregpv)
    % Extract also NonlinearRegressors, because it must
    % be set after CustomRegressors.
    ind = strmatch('nlr', lower(pvlist(1:2:end)));
    ind2 = strmatch('nonlinearr', lower(pvlist(1:2:end)));
    ind = [ind(:); ind2(:)]';
    if ~isempty(ind)
        indpv = [ind(:)'*2-1;ind(:)'*2];
        indpv = indpv(:);
        custregpv2 = pvlist(indpv);
        custregpv = [custregpv(:); custregpv2(:)]';
        pvlist(indpv) = [];
    end
end

if nlIndInPvlist==0          % M = NLARX(DATA, ORDERS, NL, 'Property',Value,..)
    % G416499 fix (error checks)
    [ny, ncn] = size(nn);
    nu = (ncn-ny)/2;
    if ~(isnonnegintmat(nn) && nu>=0 && nu==round(nu))
        ctrlMsgUtils.error('Ident:estimation:nlarxOrdersFormat')
    end
    if ~isempty(nlobj) && ~any(numel(nlobj)==[1 ny]) % numel(nlobj) should be 1 (scalar expansion) or ny
        ctrlMsgUtils.error('Ident:estimation:nlarxOrderNLSizeMismatch')
    end
    
    sys = idnlarx(nn, nlobj, pvlist{:});
else                         % M = NLARX(DATA, 'Property',Value,..)
    sys = idnlarx(pvlist{:});
end

if LmdlExtFlag
    % Linear Model Extension part 2/3.
    if ~doubleData && ~isequal(Tsdat,pvget(linmod,'Ts'))
        ctrlMsgUtils.error('Ident:estimation:nlmodelLinearModelTs','IDNLARX')
    elseif doubleData
        Tsdat = pvget(linmod,'Ts');
    end
    
    nlobj = sys.Nonlinearity;
    LinCoefs = idarx2linearcoefs(linmod);
    for ky=1:ny
        nlobj(ky) = soLinearInit(nlobj(ky), LinCoefs{ky});
    end
    sys.Nonlinearity = nlobj;
    if norm(linmod.InputDelay,1)>0
        ctrlMsgUtils.warning('Ident:idnlmodel:LinearModelDelayIgnored','IDNLARX');
    end
end

% Algorithm properties short-hand handling
algo = pvget(sys, 'Algorithm');
if ~isempty(fnames)
    algo = setmfields(algo, fnames, fvalues);
    sys = pvset(sys, 'Algorithm', algo);
end

% Check data-model consistency
[ny, nu] = size(sys);
[data, msg] = datacheck(data, ny, nu);
error(msg)

if doubleData
    data.Ts = Tsdat;
end

% Change criteria to trace for lsqnonlin (since we are starting from data
% and orders)
sys = LocalUpdateCriterion(sys);

% Estimate model
sys = pem(sys, data, custregpv{:});
if LmdlExtFlag
    % Linear Model Extension part 3/3 (Inherit I-O properties)
    
    sys = pvset(sys, 'InputName', pvget(linmod, 'InputName'));
    sys = pvset(sys, 'InputUnit', pvget(linmod, 'InputUnit'));
    sys = pvset(sys, 'OutputName', pvget(linmod, 'OutputName'));
    sys = pvset(sys, 'OutputUnit', pvget(linmod, 'OutputUnit'));
    sys = pvset(sys, 'Ts', pvget(linmod, 'Ts'));
    sys = pvset(sys, 'TimeUnit', pvget(linmod, 'TimeUnit'));
end
ei = pvget(sys,'EstimationInfo');
ei.Status = 'Estimated model (NLARX)';
ei.Method = sprintf('NLARX using SearchMethod = %s',algo.SearchMethod);
ei.DataName = inputname(1);
sys = pvset(sys, 'EstimationInfo', ei);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = LocalUpdateCriterion(m)
% set criterion to trace if searchmethod is lsqnonlin, det otherwise

searchm = m.Algorithm.SearchMethod;
cr = m.Algorithm.Criterion;
if strcmpi(searchm,'lsqnonlin') && strcmpi(cr,'det')
    m.Algorithm.Criterion = 'Trace';
end

% Sep2009
% FILE END