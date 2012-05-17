function x = eml_scalar_asecd(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

radToDeg = eml_const(eml_rdivide(180,pi));
x = radToDeg.*eml_acos(eml_rdivide(1,x));
