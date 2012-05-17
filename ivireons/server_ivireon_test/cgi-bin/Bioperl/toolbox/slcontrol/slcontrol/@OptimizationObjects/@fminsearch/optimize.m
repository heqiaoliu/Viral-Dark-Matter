function [oppoint,opreport,exitflag,output] = optimize(this)
% OPTIMIZE

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2007/10/15 23:31:40 $

% Construct the inputs to the optimizer
X = [this.x0(this.indx);this.u0(this.indu)];

% Call the optimizer 
[X,fval,exitflag,output] = fminsearch(@LocalFunctionEval,X,...
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

% Compute the errors in the constraints
F = norm([this.F_dx(:); this.F_y(:); this.F_const(:)]);
G = [];