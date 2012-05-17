function x = fliplr(x)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_lib_assert(ndims(x) == 2, 'MATLAB:fliplr:SizeX', 'X must be a 2-D matrix.');
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
nd2 = eml_index_rdivide(n,2);
for j1 = 1:nd2
    j2 = eml_index_plus(eml_index_minus(n,j1),1);
    for i = 1:m
        xtmp = x(i,j1);
        x(i,j1) = x(i,j2);
        x(i,j2) = xtmp;
    end
end
