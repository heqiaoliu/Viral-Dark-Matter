function sys = idnlhw(varargin)
%IDNLHW  Create Hammerstein-Wiener model.
%
%   M = IDNLHW(ORDERS,InputNL,OutputNL)
%
%   M is the created Hammerstein-Wiener (IDNLHW) model.
%   ORDERS = [nb nf nk] are the orders and delays of the linear transfer
%     function equation  x(t) = [B(q)/F(q)] w(t-nk) relating the input x(t)
%     and the output w(t) of the linear subsystem.
%
%   InputNL is the input static nonlinearity G, so that w(t) = G(u(t)),
%     u(t) being the input of the IDNLHW model.
%   OutputNL is the output static nonlinearity H, so that y(t) = H(x(t)),
%     y(t) being the output of the IDNLHW model.
%   InputNL and OutputNL are both implemented by nonlinearity estimator
%   objects, one of: pwlinear, deadzone, saturation, sigmoidnet, poly1d,
%   wavenet, customnet or unitgain. Type "help pwlinear" etc for more
%   details. Type "idprops idnlestimators" for an overview of nonlinearity
%   estimators. These objects have properties that can be set as in:
%
%   M = IDNLHW([2 2 1],sigmoidnet('num',5),deadzone([-1,2]))
%   (SISO model with sigmoid network as input nonlinearity and dead zone as
%   output nonlinearity)
%
%   For default property settings of nonlinearity estimators, (abbreviated)
%   strings can be used as in
%   M = IDNLHW([2 2 1],'sigmoidnet','deadzone') or
%   M = IDNLHW([2 2 1],'sig','dead').
%
%   The estimator unitgain (can also be entered as []) means no
%   nonlinearity. For example:
%   M = IDNLHW([2 2 1],'saturation',[]) % Hammerstein model (only input nonlinearity).
%   M = IDNLHW([2 2 1],[],'saturation') % Wiener model (only output nonlinearity).
%
%   MULTIVARIABLE MODELS:
%   For a multivariate model with nu inputs and ny outputs,
%   nb, nf and nk are ny-by-nu matrices whose (i,j)-th entry specifies the
%   orders and delay of the transfer function from the j-th input to the
%   i-th output. See "help oe" for more information on configuration of
%   these matrices.
%
%   For multivariate models, the nonlinearities (G and H) are applied
%   componentwise. Different nonlinearities can be applied to different
%   channels as in IDNLHW(ORDERS,[sigmoidnet('num',6); pwlinear],[]), which
%   creates a Hammerstein model using sigmoid network and piece-wise linear
%   nonlinearity estimators for the two input channels respectively.
%
%   M = IDNLHW(ORDERS, InputNL, OutputNL, 'Property',Value,..) allows to
%   specify extra property values. See "idprops idnlhw".
%
%   Alternatively, the syntax M = IDNLHW('Property',Value,..) can also
%   be used, where the property-value list should include 'nb', 'nf',
%   'nk', 'InputNonlinearity' and 'OutputNonlinearity'.
%
%   INITIALIZATION WITH A LINEAR MODEL:
%   You can initialize the linear component of the IDNLHW model using a
%   linear model of output-error structure by replacing ORDERS with a
%   linear model. The linear model must be a discrete-time IDPOLY model of
%   Output-Error structure (na=nc=nd=0) or an IDSS model with K=0. For
%   example, M = IDNLHW(LINMOD, 'sigmoidnet', 'saturation') sets the 
%   the orders (nb, nf, nk) as well as the values of properties "b" and "f"
%   of M equal to those of the IDPOLY model LINMOD. Input and output
%   channel names and units, time unit and sampling interval values are
%   also inherited by M from LINMOD. However, algorithm properties are not 
%   inherited. 
%
%   MODEL ESTIMATION:
%   Models created using IDNLHW can be estimated using PEM, as in: 
%       M = IDNLHW([2 2 1],'wavenet','pwlinear');
%       ME = PEM(DATA,M);
%   Note that it is not necessary to create model using IDNLHW explicitly.
%   Estimation of model using NLHW creates an IDNLHW model object
%   automatically. However, you may want to create model separately if it
%   needs to be configured before estimation, such as for specifying
%   initial values of B, F polynomials, setting algorithm properties etc. 
%
%   See also NLHW, IDNLHW/PEM, IDNLARX, IDNLHW/PLOT, IDNLHW/LINEARIZE.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.14 $ $Date: 2009/12/05 02:04:42 $

