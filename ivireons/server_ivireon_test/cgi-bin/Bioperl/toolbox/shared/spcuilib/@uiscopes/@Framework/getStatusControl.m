function hWidget = getStatusControl(this, control)
%GETSTATUSCONTROL Get the statusControl.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/28 03:27:01 $

hWidget = this.UIMgr.findwidget('StatusBar', 'StdOpts',control);

% [EOF]
