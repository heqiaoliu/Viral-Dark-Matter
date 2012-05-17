function [linsys, ybar] = lintan(nlsys,u0)
%LINTAN Tangent linearization of IDNLHW models.
%This function is now obsolete. Use LINEARIZE instead.

% Old help content:
%   LM = LINTAN(NLMODEL)
%   LM = LINTAN(NLMODEL,U)
%
%   NLMODEL: the nonlinear model to be linearized, an IDNLHW object.
%   LM: the linearized model, an IDPOLY object for single output model,
%          or an IDSS object for multi-output model. The linearization is
%          carried out around an equilibrium point, such that the
%          output from NLMODEL is a constant Y if the input is a constant U
%          (after the transient).
%   U:     The equilibrium is determined for the constant input U (A vector
%          of the same dimension as the input to NLMODEL). Default U = 0.
%
%   LINTAN provides a linear model that is the best linear approximation
%   for inputs that vary in a small (infinitesemal) neighbourhood of a
%   constant input u(t) = U. This is the common linearization based on
%   function expansion. For linear approximations that should reasonable
%   over larger input ranges, it might be better to use the command LINAPP.
%
%   See also LINAPP.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:54:15 $

% Author(s): Qinghua Zhang

ctrlMsgUtils.warning('Ident:utility:lintanObsolete')

%{
[ny,nu]=size(nlsys);
varg = varargin;
if nargin<2
    varg = {zeros(1,nu)};
end

linsys = linearize(nlsys,varg{:});

if nargout>1
    if nargin<2
        model = varargin{1};
        u0 = zeros(1,size(model,'nu'));
    else
        u0 = varargin{2};
    end
    ybar = getJacobian(model,u0);
end
%}

nin=nargin;
error(nargchk(1,2, nin,'struct'));

if ~isa(nlsys, 'idnlhw')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','lintan','IDNLHW')
end

if ~isestimated(nlsys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','lintan','nlhw')
end

[ny, nu] = size(nlsys);

if nin<2 || isempty(u0)
    u0 = zeros(nu,1);
else
    u0 = u0(:);
end

linsys = getlinmod(nlsys);
linsys = idss(linsys);
ut = pvget(linsys, 'Utility');
if isfield(ut,'Idpoly')
    ut = rmfield(ut,'Idpoly');
end
linsys = pvset(linsys, 'Utility', ut);

Alin = pvget(linsys, 'A');
Blin = pvget(linsys, 'B');
Clin = pvget(linsys, 'C');
Dlin = pvget(linsys, 'D');
nx = size(Alin,1);

inmdl = pvget(nlsys, 'InputNonlinearity');
outmdl = pvget(nlsys, 'OutputNonlinearity');

% Process input model
if length(u0)~=nu
    ctrlMsgUtils.error('Ident:analysis:lintanDimU','lintan(NLMODEL, U)')
end

f0 = zeros(nu,1); % v0, input of the linear block
f1 = zeros(nu,1);
for ku=1:nu
    if ~isdifferentiable(inmdl(ku))
        ctrlMsgUtils.error('Ident:analysis:lintan2',...
            upper(class(inmdl(ku))),'linearize')
    end
    
    [fval0, dum, deri0] = getJacobian(inmdl(ku), u0(ku));
    f0(ku) = fval0;
    f1(ku) = deri0;
end

x0 = pinv(eye(nx)-Alin)*(Blin*f0); % State value for equilibrium point
w0 = Clin*x0 + Dlin*f0;            % output of the linear block

% Process output model
g0 = zeros(ny,1); % y0
g1 = zeros(ny,1);
for ky=1:ny
    if ~isdifferentiable(outmdl(ky))
        ctrlMsgUtils.error('Ident:analysis:lintan2',...
            upper(class(outmdl(ky))),'linearize')
    end
    [fval0, dum, deri0] = getJacobian(outmdl(ky), w0(ky));
    g0(ky) = fval0;
    g1(ky) = deri0;
end

ybar = g0;

Btan = Blin*diag(f1);
Ctan = diag(g1)*Clin;
Dtan = diag(g1)*Dlin*diag(f1);

udrift = Blin*(f0 - f1.*u0);
ydrift = g0 - diag(g1)*(Clin*x0 + Dlin*(f1.*u0));

% Use the linsys object for the linearized model
% Atan = Alin, no need to update.
linsys = pvset(linsys, 'B', Btan, 'C', Ctan, 'D', Dtan);

if ny==1
    wstate = warning('off');
    linsys = idpoly(linsys);
    warning(wstate);
end

% Mark Utility
ut = pvget(linsys, 'Utility');
ut.udrift = udrift;
ut.ydrift = ydrift;
linsys = pvset(linsys, 'Utility', ut);

%Copy properties
Ts = pvget(nlsys, 'Ts');
tunit = pvget(nlsys, 'TimeUnit');
iname = pvget(nlsys, 'InputName');
iunit = pvget(nlsys, 'InputUnit');
oname = pvget(nlsys, 'OutputName');
ounit = pvget(nlsys, 'OutputUnit');

linsys = pvset(linsys, 'Ts', Ts, 'TimeUnit', tunit, 'InputName', iname, ...
    'InputUnit', iunit, 'OutputName', oname, 'OutputUnit', ounit);

iargnanme = inputname(1);
if isempty(iargnanme)
    linsys = pvset(linsys, 'Notes', 'Tangent linearization of an IDNLHW model');
else
    linsys = pvset(linsys, 'Notes', ['Tangent linearization of ', iargnanme]);
end

% FILE END
