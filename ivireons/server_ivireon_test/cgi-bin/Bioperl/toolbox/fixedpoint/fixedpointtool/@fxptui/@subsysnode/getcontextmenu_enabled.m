function s = getcontextmenu_enabled(h)
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/15 22:50:50 $

isParentLinked = h.isparentlinked;
isObjectLinked = h.daobject.isLinked;

%if the parent is linked disable signal logging
if(isParentLinked)
    s.OPEN_SYSTEM = 'On';
    s.HILITE_SYSTEM = 'On';
    s.LOG_ALL_SYS = 'Off';
    s.LOG_OUTPORT_SYS = 'Off';
    s.LOG_NAMED_SYS = 'Off';
    s.LOG_UNNAMED_SYS = 'Off';
    s.LOG_ALL = 'Off';
    s.LOG_NAMED = 'Off';
    s.LOG_UNNAMED = 'Off';
    s.LOG_NONE_SYS = 'Off';
    s.LOG_NO_OUTPORT_SYS = 'Off';
    s.LOG_NO_NAMED_SYS = 'Off';
    s.LOG_NO_UNNAMED_SYS = 'Off';
    s.LOG_NONE = 'Off';
    s.LOG_NO_NAMED = 'Off';
    s.LOG_NO_UNNAMED = 'Off';
    s.OPEN_SIGLOGDIALOG_SYS = 'Off';
    s.OPEN_SYSTEMDIALOG = 'On';
    return;
end
%if the parent is not linked and this object is linked only enable signal
%logging on the outports
if(isObjectLinked)
    s.OPEN_SYSTEM = 'On';
    s.HILITE_SYSTEM = 'On';
    s.LOG_ALL_SYS = 'Off';
    s.LOG_OUTPORT_SYS = getoutport_enabled(h);
    s.LOG_NAMED_SYS = 'Off';
    s.LOG_UNNAMED_SYS = 'Off';
    s.LOG_ALL = 'Off';
    s.LOG_NAMED = 'Off';
    s.LOG_UNNAMED = 'Off';
    s.LOG_NONE_SYS = 'Off';
    s.LOG_NO_OUTPORT_SYS = getoutport_enabled(h);
    s.LOG_NO_NAMED_SYS = 'Off';
    s.LOG_NO_UNNAMED_SYS = 'Off';
    s.LOG_NONE = 'Off';
    s.LOG_NO_NAMED = 'Off';
    s.LOG_NO_UNNAMED = 'Off';
    s.OPEN_SIGLOGDIALOG_SYS = 'On';
    s.OPEN_SYSTEMDIALOG = 'On';
else
    s.OPEN_SYSTEM = 'On';
    s.HILITE_SYSTEM = 'On';
    s.LOG_ALL_SYS = 'On';
    s.LOG_OUTPORT_SYS = getoutport_enabled(h);
    s.LOG_NAMED_SYS = 'On';
    s.LOG_UNNAMED_SYS = 'On';
    s.LOG_ALL = 'On';
    s.LOG_NAMED = 'On';
    s.LOG_UNNAMED = 'On';
    s.LOG_NONE_SYS = 'On';
    s.LOG_NO_OUTPORT_SYS = getoutport_enabled(h);
    s.LOG_NO_NAMED_SYS = 'On';
    s.LOG_NO_UNNAMED_SYS = 'On';
    s.LOG_NONE = 'On';
    s.LOG_NO_NAMED = 'On';
    s.LOG_NO_UNNAMED = 'On';
    s.OPEN_SIGLOGDIALOG_SYS = 'On';
    s.OPEN_SYSTEMDIALOG = 'On';
end

% [EOF]
