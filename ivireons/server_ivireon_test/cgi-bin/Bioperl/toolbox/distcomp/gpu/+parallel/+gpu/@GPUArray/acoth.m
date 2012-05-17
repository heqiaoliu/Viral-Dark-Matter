function out = acoth( in )
%ACOTH Inverse hyperbolic cotangent of GPUArray
%   Y = ACOTH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       E = acoth(D)
%   
%   See also ACOTH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:46 $

out = pElementwiseUnaryOp( 'acoth', in );
