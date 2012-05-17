function obj = ones( varargin )
%PARALLEL.GPU.GPUARRAY.ONES Ones GPUArray
%   D = PARALLEL.GPU.GPUARRAY.ONES(N) is an N-by-N GPUArray matrix of ones.
%   
%   D = PARALLEL.GPU.GPUARRAY.ONES(M,N) is an M-by-N GPUArray matrix of ones.
%   
%   D = PARALLEL.GPU.GPUARRAY.ONES(M,N,P,...) or PARALLEL.GPU.GPUARRAY.ONES([M,N,P,...])
%   is an M-by-N-by-P-by-... GPUArray of ones.
%   
%   D = PARALLEL.GPU.GPUARRAY.ONES(M,N,P,..., CLASSNAME) or 
%   PARALLEL.GPU.GPUARRAY.ONES([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   GPUArray of ones of class specified by CLASSNAME.
%   
%   Examples:
%   import parallel.gpu.GPUArray
%       N  = 1000;
%       D1 = GPUArray.ones(N)   % 1000-by-1000 GPUArray matrix of ones
%       D2 = GPUArray.ones(N,N*2) % 1000-by-2000
%       D3 = GPUArray.ones([N,N*2], 'int8') % underlying class 'int8'
%   
%   See also ONES, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:19 $

[szVec, clz, E] = parallel.internal.buildFcnArgCheck( 'ones', ...
                                                  'parallel:gpu:ones', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end
obj = parallel.gpu.GPUArray.hGenericOnes( szVec, 1, clz );
end
