function out = ge( in1, in2 )
%>= Greater than or equal for GPUArray
%   C = A >= B
%   C = GE(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       T = D >= D
%       F = D >= D+0.5
%   
%   returns T = GPUArray.true(N)
%   and F = GPUArray.false(N).
%   
%   See also GE, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:20 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'ge', in1, in2, '>=' );
