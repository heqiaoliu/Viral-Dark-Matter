function sys = nlhw(data, varargin)
%NLHW Estimate Hammerstein-Wiener model.
%
%   M = NLHW(DATA,ORDERS, InputNL, OutputNL)
%
%   M is the estimated model, returned as an IDNLHW model object.
%   DATA: A time domain IDDATA object containing input-output data u and y.
%   ORDERS = [nb nf nk] are the orders and delays of the linear transfer
%     function equation  x(t) = [B(q)/F(q)] w(t-nk) relating the input x(t)
%     and the output w(t) of the linear subsystem.
%   InputNL is the input static nonlinearity G, so that w(t) = G(u(t)).
%   OutputNL is the output static nonlinearity H, so that y(t) = H(x(t)).
%   InputNL and OutputNL are both implemented by nonlinearity estimator
%   objects, one of: pwlinear, poly1d, deadzone, saturation, sigmoidnet,
%   wavenet, customnet or unitgain.
%
%   See "help pwlinear" etc for more details. Type "idprops idnlestimators"
%   for an overview of nonlinearity estimators. These objects have
%   properties that can be set at the time of
%   estimation as in:
%   M = NLHW(DATA,[2 2 1],sigmoidnet('num',5),deadzone([-1,2])), which uses
%   a sigmoid network with 5 units for input nonlinearity and a dead zone
%   estimator with zero interval of [-1 2] for output nonlinearity.
%
%   For default property settings of nonlinearity estimators, (abbreviated)
%   strings can be used as in:
%       M = NLHW(DATA,[2 2 1],'sig','dead')
%   The estimator unitgain (can also be entered as []) means no nonlinearity.
%   M = NLHW(DATA,[2 2 1],'sat',[]) thus gives a Hammerstein model.
%
%   MULTIVARIABLE MODELS:
%   For multivariate data with nu inputs and ny outputs, nb, nf and nk are
%   ny-by-nu matrices whose (i,j)-th entry specifies the orders and delay
%   of the transfer function from the j-th input to the i-th output.
%   For multivariate models, G and H are applied componentwise. Different
%   nonlinearities can be applied to different channels as in:
%   NLHW(DATA,ORDERS,[sigmoidnet;pwlinear],[])
%
%   PROPERTY-VALUE PAIRS:
%   M = NLHW(DATA, ORDERS, InputNL, OutputNL, 'Property',Value,...) allows to
%   specify extra property values. See "idprops idnlhw" and "idprops idnlhw
%   algorithm" for settable properties.
%
%   Alternatively, the syntax M = NLHW(DATA, 'Property',Value,...) can also
%   be used, where the property-value list must include 'nb', 'nf',
%   'nk', 'InputNonlinearity' and 'OutputNonlinearity'.
%
%   M = NLHW(DATA, ORDERS, InputNL, OutputNL, 'InitialState',INIT,..) allows
%   setting of how the initial states should be handled during estimation.
%   INIT='z' for zero (default) and INIT='e' for estimating initial states.
%
%   INITIALIZATION WITH A LINEAR MODEL:
%   You can initialize the linear component of the IDNLHW model using a
%   linear model of output-error structure by replacing ORDERS with a
%   linear model. The linear model must be a discrete-time IDPOLY model of
%   Output-Error structure (na=nc=nd=0) or an IDSS model with K=0. For
%   example, M = NLHW(DATA,LINMOD, 'sigmoidnet', 'saturation') sets the 
%   the orders (nb, nf, nk) as well as the values of properties "b" and "f"
%   equal to those of the IDPOLY model LINMOD. 
%
%   MODEL REFINEMENT:
%   The iterative search for the estimate can be continued by successive
%   calls of NLHW, like:
%       M = NLHW(DATA,[2 2 1],'sig')
%       M = NLHW(DATA,M).
%
%   An estimate can be reinitialized to avoid being trapped in local minima
%   by M = INIT(M), M = NLHW(DATA,M). See IDNLHW/INIT for more details.
%   The iterative search for best fit is affected by Property/Value pairs like
%   NLHW(...,'MaxIter',N,'Tolerance',tol,'LimitError',lim,'Display','on')
%   See "idprops idnlhw algorithm" for a list of algorithm properties.
%
%   The resulting model can be examined for its behavior using response
%   computation and validation commands such as PLOT, STEP, COMPARE, RESID,
%   SIM, PREDICT, and LINEARIZE. The linear block of the model is stored in
%   its (read-only) LinearModel property and can be retrieved as LinMod =
%   M.LinearModel. The linear model is delivered as an IDPOLY or an IDSS
%   model object.
%
%   See also IDNLHW, IDNLHW/PEM, IDNLHW/INIT, NLARX, IDNLHW/FINDSTATES,
%   IDNLHW/PREDICT, IDNLMODEL/STEP, IDNLHW/PLOT, IDNLHW/LINEARIZE.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.18 $ $Date: 2009/12/05 02:04:25 $

