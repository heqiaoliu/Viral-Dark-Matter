function p = eml_scalexp_compatible(a,b)
%Embedded MATLAB Private Function

%   Returns true if and only if the sizes of A and B are compatible for an
%   elementwise binary operation, i.e. either A and B have the same sizes
%   or one is a static scalar.

%   Copyright 2005-2009 The MathWorks, Inc.
%#eml

if ~eml_is_const(size(a)) || ~eml_is_const(size(b))
    p = (eml_is_const(isscalar(a)) && isscalar(a)) || ...
        (eml_is_const(isscalar(b)) && isscalar(b)) || ...
        isequal(size(a),size(b));
else
    p = eml_const(isscalar(a) || isscalar(b) || isequal(size(a),size(b)));
end
