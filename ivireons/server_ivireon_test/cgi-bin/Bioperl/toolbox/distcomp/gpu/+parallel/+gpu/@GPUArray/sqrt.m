function out = sqrt( in )
%SQRT Square root of GPUArray
%   Y = SQRT(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = -GPUArray.ones(N)
%       E = sqrt(D)
%   
%   See also SQRT, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:55 $

out = pElementwiseUnaryOp( 'sqrt', in );
