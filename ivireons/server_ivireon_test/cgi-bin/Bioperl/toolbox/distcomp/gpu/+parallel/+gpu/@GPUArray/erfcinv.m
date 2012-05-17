function out = erfcinv( in )
%ERFCINV Inverse complementary error function of GPUArray
%   Y = ERFCINV(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = erfcinv(D)
%   
%   See also ERF, ERFC, ERFINV, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:45 $

out = pElementwiseUnaryOp( 'erfcinv', in );
