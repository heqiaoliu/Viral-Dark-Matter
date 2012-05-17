function out = power( in1, in2 )
%.^ Array power for GPUArray
%   C = A .^ B
%   C = POWER(A,B)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = 2*GPUArray.eye(N);
%       D2 = D1 .^ 2
%   
%   See also POWER, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/EYE.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:09:41 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'power', in1, in2, '.^' );
