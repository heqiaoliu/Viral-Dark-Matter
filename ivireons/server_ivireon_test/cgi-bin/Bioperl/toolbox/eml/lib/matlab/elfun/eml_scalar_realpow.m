function z = eml_scalar_realpow(x,y)
%Embedded MATLAB Library Function

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

if isnan(x) || isnan(y)
    z = x + y;
else
    z = eml_pow(x,y);
end
