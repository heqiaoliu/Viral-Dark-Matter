function s = getcontextmenu_enabled(h)
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/08 12:52:55 $

s.OPEN_SYSTEM = 'On';
s.HILITE_SYSTEM = 'Off';
s.LOG_ALL_SYS = 'Off';
s.LOG_NAMED_SYS = 'Off';
s.LOG_OUTPORT_SYS = 'Off';
s.LOG_UNNAMED_SYS = 'Off';
s.LOG_ALL = getexistingsubsys(h);
s.LOG_NAMED = getexistingsubsys(h);
s.LOG_UNNAMED = getexistingsubsys(h);
s.LOG_NONE_SYS = 'Off';
s.LOG_NO_OUTPORT_SYS = 'Off';
s.LOG_NO_NAMED_SYS = 'Off';
s.LOG_NO_UNNAMED_SYS = 'Off';
s.LOG_NONE = getexistingsubsys(h);
s.LOG_NO_NAMED = getexistingsubsys(h);
s.LOG_NO_UNNAMED = getexistingsubsys(h);
s.OPEN_SIGLOGDIALOG_SYS = 'Off';
s.OPEN_SYSTEMDIALOG = 'On';

%----------------------------------------------------------------
function str = getexistingsubsys(h)
% get the subsystem that is contained in this state.
ch = h.daobject.getHierarchicalChildren;
if ~isempty(find(ch,'-isa','Simulink.SubSystem'))
    str = 'On';
else
    str = 'Off';
end

%------------------------------------------------------------------
% [EOF]

