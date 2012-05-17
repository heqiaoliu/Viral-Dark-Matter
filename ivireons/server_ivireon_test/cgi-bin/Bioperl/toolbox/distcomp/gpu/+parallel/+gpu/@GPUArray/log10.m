function out = log10( in )
%LOG10 Common (base 10) logarithm of GPUArray
%   Y = LOG10(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = 10.^GPUArray.colon(1,N);
%       E = log10(D)
%   
%   See also LOG10, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:30 $

out = pElementwiseUnaryOp( 'log10', in );
