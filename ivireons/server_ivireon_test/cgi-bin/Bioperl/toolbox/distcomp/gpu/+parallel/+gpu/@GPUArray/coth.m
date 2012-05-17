function out = coth( in )
%COTH Hyperbolic cotangent of GPUArray
%   Y = COTH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       E = coth(D)
%   
%   See also COTH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:06 $

out = pElementwiseUnaryOp( 'coth', in );
