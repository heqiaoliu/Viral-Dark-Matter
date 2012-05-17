function grp_res = getrespanel(h)
%GETRESPANEL   Get the results panel.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/02/18 02:07:03 $

r = 1;
me = fxptui.getexplorer;

isenabled = false;
if(~isempty(me) && ~isempty(me.getaction('VIEW_AUTOSCALEINFO')))
  isenabled = isequal('on', me.getaction('VIEW_AUTOSCALEINFO').Enabled);
end

button_info.Type = 'pushbutton';
button_info.Tag = 'button_info';
button_info.Enabled = isenabled;
button_info.MatlabMethod = 'fxptui.cb_scaleinfo;';
% make the variable persistent to improve performance.
persistent toolTip;
if isempty(toolTip)
    toolTip = DAStudio.message('FixedPoint:fixedPointTool:labelAUTOSCALEINFO');
end
button_info.ToolTip = toolTip; 
button_info.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'info.png');
button_info.RowSpan = [r r];
button_info.ColSpan = [1 1];

txt_info.Type = 'text';
txt_info.Tag = 'txt_info';
% make the variable persistent to improve performance.
persistent textName;
if isempty(textName)
    textName = DAStudio.message('FixedPoint:fixedPointTool:labelAUTOSCALEINFO');
end
txt_info.Name = textName;
txt_info.RowSpan = [r r];r=r+1;
txt_info.ColSpan = [2 3];

isenabled = false;
if(~isempty(me) && ~isempty(me.getaction('RESULTS_SWAPRUNS')))
  isenabled = isequal('on', me.getaction('RESULTS_SWAPRUNS').Enabled);
end

button_swap.Type = 'pushbutton';
button_swap.Tag = 'button_swap';
button_swap.Enabled = isenabled;
button_swap.MatlabMethod = 'fxptui.cb_swapruns;';
% make the variable persistent to improve performance.
persistent swaptoolTip;
if isempty(swaptoolTip)
    swaptoolTip = DAStudio.message('FixedPoint:fixedPointTool:tooltipRESULTSSWAPRUNS');
end
button_swap.ToolTip = swaptoolTip; 
button_swap.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'result3.png');
button_swap.RowSpan = [r r];
button_swap.ColSpan = [1 1];

txt_swap.Type = 'text';
txt_swap.Tag = 'txt_swap';
% make the variable persistent to improve performance.
persistent swapruns;
if isempty(swapruns)
    swapruns = DAStudio.message('FixedPoint:fixedPointTool:labelRESULTSSWAPRUNS');
end
txt_swap.Name = swapruns;
txt_swap.RowSpan = [r r];r=r+1;
txt_swap.ColSpan = [2 3];

pnl_info.Type = 'panel';
pnl_info.RowSpan = [1 1];
pnl_info.ColSpan = [1 1];
pnl_info.LayoutGrid  = [1 3];
pnl_info.ColStretch = [0 0 1];
pnl_info.Items = {button_info, txt_info, button_swap, txt_swap};

% make the variable persistent to improve performance.
persistent grp_name;
if isempty(grp_name)
    grp_name = DAStudio.message('FixedPoint:fixedPointTool:labelResults');
end
grp_res.Name = grp_name; 
grp_res.Type = 'group';
grp_res.Items = {pnl_info};
grp_res.LayoutGrid = [1 3];
grp_res.Enabled = isenabled;

% [EOF]
