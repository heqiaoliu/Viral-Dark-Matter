function x = eml_scalar_cosh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_cosh(x);
else
    % Adapted from utComplexScalarCosh in src\util\libm\cmath1.cpp
    if imag(x) == 0 && eml_option('NonFinitesSupport')
        % This case is minor optimization in general and necessary
        % only for some nonfinite inputs.
        x = complex(eml_cosh(real(x)),0);
    else
        x = complex( ...
            eml_cosh(real(x)).*eml_cos(imag(x)), ...
            eml_sinh(real(x)).*eml_sin(imag(x)));
    end
end
