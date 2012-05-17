function x = eml_scalar_exp(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_exp(x);
else
    r = eml_exp(real(x));
    x = complex(r.*eml_cos(imag(x)),r.*eml_sin(imag(x)));
end
