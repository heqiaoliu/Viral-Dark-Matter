function out = sech( in )
%SECH Hyperbolic secant of GPUArray
%   Y = SECH(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.zeros(N);
%       E = sech(D)
%   
%   See also SECH, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:50 $

out = pElementwiseUnaryOp( 'sech', in );
