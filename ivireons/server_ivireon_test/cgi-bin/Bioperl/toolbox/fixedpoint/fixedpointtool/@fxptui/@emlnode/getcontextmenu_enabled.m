function s = getcontextmenu_enabled(h)
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:21 $

s.OPEN_SYSTEM = 'On';
s.HILITE_SYSTEM = 'On';
s.LOG_ALL_SYS = 'Off';
s.LOG_OUTPORT_SYS = 'On';
s.LOG_NAMED_SYS = 'Off';
s.LOG_UNNAMED_SYS = 'Off';
s.LOG_ALL = 'Off';
s.LOG_NAMED = 'Off';
s.LOG_UNNAMED = 'Off';
s.LOG_NONE_SYS = 'Off';
s.LOG_NO_OUTPORT_SYS = 'On';
s.LOG_NO_NAMED_SYS = 'Off';
s.LOG_NO_UNNAMED_SYS = 'Off';
s.LOG_NONE = 'Off';
s.LOG_NO_NAMED = 'Off';
s.LOG_NO_UNNAMED = 'Off';
s.OPEN_SIGLOGDIALOG_SYS = 'On';
s.OPEN_SYSTEMDIALOG = 'On';

% [EOF]
