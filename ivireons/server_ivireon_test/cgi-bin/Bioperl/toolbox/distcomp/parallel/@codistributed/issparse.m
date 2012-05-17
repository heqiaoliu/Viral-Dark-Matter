function tf = issparse(A)
%ISSPARSE True for sparse codistributed matrix
%   TF = ISSPARSE(D)
%   
%   Example:
%   spmd
%       N = 1000;
%       D = codistributed.speye(N,N);
%       t = issparse(D)
%       f = issparse(full(D))
%   end
%   
%   returns t = true and f = false.
%   
%   See also ISSPARSE, CODISTRIBUTED, CODISTRIBUTED/SPEYE.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/08/11 15:40:38 $

aDist = getCodistributor(A);
localA = getLocalPart(A);

tf = aDist.hIssparseImpl(localA);
