function out = csch( in )
%CSCH Hyperbolic cosecant of GPUArray
%   Y = CSCH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       E = csch(D)
%   
%   See also CSCH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:08 $

out = pElementwiseUnaryOp( 'csch', in );