% Author(s): Qinghua Zhang

%   Technology created in colloboration with INRIA and University Joseph
%   Fourier of Grenoble - FRANCE

ni = nargin;
error(nargchk(2, inf, ni, 'struct'))

% The case of m=nlhw(data,m,...) working as pem
sys = [];
if isa(data, 'idnlhw') && (isa(varargin{1}, 'iddata') || (isreal(varargin{1}) && ndims(varargin{1})==2))
    sys = data;
    data = varargin{1};
elseif isa(varargin{1}, 'idnlhw') && (isa(data, 'iddata') || (isreal(data) && ndims(data)==2))
    sys = varargin{1};
end
if isa(sys, 'idnlhw')
    if rem(ni,2)~=0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','nlhw','nlhw')
    end
    sys = pem(sys, data, varargin{2:end});
    ei = pvget(sys,'EstimationInfo');
    % ei.Status = 'Estimated by NLHW';
    ei.DataName = inputname(1);
    sys = pvset(sys, 'EstimationInfo', ei);
    return
end
% END of m=nlhw(data,m,...)

% flag double data
if isa(data,'double') && ~isempty(data) && isreal(data) && ndims(data)==2
    doubleData = true; %sample time should be inherited from linear model
    Tsdat = 1;
elseif isa(data,'iddata')
    doubleData = false;
    Tsdat = pvget(data,'Ts'); Tsdat = Tsdat{1};
else
    ctrlMsgUtils.error('Ident:estimation:nlestDataRequired','nlhw')
end

if ~(isa(data, 'iddata') || (~isempty(data) && isreal(data) && ndims(data)==2))
    ctrlMsgUtils.error('Ident:estimation:nlestDataRequired','nlhw')
end

% Catch the case ORDERS = {nb nf nk} (using cell array)
if iscell(varargin{1}) && numel(varargin{1})==3 && all(cellfun(@isnonnegintmat, varargin{1}))
    ctrlMsgUtils.error('Ident:estimation:nlhwOrdersFormat')
end

nbfk = {'nb','nf','nk'};
nn = [];

varg1 = varargin{1};

% Linear Model Extension, Part 1/3 (argument checks)
if isa(varg1, 'idmodel') && ~(isa(varg1, 'idpoly') || isa(varg1, 'idss'))
    ctrlMsgUtils.error('Ident:estimation:nlhwLinearModelType')
end

linmdl = [];

if ~doubleData && isa(varg1,'idmodel') && ~isequal(Tsdat,pvget(varg1,'Ts'))
    ctrlMsgUtils.error('Ident:estimation:nlmodelLinearModelTs','IDNLHW')
elseif doubleData && isa(varg1,'idmodel')
    Tsdat = pvget(varg1,'Ts');
end
linmdl = [];   % cell array
linmod = varg1; % obj
if isa(varg1, 'idpoly')
    if any(varg1.nc(:)) || any(varg1.nd(:)) || any(varg1.na(:))
        ctrlMsgUtils.error('Ident:idnlmodel:IdnlhwLinearModelForm')
    end
    
    linmdl = {varg1}; % Currently IDPOLY is SO only.
    varg1 = [varg1.nb, varg1.nf, varg1.nk];
end

