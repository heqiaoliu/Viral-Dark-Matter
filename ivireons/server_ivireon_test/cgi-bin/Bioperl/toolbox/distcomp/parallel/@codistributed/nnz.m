function numNz = nnz(A)
%NNZ Number of nonzero codistributed matrix elements
%   N = NNZ(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.speye(N);
%       n = nnz(D)
%   end
%   
%   returns n = N.
%   
%   t = issparse(D)
%   
%   returns t = true.
%   
%   See also NNZ, CODISTRIBUTED, CODISTRIBUTED/SPEYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:41 $

aDist = getCodistributor(A);
localA = getLocalPart(A);

numNz = aDist.hNnzImpl(localA);
