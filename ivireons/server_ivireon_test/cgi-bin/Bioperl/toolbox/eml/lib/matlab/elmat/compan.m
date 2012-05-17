function A = compan(c)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(c,'float'), ...
    'Input to compan must be floats, namely single or double.');
eml_lib_assert(isvector(c), ...
    'MATLAB:compan:NeedVectorInput', ...
    'Input argument must be a vector.');
n = eml_numel(c);
A = eml_expand(eml_scalar_eg(c),[n-1,n-1]);
if n < 2
    return
end
A(1,n-1) = -c(n) ./ c(1);
if n == 2
    return
end
for i = 1:n-2
    A(1,i) = eml_div(-c(i+1),c(1));
    A(i+1,i) = 1;
end
