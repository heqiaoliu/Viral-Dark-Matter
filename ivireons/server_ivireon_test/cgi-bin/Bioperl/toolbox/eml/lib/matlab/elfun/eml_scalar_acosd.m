function x = eml_scalar_acosd(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

radToDeg = eml_const(eml_rdivide(180,pi));
x = radToDeg.*eml_scalar_acos(x);
