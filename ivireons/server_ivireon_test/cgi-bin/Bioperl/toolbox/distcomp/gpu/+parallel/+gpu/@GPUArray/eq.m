function out = eq( in1, in2 )
%== Equal for GPUArray
%   C = A == B
%   C = EQ(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       T = D == D
%       F = D == D'
%   
%   returns T = GPUArray.true(N) and F is probably the same as
%   logical(GPUArray.eye(N)).
%   
%   See also EQ, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:13 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'eq', in1, in2, '==' );