%   Technology created in colloboration with INRIA and University Joseph
%   Fourier of Grenoble - FRANCE

% Author(s): Qinghua Zhang

superiorto('iddata')
superiorto('idmodel')

ni = nargin;

% First processing the ni==0 cases
if ni==0
    varargin{1} = [1 1 1];
end

pvstart = 1;

varg1 = varargin{1};

if isa(varg1,'idnlhw')
    % Quick exit
    if ni==1
        sys = varg1;
        return
    else
        ctrlMsgUtils.error('Ident:general:useSetForProp','IDNLHW')
    end
end

% Linear Model Extension, Part 1/2 (argument checks)
if isa(varg1, 'idmodel') && ~(isa(varg1, 'idpoly') || isa(varg1, 'idss'))
    ctrlMsgUtils.error('Ident:idnlmodel:IdnlhwLinearModelType')
end
if isa(varg1, 'idpoly') || isa(varg1, 'idss')
    if pvget(varg1, 'Ts')<=0
        ctrlMsgUtils.error('Ident:idnlmodel:NlmodelLinearModelTs','IDNLHW')
    end
end
linmdl = []; % cell array
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
        if all(linmdl{ky}.f==1) && all(linmdl{ky}.a == linmdl{ky}.c)
            linmdl{ky}.f = linmdl{ky}.a(ones(size(linmdl{ky}.b,1),1),:);
            linmdl{ky}.a = 1;
            linmdl{ky}.c = 1;
        end
    end
    varg1 = zeros(nym,num*3);
    for ky=1:nym
        varg1(ky,:) = [linmdl{ky}.nb, linmdl{ky}.nf, linmdl{ky}.nk];
    end
end

nn = varg1;

[~, ncn] = size(nn);
nu = ncn/3;
if isnonnegintmat(nn) && nu==round(nu)
    nb = nn(:,1:nu);
    nf = nn(:, nu+1:2*nu);
    nk = nn(:, 2*nu+1:ncn);
    
    error(nbfkchck(nb,nf,nk))
    pvstart = 4;
elseif ~ischar(nn)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlhwWrongSyntax')
end

if pvstart>1
    if ni==2
        ctrlMsgUtils.error('Ident:idnlmodel:missingYNL')
    end
    
    if ni<2
        unlobj = pwlinear;
    else
        unlobj = varargin{2};
    end
    
    if ni<3
        ynlobj = pwlinear;
        ni = 3; % as if ynlobj was given in arg3 (for PV-pairs checking)
    else
        ynlobj = varargin{3};
    end
end

% Now the value of pvstart is determined

if ~rem(ni-pvstart,2)
    ctrlMsgUtils.error('Ident:idnlmodel:idnlhwWrongSyntax')
end
if ~iscellstr(varargin(pvstart:2:ni))
    ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
end

if pvstart<2 % Model orders not specified by nn
    [nb, msg] = pvsearch('nb', varargin, false, 'idnlhw');
    error(msg)
    
    [nf, msg] = pvsearch('nf', varargin, false, 'idnlhw');
    error(msg)
    
    [nk, msg] = pvsearch('nk', varargin, false, 'idnlhw');
    error(msg)
    
    msg = nbfkchck(nb,nf,nk);
    error(msg)
end

[ny, nu] = size(nb);

% Set to zero entries of nf corresponding to zero nb
nf(nb==0) = 0;


unlind = 0;
ynlind = 0;

