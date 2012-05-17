%INT8 Convert GPUArray to signed 8-bit integer
%   I = INT8(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Du = GPUArray.ones(N,'uint8');
%       Di = int8(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   
%   converts the N-by-N uint8 GPUArray Du to the
%   int8 GPUArray Di.
%   classDu is 'uint8' while classDi is 'int8'.
%   
%   See also INT8, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:01 $
