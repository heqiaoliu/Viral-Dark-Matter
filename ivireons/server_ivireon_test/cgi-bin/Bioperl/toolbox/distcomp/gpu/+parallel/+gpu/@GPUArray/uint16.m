%UINT16 Convert GPUArray to unsigned 16-bit integer
%   I = UINT16(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Di = GPUArray.ones(N,'int16');
%       Du = uint16(Di)
%       classDi = classUnderlying(Di)
%       classDu = classUnderlying(Du)
%   
%   converts the N-by-N int16 GPUArray Di to the
%   uint16 GPUArray Du.
%   classDi is 'int16' while classDu is 'uint16'.
%   
%   See also UINT16, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:29 $
