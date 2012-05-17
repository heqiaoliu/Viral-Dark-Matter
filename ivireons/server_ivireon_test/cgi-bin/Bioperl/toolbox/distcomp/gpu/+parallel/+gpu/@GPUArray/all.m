%ALL True if all elements of a GPUArray vector are nonzero
%   A = ALL(D)
%   A = ALL(D,DIM)
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.colon(1,N)
%       t = all(D)
%   
%   returns t the GPUArray logical scalar with value true.
%   
%   See also ALL, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:32 $
