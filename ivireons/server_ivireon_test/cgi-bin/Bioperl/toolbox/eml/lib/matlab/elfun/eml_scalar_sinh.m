function x = eml_scalar_sinh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_sinh(x);
else
    % Adapted from utComplexScalarSinh in src\util\libm\cmath1.cpp
    if imag(x) == 0 && eml_option('NonFinitesSupport')
        % This case is minor optimization in general and necessary
        % only for some nonfinite inputs.
        x = complex(eml_sinh(real(x)),0);
    else
        x = complex( ...
            eml_sinh(real(x)).*eml_cos(imag(x)), ...
            eml_cosh(real(x)).*eml_sin(imag(x)));
    end
end
