function obj = true( varargin )
%PARALLEL.GPU.GPUARRAY.TRUE True GPUArray
%   D = PARALLEL.GPU.GPUARRAY.TRUE(N) is an N-by-N GPUArray matrix 
%   of logical ones.
%   
%   D = PARALLEL.GPU.GPUARRAY.TRUE(M,N) is an M-by-N GPUArray matrix
%   of logical ones.
%   
%   D = PARALLEL.GPU.GPUARRAY.TRUE(M,N,P, ...) or PARALLEL.GPU.GPUARRAY.TRUE([M,N,P, ...])
%   is an M-by-N-by-P-by-... GPUArray of logical ones.
%   
%   Examples:
%   import parallel.gpu.GPUArray
%       N  = 1000;
%       D1 = GPUArray.true(N) % 1000-by-1000 true logical GPUArray
%       D2 = GPUArray.true(N, N*2) % 1000-by-2000
%       D3 = GPUArray.true([N, N*2]) % 1000-by-2000
%   
%   See also TRUE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/FALSE, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:28 $

[szVec, ~, E] = parallel.internal.buildFcnArgCheck( 'true', ...
                                                  'parallel:gpu:true', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end
obj = parallel.gpu.GPUArray.hGenericOnes( szVec, 1, 'logical' );
end
