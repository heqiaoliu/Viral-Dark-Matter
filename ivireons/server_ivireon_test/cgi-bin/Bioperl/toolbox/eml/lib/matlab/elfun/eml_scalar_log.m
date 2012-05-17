function x = eml_scalar_log(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_log(x);
else
    x = complex( ...
        eml_log(eml_scalar_abs(x)), ...
        eml_scalar_atan2(imag(x),real(x)));
end
