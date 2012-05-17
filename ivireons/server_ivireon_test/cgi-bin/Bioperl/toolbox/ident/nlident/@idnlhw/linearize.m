function sys = linearize(nlsys,u0,x0)
%LINEARIZE Linearize Hammerstein-Wiener (IDNLHW) model.
%
% SYS = LINEARIZE(NLSYS, U0) linearizes the IDNLHW model about equilibrium
% input values U0.
%
% SYS = LINEARIZE(NLSYS, U0, X0) linearizes the IDNLHW model NLSYS about
% the operating point specified by input (U0) and state (X0) values. To
% determine U0 and X0 values from specifications, use commands such as
% FINDOP and FINDSTATES.
%
% SYS is returned as an LTI object of Control System Toolbox(TM) if that
% toolbox is available. Otherwise, SYS is returned as an IDSS model of
% System Identification Toolbox(TM).
%
% LINEARIZE provides a linear model that is the best linear approximation
% for inputs that vary in a small neighbourhood of a constant input u(t) =
% U. This is the common linearization based on function expansion (also
% known as tangent linearization). For linear approximations over larger
% input ranges, it might be better to use the LINAPP command.
%
% See also IDNLHW/LINAPP, IDNLHW/FINDOP, IDNLHW/OPERSPEC,
% IDNLHW/FINDSTATES, IDNLARX/LINEARIZE.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2009/10/16 04:57:03 $

error(nargchk(2, 3, nargin,'struct'))

% Model size
[ny,nu] = size(nlsys);

if ~isestimated(nlsys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','linearize','nlhw')
end

[u0,msg] = LocalValidateData(u0,nu,'input');
error(msg)

[A,B,C,D] = ssdata(getlinmod(nlsys));
Nx = size(A,1);
AIB = pinv(eye(Nx)-A)*B;
%TFun = C*AIB+D;
UNL = nlsys.InputNonlinearity;
YNL = nlsys.OutputNonlinearity;

% Derivative of input nonlinearity
ulin = zeros(nu,1);
dunl = zeros(nu,1);
for ku = 1:nu
    [ulin(ku), dum, dunl(ku)] = getJacobian(UNL(ku),u0(ku),false);
end

if nargin<3
    x0 = AIB*ulin;
else
    [x0, msg] = LocalValidateData(x0,Nx,'states');
    error(msg)
end

% Output of linear model
ylin = C*x0+D*ulin;

% Derivative of output nonlinearity
y = zeros(ny,1);
dynl = zeros(ny,1);
for ky = 1:ny
    [y(ky), dum, dynl(ky)] = getJacobian(YNL(ky),ylin(ky),false);
end

Bnew = B*diag(dunl);
Cnew = diag(dynl)*C;
Dnew = diag(dynl)*D*diag(dunl);
cstbinstalled = iscstbinstalled;
Ts = pvget(nlsys,'Ts');
Nam = inputname(1);
if isempty(Nam)
    Notes = sprintf('Obtained by linearization of IDNLHW model on %s.',datestr(clock));
else
    Notes = sprintf('Obtained by linearization of IDNLHW model ''%s'' on %s.',...
        Nam,datestr(clock));
end

commonPV = {'InputName',pvget(nlsys,'InputName'),...
    'OutputName',pvget(nlsys,'OutputName'),...
    'Name',pvget(nlsys,'Name'),'Notes',Notes};

idmodelPV =   {'InputUnit',pvget(nlsys,'InputUnit'),...
    'OutputUnit',pvget(nlsys,'OutputUnit')};

if cstbinstalled
    sys = ss(A,Bnew,Cnew,Dnew,Ts,commonPV{:});
else
    sys = idss(A,Bnew,Cnew,Dnew,zeros(Nx,ny),x0,Ts,commonPV{:},idmodelPV{:});
end

%--------------------------------------------------------------------------
function [x,msg] = LocalValidateData(x,nx,Type)
% validate data u0 and x0 provided by user

msg = struct([]);
if ~isrealvec(x) || ~isequal(length(x),nx) || any(~isfinite(x))
    if strcmp(Type,'input')
        msg = sprintf('In the "linearize(NLSYS, U0,...)" command, U0 must be specified as a real, finite vector of length %d.',nx);
        msg = struct('identifier','Ident:transformation:linearizeInvalidInput','message',msg);
    else
        msg = sprintf('In the "linearize(NLSYS, U0, X0)" command, X0 must be specified as a real, finite vector of length %d.',nx);
        msg = struct('identifier','Ident:transformation:linearizeInvalidStates','message',msg);
    end
    return
else
    x = x(:);
end
