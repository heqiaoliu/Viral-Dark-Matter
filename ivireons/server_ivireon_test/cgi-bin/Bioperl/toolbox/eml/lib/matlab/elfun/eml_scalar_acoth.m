function x = eml_scalar_acoth(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

x = eml_scalar_atanh(eml_div(1,x));
