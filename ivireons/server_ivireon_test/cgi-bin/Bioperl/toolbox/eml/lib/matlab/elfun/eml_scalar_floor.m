function x = eml_scalar_floor(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if isa(x,'float')
    if isreal(x)
        x = eml_floor(x);
    else
        x = complex(eml_floor(real(x)),eml_floor(imag(x)));
    end
end