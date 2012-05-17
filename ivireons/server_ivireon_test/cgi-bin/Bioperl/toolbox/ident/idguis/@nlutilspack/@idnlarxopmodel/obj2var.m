function var = obj2var(this, varargin)
%OBJ2VAR  Serializes estimated parameter/state object data into estimation
%   variable data for optimizers.

%   Written by: Rajiv Singh
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:16:07 $

% Check that the function is called with one or two arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

op = this.OperPoint;
u0 = op.Input;
y0 = op.Output;

% optimization parameters are all channels that are free to vary (Known =
% false) 
par =  [y0.Value, u0.Value(~u0.Known)]; %all y are optim pars
lb  =  [y0.Min,   u0.Min(~u0.Known)];
ub  =  [y0.Max,   u0.Max(~u0.Known)];

% Return free parameter information structure.
var = struct('Value', par,  ...
             'Minimum', lb, ...
             'Maximum', ub  ...
            );
   