function out = cosh( in )
%COSH Hyperbolic cosine of GPUArray
%   Y = COSH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.zeros(N);
%       E = cosh(D)
%   
%   See also COSH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:04 $

out = pElementwiseUnaryOp( 'cosh', in );
