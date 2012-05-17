function obj = inf( varargin )
%PARALLEL.GPU.GPUARRAY.INF Infinity GPUArray
%   D = PARALLEL.GPU.GPUARRAY.INF(N) is an N-by-N GPUArray matrix of INFs.
%   
%   D = PARALLEL.GPU.GPUARRAY.INF(M,N) is an M-by-N GPUArray matrix of INFs.
%   
%   D = PARALLEL.GPU.GPUARRAY.INF(M,N,P,...) or PARALLEL.GPU.GPUARRAY.INF([M,N,P,...])
%   is an M-by-N-by-P-by-... GPUArray of INFs.
%   
%   D = PARALLEL.GPU.GPUARRAY.INF(M,N,P,..., CLASSNAME) or 
%   PARALLEL.GPU.GPUARRAY.INF([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   GPUArray of INFs of class specified by CLASSNAME.  CLASSNAME 
%   must be either 'single' or 'double'.
%   
%   
%   Example:
%   % Create a 1000-by-1 GPUArray of underlying class 'single' 
%   % containing the value Inf:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D1 = GPUArray.inf(N, 1,'single')
%   
%   See also INF, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS, PARALLEL.GPU.GPUARRAY/ONES


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:57 $

[szVec, clz, E] = parallel.internal.buildFcnArgCheck( 'inf', ...
                                                  'parallel:gpu:inf', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end
obj = parallel.gpu.GPUArray.hGenericOnes( szVec, Inf, clz );
end
