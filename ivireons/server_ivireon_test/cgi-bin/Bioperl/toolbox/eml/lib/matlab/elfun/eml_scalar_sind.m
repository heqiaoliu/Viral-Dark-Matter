function x = eml_scalar_sind(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

degToRad = eml_const(eml_rdivide(pi,180));
n = eml_scalar_round(eml_rdivide(x,90));
x = x - eml_times(n,90);
m = eml_scalar_round(eml_scalar_mod(n,4));
if m < 2
    if m < 1
        x = eml_sin(degToRad.*x); % m == 0
    else
        x = eml_cos(degToRad.*x); % m == 1
    end
elseif m < 3
    x = -eml_sin(degToRad.*x); % m == 2
else
    x = -eml_cos(degToRad.*x); % m == 3
end

