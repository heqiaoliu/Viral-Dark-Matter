%SINGLE Convert GPUArray to single precision
%   S = SINGLE(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Du = GPUArray.ones(N,'uint32');
%       Ds = single(Du)
%       classDu = classUnderlying(Du)
%       classDs = classUnderlying(Ds)
%   
%   converts the N-by-N uint32 GPUArray Du to the
%   single GPUArray Ds.
%   classDu is 'uint32' while classDs is 'single'.
%   
%   See also SINGLE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:23 $
