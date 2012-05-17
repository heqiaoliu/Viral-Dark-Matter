function out = sign( in )
%SIGN Signum function for GPUArray
%   Y = SIGN(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.colon(1, N) - ceil(N/2)
%       E = sign(D)
%   
%   See also SIGN, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:51 $

out = pElementwiseUnaryOp( 'sign', in );
