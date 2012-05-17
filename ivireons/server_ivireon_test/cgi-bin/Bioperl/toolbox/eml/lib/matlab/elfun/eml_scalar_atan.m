function x = eml_scalar_atan(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_atan(x);
else
    % y = -i*double_atanh(i*x);
    t = eml_scalar_atanh(complex(-imag(x),real(x)));
    x = complex(imag(t),-real(t));
end
