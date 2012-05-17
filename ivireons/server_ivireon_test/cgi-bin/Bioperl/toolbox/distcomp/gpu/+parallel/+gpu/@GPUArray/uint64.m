%UINT64 Convert GPUArray to unsigned 64-bit integer
%   I = UINT64(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Di = GPUArray.ones(N,'int64');
%       Du = uint64(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   
%   converts the N-by-N int64 GPUArray Di to the
%   uint64 GPUArray Du.
%   classDi is 'int64' while classDu is 'uint64'.
%   
%   See also UINT64, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:31 $
