function [az,elev,r] = cart2sph(x,y,z)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 2, 'Not enough input arguments.');
hypotxy = hypot(x,y);
r = hypot(hypotxy,z);
elev = atan2(z,hypotxy);
az = atan2(y,x);
