function obj = zeros( varargin )
%PARALLEL.GPU.GPUARRAY.ZEROS Zeros GPUArray
%   D = PARALLEL.GPU.GPUARRAY.ZEROS(N) is an N-by-N GPUArray matrix of zeros.
%   
%   D = PARALLEL.GPU.GPUARRAY.ZEROS(M,N) is an M-by-N GPUArray matrix of zeros.
%   
%   D = PARALLEL.GPU.GPUARRAY.ZEROS(M,N,P,...) or PARALLEL.GPU.GPUARRAY.ZEROS([M,N,P,...])
%   is an M-by-N-by-P-by-... GPUArray of zeros.
%   
%   D = PARALLEL.GPU.GPUARRAY.ZEROS(M,N,P,..., CLASSNAME) or 
%   PARALLEL.GPU.GPUARRAY.ZEROS([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   GPUArray of zeros of class specified by CLASSNAME.
%   
%   Examples:
%   import parallel.gpu.GPUArray
%       N  = 1000;
%       D1 = GPUArray.zeros(N)   % 1000-by-1000 GPUArray matrix of zeros
%       D2 = GPUArray.zeros(N,N*2) % 1000-by-2000
%       D3 = GPUArray.zeros([N,N*2], 'int8') % underlying class 'int8'
%   
%   See also ZEROS, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:33 $

[szVec, clz, E] = parallel.internal.buildFcnArgCheck( 'ones', ...
                                                  'parallel:gpu:zeros', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end
obj = parallel.gpu.GPUArray.hZeros( szVec, clz );
