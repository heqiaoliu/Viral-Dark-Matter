function propsSchema = getPropsSchema(hCfg, hDlg)
%GETPROPSSCHEMA Get the propsSchema.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:25 $

% Add the autoscale mode combobox.
[mode_lbl, mode] = uiscopes.getWidgetSchema(hCfg, 'AutoscaleMode', 'combobox', 1, 1);
mode_lbl.ColSpan = [1 2];
mode.ColSpan = [3 3];
mode.DialogRefresh = true;

% Add the always expand checkbox.
expandonly = uiscopes.getWidgetSchema(hCfg, 'ExpandOnly', 'checkbox', 2, 2);
expandonly.ColSpan = [2 5];

% Determine if we should disable the expand checkbox.
val = uiservices.getWidgetValue(mode, hDlg);
if ischar(val) && strcmp(val, 'Auto') || ~ischar(val) && val == 1
    expandonly.Visible = true;
else
    expandonly.Visible = false;
end

yaxis.Type = 'text';
yaxis.Tag  = 'YAxisLabel';
yaxis.Name = 'Y-axis';
yaxis.ColSpan = [1 5];
yaxis.RowSpan = [3 3];

% Add the y-axis data range editbox.
[yrange_lbl, yrange] = uiscopes.getWidgetSchema(hCfg, 'YDataDisplay', 'edit', 4, 2);

% Add the yrange anchor "orientation" combobox.
[yanchor_lbl, yanchor] = uiscopes.getWidgetSchema(hCfg, 'AutoscaleYAnchor', 'combobox', 4, 4);

% Get the autoscale x-axis checkbox.
xaxis = uiscopes.getWidgetSchema(hCfg, 'AutoscaleXAxis', 'checkbox', 5, 1);
xaxis.ColSpan = [1 5];
xaxis.DialogRefresh = true;

% Add the x-axis data range editbox.
[xrange_lbl, xrange] = uiscopes.getWidgetSchema(hCfg, 'XDataDisplay', 'edit', 6, 2);

% Add the xrange anchor "orientation" combobox.
[xanchor_lbl, xanchor] = uiscopes.getWidgetSchema(hCfg, 'AutoscaleXAnchor', 'combobox', 6, 4);

% Disable the x-range items when the x-range is not being autoscaled.
val = uiservices.getWidgetValue(xaxis, hDlg);
xrange_lbl.Visible  = val;
xrange.Visible      = val;
xanchor_lbl.Visible = val;
xanchor.Visible     = val;

spacer.Type    = 'text';
spacer.Tag     = 'Spacer';
spacer.Name    = '  ';
spacer.ColSpan = [1 1];
spacer.RowSpan = [3 3];

propsSchema.Name = 'Parameters';
propsSchema.Type = 'group';
propsSchema.LayoutGrid = [7 5];
propsSchema.RowStretch = [0 0 0 0 0 0 1];
propsSchema.ColStretch = [0 1 2 1 2];
propsSchema.Items = {...
    mode_lbl, mode, ...
    expandonly, ...
    yaxis, ...
    spacer, ...
    yrange_lbl, yrange, ...
    yanchor_lbl, yanchor, ...
    xaxis, ...
    xrange_lbl, xrange, ...
    xanchor_lbl, xanchor};

% [EOF]
