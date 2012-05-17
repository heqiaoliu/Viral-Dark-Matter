%GPUArray create data on the GPU
%   G = parallel.gpu.GPUArray( x ) copies the numeric data X to the GPU. The
%   resulting object G is of class parallel.gpu.GPUArray. This data can be operated
%   on by passing it to the FEVAL method of parallel.gpu.CUDAKernel objects, or by
%   using one of the methods defined for GPUArray objects.
%   
%   The MATLAB data X must be numeric (for example: single, double, int8 etc.)
%   or logical, and the GPU device must have sufficient free memory to store the
%   data. X must be full.
%   
%   Example:
%   X = rand( 10, 'single' );
%   G = parallel.gpu.GPUArray( X );
%   isequal( gather( G ), X )  % returns true
%   classUnderlying( G )       % returns 'single'
%   G2 = G .* G                % use "times" method defined for GPUArray objects
%   
%   See also GPUARRAY
%   


%   Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:41 $