if isa(varg1, 'idss')
    if ~strcmpi(varg1.DisturbanceModel, 'None')
        ctrlMsgUtils.error('Ident:idnlmodel:IdnlhwIDSSModelForm')
    end
    [nym, num] = size(varg1);
    linmdl = cell(nym,1);
    for ky=1:nym
        linmdl{ky} = idpoly(varg1(ky,:));
        % Transform A and C polynomials to F polynomial
        was = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:MISOidpolyDoubleBF',...
            'Ident:idmodel:IdpolyBFFormatMismatch');
        if all(linmdl{ky}.f==1) && all(linmdl{ky}.a == linmdl{ky}.c)
            linmdl{ky}.f = linmdl{ky}.a(ones(size(linmdl{ky}.b,1),1),:);
            linmdl{ky}.a = 1;
            linmdl{ky}.c = 1;
        end
        delete(was)
    end
    varg1 = zeros(nym,num*3);
    for ky=1:nym
        varg1(ky,:) = [linmdl{ky}.nb, linmdl{ky}.nf, linmdl{ky}.nk];
    end
end
LmdlExtFlag = ~isempty(linmdl);

if isnonnegintmat(varg1)
    % The case of M = NLHW(DATA, ORDERS, UNL,YNL,'Property',Value,..)
    
    if ni<3
        varargin{2} = pwlinear;
    end
    
    if ni<4
        varargin{3} = pwlinear;
    end
    
    if rem(ni,2)~=0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','nlhw','nlhw')
    end
    
    nn = varg1;
    [ny, ncn] = size(nn);
    nu = ncn/3;
    if  nu~=round(nu)
        ctrlMsgUtils.error('Ident:estimation:nlhwOrdersFormat')
    end
    
    unlobj = varargin{2};
    ynlobj = varargin{3};
    
    if ~iscellstr(varargin(4:2:end))
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Algorithm properties short-hand handling
    [fnames, fvalues, pvlist] = algoshortcut(varargin(4:end));
    pvlist(1:2:end) = lower(pvlist(1:2:end));
    
    % Check if nk, nf, nk are also specified in PV-pairs
    for kp=1:3
        ind = strmatch(nbfk{kp}, pvlist(1:2:end), 'exact');
        if ~isempty(ind)
            ctrlMsgUtils.error('Ident:estimation:nlestOrdersMultiSpec','nlhw')
        end
    end
    
    % Check if I/O Nonlinearities is also specified in PV-pairs
    for kp=1:2:numel(pvlist)
        if (length(pvlist{kp})>2 && ...
                ~isempty(strmatch(pvlist{kp}, {'unlity', 'ynlity','unonlinearity', 'ynonlinearity'}))) || ...
                (length(pvlist{kp})>6 && ~isempty(strmatch(pvlist{kp}, {'inputnlity', 'inputnonlinearity'}))) || ...
                (length(pvlist{kp})>7 && ~isempty(strmatch(pvlist{kp}, {'outputnlity', 'outputnonlinearity'})))
            if pvlist{kp}(1)=='u' ||  pvlist{kp}(1)=='i'
                ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','InputNonlinearity')
            else
                ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','OutputNonlinearity')
            end
        end
    end
    
elseif ischar(varg1)
    % The case of M = NLHW(DATA, 'Property',Value,..)
    
    if rem(ni,2)==0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','nlhw','nlhw')
    end
    
    if ~iscellstr(varargin(1:2:end))
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Algorithm properties short-hand handling
    [fnames, fvalues, pvlist] = algoshortcut(varargin);
    pvlist(1:2:end) = lower(pvlist(1:2:end));
    
    % Check if nb, nf, nk are specified
    for kp=1:3
        ind = strmatch(nbfk{kp}, pvlist(1:2:end), 'exact');
        if isempty(ind)
            ctrlMsgUtils.error('Ident:estimation:nlestMissingOrders','nlhw',nbfk{kp},'nlhw')
        elseif length(ind)>1
            ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp',nbfk{kp})
        end
    end
    
    % Check if Nonlinearity is specified
    unlkp = 0;
    ynlkp = 0;
    for kp=1:2:numel(pvlist)
        if (length(pvlist{kp})>2 && ...
                ~isempty(strmatch(pvlist{kp}, {'unlity', 'ynlity','unonlinearity', 'ynonlinearity'}))) || ...
                (length(pvlist{kp})>6 && ~isempty(strmatch(pvlist{kp}, {'inputnlity', 'inputnonlinearity'}))) || ...
                (length(pvlist{kp})>7 && ~isempty(strmatch(pvlist{kp}, {'outputnlity', 'outputnonlinearity'})))
            if pvlist{kp}(1)=='u' ||  pvlist{kp}(1)=='i'
                unlkp = unlkp + 1;
                unlobj = pvlist{kp+1};
            else
                ynlkp = ynlkp + 1;
                ynlobj = pvlist{kp+1};
            end
        end
    end
    
    if unlkp>1
        ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','InputNonlinearity')
    end
    if ynlkp>1
        ctrlMsgUtils.error('Ident:general:multipleSpecificationForProp','OutputNonlinearity')
    end
    
    if unlkp==0
        ctrlMsgUtils.error('Ident:estimation:nlhwMissingUNL')
    end
    if ynlkp==0
        ctrlMsgUtils.error('Ident:estimation:nlhwMissingYNL')
    end
    
