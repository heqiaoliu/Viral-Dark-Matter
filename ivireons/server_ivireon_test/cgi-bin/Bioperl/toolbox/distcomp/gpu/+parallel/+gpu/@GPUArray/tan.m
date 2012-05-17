function out = tan( in )
%TAN Tangent of GPUArray in radians
%   Y = TAN(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = pi/4*GPUArray.ones(N);
%       E = tan(D)
%   
%   See also TAN, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:58 $

out = pElementwiseUnaryOp( 'tan', in );
