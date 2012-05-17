function out = acsc( in )
%ACSC Inverse cosecant of GPUArray, result in radian
%   Y = ACSC(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = acsc(D)
%   
%   See also ACSC, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:47 $

out = pElementwiseUnaryOp( 'acsc', in );
