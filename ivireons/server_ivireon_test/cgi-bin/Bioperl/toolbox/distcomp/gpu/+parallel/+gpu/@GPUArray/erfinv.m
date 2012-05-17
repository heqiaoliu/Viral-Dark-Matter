function out = erfinv( in )
%ERFINV Inverse error function of GPUArray
%   Y = ERFINV(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = erfinv(D)
%   
%   See also ERF, ERFC, ERFCINV,  PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:46 $

out = pElementwiseUnaryOp( 'erfinv', in );
