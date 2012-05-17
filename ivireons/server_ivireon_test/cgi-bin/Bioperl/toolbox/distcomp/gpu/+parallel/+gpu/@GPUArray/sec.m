function out = sec( in )
%SEC Secant of GPUArray in radians
%   Y = SEC(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.zeros(N);
%       E = sec(D)
%   
%   See also SEC, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:49 $

out = pElementwiseUnaryOp( 'sec', in );
