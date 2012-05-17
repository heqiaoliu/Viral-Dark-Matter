function out = log2( in )
%LOG2 Base 2 logarithm and dissect floating point number of GPUArray
%   Y = LOG2(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = 2.^GPUArray.colon(1, N);
%       E = log2(D)
%   
%   See also LOG2, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:32 $

out = pElementwiseUnaryOp( 'log2', in );
