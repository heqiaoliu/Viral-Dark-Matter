function out = expm1( in )
%EXPM1 Compute exp(z)-1 accurately for GPUArray
%   Y = EXPM1(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = eps(1) .* GPUArray.ones(N);
%       E = expm1(D)
%   
%   See also EXPM1, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:15 $

out = pElementwiseUnaryOp( 'expm1', in );
