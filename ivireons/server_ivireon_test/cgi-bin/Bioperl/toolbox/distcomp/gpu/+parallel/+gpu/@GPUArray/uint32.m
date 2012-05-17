%UINT32 Convert GPUArray to unsigned 32-bit integer
%   I = UINT32(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Di = GPUArray.ones(N,'int32');
%       Du = uint32(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   
%   converts the N-by-N int32 GPUArray Di to the
%   uint32 GPUArray Du.
%   classDi is 'int32' while classDu is 'uint32'.
%   
%   See also UINT32, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:30 $
