function out = log1p( in )
%LOG1P Compute log(1+z) accurately of GPUArray
%   Y = LOG1P(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = eps(1) .* GPUArray.ones(N);
%       E = log1p(D)
%   
%   See also LOG1P, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:31 $

out = pElementwiseUnaryOp( 'log1p', in );
