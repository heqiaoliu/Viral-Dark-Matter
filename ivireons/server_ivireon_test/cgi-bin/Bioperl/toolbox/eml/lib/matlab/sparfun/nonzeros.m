function v = nonzeros(s)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isnumeric(s) || ischar(s) || islogical(s), ...
    'Input must be numeric, char, or logical.');
n = cast(eml_numel(s),eml_index_class);
nz = cast(nnz(s),eml_index_class);
assert(nz <= n); %<HINT>
v = eml.nullcopy(eml_expand(eml_scalar_eg(s),[nz,1]));
i = zeros(eml_index_class);
for k = 1:n
    if s(k) ~= 0
        i = eml_index_plus(i,1);
        assert(i <= nz); %<HINT>
        v(i) = s(k);
    end
end
