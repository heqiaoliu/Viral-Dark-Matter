function out = gamma( in )
%GAMMA Gamma function of GPUArray
%   Y = GAMMA(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = gamma(D)
%   
%   See also GAMMALN,  PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:51 $

out = pElementwiseUnaryOp( 'gamma', in );
