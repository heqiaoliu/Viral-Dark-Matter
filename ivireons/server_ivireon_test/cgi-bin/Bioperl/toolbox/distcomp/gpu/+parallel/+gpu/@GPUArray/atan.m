function out = atan( in )
%ATAN Inverse tangent of GPUArray, result in radians
%   Y = ATAN(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = atan(D)
%   
%   See also ATAN, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:53 $

out = pElementwiseUnaryOp( 'atan', in );
