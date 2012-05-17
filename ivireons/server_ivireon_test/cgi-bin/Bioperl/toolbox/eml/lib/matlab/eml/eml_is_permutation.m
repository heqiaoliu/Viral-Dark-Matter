function p = eml_is_permutation(perm)
%Embedded MATLAB Library Function

%   Returns true if perm has all integer elements and the elements
%   1:numel(perm), false otherwise.

%   Copyright 2007-2008 The MathWorks, Inc.
%#eml

eml_prefer_const(perm);
p = false;
n = cast(eml_numel(perm),eml_index_class);
b = false(n,1);
for k = 1:n
    j = perm(k);
    if j < 1 || j > n || eml_scalar_floor(j) ~= j
        return
    end
    b(j) = true;
end
p = all(b);
