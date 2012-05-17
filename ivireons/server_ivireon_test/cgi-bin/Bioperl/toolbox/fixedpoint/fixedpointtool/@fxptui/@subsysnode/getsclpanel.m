function grp_scl = getsclpanel(h) %#ok
%GETSCLPANEL   Get the sclpanel.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/04/21 03:18:59 $

r=1;
appdata = [];
me = fxptui.getexplorer;
if(isempty(me))
  isenabled = false;
else
  action = me.getaction('SCALE_PROPOSE');
  isenabled = isequal('on', action.Enabled);
  appdata = SimulinkFixedPoint.getApplicationData(me.getRoot.daobject.getFullName);
end

button_propose.Type = 'pushbutton';
button_propose.Tag = 'button_propose';
button_propose.Enabled = isenabled;
button_propose.MatlabMethod = 'fxptui.cb_scalepropose;';
% make the variable persistent to improve performance.
persistent propose_tooltip;
if isempty(propose_tooltip)
    propose_tooltip = DAStudio.message('FixedPoint:fixedPointTool:tooltipSCALEPROPOSE');
end
button_propose.ToolTip = propose_tooltip;
button_propose.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'scalepropose.png');
button_propose.RowSpan = [r r];
button_propose.ColSpan = [1 1];

txt_propose.Type = 'text';
txt_propose.Tag = 'txt_propose';
% make the variable persistent to improve performance.
persistent propose_name;
if isempty(propose_name)
    propose_name = DAStudio.message('FixedPoint:fixedPointTool:labelSCALEPROPOSE');
end
txt_propose.Name = propose_name;
txt_propose.RowSpan = [r r];r = r+1;
txt_propose.ColSpan = [2 3];

if(isempty(me))
  isenabled = false;
else
  action = me.getaction('SCALE_APPLY');
  isenabled = isequal('on', action.Enabled);
end
button_apply.Type = 'pushbutton';
button_apply.Tag = 'button_apply';
button_apply.Enabled = isenabled;
button_apply.MatlabMethod = 'fxptui.cb_scaleapply;';
% make the variable persistent to improve performance.
persistent apply_tooltip;
if isempty(apply_tooltip)
    apply_tooltip = DAStudio.message('FixedPoint:fixedPointTool:tooltipSCALEAPPLY');
end
button_apply.ToolTip = apply_tooltip;
button_apply.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'scaleapply.png');
button_apply.RowSpan = [r r];
button_apply.ColSpan = [1 1];

txt_apply.Type = 'text';
txt_apply.Tag = 'txt_apply';
% make the variable persistent to improve performance.
persistent apply_name;
if isempty(apply_name)
    apply_name = DAStudio.message('FixedPoint:fixedPointTool:labelSCALEAPPLY');
end
txt_apply.Name = apply_name;
txt_apply.RowSpan = [r r];r=r+1;
txt_apply.ColSpan = [2 3];

pnl_apply.Type = 'panel';
pnl_apply.RowSpan = [1 1];
pnl_apply.ColSpan = [1 1];
pnl_apply.LayoutGrid  = [1 3];
pnl_apply.ColStretch = [0 0 1];
pnl_apply.Items = {button_propose, txt_propose, button_apply, txt_apply};

% get the group containing the proposal options
prop_option_grp = getproposaloptionpanel(h);
prop_option_grp.RowSpan = [r r];r=r+1;
prop_option_grp.ColSpan = [1 1];


% make the variable persistent to improve performance.
persistent scl_name;
if isempty(scl_name)
    scl_name = DAStudio.message('FixedPoint:fixedPointTool:labelAutoscaling');
end
grp_scl.Name = scl_name;
grp_scl.Type = 'group';
grp_scl.Items = {pnl_apply, prop_option_grp};
grp_scl.LayoutGrid = [r-1 3];
grp_scl.Enabled = isenabled;

% [EOF]