if pvstart<3 % nlobj definitions not found yet
    
    % Search for InputNonlinearity
    ind = strmatch('inputnonl', strtrim(lower(varargin(pvstart:2:ni))));
    if isempty(ind)
        ind = strmatch('unonl', strtrim(lower(varargin(pvstart:2:ni))));
    end
    if isempty(ind)
        ind = strmatch('inputnl', strtrim(lower(varargin(pvstart:2:ni))));
    end
    if isempty(ind)
        ind = strmatch('unl', strtrim(lower(varargin(pvstart:2:ni))));
    end
    
    if length(ind)>1
        ctrlMsgUtils.error('Ident:idnlmodel:ambiguousNLSpec','InputNonlinearity')
    elseif length(ind)==1
        unlind =  pvstart-1+ind*2;
        unlobj = varargin{unlind};
    else
        unlobj = 'unitgain'; % Default nonlinearity type.
    end
    
    % Search for OutputNonlinearity
    ind = strmatch('outputnonl', strtrim(lower(varargin(pvstart:2:ni))));
    if isempty(ind)
        ind = strmatch('ynonl', strtrim(lower(varargin(pvstart:2:ni))));
    end
    if isempty(ind)
        ind = strmatch('outputnl', strtrim(lower(varargin(pvstart:2:ni))));
    end
    if isempty(ind)
        ind = strmatch('ynl', strtrim(lower(varargin(pvstart:2:ni))));
    end
    
    if length(ind)>1
        ctrlMsgUtils.error('Ident:idnlmodel:ambiguousNLSpec','OutputNonlinearity')
    elseif length(ind)==1
        ynlind =  pvstart-1+ind*2;
        ynlobj = varargin{ynlind};
    else
        ynlobj = 'unitgain'; % Default nonlinearity type.
    end
end

[unlobj, msg] = nlobjcheck(unlobj, nu, 'Input');
error(msg)

[ynlobj, msg] = nlobjcheck(ynlobj, ny, 'Output');
error(msg)

% Initialize linear parameters memory
% Note: Btail is the tail of B (without the nk leading zeros)
Btail = cell(ny,nu);
F = cell(ny,nu);
for ky=1:ny
    for ku=1:nu
        %     Btail{ky,ku} = ones(1,nb(ky,ku));
        %     F{ky,ku} = ones(1,1+nf(ky,ku));
        Btail{ky,ku} = NaN(1,nb(ky,ku));
        F{ky,ku} = NaN(1,1+nf(ky,ku));
        F{ky,ku}(1) = 1;
    end
end

estinfo = iddef('estimation');
estinfo.InitRandnState = [];
estinfo.EstimationTime = [];

% Create object structure
sys = struct('nk', nk, 'Btail', {Btail}, 'f', {F}, 'ncind', [], ...
    'InputNonlinearity', unlobj, 'OutputNonlinearity', ynlobj, ...
    'InitialState', 'z', 'InitMethod', [], ...
    'Algorithm',  bbalgodef, ...
    'CovarianceMatrix', 'none', ...
    'EstimationInfo', estinfo);

sys.Algorithm.Weighting = eye(ny);

% Create IDNLMODEL parent
nlm = idnlmodel(ny,nu,1);

sys = class(sys,'idnlhw', nlm);

% Finally, set any PV pairs
ind = 1:ni;
if unlind
    % Avoid reset Nonlinearity
    ind([unlind-1, unlind]) = 0;
end
if ynlind
    % Avoid reset Nonlinearity
    ind([ynlind-1, ynlind]) = 0;
end
ind(1:pvstart-1) = 0;
ind = find(ind);

% Process InitialState
[sys, ind] = estimateinitarg(sys, varargin, ind);

if ~isempty(ind)
    try
        set(sys,varargin{ind})
    catch E
        throw(E)
    end
end

% Linear Model Extension, Part 2/2
WRN = ctrlMsgUtils.SuspendWarnings;
if ~isempty(linmdl)
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
    
    % Inherit I-O properties
    
    sys = pvset(sys, 'InputName', pvget(linmod, 'InputName'));
    sys = pvset(sys, 'InputUnit', pvget(linmod, 'InputUnit'));
    sys = pvset(sys, 'OutputName', pvget(linmod, 'OutputName'));
    sys = pvset(sys, 'OutputUnit', pvget(linmod, 'OutputUnit'));
    sys = pvset(sys, 'Ts', pvget(linmod, 'Ts'));
    sys = pvset(sys, 'TimeUnit', pvget(linmod, 'TimeUnit'));
    
    if norm(linmod.InputDelay,1)>0
        ctrlMsgUtils.warning('Ident:idnlmodel:LinearModelDelayIgnored','IDNLHW');
    end
end
delete(WRN)
sys = timemark(sys, 'c');

% Oct2009
% FILE END