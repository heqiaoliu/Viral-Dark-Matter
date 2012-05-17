function x = eml_scalar_acos(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_acos(x);
else
    % v = sqrt(1+x)
    % u = sqrt(1-x)
    % y = 2*atan(real(u)/real(v)) + i*asinh(imag(v'*u))
    v  = eml_scalar_sqrt(1 + x);
    u  = eml_scalar_sqrt(1 - x);
    yr = 2*eml_scalar_atan2(eml_scalar_abs(real(u)),eml_scalar_abs(real(v)));
    if (real(u) < 0) ~= (real(v) < 0)
        yr = -yr;
    end
    yi = eml_scalar_asinh(imag(u).*real(v) - real(u).*imag(v));
    x = complex(yr,yi);
end
