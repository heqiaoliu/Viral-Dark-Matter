function out = isfinite( in )
%ISFINITE True for finite elements of GPUArray
%   TF = ISFINITE(D)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       T = isfinite(D)
%   
%   returns T = GPUArray.true(size(D)).
%   
%   See also ISFINITE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:25 $

out = pElementwiseUnaryOp( 'isfinite', in );