else
    ctrlMsgUtils.error('Ident:estimation:nlhwSyntax')
end

if isa(unlobj, 'idnlfun')
    % Do nothing
elseif isempty(unlobj)
    unlobj = unitgain;
elseif ischar(unlobj)
    [unlobj, msg] = strchoice(idnlfunclasses, unlobj, 'InputNonlinearity');
    if isempty(msg)
        unlobj = feval(unlobj);
    else
        error(msg)
    end
else
    ctrlMsgUtils.error('Ident:estimation:idnlhwUNLobjFormat')
end
if isa(ynlobj, 'idnlfun')
    % Do nothing
elseif isempty(ynlobj)
    ynlobj = unitgain;
elseif ischar(ynlobj)
    [ynlobj, msg] = strchoice(idnlfunclasses, ynlobj, 'OutputNonlinearity');
    if isempty(msg)
        ynlobj = feval(ynlobj);
    else
        error(msg)
    end
else
    ctrlMsgUtils.error('Ident:estimation:idnlhwYNLobjFormat')
end

if ~isempty(nn)              % M = NLHW(DATA, ORDERS, UNL,YNL,'Property',Value,..)
    % G416499 fix (error checks)
    [nnrows, nncols] = size(nn);
    if ~isempty(ynlobj) && ~any(numel(ynlobj)==[1 nnrows])
        ctrlMsgUtils.error('Ident:estimation:nlarxOrderYNLSizeMismatch')
    end
    if ~isempty(unlobj) && ~any(numel(unlobj)==[1 nncols/3])
        ctrlMsgUtils.error('Ident:estimation:nlarxOrderUNLSizeMismatch')
    end
    sys = idnlhw(nn, unlobj, ynlobj, pvlist{:});
else                         % M = NLHW(DATA, 'Property',Value,..)
    sys = idnlhw(pvlist{:});
end

% Linear Model Extension, Part 2/3
WRN = ctrlMsgUtils.SuspendWarnings;
if LmdlExtFlag
    nb = pvget(sys, 'nb');
    nf = pvget(sys, 'nf');
    nk = pvget(sys, 'nk');
    Bc = cell(ny, nu);
    Fc = cell(ny, nu);
    for ky=1:ny
        lmdl = linmdl{ky}; %idpoly(1,B,1,1,F);
        for ku=1:nu
            Bc{ky,ku} = lmdl.b(ku,1:nb(ky,ku)+nk(ky,ku));
            Fc{ky,ku} = lmdl.f(ku,1:nf(ky,ku)+1);
        end
    end
    sys = pvset(sys, 'b', Bc);
    sys = pvset(sys, 'f', Fc);
    if norm(lmdl.InputDelay,1)>0
        ctrlMsgUtils.warning('Ident:idnlmodel:LinearModelDelayIgnored','IDNLHW');
    end
end
delete(WRN);

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

% change criteria to trace for lsqnonlin (since we are starting from data
% and orders)
sys = LocalUpdateCriterion(sys);

% Estimate model
sys = pem(sys, data);

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
ei.Status = 'Estimated model (NLHW)';
ei.Method = sprintf('NLHW using SearchMethod = %s',algo.SearchMethod);
ei.DataName = inputname(1);
sys = pvset(sys, 'EstimationInfo', ei);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = LocalUpdateCriterion(m)
% set criterion to trace if searchmethod is lsqnonlin, det otherwise

searchm = m.Algorithm.SearchMethod;
cr = m.Algorithm.Criterion;
if strcmpi(searchm,'lsqnonlin') && strcmpi(cr,'det')
    m.Algorithm.Criterion = 'trace';
end

% Oct2009
% FILE END