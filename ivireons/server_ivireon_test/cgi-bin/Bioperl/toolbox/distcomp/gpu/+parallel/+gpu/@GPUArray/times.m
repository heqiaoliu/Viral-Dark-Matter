function out = times( in1, in2 )
%.* GPUArray multiply
%   C = A .* B
%   C = TIMES(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.eye(N);
%       D2 = GPUArray(rand(N));
%       D3 = D1 .* D2
%   
%   See also TIMES, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:10:00 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'times', in1, in2, '.*' );
