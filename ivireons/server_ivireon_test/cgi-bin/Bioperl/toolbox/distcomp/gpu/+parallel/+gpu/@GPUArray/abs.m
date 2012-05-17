function out = abs( in )
%ABS Absolute value of GPUArray
%   Y = ABS(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = -3*GPUArray.ones(N)
%       absD = abs(D)
%   
%   
%   See also ABS, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:42 $

out = pElementwiseUnaryOp( 'abs', in );
