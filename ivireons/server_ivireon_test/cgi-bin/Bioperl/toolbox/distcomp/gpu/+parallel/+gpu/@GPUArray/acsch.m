function out = acsch( in )
%ACSCH Inverse hyperbolic cosecant of GPUArray
%   Y = ACSCH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       E = acsch(D)
%   
%   See also ACSCH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:48 $

out = pElementwiseUnaryOp( 'acsch', in );
