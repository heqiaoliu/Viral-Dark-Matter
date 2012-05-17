function x = eml_scalar_asech(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

x = eml_scalar_acosh(eml_div(1,x));
