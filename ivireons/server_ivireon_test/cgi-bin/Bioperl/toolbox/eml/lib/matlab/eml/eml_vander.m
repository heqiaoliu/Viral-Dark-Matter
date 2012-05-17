function A = eml_vander(v,ord)
%Embedded MATLAB Private Function

%   Vandermonde matrix with optional specified order.
%   A = [v(:).^ord,v(:).^(ord-1),...,v(:).^2,v(:),ones(numel(v),1)]
%   The default value of ORD is numel(v)-1.

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

n = eml_numel(v);
if nargin < 2
    ord = n - 1;
else
    eml_prefer_const(ord);
end
A = eml.nullcopy(eml_expand(eml_scalar_eg(v),[n,ord+1]));
if isempty(A)
    return
end
for k = 1:n
    A(k,ord+1) = 1;
end
if ord < 1
    return
end
for k = 1:n
    A(k,ord) = v(k);
end
for j = ord-1:-1:1
    for k = 1:n
        A(k,j) = v(k).*A(k,j+1);
    end
end
