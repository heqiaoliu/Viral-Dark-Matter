function out = uplus( in )
%+ Unary plus for GPUArray
%   B = +A
%   B = UPLUS(A)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.eye(N);
%       D2 = +D1
%   
%   See also UPLUS, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:10:05 $

out = pElementwiseUnaryOp( 'uplus', in, '+' );
