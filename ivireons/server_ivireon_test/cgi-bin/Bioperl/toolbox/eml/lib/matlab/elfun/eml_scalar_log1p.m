function z = eml_scalar_log1p(z)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

absz = abs(z);
if (absz > eml_const(eml_rdivide(1,eps(class(z))))) || ~isfinite(z)
    % Large abs(z), including nan and inf.
    z = eml_scalar_log(1+z);
elseif isreal(z) || imag(z) == 0 %Note: ISREAL helps constant folder
    if absz < eps(class(z))
        % Leave z alone, i.e. use log(1+z) ~ z.
    else
        % Real z, abs(z) not too large, and z not so small that 1+z ==
        % 1. Algorithm due to W. Kahan, from unpublished course notes.
        u = 1 + z; % Can't use u = 1 + real(z) because of z < -1 case.
        z(1) = eml_scalar_log(u).*eml_rdivide(real(z),real(u)-1);
    end
elseif real(z) < -.5
    % Complex z, abs(z) not too large, real(z) < -1/2.
    % OK to compute log(1+z)
    z = eml_scalar_log(1+z);
else
    % Complex z, abs(z) not too large, real(z) >= -1/2.
    % Let 1+z = r*exp(i*theta), then log(1+z) = log(r^2)/2+i*theta.
    % Do not actually compute r, but use log1p recursively with r^2-1.
    % Let x = real(z) and y = imag(z).
    % Note that log1p(2*x+x*x+y*y) is always real, since here we have
    % 2*x+x*x+y*y = -1 + (x+1)^2 + y^2 >= -1 + 0.25.
    z = complex( ...
        eml_rdivide(eml_scalar_log1p(2.*real(z)+absz.*absz),2), ...
        eml_scalar_atan2(imag(z),1+real(z)));
end
