function x = flipdim(x,dim)
%Embedded MATLAB Library Function

%   Copyright 1984-2009 The MathWorks, Inc.
%#eml

eml_allow_enum_inputs;
eml_assert(nargin == 2, 'Requires two arguments.');
eml_prefer_const(dim);
eml_assert_valid_dim(dim);
vlen = size(x,dim);
if ~isempty(x) && dim <= ndims(x) && vlen > 1
    vstride = eml_matrix_vstride(x,dim);
    vspread = eml_index_times(eml_index_minus(vlen,1),vstride);
    npages  = eml_matrix_npages(x,dim);
    i2      = zeros(eml_index_class);
    for i = 1:npages
        i1 = i2;
        i2 = eml_index_plus(i2,vspread);
        for j = 1:vstride
            i1 = eml_index_plus(i1,1);
            i2 = eml_index_plus(i2,1);
            ixleft = i1;
            ixright = i2;
            while ixleft < ixright
                tmp = x(ixleft);
                x(ixleft) = x(ixright);
                x(ixright) = tmp;
                ixleft = eml_index_plus(ixleft,vstride);
                ixright = eml_index_minus(ixright,vstride);
            end
        end
    end
end
