function grp_log = getsimpanel(h)
%GETMMOPANEL   Get the mmopanel.

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/04/05 22:16:58 $

r = 1;
me = fxptui.getexplorer;

if(isempty(me))
    isStartEnabled = false;
else
    action = me.getaction('START');
    isStartEnabled = strcmp('on', action.enabled);
end

button_run.Type = 'pushbutton';
button_run.Tag = 'button_run';
button_run.Enabled = isStartEnabled;
button_run.MatlabMethod = 'fxptui.cb_simulation(''start'');';
% make the variable persistent to improve performance.
persistent run_ttip;
if isempty(run_ttip)
    run_ttip = DAStudio.message('FixedPoint:fixedPointTool:tooltipStart');
end
button_run.ToolTip = run_ttip; 
button_run.FilePath = fullfile(matlabroot, 'toolbox', 'fixedpoint', 'fixedpointtool', 'resources', 'start.png');
button_run.RowSpan = [r r];
button_run.ColSpan = [1 1];

txt_run.Type = 'text';
txt_run.Tag = 'txt_run';
% make the variable persistent to improve performance.
persistent run_txt;
if isempty(run_txt)
    run_txt = DAStudio.message('FixedPoint:fixedPointTool:tooltipStart');
end
txt_run.Name = run_txt;
txt_run.RowSpan = [r r];r=r+1;
txt_run.ColSpan = [2 2];

pnl_run.Type = 'panel';
pnl_run.RowSpan = [1 1];
pnl_run.ColSpan = [1 1];
pnl_run.LayoutGrid  = [1 3];
pnl_run.ColStretch = [0 0 1];
pnl_run.Items = {button_run, txt_run};

[listselection, list] = h.getmmo;
cbo_log.Value = listselection;
cbo_log.Type = 'combobox';
cbo_log.Tag = 'cbo_log';
% make the variable persistent to improve performance.
persistent log_txt;
if isempty(log_txt)
    log_txt = DAStudio.message('FixedPoint:fixedPointTool:labelLoggingMode');
end
cbo_log.Name = log_txt; 
cbo_log.NameLocation = 2;
cbo_log.Entries = list;
cbo_log.Enabled = h.isdominantsystem('MinMaxOverflowLogging') && isStartEnabled;
cbo_log.RowSpan = [r r];r=r+1;
cbo_log.ColSpan = [1 1];

[listselection, list] = h.getdto;
cbo_dt.Value = listselection;
cbo_dt.Type = 'combobox';
cbo_dt.Tag = 'cbo_dt';
% make the variable persistent to improve performance.
persistent dto_txt;
if isempty(dto_txt)
    dto_txt = DAStudio.message('FixedPoint:fixedPointTool:labelDataTypeOverride');
end
cbo_dt.Name = dto_txt;
cbo_dt.NameLocation = 2;
cbo_dt.Entries = list;
cbo_dt.Enabled = h.isdominantsystem('DataTypeOverride') && isStartEnabled;
cbo_dt.RowSpan = [r r];
cbo_dt.ColSpan = [1 1];
cbo_dt.MatlabMethod = 'updateDTOAppliesToControl';
cbo_dt.MatlabArgs  = {'%source','%dialog'};

[listselection, list] = h.getdtoappliesto;
cbo_dt_appliesto.Value = listselection;
cbo_dt_appliesto.Type = 'combobox';
cbo_dt_appliesto.Tag = 'cbo_dt_appliesto';
% make the variable persistent to improve performance.
persistent dto_txt_appliesto;
if isempty(dto_txt_appliesto)
    dto_txt_appliesto = DAStudio.message('FixedPoint:fixedPointTool:labelDataTypeOverrideAppliesTo');
end
cbo_dt_appliesto.Name = dto_txt_appliesto;
cbo_dt_appliesto.NameLocation = 2;
cbo_dt_appliesto.Entries = list;
appliesToDisablingSettings =   { DAStudio.message('FixedPoint:fixedPointTool:labelUseLocalSettings'), ...
    DAStudio.message('FixedPoint:fixedPointTool:labelForceOff')}';
cbo_dt_appliesto.Visible = h.isdominantsystem('DataTypeOverride') && ~ismember(cbo_dt.Value, appliesToDisablingSettings);
cbo_dt_appliesto.Enabled = cbo_dt.Enabled && isStartEnabled; 
cbo_dt_appliesto.RowSpan = [r r];
cbo_dt_appliesto.ColSpan = [2 2];


txt1.Type = 'text';
txt1.Name = '    ';
txt1.RowSpan = [r r];r=r+1;
txt1.ColSpan = [3 6];

%get the list of valid settings from the underlying object
%make the variables persistent to improve performance.
persistent label_overwrite;
persistent label_merge;
if isempty(label_overwrite)
    label_overwrite = DAStudio.message('FixedPoint:fixedPointTool:labelOverwrite');
end
if isempty(label_merge)
    label_merge = DAStudio.message('FixedPoint:fixedPointTool:labelMerge');
end
labels = {label_overwrite, label_merge}; %leave a space after single words for xlate
% get the setting from the underlying object
me = fxptui.getexplorer;
if(isempty(me))
    str = '';
else
    objval = me.getRoot.daobject.MinMaxOverflowArchiveMode;
    % use a switchyard instead of ismember() to improve performance.
    switch objval
      case 'Overwrite'
        str = label_overwrite;
      case 'Merge'
        str = label_merge;
      otherwise
        %do nothing
    end
end
cbo_arch.Type = 'combobox';
cbo_arch.Value = str;
cbo_arch.Tag = 'cbo_arch';
% make the variable persistent to improve performance.
persistent arch_txt;
if isempty(arch_txt)
    arch_txt = DAStudio.message('FixedPoint:fixedPointTool:labelMergeOverwrite');
end
cbo_arch.Name = arch_txt;
cbo_arch.NameLocation = 2;
cbo_arch.Entries = labels;
cbo_arch.Enabled = isStartEnabled;
cbo_arch.RowSpan = [r r];r=r+1;
cbo_arch.ColSpan = [1 1];

txt2.Type = 'text';
txt2.Name = '';
txt2.RowSpan = [r r];
txt2.ColSpan = [1 6];

% make the variable persistent to improve performance.
persistent sim_setting_txt;
if isempty(sim_setting_txt)
    sim_setting_txt = DAStudio.message('FixedPoint:fixedPointTool:labelSimulationSettings');
end
grp_log.Name = sim_setting_txt;
grp_log.Type = 'group';
grp_log.Items = {pnl_run, cbo_log, cbo_dt, cbo_dt_appliesto, txt1, cbo_arch, txt2};
grp_log.LayoutGrid = [r 6];
grp_log.RowStretch = [0 0 0 0 1];
grp_log.ColStretch = [0 0 0 0 0 1];
grp_log.Enabled = isStartEnabled;

% [EOF]
