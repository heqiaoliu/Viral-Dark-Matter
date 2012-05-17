function out = acos( in )
%ACOS Inverse cosine of GPUArray, result in radians
%   Y = ACOS(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.zeros(N);
%       E = acos(D)
%   
%   See also ACOS, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:43 $

out = pElementwiseUnaryOp( 'acos', in );
