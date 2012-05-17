function x = eml_scalar_ceil(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isfloat(x)
    if isreal(x)
        x = eml_ceil(x);
    else
        x = complex(eml_ceil(real(x)),eml_ceil(imag(x)));
    end
end
