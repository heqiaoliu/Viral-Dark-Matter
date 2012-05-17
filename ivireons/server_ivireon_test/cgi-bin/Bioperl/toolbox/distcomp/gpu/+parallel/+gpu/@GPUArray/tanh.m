function out = tanh( in )
%TANH Hyperbolic tangent of GPUArray
%   Y = TANH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       E = tanh(D)
%   
%   See also TANH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:59 $

out = pElementwiseUnaryOp( 'tanh', in );
