%INT64 Convert GPUArray to signed 64-bit integer
%   I = INT64(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Du = GPUArray.ones(N,'uint64');
%       Di = int64(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   
%   converts the N-by-N uint64 GPUArray Du to the
%   int64 GPUArray Di.
%   classDu is 'uint64' while classDi is 'int64'.
%   
%   See also INT64, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:00 $
