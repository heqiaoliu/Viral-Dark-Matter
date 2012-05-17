function out = sinh( in )
%SINH Hyperbolic sine of GPUArray
%   Y = SINH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       E = sinh(D)
%   
%   See also SINH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:53 $

out = pElementwiseUnaryOp( 'sinh', in );
