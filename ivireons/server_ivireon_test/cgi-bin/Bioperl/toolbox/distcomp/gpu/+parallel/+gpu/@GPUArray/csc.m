function out = csc( in )
%CSC Cosecant of GPUArray in radians
%   Y = CSC(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = csc(D)
%   
%   See also CSC, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:07 $

out = pElementwiseUnaryOp( 'csc', in );
