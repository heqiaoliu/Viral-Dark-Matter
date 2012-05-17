%ANY True if any element of a GPUArray vector is nonzero or TRUE
%   A = ANY(D)
%   A = ANY(D,DIM)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.eye(N);
%       t = any(D,1)
%   
%   returns t the GPUArray row vector equal to
%   GPUArray.true(1,N).
%   
%   See also ANY, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/EYE, PARALLEL.GPU.GPUARRAY/TRUE.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:33 $
