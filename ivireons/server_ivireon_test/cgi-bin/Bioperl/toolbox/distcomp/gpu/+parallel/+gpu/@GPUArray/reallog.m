function out = reallog( in )
%REALLOG Real logarithm of GPUArray
%   Y = REALLOG(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = -exp(1)*GPUArray.ones(N)
%       try reallog(D), catch, disp('negative input!'), end
%       E = reallog(-D)
%   
%   See also REALLOG, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:43 $

out = pElementwiseUnaryOp( 'reallog', in );
