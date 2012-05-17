function x = eml_scalar_acscd(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

radToDeg = eml_const(eml_rdivide(180,pi));
x = radToDeg.*eml_asin(eml_rdivide(1,x));
