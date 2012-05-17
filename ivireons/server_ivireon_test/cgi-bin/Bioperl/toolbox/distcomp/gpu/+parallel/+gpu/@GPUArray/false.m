function obj = false( varargin )
%PARALLEL.GPU.GPUARRAY.FALSE False GPUArray
%   D = PARALLEL.GPU.GPUARRAY.FALSE(N) is an N-by-N GPUArray matrix 
%   of logical zeros.
%   
%   D = PARALLEL.GPU.GPUARRAY.FALSE(M,N) is an M-by-N GPUArray matrix
%   of logical zeros.
%   
%   D = PARALLEL.GPU.GPUARRAY.FALSE(M,N,P, ...) or PARALLEL.GPU.GPUARRAY.FALSE([M,N,P, ...])
%   is an M-by-N-by-P-by-... GPUArray of logical zeros.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N  = 1000;
%       D1 = GPUArray.false(N) % 1000-by-1000 false GPUArray
%       D2 = GPUArray.false(N, 2*N) % 1000-by-2000
%       D3 = GPUArray.false([N, 2*N]) % 1000-by-2000
%   
%   See also FALSE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/TRUE, PARALLEL.GPU.GPUARRAY/ZEROS


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:48 $

[szVec, ~, E] = parallel.internal.buildFcnArgCheck( 'false', ...
                                                  'parallel:gpu:false', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end
obj = parallel.gpu.GPUArray.hFalse( szVec );
