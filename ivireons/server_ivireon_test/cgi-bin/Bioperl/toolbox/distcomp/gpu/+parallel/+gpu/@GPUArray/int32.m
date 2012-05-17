%INT32 Convert GPUArray to signed 32-bit integer
%   I = INT32(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Du = GPUArray.ones(N,'uint32');
%       Di = int32(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   
%   converts the N-by-N uint32 GPUArray Du to the
%   int32 GPUArray Di.
%   classDu is 'uint32' while classDi is 'int32'.
%   
%   See also INT32, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:59 $
