function out = cos( in )
%COS Cosine of GPUArray in radians
%   Y = COS(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.zeros(N);
%       E = cos(D)
%   
%   See also COS, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:03 $

out = pElementwiseUnaryOp( 'cos', in );
