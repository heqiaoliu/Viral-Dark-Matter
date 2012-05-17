function out = acot( in )
%ACOT Inverse cotangent of GPUArray, result in radians
%   Y = ACOT(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = acot(D)
%   
%   See also ACOT, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:45 $

out = pElementwiseUnaryOp( 'acot', in );
