function x = eml_scalar_sech(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

x = eml_div(1,eml_scalar_cosh(x));
