function obj = triu( obj, k )
%TRIU Extract upper triangular part of GPUArray
%   T = TRIU(A,K) yields the elements on and above the K-th diagonal of A. 
%   K = 0 is the main diagonal, K > 0 is above the main diagonal and K < 0
%   is below the main diagonal.
%   T = TRIU(A) is the same as T = TRIU(A,0) where T is the upper triangular 
%   part of A.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       D = GPUArray(rand(N));
%       T1 = triu(D,1)
%       Tm1 = triu(D,-1)
%   
%   See also TRIU, PARALLEL.GPU.GPUARRAY.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:28:27 $

if nargin < 2
    k = 0; 
end

[objIsGpu, k] = gatherIfNecessary( obj, k );

if ~objIsGpu
    obj = triu(obj, k);
    return
end

try
    obj = hTriu( obj, k );
catch E
    throw(E);
end
