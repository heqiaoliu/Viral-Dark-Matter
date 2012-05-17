function s = getcontextmenu_enabled(h)
%GETCONTEXTMENU_ENABLED returns structure indicating which context menu
%actions are enabled

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/20 02:18:26 $

s.OPEN_SYSTEM = 'On';
s.HILITE_SYSTEM = 'On';
s.LOG_ALL_SYS = getenabledstring(h);
s.LOG_OUTPORT_SYS = getoutport_enabled(h);
s.LOG_NAMED_SYS = 'Off';
s.LOG_UNNAMED_SYS = 'Off';
s.LOG_ALL = getexistingsubsys(h);
s.LOG_NAMED = getexistingsubsys(h);
s.LOG_UNNAMED = getexistingsubsys(h);
s.LOG_NONE_SYS = getenabledstring(h);
s.LOG_NO_OUTPORT_SYS = getoutport_enabled(h);
s.LOG_NO_NAMED_SYS = 'Off';
s.LOG_NO_UNNAMED_SYS = 'Off';
s.LOG_NONE = getexistingsubsys(h);
s.LOG_NO_NAMED = getexistingsubsys(h);
s.LOG_NO_UNNAMED = getexistingsubsys(h);
s.OPEN_SIGLOGDIALOG_SYS = 'On';
s.OPEN_SYSTEMDIALOG = 'On';

%--------------------------------------------------------------------------
function str = getenabledstring(h)
if(numel(h.daobject.AvailSigsInstanceProps.Signals) > 0)
  str = 'On';
else
  str = 'Off';
end

%----------------------------------------------------------------
function str = getexistingsubsys(h)
% Get thte SF object that the node points to. 
ch = fxptui.sfchartnode.getSFChartObject(h.daobject);
if ~isempty(find(ch,'-isa','Simulink.SubSystem'))
    str = 'On';
else
    str = 'Off';
end

% [EOF]
