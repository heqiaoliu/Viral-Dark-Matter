function out = isinf( in )
%ISINF True for infinite elements of GPUArray
%   TF = ISINF(D)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.inf(N);
%       T = isinf(D)
%   
%   returns T = GPUArray.true(size(D)).
%   
%   See also ISINF, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/INF.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:26 $

out = pElementwiseUnaryOp( 'isinf', in );
