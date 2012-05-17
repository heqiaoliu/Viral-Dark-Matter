function out = asinh( in )
%ASINH Inverse hyperbolic sine of GPUArray
%   Y = ASINH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.zeros(N);
%       E = asinh(D)
%   
%   See also ASINH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:52 $

out = pElementwiseUnaryOp( 'asinh', in );
