function out = atan2( in1, in2 )
%ATAN2 Four quadrant inverse tangent of GPUArray
%   Z = ATAN2(Y,X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.ones(N);
%       E = atan2(D,D)
%   
%   See also ATAN2, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/05/10 17:08:54 $

error( nargchk( 2, 2, nargin, 'struct' ) );
out = pElementwiseBinaryOp( 'atan2', in1, in2 );
