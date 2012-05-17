function B = triu(A,k)
%TRIU Extract upper triangular part of codistributed array
%   T = TRIU(A,K) yields the elements on and above the K-th diagonal of A. 
%   K = 0 is the main diagonal, K > 0 is above the main diagonal and K < 0
%   is below the main diagonal.
%   T = TRIU(A) is the same as T = TRIU(A,0) where T is the upper triangular 
%   part of A.
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.rand(N);
%       T1 = triu(D,1)
%       Tm1 = triu(D,-1)
%   end
%   
%   See also TRIU, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/08 13:25:54 $

if nargin < 2
    k = 0; 
else
    k = distributedutil.CodistParser.gatherIfCodistributed(k);
    if ~isa(A, 'codistributed')
        B = triu(A, k);
        return;
    end
end

if ndims(A) ~= 2
    error('distcomp:codistributed:triu:notMatrix',...
          'First input must be a matrix.')
end

try
    distributedutil.CodistParser.verifyDiagIntegerScalar('triu', k);
catch E
    throw(E)
end

aDist = getCodistributor(A);
localA = getLocalPart(A);

[localA, aDist] = aDist.hTriuImpl(localA, k);

B = codistributed.pDoBuildFromLocalPart(localA,aDist); %#ok<DCUNK> private static.
