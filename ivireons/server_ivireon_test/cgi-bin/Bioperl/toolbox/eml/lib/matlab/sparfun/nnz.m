function n = nnz(s)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isnumeric(s) || ischar(s) || islogical(s), ...
    'Input must be numeric, char, or logical.');
j = zeros(eml_index_class);
for k = 1:eml_numel(s)
    if s(k) ~= 0
        j = eml_index_plus(j,1);
    end
end
n = double(j);