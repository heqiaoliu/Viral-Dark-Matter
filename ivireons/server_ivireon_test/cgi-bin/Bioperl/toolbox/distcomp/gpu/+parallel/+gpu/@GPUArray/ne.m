function out = ne( in1, in2 )
%~= Not equal for GPUArray
%   C = A ~= B
%   C = NE(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       F = D ~= D
%       T = D ~= D'
%   
%   returns F = GPUArray.false(N) and T is probably the same as
%   GPUArray.true(N), but with the main diagonal all false
%   values.
%   
%   See also NE, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:39 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'ne', in1, in2, '~=' );
