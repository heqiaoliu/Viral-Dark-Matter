function sz = eml_scalexp_size(x,y,z)
%Embedded MATLAB Private Function

%   Utility function to return the size of the result of a binary 
%   elementwise operation on the scalar expansion of x and y or
%   ternary elementwise operation on the scalar expansion of x, y, and z.

%   Copyright 2005-2008 The MathWorks, Inc.
%#eml

if  ~eml_option('VariableSizing')  || ...
    (eml_is_const(size(x)) && ...
     eml_is_const(size(y)) && ...
     (nargin < 3 || eml_is_const(size(z))))
    eml_transient;
end
if nargin == 2
    eml_lib_assert(eml_scalexp_compatible(x,y), ...
            'MATLAB:dimagree', ...
            'Matrix dimensions must agree.');
    if isscalar(x)
        sz = size(y);
    else
        sz = size(x);
    end
else
    eml_lib_assert(eml_scalexp_compatible(x,y) && ...
            eml_scalexp_compatible(x,z) && ...
            eml_scalexp_compatible(y,z), ...
            'MATLAB:dimagree', ...
            'Matrix dimensions must agree.');
    if isscalar(x)
        if isscalar(y)
            sz = size(z);
        else
            sz = size(y);
        end
    else
        sz = size(x);
    end
end
