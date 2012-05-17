function [x,y,z] = pol2cart(th,r,z)
%Embedded MATLAB Library Function

%   Original MATLAB version  L. Shure, 4-20-92.
%   Copyright 2002-2007 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
x = r.*cos(th);
y = r.*sin(th);
