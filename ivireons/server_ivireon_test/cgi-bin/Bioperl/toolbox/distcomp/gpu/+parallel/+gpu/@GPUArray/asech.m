function out = asech( in )
%ASECH Inverse hyperbolic secant of GPUArray
%   Y = ASECH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       E = asech(D)
%   
%   See also ASECH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:50 $

out = pElementwiseUnaryOp( 'asech', in );
