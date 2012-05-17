function allpar = var2obj(this, x)
%VAR2OBJ updates parameters in OperpOint property using the lastest values
%of estimated subset from input x.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:09 $

% Check that the function is called with two arguments.
nin = nargin;
error(nargchk(2, 2, nin, 'struct'));
x = x(:)';
op = this.OperPoint;
u0 = op.Input;
y0 = op.Output;
ny = length(y0.Value);
y0.Value = x(1:ny); %all y are optim pars
u0.Value(~u0.Known) = x(ny+1:end);
allpar              = [y0.Value,u0.Value];
