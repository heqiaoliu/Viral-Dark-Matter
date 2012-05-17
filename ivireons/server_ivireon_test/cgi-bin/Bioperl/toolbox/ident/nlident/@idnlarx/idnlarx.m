function sys = idnlarx(varargin)
%IDNLARX  Create Nonlinear ARX model.
%
%   M = IDNLARX(ORDERS)   M = IDNLARX(ORDERS, NONLINEARITY)
%
%   M: The returned Nonlinear ARX (IDNLARX) model.
%   ORDERS = [na nb nk] meaning that a predictor model of the kind
%     ypred = F(y(t-1),..y(t-na),u(t-nk),...,u(t-nk-nb+1)) is estimated.
%     For multi-output systems, ORDERS has as many rows as there are outputs.
%     na is then an ny-by-ny matrix whose entry na(i,j) gives the number of
%     delayed j-th output used in the model of the i-th output. Similarly, nb
%     and nk are ny-by-nu matrices. (ny:# of outputs, nu:# of inputs).
%     See also Help ARX.
%
%   NONLINEARITY: The character of the function F. One of the following
%     nonlinearity estimator objects:
%     sigmoidnet (default), wavenet, treepartition, customnet, neuralnet,
%     linear.
%     See "help sigmoidnet" etc for more details. Type
%     "idprops idnlestimators" for an overview of nonlinearity
%     estimators. These objects have properties that can be set at the time
%     of creation as in IDNLARX([2 3 1],sigmoidnet('Num',15)). For a
%     multi-output model, NONLINEARITY is an ny-by-1 array, like
%     [sigmoidnet;wavenet]. If a scalar object is given, it is applied to all
%     outputs. For default properties, NONLINEARITY can also be set as a
%     (abbreviated) string: IDNLARX([3 2 1],'sigmoidnet') or
%     IDNLARX([3 2 1],'sig').
%
%   Use M = IDNLARX(ORDERS,  NONLINEARITY, 'Property',Value,..) to specify extra
%   property values. See idprops idnlarx for a complete list of properties.
%
%   Alternatively, the syntax M = IDNLARX('Property',Value,..) can also
%   be used, where the property-value list should include 'na', 'nb' and
%   'nk' for ORDERS, and 'Nonlinearity' for NL.
%
%   INITIALIZATION WITH A LINEAR MODEL:
%   You can initialize the linear component of the IDNLARX model using a
%   linear model of ARX structure by replacing ORDERS with a linear model.
%   The linear model must be a discrete-time IDPOLY model of ARX structure
%   (nc=nd=nf=0) or an IDARX model. For example, M = IDNLARX(LINMOD,'sigmoidnet') 
%   computes the orders of the nonlinear model M using LINMOD and also
%   initializes its linear term using A and B polynomials of LINMOD. The
%   linear term initilization happens only if the model's nonlinearity
%   estimator uses a linear term; this includes wavenet, sigmoidnet and
%   treepartition nonlinearity estimators. Input and output channel names
%   and units, time unit and sampling interval values are also inherited by
%   M from LINMOD. However, algorithm properties are not inherited.
%
%   MODEL ESTIMATION:
%   Models created using IDNLARX can be estimated using PEM, as in: 
%       M = IDNLARX([2 2 1],'wavenet');
%       ME = PEM(DATA,M);
%   Note that it is not necessary to create model using IDNLARX explicitly.
%   Estimation of model using NLARX creates an IDNLARX model object
%   automatically. However, you may want to create model separately if it
%   needs to be configured before estimation, such as for specifying custom
%   regressors, algorithm properties etc.
%
%   See also NLARX, GETREG, CUSTOMREG, IDNLHW, IDNLARX/PEM, IDNLARX/PLOT,
%   IDNLARX/LINEARIZE.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.15 $ $Date: 2009/12/05 02:04:28 $

% Author(s): Qinghua Zhang

%   Technology created in colloboration with INRIA and University Joseph
%   Fourier of Grenoble - FRANCE

superiorto('iddata')
superiorto('idmodel')
superiorto('customreg')

ni = nargin;

pvstart = 1;

% First processing the ni==0 cases
if ni==0
    varargin{1} = [1 1 1];
    varargin{2} = wavenet;
end

varg1 = varargin{1};

if isa(varg1,'idnlarx')
    % Quick exit
    if ni==1
        sys = varg1;
        return
    else
        ctrlMsgUtils.error('Ident:general:useSetForProp','IDNLARX')
    end
end

% Linear Model Extension part 1/2 (argument checks)
if isa(varg1, 'idmodel') && ~(isa(varg1, 'idpoly') || isa(varg1, 'idarx'))
    ctrlMsgUtils.error('Ident:idnlmodel:IdnlarxLinearModelType')
end
if isa(varg1, 'idpoly')
    if any(varg1.nc(:)) || any(varg1.nd(:)) || any(varg1.nf(:))
        ctrlMsgUtils.error('Ident:idnlmodel:IdnlarxLinearModelForm')
    end
end

if isa(varg1, 'idpoly') || isa(varg1, 'idarx')
    if pvget(varg1, 'Ts')<=0
        ctrlMsgUtils.error('Ident:idnlmodel:NlmodelLinearModelTs','IDNLARX')
    end
    linmod = varg1;
    varg1 = [varg1.na, varg1.nb, varg1.nk];
else
    linmod = [];
end

nn = varg1;

[ny, ncn] = size(nn);
nu = (ncn-ny)/2;
if isnonnegintmat(nn) && nu>=0 && nu==round(nu)
    na = nn(:,1:ny);
    nb = nn(:, ny+1:ny+nu);
    nk = nn(:, ny+nu+1:ny+nu+nu);
    error(nabkchck(na, nb, nk));
    pvstart = 2;
elseif ~ischar(nn)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlarxWrongSyntax')
end

if pvstart>1
    if ni<2
        nlobj = wavenet;
        ni = 2; % as if nlobj was given in arg2 (for PV-pairs checking)
    else
        nlobj = varargin{2};
    end
    
    if isa(nlobj, 'idnlfun')
        pvstart = 3;
    elseif isempty(nlobj) && (isfloat(nlobj) || ischar(nlobj))
        nlobj = linear;
        pvstart = 3;
    elseif ischar(nlobj)
        [nlobj, msg] = strchoice(idnlfunclasses, nlobj, 'Nonlinearity');
        if isempty(msg)
            pvstart = 3;
        end
    end
end

% Now the value of pvstart is determined
if ~rem(ni-pvstart,2)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlarxWrongSyntax')
end

if pvstart<2 % Model orders not specified by nn
    [na, msg] = pvsearch('na', varargin, false, 'idnlarx');
    error(msg)
    
    [nb, msg] = pvsearch('nb', varargin, false, 'idnlarx');
    error(msg)
    
    [nk, msg] = pvsearch('nk', varargin, false, 'idnlarx');
    error(msg)
    
    error(nabkchck(na,nb,nk))
    [ny, nu] = size(nb);
end

nlind = 0;
if pvstart<3 % nlobj definition not found yet
    if ~iscellstr(varargin(pvstart:2:ni))
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    ind = strmatch('nonlineari', lower(varargin(pvstart:2:ni)));
    if isempty(ind)
        ind = strmatch('nli', lower(varargin(pvstart:2:ni)));
    end
    if isempty(ind)
        ind = strmatch('nl', lower(varargin(pvstart:2:ni)), 'exact');
    end
    
    if length(ind)>1
        ctrlMsgUtils.error('Ident:idnlmodel:ambiguousNLSpec','Nonlinearity')
    elseif length(ind)==1
        nlind =  pvstart-1+ind*2;
        if nlind<=ni
            nlobj = varargin{nlind};
        else
            nlobj = [];
        end
    else
        nlobj = 'wavenet'; % Default nonlinearity type.
    end
end

% nljob handling
[nlobj, msg] = nlobjcheck(nlobj, ny);
error(msg)

% Prepare property default values
if ny>1
    nlreg =cell(ny,1);
    [nlreg{:}] = deal('all');
else
    nlreg = 'all';
end
estinfo = iddef('estimation');
estinfo.InitRandnState = [];
estinfo.EstimationTime = [];
if ny>1
    custreg = cell(ny,1);
    [custreg{:}] = deal({});
else
    custreg = {};
end

% Create object structure
sys = struct('na',na, 'nb',nb, 'nk',nk, ...
    'CustomRegressors', {custreg}, 'NonlinearRegressors', {nlreg}, ...
    'Nonlinearity', nlobj, 'Focus', 'Prediction', ...
    'Algorithm',  bbalgodef, ...
    'CovarianceMatrix', 'none', ...
    'EstimationInfo', estinfo);
%Note: {custreg} and {nlreg} are necessary in both SO and MO cases for the struct(...) syntax.

sys.Algorithm.Weighting = eye(ny);

% Create IDNLMODEL parent
[ny, nu] = size(nb);
nlm = idnlmodel(ny,nu,1);
sys = class(sys,'idnlarx', nlm);

% Set NonlinearRegressors=[] for Nonlinearity=linear
sys = linearnlrset(sys, nlobj);

% Finally, set any PV pairs
if rem(ni-pvstart+1,2)
    ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs','IDNLARX','idnlarx')
end
if nlind
    % Avoid reset Nonlinearity
    ind = [pvstart:nlind-2, nlind+1:ni];
else
    ind = pvstart:ni;
end
if ~isempty(ind)
    try
        set(sys,varargin{ind})
    catch E
        throw(E)
    end
end

% Regressor dimension consistency check
msg = regdimcheck(nlobj, sys);
error(msg)

if ~isempty(linmod)
    % Linear Model Extension part 2/2.
    nlobj = sys.Nonlinearity;
    LinCoefs = idarx2linearcoefs(linmod);
    for ky=1:ny
        nlobj(ky) = soLinearInit(nlobj(ky), LinCoefs{ky});
    end
    sys.Nonlinearity = nlobj;
    
    % Inherit I-O properties
    
    sys = pvset(sys, 'InputName', pvget(linmod, 'InputName'));
    sys = pvset(sys, 'InputUnit', pvget(linmod, 'InputUnit'));
    sys = pvset(sys, 'OutputName', pvget(linmod, 'OutputName'));
    sys = pvset(sys, 'OutputUnit', pvget(linmod, 'OutputUnit'));
    sys = pvset(sys, 'Ts', pvget(linmod, 'Ts'));
    sys = pvset(sys, 'TimeUnit', pvget(linmod, 'TimeUnit'));
    
    if norm(linmod.InputDelay,1)>0
        ctrlMsgUtils.warning('Ident:idnlmodel:LinearModelDelayIgnored','IDNLARX');
    end
    
end

sys = timemark(sys, 'c');

% Oct2009
% FILE END
