function z = eml_scalar_expm1(z)
%Embedded MATLAB Library Function

%   Algorithm due to W. Kahan, unpublished course notes.
%   Copyright 1984-2007 The MathWorks, Inc.
%#eml

pid2 = eml_const(eml_rdivide(pi,2));
u = eml_scalar_exp(z);
if (u == 0) || ~isfinite(u) || (abs(imag(z)) > pid2)
    z = u - 1;
elseif real(u) < 0.5
    z = (u - 1) .* eml_div(z,eml_scalar_log(u));
elseif u ~= 1
    z = (u - 1) .* eml_div(z,eml_scalar_log1p(u-1));
end
