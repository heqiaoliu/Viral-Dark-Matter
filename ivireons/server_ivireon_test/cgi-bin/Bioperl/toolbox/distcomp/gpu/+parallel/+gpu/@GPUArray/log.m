function out = log( in )
%LOG Natural logarithm of GPUArray
%   Y = LOG(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = log(D)
%   
%   See also LOG, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:29 $

out = pElementwiseUnaryOp( 'log', in );
