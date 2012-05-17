function e = end( obj, k, n )
%END Overloaded for distributed arrays
%   E = END(D,K,N)
%   
%   See also END, DISTRIBUTED.


%   Copyright 2006-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 22:01:37 $

% Duplicate of codistributed/end logic.
s = size(obj);
s = [s ones(1,n-length(s)+1)];
if n == 1 && k == 1
    e = prod(s);
elseif n == ndims(obj) || k < n
    e = s(k);
else % k == n || n ~= ndims(obj)
    e = prod(s(k:end));
end
end
