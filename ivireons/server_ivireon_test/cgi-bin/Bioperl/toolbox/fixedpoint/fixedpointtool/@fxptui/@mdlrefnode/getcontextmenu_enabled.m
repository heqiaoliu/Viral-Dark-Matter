function s = getcontextmenu_enabled(h)
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/10/15 22:50:44 $


s.OPEN_SYSTEM = 'On';
s.HILITE_SYSTEM = 'On';
s.LOG_ALL_SYS = getenabledstring(h);
s.LOG_OUTPORT_SYS = getoutport_enabled(h);
s.LOG_NAMED_SYS = 'Off';
s.LOG_UNNAMED_SYS = 'Off';
s.LOG_ALL = 'Off';
s.LOG_NAMED = 'Off';
s.LOG_UNNAMED = 'Off';
s.LOG_NONE_SYS = getenabledstring(h);
s.LOG_NO_OUTPORT_SYS = getoutport_enabled(h);
s.LOG_NO_NAMED_SYS = 'Off';
s.LOG_NO_UNNAMED_SYS = 'Off';
s.LOG_NONE = 'Off';
s.LOG_NO_NAMED = 'Off';
s.LOG_NO_UNNAMED = 'Off';
s.OPEN_SIGLOGDIALOG_SYS = 'On';
s.OPEN_SYSTEMDIALOG = 'On';

%--------------------------------------------------------------------------
function str = getenabledstring(h)
set_param(h.daobject.getFullName, 'UpdateSigLoggingInfo', 'On');
if(numel(h.daobject.AvailSigsInstanceProps.Signals) > 0)
  str = 'On';
else
  str = 'Off';
end

% [EOF]
