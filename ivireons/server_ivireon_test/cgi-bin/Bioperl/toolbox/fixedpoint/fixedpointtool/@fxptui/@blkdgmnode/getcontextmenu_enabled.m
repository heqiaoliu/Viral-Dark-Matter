function s = getcontextmenu_enabled(h) %#ok<INUSD>
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/14 19:35:14 $

s.OPEN_SYSTEM = 'On';
s.HILITE_SYSTEM = 'Off';
s.LOG_ALL_SYS = 'On';
s.LOG_OUTPORT_SYS = 'Off';
s.LOG_NAMED_SYS = 'On';
s.LOG_UNNAMED_SYS = 'On';
s.LOG_ALL = 'On';
s.LOG_NAMED = 'On';
s.LOG_UNNAMED = 'On';
s.LOG_NONE_SYS = 'On';
s.LOG_NO_OUTPORT_SYS = 'Off';
s.LOG_NO_NAMED_SYS = 'On';
s.LOG_NO_UNNAMED_SYS = 'On';
s.LOG_NONE = 'On';
s.LOG_NO_NAMED = 'On';
s.LOG_NO_UNNAMED = 'On';
s.OPEN_SIGLOGDIALOG_SYS = 'Off';
s.OPEN_SYSTEMDIALOG = 'Off';

% [EOF]
