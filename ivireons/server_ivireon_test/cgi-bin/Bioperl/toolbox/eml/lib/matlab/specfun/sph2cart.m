function [x,y,z] = sph2cart(az,elev,r)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 2, 'Not enough input arguments.');
z = r .* sin(elev);
rcoselev = r .* cos(elev);
x = rcoselev .* cos(az);
y = rcoselev .* sin(az);
