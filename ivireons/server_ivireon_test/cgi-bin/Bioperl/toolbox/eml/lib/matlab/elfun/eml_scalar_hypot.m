function z = eml_scalar_hypot(x,y)
%Embedded MATLAB Library Function

%   Copyright 2003-2007 The MathWorks, Inc.
%#eml

ax = cast(eml_scalar_abs(x),class(x+y));
ay = cast(eml_scalar_abs(y),class(ax));
z = eml_dlapy2(ax,ay);
