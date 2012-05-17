function UpdateErrors(this,X)
% UPDATEERRORS

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2007/10/15 23:31:36 $

% Partition the state and input vectors
x = this.x0;
x(this.indx) = X(1:length(this.indx));
u = this.u0;
u(this.indu) = X(length(this.indx)+1:end);

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

% Store the algebraic constraints
this.computeAlgConstraints;