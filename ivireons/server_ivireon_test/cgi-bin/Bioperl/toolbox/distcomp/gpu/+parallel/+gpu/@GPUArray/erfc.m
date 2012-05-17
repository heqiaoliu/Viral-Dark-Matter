function out = erfc( in )
%ERFC Complementary error function of GPUArray
%   Y = ERFC(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = erfc(D)
%   
%   See also ERF, ERFINV, ERFCINV, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.
%   
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:44 $

out = pElementwiseUnaryOp( 'erfc', in );
