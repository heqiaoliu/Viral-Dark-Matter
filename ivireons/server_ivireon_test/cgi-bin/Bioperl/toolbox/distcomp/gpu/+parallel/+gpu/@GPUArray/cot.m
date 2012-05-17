function out = cot( in )
%COT Cotangent of GPUArray in radians
%   Y = COT(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = cot(D)
%   
%   See also COT, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:05 $

out = pElementwiseUnaryOp( 'cot', in );
