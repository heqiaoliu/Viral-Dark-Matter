function val = getParallelFunctionDepth()
%getParallelFunctionDepth get the current parallel function depth
%
% Get the current parallel function depth.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/01/20 15:33:08 $

% Get the current value by incrementing by zero
val = internal.matlab.incrementParallelFunctionDepth(0);