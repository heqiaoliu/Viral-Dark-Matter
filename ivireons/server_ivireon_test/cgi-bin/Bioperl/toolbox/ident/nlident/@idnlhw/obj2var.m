function var = obj2var(sys,varargin)
% OBJ2VAR Serializes estimated parameter/state object data into estimation
% variable data for optimizers.
% Returns a struct containing a list of free entities along with their
% bounds.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/11/09 20:19:55 $

% Author(s): Qinghua Zhang

var = struct('Value', getParameterVector(sys), ...
             'Minimum', [], ....
             'Maximum', []);
lp = length(var.Value);
var.Minimum = -inf(lp,1);
var.Maximum = inf(lp,1);

% FILE END