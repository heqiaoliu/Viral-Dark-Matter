function out = gammaln( in )
%GAMMALN Logarithm of gamma function of GPUArray
%   Y = GAMMALN(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = gammaln(D)
%   
%   See also GAMMA,  PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:52 $

out = pElementwiseUnaryOp( 'gammaln', in );
