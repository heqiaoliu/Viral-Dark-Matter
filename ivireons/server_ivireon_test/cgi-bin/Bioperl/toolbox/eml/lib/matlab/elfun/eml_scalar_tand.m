function x = eml_scalar_tand(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

degToRad = eml_const(eml_rdivide(pi,180));
n = eml_scalar_round(eml_rdivide(x,90));
x = x - n.*90;
if n == 2*(eml_scalar_floor(eml_rdivide(n,2))) 
    x = eml_tan(degToRad.*x);
elseif x ~= 0
    x = eml_rdivide(-1,eml_tan(degToRad.*x));
elseif n >= 0
    x = eml_guarded_inf(class(x));
else
    x = -eml_guarded_inf(class(x));
end


