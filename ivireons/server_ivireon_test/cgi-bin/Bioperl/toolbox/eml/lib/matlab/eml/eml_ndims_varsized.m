function n = eml_ndims_varsized(sz,k)
%Embedded MATLAB Private Function

%   Counts the number of elements in the size vector, after the trailing
%   ones have been dropped.

%   Copyright 2008-2009 The MathWorks, Inc.
%#eml

eml_prefer_const(k);
eml_assert(eml_is_const(k));
while(k > 2 && sz(k) == 1)
    k = k-1;
end

n = k;
