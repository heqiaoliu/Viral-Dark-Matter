function obj = eye(varargin)
%PARALLEL.GPU.GPUARRAY.EYE Identity GPUArray matrix
%   D = PARALLEL.GPU.GPUARRAY.EYE(N) is the N-by-N GPUArray matrix with ones on
%   the diagonal and zeros elsewhere.
%   
%   D = PARALLEL.GPU.GPUARRAY.EYE(M,N) or PARALLEL.GPU.GPUARRAY.EYE([M,N]) is the M-by-N 
%   GPUArray matrix with ones on the diagonal and zeros elsewhere.
%   
%   D = PARALLEL.GPU.GPUARRAY.EYE() is the GPUArray scalar 1.
%   
%   D = PARALLEL.GPU.GPUARRAY.EYE(M,N,CLASSNAME) or PARALLEL.GPU.GPUARRAY.EYE([M,N],CLASSNAME)
%   is the M-by-N GPUArray identity matrix with underlying data of 
%   class CLASSNAME.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       % Create a 1000-by-1000 GPUArray with underlying class 'int32'.
%       D1 = GPUArray.eye(N,'int32');
%   
%   See also EYE, PARALLEL.GPU.GPUARRAY.
%   

%
%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/06/10 14:27:47 $
    
[szVec, clz, E] = parallel.internal.buildFcnArgCheck( 'eye', ...
                                                  'parallel:gpu:eye', ...
                                                  varargin{:} );
if ~isempty( E )
    throw( E );
end

if isempty(szVec)
    szVec = [1 1];
end

obj = parallel.gpu.GPUArray.hEye( szVec, clz );

end
