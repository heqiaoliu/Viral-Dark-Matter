function x = eml_scalar_acosh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    % Adapted from the algorithm in src\util\libm\fdlibm.cpp
    % Method :
    %	Based on
    %		acosh(x) = log [ x + sqrt(x*x-1) ]
    %	we have
    %		acosh(x) := log(x)+ln2,	if x is large; else
    %		acosh(x) := log(2x-1/(sqrt(x*x-1)+x)) if x>2; else
    %		acosh(x) := log1p(t+sqrt(2.0*t+t*t)); where t=x-1.
    %
    % Special cases:
    %	acosh(x) is NaN if x<1.
    if x < 1
        x = eml_guarded_nan(class(x));
    elseif x >= eml_const(eml_pow(2,28)) % x >= large
        x = eml_log(x) + eml_log(2);
    elseif x > 2 % 2 < x < large
        x = eml_log(x + eml_sqrt(x.*x - 1));
    else % 1 < x <= 2
        x = x - 1;
        x = eml_scalar_log1p(x + sqrt(2.*x + x.*x));
    end
else
    % v = sqrt(x+1)
    % u = sqrt(x-1)
    % y = asinh(real(u'*v)) + 2*i*atan(imag(u)/real(v))
    v = eml_scalar_sqrt(x + 1);
    u = eml_scalar_sqrt(x - 1);
    % Compute tr = asinh(real(conj(u)*v))
    yr = eml_scalar_asinh(real(u).*real(v) + imag(u).*imag(v));
    % Compute yi = 2*atan(imag(u)/real(v))
    yi = 2*eml_scalar_atan2(abs(imag(u)),abs(real(v)));
    if (imag(u) < 0) ~= (real(v) < 0)
        yi = -yi;
    end
    x = complex(yr,yi);
end
