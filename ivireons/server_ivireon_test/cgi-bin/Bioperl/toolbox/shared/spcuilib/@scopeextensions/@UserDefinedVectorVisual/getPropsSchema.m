function propsSchema = getPropsSchema(hCfg, hDlg)
%GETPROPSCHEMA Get the propSchema.

%   Author(s): J. Schickler
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/08 21:44:02 $

% Get the 3 tabs.
main = groupToTab(getMainTab(hCfg), 'Main');
axis = groupToTab(getAxisTab(hCfg, hDlg), 'Axis Properties');

% Put the tabs together.
propsSchema.Type = 'tab';
propsSchema.Tabs = {main, axis};

% -------------------------------------------------------------------------
function main = getMainTab(hCfg)

[buffer_lbl, buffer] = uiscopes.getWidgetSchema(hCfg, 'DisplayBuffer', 'edit', 1, 1);

grid    = uiscopes.getWidgetSchema(hCfg, 'Grid',    'checkbox', 2, 1);
legend  = uiscopes.getWidgetSchema(hCfg, 'Legend',  'checkbox', 3, 1);
compact = uiscopes.getWidgetSchema(hCfg, 'Compact', 'checkbox', 4, 1);

main.Type = 'group';
main.Name = uiscopes.message('ParametersLabel');
main.LayoutGrid = [6 2];
main.RowStretch = [0 0 0 0 0 1];
main.ColStretch = [0 1];
main.Items = {buffer_lbl, buffer, grid, legend, compact};

% -------------------------------------------------------------------------
function axis = getAxisTab(hCfg, hDlg)

inherit = uiscopes.getWidgetSchema(hCfg, 'InheritSampleIncrement', 'checkbox', 1, 1);
inherit.DialogRefresh = true;

% XOffset and IncrementPerSample are visible when the
% InheritSampleIncrement is set to false.
visState = ~uiservices.getWidgetValue(inherit, hDlg);
[offset_lbl, offset] = uiscopes.getWidgetSchema(hCfg, 'XOffset', 'edit', 2, 1);
offset_lbl.Visible = visState;
offset.Visible = visState;

[increment_lbl, increment] = uiscopes.getWidgetSchema(hCfg, ...
    'IncrementPerSample', 'edit', 3, 1);
increment_lbl.Visible = visState;
increment.Visible = visState;

[xlabel_lbl, xlabel] = uiscopes.getWidgetSchema(hCfg, 'XLabel', 'edit', 4, 1);

displaylimits = uiscopes.getWidgetSchema(hCfg, 'AutoDisplayLimits', 'checkbox', 5, 1);
displaylimits.DialogRefresh = true;

% MinimumXLim and MaximumXLim are visible when the AutoDisplayLimits are
% set to false.
visState = ~uiservices.getWidgetValue(displaylimits, hDlg);
[minxlim_lbl, minxlim] = uiscopes.getWidgetSchema(hCfg, 'MinXLim', 'edit', 6, 1);
minxlim_lbl.Visible = visState;
minxlim.Visible     = visState;

[maxxlim_lbl, maxxlim] = uiscopes.getWidgetSchema(hCfg, 'MaxXLim', 'edit', 7, 1);
maxxlim_lbl.Visible = visState;
maxxlim.Visible     = visState;

[ylabel_lbl,  ylabel]  = uiscopes.getWidgetSchema(hCfg, 'YLabel', 'edit', 8, 1);
[minylim_lbl, minylim] = uiscopes.getWidgetSchema(hCfg, 'MinYLim', 'edit', 9, 1);
[maxylim_lbl, maxylim] = uiscopes.getWidgetSchema(hCfg, 'MaxYLim', 'edit', 10, 1);

axis.Type = 'group';
axis.Name = uiscopes.message('ParametersLabel');
axis.LayoutGrid = [11 2];
axis.RowStretch = [zeros(1, 10) 1];
axis.ColStretch = [0 1];
axis.Items = {inherit, ...
    offset_lbl, offset, ...
    increment_lbl, increment...
    xlabel_lbl, xlabel, ...
    displaylimits, ...
    minxlim_lbl, minxlim, ...
    maxxlim_lbl, maxxlim, ...
    ylabel_lbl, ylabel, ...
    minylim_lbl, minylim, ...
    maxylim_lbl, maxylim};

% -------------------------------------------------------------------------
function tab = groupToTab(group, tabName)

tab.Name  = tabName;
tab.Items = {group};

% [EOF]
