function out = rdivide( in1, in2 )
%./ Right array divide for GPUArray matrix
%   C = A ./ B
%   C = RDIVIDE(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.colon(1, N)'
%       D2 = 1 ./ D1
%   
%   See also RDIVIDE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:42 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'rdivide', in1, in2, './' );
