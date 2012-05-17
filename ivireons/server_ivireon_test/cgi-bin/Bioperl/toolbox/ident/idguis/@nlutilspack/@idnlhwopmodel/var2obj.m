function allpar = var2obj(this, x)
%VAR2OBJ updates parameters in OperPoint property using the lastest values
%of estimated subset from input x.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:22 $

% Check that the function is called with two arguments.
nin = nargin;
error(nargchk(2, 2, nin, 'struct'));
x = x(:)';
op = this.OperPoint;
u0 = op.Input;
u0.Value(~u0.Known) = x; %only free inputs are optim parameters
allpar              = u0.Value;
