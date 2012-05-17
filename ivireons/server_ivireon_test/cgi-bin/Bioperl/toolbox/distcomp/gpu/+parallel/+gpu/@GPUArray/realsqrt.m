function out = realsqrt( in )
%REALSQRT Real square root of GPUArray
%   Y = REALSQRT(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = -4*GPUArray.ones(N)
%       try realsqrt(D), catch, disp('negative input!'), end
%       E = realsqrt(-D)
%   
%   See also REALSQRT, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:45 $

out = pElementwiseUnaryOp( 'realsqrt', in );
