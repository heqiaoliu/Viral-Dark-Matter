function out = minus( in1, in2 )
%- Minus for GPUArray
%   C = A - B
%   C = MINUS(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.ones(N);
%       D2 = 2*D1
%       D3 = D1 - D2
%   
%   See also MINUS, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:35 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'minus', in1, in2, '-' );
