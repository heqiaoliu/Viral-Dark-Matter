function t = eml_is_positive_integer_scalar(x)
%Embedded MATLAB Private Function

%   Copyright 2009 The MathWorks, Inc.
%#eml
    t = length(x)==1 && ...
        isnumeric(x) && ...
        (isinteger(x) || (floor(x)==x && ~isinf(x))) && ...
        x>0;
end
