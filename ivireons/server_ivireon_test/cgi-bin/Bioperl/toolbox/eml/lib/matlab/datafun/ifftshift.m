function x = ifftshift(x,dim)
%Embedded MATLAB Library Function

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
if nargin == 1
    for dim = ones(eml_index_class):ndims(x)
        x = eml_ifftshift(x,dim);
    end
else
    eml_prefer_const(dim);
    eml_assert_valid_dim(dim);
    x = eml_ifftshift(x,dim);
end
