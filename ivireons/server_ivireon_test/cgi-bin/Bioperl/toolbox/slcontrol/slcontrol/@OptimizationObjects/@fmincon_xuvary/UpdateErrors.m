function UpdateErrors(this,X)
% UPDATEERRORS

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/04/30 00:43:51 $

% Create the state and input vectors
x = X(1:length(this.x0));
u = X(length(this.x0)+1:end);

% Populate the state structure
xstruct = setx(this,x);

% Compute with the output constraint deviations
y = getOutputs(this.opcond,xstruct,u);
F_y = zeros(length(y),1);
F_y(this.iy) = y(this.iy) - this.y0(this.iy);
F_y(this.indy) = -max([y(this.indy)-this.uby(this.indy),...
                         this.lby(this.indy)-y(this.indy),...
                         zeros(length(this.indy),1)],[],2);
this.F_y = F_y;

% Store the error in the derivates and updates that are constrained to be
% zero.
dxstruct = getDerivs(slcontrol.Utilities,this.model,this.t,xstruct,u);
dx = simulinkStructToVector(slcontrol.Utilities,dxstruct);
this.F_dx = dx(this.idx);

% Compute the errors in x and u
if ~isempty([this.ix(:);this.iu(:)])
    this.F_x = x(this.ix)-this.x0(this.ix);
    this.F_u = u(this.iu)-this.u0(this.iu);
else
    this.F_x = x - this.x0(:);
    this.F_u = u - this.u0(:);
end

% Store the algebraic constraints
this.computeAlgConstraints;