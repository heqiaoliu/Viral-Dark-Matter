function appdata = getappdata(h)
%GETAPPDATA Get the appdata from the block diagram.
%   OUT = GETAPPDATA(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:49:53 $

appdata = SimulinkFixedPoint.getApplicationData(h.getRoot.daobject.getFullName);

% [EOF]
