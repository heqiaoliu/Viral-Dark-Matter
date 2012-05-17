function x = eml_scalar_cos(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_cos(x);
else
    % Adapted from utComplexScalarCos in src\util\libm\cmath1.cpp
    if imag(x) == 0 && eml_option('NonFinitesSupport')
        % This case is necessary to match MATLAB only for some non-finite
        % inputs, but it is a minor optimization in general.
        x = complex(eml_cos(real(x)),0);
    else
        x = complex( ...
            eml_cos(real(x)).*eml_cosh(imag(x)), ...
            -eml_sin(real(x)).*eml_sinh(imag(x)));
    end
end
