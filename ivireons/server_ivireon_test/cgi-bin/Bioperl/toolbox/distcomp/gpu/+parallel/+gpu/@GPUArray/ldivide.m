function out = ldivide( in1, in2 )
%.\ Left array divide for GPUArray matrix
%   C = A .\ B
%   C = LDIVIDE(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.colon(1, N)'
%       D2 = D1 .\ 1 
%   
%   See also LDIVIDE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:07 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'ldivide', in1, in2, '.\' );
