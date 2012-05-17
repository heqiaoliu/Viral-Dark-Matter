function [th,r,z] = cart2pol(x,y,z)
%Embedded MATLAB Library Function

%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
th = atan2(y,x);
r = hypot(x,y);
