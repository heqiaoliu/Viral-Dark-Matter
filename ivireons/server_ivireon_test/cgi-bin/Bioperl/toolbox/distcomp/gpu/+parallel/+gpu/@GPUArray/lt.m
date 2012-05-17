function out = lt( in1, in2 )
%< Less than for GPUArray
%   C = A < B
%   C = LT(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       T = D < D+0.5
%       F = D < D
%   
%   returns T = GPUArray.true(N)
%   and F = GPUArray.false(N).
%   
%   See also LT, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:33 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'lt', in1, in2, '<' );
