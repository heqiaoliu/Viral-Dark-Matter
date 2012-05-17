function xyzExtents = getXYZExtents(this)
%GETXYZEXTENTS Get the xYZExtents.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:00 $

xyzExtents = [ ...
    calculateXLim(this) ; ...
    this.YExtents ; ...
    -1 1];

% [EOF]
