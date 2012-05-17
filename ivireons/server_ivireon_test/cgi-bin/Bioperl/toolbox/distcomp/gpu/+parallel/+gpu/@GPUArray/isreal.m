%ISREAL True for real GPUArray
%   TF = ISREAL(X)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       rp = 3 * GPUArray.ones(N);
%       ip = 4 * GPUArray.ones(N);
%       D = complex(rp, ip);
%       f = isreal(D)
%   
%   returns f = false.
%   
%   See also ISREAL, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COMPLEX, PARALLEL.GPU.GPUARRAY/ONES.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:06 $
