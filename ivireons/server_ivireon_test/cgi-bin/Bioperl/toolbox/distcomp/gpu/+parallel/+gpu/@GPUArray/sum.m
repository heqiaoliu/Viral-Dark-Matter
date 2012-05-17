%SUM Sum of elements of GPUArray
%   SUM(X)
%   SUM(X,'double')
%   SUM(X,'native')
%   SUM(X,DIM)
%   SUM(X,DIM,'double')
%   SUM(X,DIM,'native')
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray.colon(1,N)
%       s = sum(D)
%   
%   returns s = (1+1000)*1000/2 = 500500.
%   
%   SUM is not supported in the native datatype when the underlying class 
%   of X is int64 or uint64.
%   
%   The order of the additions within the SUM operation is not defined, so
%   the SUM operation on GPUArray might not return exactly the same 
%   answer as the SUM operation on the corresponding MATLAB numeric array.
%   In particular, the differences might be significant when X is a signed
%   integer type and its sum is accumulated natively.
%   
%   See also SUM, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/ZEROS.
%   
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:28:25 $
