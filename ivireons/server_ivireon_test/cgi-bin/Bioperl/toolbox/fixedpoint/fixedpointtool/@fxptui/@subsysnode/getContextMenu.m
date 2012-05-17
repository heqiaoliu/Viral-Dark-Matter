function cm = getContextMenu(h, selectedHandles)
%GETCONTEXTMENU

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/09/13 06:53:00 $

me = fxptui.getexplorer;
am = DAStudio.ActionManager;
cm = am.createPopupMenu(me);

enabled = h.getcontextmenu_enabled;

action = me.getaction('OPEN_SYSTEM');
action.enabled = enabled.OPEN_SYSTEM;
cm.addMenuItem(action);

action = me.getaction('HILITE_SYSTEM');
action.enabled = enabled.HILITE_SYSTEM;
cm.addMenuItem(action);

action = me.getaction('HILITE_CLEAR');
cm.addMenuItem(action);
cm.addSeparator;

%<Logging submenu>
sm1 = am.createPopupMenu(me);
sm2 = am.createPopupMenu(me);

action = me.getaction('LOG_ALL_SYS');
action.enabled = enabled.LOG_ALL_SYS;
sm1.addMenuItem(action);

action = me.getaction('LOG_ALL');
action.enabled = enabled.LOG_ALL;
sm1.addMenuItem(action);

sm1.addSeparator;

action = me.getaction('LOG_OUTPORT_SYS');
action.enabled = enabled.LOG_OUTPORT_SYS;
sm1.addMenuItem(action);

sm1.addSeparator;

action = me.getaction('LOG_NAMED_SYS');
action.enabled = enabled.LOG_NAMED_SYS;
sm1.addMenuItem(action);

action = me.getaction('LOG_NAMED');
action.enabled = enabled.LOG_NAMED;
sm1.addMenuItem(action);

sm1.addSeparator;

action = me.getaction('LOG_UNNAMED_SYS');
action.enabled = enabled.LOG_UNNAMED_SYS;
sm1.addMenuItem(action);

action = me.getaction('LOG_UNNAMED');
action.enabled = enabled.LOG_UNNAMED;
sm1.addMenuItem(action);


action = me.getaction('LOG_NONE_SYS');
action.enabled = enabled.LOG_NONE_SYS;
sm2.addMenuItem(action);

action = me.getaction('LOG_NONE');
action.enabled = enabled.LOG_NONE;
sm2.addMenuItem(action);

sm2.addSeparator;

action = me.getaction('LOG_NO_OUTPORT_SYS');
action.enabled = enabled.LOG_NO_OUTPORT_SYS;
sm2.addMenuItem(action);

sm2.addSeparator;

action = me.getaction('LOG_NO_NAMED_SYS');
action.enabled = enabled.LOG_NO_NAMED_SYS;
sm2.addMenuItem(action);

action = me.getaction('LOG_NO_NAMED');
action.enabled = enabled.LOG_NO_NAMED;
sm2.addMenuItem(action);

sm2.addSeparator;

action = me.getaction('LOG_NO_UNNAMED_SYS');
action.enabled = enabled.LOG_NO_UNNAMED_SYS;
sm2.addMenuItem(action);

action = me.getaction('LOG_NO_UNNAMED');
action.enabled = enabled.LOG_NO_UNNAMED;
sm2.addMenuItem(action);

cm.addSubMenu(sm1, DAStudio.message('FixedPoint:fixedPointTool:menuEnableLogging'))
cm.addSubMenu(sm2, DAStudio.message('FixedPoint:fixedPointTool:menuDisableLogging'))

outports = 0;
try
  outports = get_param(h.daobject.PortHandles.Outport, 'Object');
catch fpt_exception
  %consume error for objects that don't have outports
end
switch(numel(outports))
  case 0
    action = me.getaction('OPEN_SIGLOGDIALOG_SYS');
    cm.addMenuItem(action);
    action.enabled = 'Off';
  case 1
    action = me.getaction('OPEN_SIGLOGDIALOG_SYS');
    cm.addMenuItem(action);
    action.enabled = enabled.OPEN_SIGLOGDIALOG_SYS;
  otherwise
    sm3 = am.createPopupMenu(me);
    cm.addSubMenu(sm3, DAStudio.message('FixedPoint:fixedPointTool:menuSignalProperties'))
    for idx = 1:numel(outports)
      portnum = num2str(idx);
      action = am.createAction(me, ...
        'Text', DAStudio.message('FixedPoint:fixedPointTool:menuPort', portnum), ...
        'Callback', sprintf('fxptui.cb_opensignaldlg_sys(%s);', portnum));
      sm3.addMenuItem(action);
    end
end
%</Logging submenu>

cm.addSeparator;

action = me.getaction('OPEN_SYSTEMDIALOG');
action.enabled = enabled.OPEN_SYSTEMDIALOG;
cm.addMenuItem(action);

% [EOF]
