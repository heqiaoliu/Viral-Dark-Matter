function out = fix( in )
%FIX Round GPUArray towards zero
%   Y = FIX(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.colon(1,N)./2
%       E = fix(D)
%   
%   See also FIX, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:18 $

out = pElementwiseUnaryOp( 'fix', in );
