function y = eml_scalar_angle(x)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

y = eml_scalar_atan2(imag(x),real(x));
