function out = asin( in )
%ASIN Inverse sine of GPUArray, result in radians
%   Y = ASIN(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = asin(D)
%   
%   See also ASIN, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:51 $

out = pElementwiseUnaryOp( 'asin', in );
