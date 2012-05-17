%DOUBLE Convert GPUArray to double precision
%   Y = DOUBLE(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       Ds = GPUArray.ones(N,'single');
%       Dd = double(Ds)
%       classDs = classUnderlying(Ds)
%       classDd = classUnderlying(Dd)
%   
%   takes the N-by-N GPUArray single matrix Ds and converts
%   it to the GPUArray double matrix Dd.
%   classDs is 'single' while classDd is 'double'.
%   
%   See also DOUBLE, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:42 $
