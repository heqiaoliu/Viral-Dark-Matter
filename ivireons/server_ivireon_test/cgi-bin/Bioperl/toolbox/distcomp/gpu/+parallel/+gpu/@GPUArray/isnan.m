function out = isnan( in )
%ISNAN True for Not-a-Number elements of GPUArray
%   TF = ISNAN(D)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.nan(N);
%       T = isnan(D)
%   
%   returns T = GPUArray.true(size(D)).
%   
%   See also ISNAN, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/NAN.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:27 $

out = pElementwiseUnaryOp( 'isnan', in );
