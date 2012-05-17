function x = eml_scalar_sec(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

x = eml_div(1,eml_scalar_cos(x));
