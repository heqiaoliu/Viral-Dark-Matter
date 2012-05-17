function [oppoint,opreport,exitflag,output] = optimize(this)

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.11 $ $Date: 2008/05/20 00:31:25 $

% Construct the inputs to the optimizer
X = [this.x0(this.indx);this.u0(this.indu)];
LB = [this.lbx(this.indx);this.lbu(this.indu)];
UB = [this.ubx(this.indx);this.ubu(this.indu)];

if ~isempty(feval(this.model,[],[],[],'constraints')) && ...
    strcmp(this.linoptions.OptimizationOptions.Jacobian,'on')
    ctrlMsgUtils.error('Slcontrol:findop:AnalyticJacobianConstraintNotAllowed', this.model)
end

% Call the optimizer 
[X,resnorm,residual,exitflag,output] = lsqnonlin(@LocalFunctionEval,X,LB,UB,...
                                         this.linoptions.OptimizationOptions,this);

x = this.x0;
x(this.indx) = X(1:length(this.indx));

u = this.u0;
u(this.indu) = X(length(this.indx)+1:end);

% Populate the state structure
xstruct = setx(this,x);

% Compute the results
[oppoint,opreport] = computeresults(this,xstruct,u);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F,G] = LocalFunctionEval(X,this)

% Compute the errors in the constraints
UpdateErrors(this,X);

% Compute the cost functions
F = [this.F_dx(:); this.F_y(:); this.F_const(:)];
% Compute the Jacobian if needed.
if nargout > 1
    G = LocalComputeGradient(this);
else
    G = [];
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = LocalComputeGradient(this)

% Compute the gradient exactly using the Jacobian of the model
[A,B,C,D] = sortJacobian(this);

G = full([A(this.idx,this.indx), B(this.idx,this.indu);...
            C(:,this.indx), D(:,this.indu)]);
