function out = hypot( in1, in2 )
%HYPOT Robust computation of square root of sum of squares for GPUArray
%   C = HYPOT(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = 3e300*GPUArray.ones(N);
%       D2 = 4e300*GPUArray.ones(N);
%       E = hypot(D1,D2)
%   
%   See also HYPOT, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:22 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'hypot', in1, in2 );
