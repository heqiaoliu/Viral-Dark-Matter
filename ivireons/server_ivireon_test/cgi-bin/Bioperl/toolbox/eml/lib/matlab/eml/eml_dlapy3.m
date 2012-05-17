function y = eml_dlapy3(x1,x2,x3)
%Embedded MATLAB Private Function

%   DLAPY3

%   Copyright 2005-2008 The MathWorks, Inc.
%#eml

a = eml_scalar_abs(x1);
b = eml_scalar_abs(x2);
c = eml_scalar_abs(x3);
if a > b
    y = a;
else
    y = b;
end
if c > y
    y = c;
end
if y > 0 && ~isinf(y)
    a = eml_rdivide(a,y);
    b = eml_rdivide(b,y);
    c = eml_rdivide(c,y);
    y = y * sqrt(a*a + c*c + b*b);
else
    y = a + b + c;  % Preserve NaNs.
end
