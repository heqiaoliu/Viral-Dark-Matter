function obj = nan( varargin )
%PARALLEL.GPU.GPUARRAY.NAN Build GPUArray containing Not-a-Number
%   D = PARALLEL.GPU.GPUARRAY.NAN(N) is an N-by-N GPUArray matrix of NANs.
%   
%   D = PARALLEL.GPU.GPUARRAY.NAN(M,N) is an M-by-N GPUArray matrix of NANs.
%   
%   D = PARALLEL.GPU.GPUARRAY.NAN(M,N,P,...) or PARALLEL.GPU.GPUARRAY.NAN([M,N,P,...])
%   is an M-by-N-by-P-by-... GPUArray of NANs.
%   
%   D = PARALLEL.GPU.GPUARRAY.NAN(M,N,P,..., CLASSNAME) or 
%   PARALLEL.GPU.GPUARRAY.NAN([M,N,P,...], CLASSNAME) is an M-by-N-by-P-by-... 
%   GPUArray of NANs of class specified by CLASSNAME.  CLASSNAME
%   must be either 'single' or 'double'.
%   
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       % Create a 1000-by-1 GPUArray of underlying class 'single'
%       % containing the value NaN.
%       D1 = GPUArray.nan(N, 1,'single')
%   
%   See also NAN, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:16 $

[szVec, clz, E] = parallel.internal.buildFcnArgCheck( 'nan', ...
                                                  'parallel:gpu:nan', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end
obj = parallel.gpu.GPUArray.hGenericOnes( szVec, NaN, clz );
end
