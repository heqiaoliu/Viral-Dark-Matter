function out = round( in )
%ROUND Round towards nearest integer for GPUArray
%   Y = ROUND(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.colon(1, N)./2
%       E = round(D)
%   
%   See also ROUND, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:48 $

out = pElementwiseUnaryOp( 'round', in );
