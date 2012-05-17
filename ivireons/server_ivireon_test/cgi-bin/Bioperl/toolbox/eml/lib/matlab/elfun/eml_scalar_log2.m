function [f,e] = eml_scalar_log2(x)
%Embedded MATLAB Library Function

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

if nargout == 2
    [f,e] = scalar_frexp(real(x));
else
    f = scalar_log2(x);
end

%--------------------------------------------------------------------------

function [f,e] = scalar_frexp(x)
% Calls C function frexp.  Return values belong to the same class as x.
if isfinite(x)
    [fdbl,eint] = eml_frexp(x);
    f = cast(fdbl,class(x));
    e = cast(eint,class(x));
else
    f = x;
    e = zeros(class(x));
end

%--------------------------------------------------------------------------

function y = scalar_log2(x)
% Scalar log2(x).  Returns NaN if x is real and x < 0.
LN2 = 0.69314718055994530941;
PIDLN2 = eml_const(cast(eml_rdivide(pi,LN2),class(x)));
xr = real(x);
xi = imag(x);
if xi ~= 0
    y = eml_div(eml_scalar_log(x),LN2);
    return
end
if xr == 0
    resr = -eml_guarded_inf(class(x));
    resi = zeros(class(x));
elseif isfinite(x)
    [t,inte] = scalar_frexp(abs(xr));
    if t == 0.5
        resr = inte - 1;
    else
        resr = eml_rdivide(eml_scalar_log(t),LN2) + inte;
    end
    if xr < 0
        resi = PIDLN2;
    else
        resi = zeros(class(x));
    end
elseif xr < 0 % log(-inf)
    resr = -xr;
    resi = PIDLN2;
else %log(inf) or log(NaN)
    resr = xr;
    resi = zeros(class(x));
end
if isreal(x)
    if resi == 0
        y = resr;
    else
        y = eml_guarded_nan(class(x));
    end
else
    y = complex(resr,resi);
end

%--------------------------------------------------------------------------
