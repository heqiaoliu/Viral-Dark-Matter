function prev = incrementParallelFunctionDepth( howMuch )
% incrementParallelFunctionDepth - change the depth for parallel_function
%
% This counter allows us to deduce if we are already inside the function
% parallel_function, since there are certain language uses that are not
% allowed in this context.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2009/01/20 15:33:09 $

persistent depth;

if isempty( depth )
    depth = 0;
    mlock;
end

prev = depth;
if howMuch ~= 0
    % Make sure we always increment in integers
    depth = depth + fix( howMuch );
    % Check that we haven't got a negative depth.
    if depth < 0
        depth = 0;
        warning('MATLAB:ParallelFunctionDepth:InvalidDepth', ...
            'Attempt to reduce the depth to less than zero');
    end
end