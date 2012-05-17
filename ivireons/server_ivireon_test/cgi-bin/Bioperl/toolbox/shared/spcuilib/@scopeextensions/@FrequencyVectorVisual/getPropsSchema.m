function propsSchema = getPropsSchema(hCfg, hDlg)
%GETPROPSCHEMA Get the propSchema.

%   Author(s): J. Schickler
%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/03/08 21:43:49 $

% Get the 3 tabs.
main = groupToTab(getMainTab(hCfg), 'Main');
axis = groupToTab(getAxisTab(hCfg, hDlg), 'Axis Properties');

% Put the tabs together.
propsSchema.Type = 'tab';
propsSchema.Tabs = {main, axis};

% -------------------------------------------------------------------------
function main = getMainTab(hCfg)

grid    = uiscopes.getWidgetSchema(hCfg, 'Grid',    'checkbox', 1, 1);
legend  = uiscopes.getWidgetSchema(hCfg, 'Legend',  'checkbox', 2, 1);
compact = uiscopes.getWidgetSchema(hCfg, 'Compact', 'checkbox', 3, 1);

main.Type = 'group';
main.Name = uiscopes.message('ParametersLabel');
main.LayoutGrid = [6 2];
main.RowStretch = [0 0 0 0 0 1];
main.ColStretch = [0 1];
main.Items = {grid, legend, compact};

% -------------------------------------------------------------------------
function axis = getAxisTab(hCfg, hDlg)

units = uiscopes.getWidgetSchema(hCfg, 'NormalizedFrequencyUnits', 'checkbox', 1, 1);
[frange_lbl, frange] = uiscopes.getWidgetSchema(hCfg, 'FrequencyRange', 'combobox', 2, 1);

inherit = uiscopes.getWidgetSchema(hCfg, 'InheritSampleTime', 'checkbox', 3, 1);
inherit.DialogRefresh = true;

% XOffset and IncrementPerSample are visible when the
% InheritSampleIncrement is set to false.
visState = ~uiservices.getWidgetValue(inherit, hDlg);

[sampletime_lbl, sampletime] = uiscopes.getWidgetSchema(hCfg, ...
    'SampleTime', 'edit', 4, 1);
sampletime_lbl.Visible = visState;
sampletime.Visible = visState;

displaylimits = uiscopes.getWidgetSchema(hCfg, 'AutoDisplayLimits', 'checkbox', 5, 1);
displaylimits.DialogRefresh = true;

% MinimumXLim and MaximumXLim are visible when the AutoDisplayLimits are
% set to false.
visState = ~uiservices.getWidgetValue(displaylimits, hDlg);
[minxlim_lbl, minxlim] = extmgr.getWidgetSchema(hCfg, 'MinXLim', ...
    uiscopes.message('FrequencyMinXLimLabel'), 'edit', 6, 1);
minxlim_lbl.Visible = visState;
minxlim.Visible     = visState;

[maxxlim_lbl, maxxlim] = extmgr.getWidgetSchema(hCfg, 'MaxXLim', ...
    uiscopes.message('FrequencyMaxXLimLabel'), 'edit', 7, 1);
maxxlim_lbl.Visible = visState;
maxxlim.Visible     = visState;

[yscaling_lbl, yscaling] = uiscopes.getWidgetSchema(hCfg, 'YAxisScaling', 'combobox', 8, 1);

[ylabel_lbl,  ylabel]  = uiscopes.getWidgetSchema(hCfg, 'YLabel', 'edit', 9, 1);
[minylim_lbl, minylim] = uiscopes.getWidgetSchema(hCfg, 'MinYLim', 'edit', 10, 1);
[maxylim_lbl, maxylim] = uiscopes.getWidgetSchema(hCfg, 'MaxYLim', 'edit', 11, 1);

axis.Type = 'group';
axis.Name = uiscopes.message('ParametersLabel');
axis.LayoutGrid = [12 2];
axis.RowStretch = [zeros(1, 11) 1];
axis.ColStretch = [0 1];
axis.Items = {units, ...
    frange_lbl, frange, ...
    inherit, ...
    sampletime_lbl, sampletime, ...
    displaylimits, ...
    minxlim_lbl, minxlim, ...
    maxxlim_lbl, maxxlim, ...
    yscaling_lbl, yscaling, ...
    ylabel_lbl, ylabel, ...
    minylim_lbl, minylim, ...
    maxylim_lbl, maxylim};

% -------------------------------------------------------------------------
function tab = groupToTab(group, tabName)

tab.Name  = tabName;
tab.Items = {group};

% [EOF]
