function out = sin( in )
%SIN Sine of GPUArray in radians
%   Y = SIN(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = pi/2*GPUArray.ones(N);
%       E = sin(D)
%   
%   See also SIN, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:52 $

out = pElementwiseUnaryOp( 'sin', in );
