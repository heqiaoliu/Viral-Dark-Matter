function obj = gpuArray( data )
%gpuArray create array on the GPU
%   G = gpuArray( X ) copies the numeric data X to the GPU. The resulting object
%   G is of class parallel.gpu.GPUArray. This data can be operated on by passing
%   it to the FEVAL method of parallel.gpu.CUDAKernel objects, or by using one of
%   the methods defined for GPUArray objects.
%
%   The MATLAB data X must be numeric (for example: single, double, int8 etc.)
%   or logical, and the GPU device must have sufficient free memory to store the
%   data. X must be full.
%
%   Example:
%   X = rand( 10, 'single' );
%   G = gpuArray( X );
%   isequal( gather( G ), X )  % returns true
%   classUnderlying( G )       % returns 'single'
%   G2 = G .* G                % use "times" method defined for GPUArray objects
%
%   See also parallel.gpu.GPUArray, parallel.gpu.CUDAKernel, gpuDevice

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:24:36 $

try
    obj = parallel.gpu.GPUArray( data );
catch E
    % strip the stack
    throw( E )
end
end
