function x = eml_scalar_atanh(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

if isreal(x)
    x = scalar_real_atanh(x);
else
    x = scalar_complex_atanh(x);
end

%--------------------------------------------------------------------------

function x = scalar_real_atanh(x)
% Adapted from utFdlibm_atanh in src\util\libm\fdlibm.cpp
% Method :
%    1.Reduced x to positive by atanh(-x) = -atanh(x)
%    2.For x>=0.5
%               1              2x                          x
%	atanh(x) = --- * log(1 + -------) = 0.5 * log1p(2 * --------)
%               2             1 - x                      1 - x
%
% 	For x<0.5
%	atanh(x) = 0.5*log1p(2x+2x*x/(1-x))
%
% Special cases:
%	atanh(x) is NaN if |x| > 1;
eml_must_inline;
if x < 0
    negx = true;
    x = -x;
else
    negx = false;
end
if x > 1
    x = eml_guarded_nan(class(x));
elseif x < 0.5
    t = x + x;
    x = eml_rdivide(eml_scalar_log1p(t + t.*eml_rdivide(x,1-x)),2);
elseif x == 1
    x = eml_guarded_inf(class(x));
else
    x = eml_rdivide(eml_scalar_log1p(eml_rdivide(x+x,1-x)),2);
end
if negx
    x = -x;
end

%--------------------------------------------------------------------------

function x = scalar_complex_atanh(x)
eml_must_inline;
theta = eml_const(eml_rdivide(eml_sqrt(realmax(class(x))),4));
rho = eml_const(eml_rdivide(1,theta));
pid2 = cast(eml_const(eml_rdivide(pi,2)),class(x));
% Do computation in the first quadrant.
xr  = abs(real(x));
xi  = abs(imag(x));
if xr > theta || xi > theta
    tmp = eml_div(1,complex(xr,xi));
    xr  = real(tmp);
    xi  = pid2;
elseif xr == 1 && xi == 0
    xr = eml_guarded_inf(class(x));
    xi = zeros(class(x));
elseif xr == 1
    t = xi + rho;
    xr = eml_log(eml_rdivide(eml_sqrt(eml_sqrt(4 + xi.*xi)),eml_sqrt(t)));
    xi = eml_rdivide(pid2 + eml_atan(eml_rdivide(t,2)),2);
else
    t = xi + rho;
    xi = eml_rdivide(eml_atan2(2.*xi,(1-xr).*(1+xr)-t.*t),2);
    xr = eml_rdivide( ...
        eml_scalar_log1p(4.*eml_rdivide(xr,(1-xr).*(1-xr) + t.*t)),4);
end
% Reflect to appropriate quadrant.
if real(x) < 0
    xr = -xr;
end
% Second part of the condition needed to have the property
% atanh(-z) == -atanh(z) on the branch cut.
if imag(x) < 0 || (imag(x) == 0 && real(x) < -1)
    xi = -xi;
end
x = complex(xr,xi);

%--------------------------------------------------------------------------
