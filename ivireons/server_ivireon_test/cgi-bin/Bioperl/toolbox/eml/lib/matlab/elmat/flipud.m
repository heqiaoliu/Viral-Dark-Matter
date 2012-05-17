function x = flipud(x)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin > 0, 'Not enough input arguments.');
eml_lib_assert(ndims(x) == 2, 'MATLAB:flipud:SizeX', 'X must be a 2-D matrix.');
m = cast(size(x,1),eml_index_class);
n = cast(size(x,2),eml_index_class);
md2 = eml_index_rdivide(m,2);
for j = 1:n
    for i = 1:md2
        xtmp = x(i,j);
        x(i,j) = x(eml_index_plus(eml_index_minus(m,i),1),j);
        x(eml_index_plus(eml_index_minus(m,i),1),j) = xtmp;
    end
end
