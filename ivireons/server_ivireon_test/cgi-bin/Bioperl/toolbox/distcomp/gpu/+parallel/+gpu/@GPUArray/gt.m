function out = gt( in1, in2 )
%> Greater than for GPUArray
%   C = A > B
%   C = GT(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       T = D > D-0.5
%       F = D > D
%   
%   returns T = GPUArray.true(N) 
%   and F = GPUArray.false(N).
%   
%   See also GT, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:21 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'gt', in1, in2, '>' );
