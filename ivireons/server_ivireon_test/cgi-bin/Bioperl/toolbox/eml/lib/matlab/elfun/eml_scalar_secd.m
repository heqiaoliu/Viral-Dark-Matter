function x = eml_scalar_secd(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

x = eml_rdivide(1,eml_scalar_cosd(x));
