%LOGICAL Convert numeric values of GPUArray to logical
%   L = LOGICAL(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Du = GPUArray.ones(N,'uint8');
%       Dl = logical(Du)
%       classDu = classUnderlying(Du)
%       classDl = classUnderlying(Dl)
%   
%   converts the N-by-N uint8 GPUArray Du to the
%   logical GPUArray Dl.
%   classDu is 'uint8' while classDl is 'logical'.
%   
%   See also LOGICAL, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:09 $
