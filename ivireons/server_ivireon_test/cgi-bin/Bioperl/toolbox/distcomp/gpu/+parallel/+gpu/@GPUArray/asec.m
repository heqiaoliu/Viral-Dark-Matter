function out = asec( in )
%ASEC Inverse secant of GPUArray, result in radians
%   Y = ASEC(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = asec(D)
%   
%   See also ASEC, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:49 $

out = pElementwiseUnaryOp( 'asec', in );
