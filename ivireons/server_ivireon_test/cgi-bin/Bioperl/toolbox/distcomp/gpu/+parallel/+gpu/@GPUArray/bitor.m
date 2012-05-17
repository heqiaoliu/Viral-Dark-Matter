function out = bitor( in1, in2 )
%BITOR Bit-wise OR of GPUArray
%   C = BITOR(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.ones(N,'uint32');
%       D2 = triu(D1);
%       D3 = bitor(D1,D2)
%   
%   See also BITOR, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:58 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'bitor', in1, in2 );
