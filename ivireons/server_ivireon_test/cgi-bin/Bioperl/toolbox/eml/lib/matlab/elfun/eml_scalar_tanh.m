function x = eml_scalar_tanh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_tanh(x);
else
    % Adapted from utComplexScalarTanh in src\util\libm\cmath1.cpp
    % tanh(z) = sinh(z)/cosh(z) -> Inf/Inf for large z.
    % Use tanh(x+i*y) = (tanh(x)+i*tan(y))/(1+i*tanh(x)*tan(y))
    tanhxr = eml_tanh(real(x));
    tanxi = eml_tan(imag(x));
    x = eml_div(complex(tanhxr,tanxi),complex(1,tanhxr.*tanxi));
end
