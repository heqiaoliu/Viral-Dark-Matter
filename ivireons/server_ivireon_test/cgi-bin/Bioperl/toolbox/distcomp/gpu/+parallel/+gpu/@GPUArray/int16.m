%INT16 Convert GPUArray to signed 16-bit integer
%   I = INT16(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Du = GPUArray.ones(N,'uint16');
%       Di = int16(Du)
%       classDu = classUnderlying(Du)
%       classDi = classUnderlying(Di)
%   
%   converts the N-by-N uint16 GPUArray Du to the
%   int16 GPUArray Di.
%   classDu is 'uint16' while classDi is 'int16'.
%   
%   See also INT16, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:58 $
