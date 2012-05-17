function ax = allaxes(h)
%ALLAXES  Collects all HG axes (private method)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:46 $

ax = [h.Axes2d(:);h.BackgroundAxes];