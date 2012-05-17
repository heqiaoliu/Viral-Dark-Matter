function obj = tril( obj, k )
%TRIL Extract lower triangular part of GPUArray
%   T = TRIL(A,K) yields the elements on and below the K-th diagonal of A. 
%   K = 0 is the main diagonal, K > 0 is above the main diagonal and K < 0
%   is below the main diagonal.
%   T = TRIL(A) is the same as T = TRIL(A,0) where T is the lower triangular 
%   part of A.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       T1 = tril(D,1)
%       Tm1 = tril(D,-1)
%   
%   See also TRIL, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:28:26 $

if nargin < 2
    k = 0; 
end

[objIsGpu, k] = gatherIfNecessary( obj, k );

if ~objIsGpu
    obj = tril(obj, k);
    return
end

try
    obj = hTril( obj, k );
catch E
    throw(E);
end

