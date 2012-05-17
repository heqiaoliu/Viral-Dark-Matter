function obj = diag( obj, k )
%DIAG Diagonal matrices and diagonals of a GPUArray matrix
%   
%   A = DIAG(D,K) when D is a GPUArray vector with N components results 
%   in a square GPUArray matrix A of order N+ABS(K) with the elements of 
%   D along the K-th diagonal of A.  Recall that K = 0 is the main diagonal, 
%   K > 0 is above the main diagonal, and K < 0 is below the main diagonal.
%   
%   A = DIAG(D) is the same as A = DIAG(D,0) and puts D along the main 
%   diagonal of A.
%   
%   D = DIAG(A,K) when A is a GPUArray matrix results in a GPUArray 
%   column vector D formed from the elements of the K-th diagonal of A.  
%   
%   D = DIAG(A) is the same as D = DIAG(A,0) and D is the main diagonal 
%   of A. Note that DIAG(DIAG(A)) results in a GPUArray diagonal matrix.
%   
%   Example:
%   import parallel.gpu.GPUArray
%       N = 1000;
%       d = GPUArray.colon(N,-1,1)'
%       d2 = GPUArray.colon(1,ceil(N/2))'
%       D = diag(d) + diag(d2,floor(N/2))
%   
%   creates two GPUArray column vectors d and d2 and then populates the
%   GPUArray matrix D with them as diagonals.
%   
%   See also DIAG, PARALLEL.GPU.GPUARRAY, PARALLEL.GPU.GPUARRAY/COLON, PARALLEL.GPU.GPUARRAY/ZEROS.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2010/06/10 14:27:40 $

if nargin < 2
    k = 0; 
end

[objIsGpu, k] = gatherIfNecessary( obj, k );

if ~objIsGpu
    obj = diag(obj, k);
    return
end

try
    obj = hDiag( obj, k );
catch E
    throw(E);
end

