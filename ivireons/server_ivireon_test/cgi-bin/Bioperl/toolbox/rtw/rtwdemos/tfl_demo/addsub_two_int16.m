function [y1, y2] = addsub_two_int16(u1, u2) %#eml

%   Copyright 2008 The MathWorks, Inc.

y1 = int16(u1 + u2);
y2 = int16(u1 - u2);