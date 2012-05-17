function out = acosh( in )
%ACOSH Inverse hyperbolic cosine of GPUArray
%   Y = ACOSH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.zeros(N);
%       E = acosh(D)
%   
%   See also ACOSH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:44 $

out = pElementwiseUnaryOp( 'acosh', in );
