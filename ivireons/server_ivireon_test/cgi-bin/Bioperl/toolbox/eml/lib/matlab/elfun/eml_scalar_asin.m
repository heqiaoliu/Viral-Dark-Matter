function x = eml_scalar_asin(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = eml_asin(x);
else
    % v = sqrt(1+x)
    % u = sqrt(1-x)
    % y = atan(real(x)/real(u*v)) + i*asinh(imag(u'*v))
    xr = real(x);
    u  = eml_scalar_sqrt(1 - x);
    v  = eml_scalar_sqrt(1 + x);
    uvr = real(u).*real(v) - imag(u).*imag(v); % real(u*v)
    yr = eml_scalar_atan2(abs(xr),abs(uvr));
    if (xr < 0) ~= (uvr < 0)
        yr = -yr;
    end
    yi = eml_scalar_asinh(real(u).*imag(v) - imag(u).*real(v));
    x = complex(yr,yi);
end
