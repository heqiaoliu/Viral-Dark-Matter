%UINT8 Convert GPUArray to unsigned 8-bit integer
%   I = UINT8(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Di = GPUArray.ones(N,'int8');
%       Du = uint8(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   
%   converts the N-by-N int8 GPUArray Di to the
%   uint8 GPUArray Du.
%   classDi is 'int8' while classDu is 'uint8'.
%   
%   See also UINT8, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:32 $
