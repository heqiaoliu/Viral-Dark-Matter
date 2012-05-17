function out = exp( in )
%EXP Exponential of GPUArray
%   Y = EXP(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = exp(D)
%   
%   See also EXP, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:14 $

out = pElementwiseUnaryOp( 'exp', in );
