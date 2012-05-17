%PROD Product of elements of GPUArray
%   PROD(X)
%   PROD(X,DIM)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = 4 * (GPUArray.colon(1, N) .^ 2);
%       D2 = D ./ (D - 1);
%       p = prod(D2)
%   
%   returns p as approximately pi/2 (by the Wallis product).
%   
%   See also PROD, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:20 $
