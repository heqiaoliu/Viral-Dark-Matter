function out = bitxor( in1, in2 )
%BITXOR Bit-wise XOR of GPUArray
%   C = BITXOR(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitxor(D1,D2)
%   
%   See also BITXOR, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:00 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'bitxor', in1, in2 );
