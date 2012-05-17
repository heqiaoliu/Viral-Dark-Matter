function out = atanh( in )
%ATANH Inverse hyperbolic tangent of GPUArray
%   Y = ATANH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = atanh(D)
%   
%   See also ATANH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:55 $

out = pElementwiseUnaryOp( 'atanh', in );
