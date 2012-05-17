function defaultPosition = getDefaultPosition
%GETDEFAULTPOSITION Define the GETDEFAULTPOSITION class.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:59 $

wh = [410 300];

oldUnits = get(0, 'Units');
set(0, 'Units', 'pixels');
screen = get(0, 'ScreenSize');
set(0, 'Units', oldUnits);

defaultPosition = [screen(3)/2-wh(1)/2 screen(4)/2-wh(2)/2 wh];

% [EOF]
