function x = eml_scalar_tan(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_tan(x);
else
    % Adapted from utComplexScalarTan in src\util\libm\cmath1.cpp
    % tan(z) = sin(z)/cos(z) -> i(Inf/Inf) for z with large |imag(z)|.
    % Use tan(x+i*y) = (tan(x)+i*tanh(y))/(1-i*tan(x)*tanh(y))
    tanxr = eml_tan(real(x));
    tanhxi = eml_tanh(imag(x));
    x = eml_div(complex(tanxr,tanhxi),complex(1,-tanxr.*tanhxi));
end
