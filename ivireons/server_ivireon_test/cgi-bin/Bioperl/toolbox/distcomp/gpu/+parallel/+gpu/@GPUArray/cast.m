%CAST Cast a GPUArray to a different data type or class
%   B = CAST(A,NEWCLASS)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Du = GPUArray.ones(N,'uint32');
%       Ds = cast(Du,'single')
%       classDu = classUnderlying(Du)
%       classDs = classUnderlying(Ds)
%   
%   casts the GPUArray uint32 array Du to the GPUArray single array
%   Ds. classDu is 'uint32', while classDs is 'single'.
%   
%   See also CAST, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES, 
%   PARALLEL.GPU.GPUARRAY/CLASSUNDERLYING.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:35 $
