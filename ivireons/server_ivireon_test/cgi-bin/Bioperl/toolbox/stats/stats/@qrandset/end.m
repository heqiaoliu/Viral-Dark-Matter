function e = end(qr,k,n)
%END Last index in an indexing expression for a point set.
%   END(P,K,N) is called for indexing expressions involving the point set P
%   when END is part of the K-th index out of N indices.  For example, the
%   expression P(end-1,:) calls P's END method with END(P,1,2).

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:11 $

switch k
    case 1
        e = qr.NumPoints;
    case 2
        e = qr.Dimensions;
    otherwise
        e = 1;
end
