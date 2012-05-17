function e = end(a,k,n)
%END Last index in an indexing expression for a categorical array.
%   END(A,K,N) is called for indexing expressions involving the categorical
%   array A when END is part of the K-th index out of N indices.  For example,
%   the expression A(end-1,:) calls A's END method with END(A,1,2).
%
%   See also CATEGORICAL/SIZE.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:36:47 $

e = builtin('end',a.codes,k,n);
