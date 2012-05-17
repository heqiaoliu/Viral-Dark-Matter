function y = eml_dlapy2(x1,x2)
%Embedded MATLAB Private Function

%   y = sqrt(abs(x1)^2 + abs(x2)^2) computed to avoid unnecessary
%   overflow and underflow.
%
%   Based on DLAPY2 (BLAS) with added support for complex inputs.
%   Written to be a low-level function called by ABS and HYPOT.

%   Copyright 2005-2008 The MathWorks, Inc.
%#eml

if eml_option('Developer')
    eml_assert(nargin == 2, 'Not enough input arguments.');
    eml_assert(isa(x1,'float') && isa(x2,'float'), 'Arguments must be floats.');
    eml_assert(isa(x1,class(x2)), 'Arguments must belong to the same class.');
    eml_assert(isscalar(x1) && isscalar(x2), 'Arguments must be scalar.');
end
if isreal(x1)
    a = eml_fabs(x1);
else
    a = eml_dlapy2(real(x1),imag(x1));
end
if isreal(x2)
    b = eml_fabs(x2);
else
    b = eml_dlapy2(real(x2),imag(x2));
end
% y = max(a,b) and b = min(a,b), except y = nan if isnan(a) || isnan(b).
if b > a || isnan(b)
    y = b;
    b = a;
else
    y = a;
end
if ~(y == 0 || isinf(y))
    b = eml_rdivide(b,y);
    y = y .* eml_sqrt(1 + b.*b);
end
