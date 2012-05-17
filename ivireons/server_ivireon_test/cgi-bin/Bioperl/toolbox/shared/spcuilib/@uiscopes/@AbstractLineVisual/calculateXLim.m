function xlim = calculateXLim(this)
%CALCULATEXLIM Calculate the XLimits for 'auto display'.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:50 $

% The xlims are simply the xyz extents by default.
xyz = getXYZExtents(this);
xlim = [xyz(1,1) xyz(1,2)];

% [EOF]
