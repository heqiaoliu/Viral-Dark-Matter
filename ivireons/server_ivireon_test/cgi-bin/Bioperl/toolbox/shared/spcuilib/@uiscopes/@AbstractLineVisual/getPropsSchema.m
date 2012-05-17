function propsSchema = getPropsSchema(hCfg, hDlg) %#ok<INUSD>
%GETPROPSSCHEMA Get the propsSchema.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/27 19:55:28 $

[vis_lbl,    vis]    = uiscopes.getWidgetSchema(hCfg, 'LineVisibilities', 'edit', 1, 1);
[style_lbl,  style]  = uiscopes.getWidgetSchema(hCfg, 'LineStyles', 'edit', 2, 1);
[marker_lbl, marker] = uiscopes.getWidgetSchema(hCfg, 'LineMarkers', 'edit', 3, 1);
[color_lbl,  color]  = uiscopes.getWidgetSchema(hCfg, 'LineColors', 'edit', 4, 1);

propsSchema.Type = 'group';
propsSchema.Name = uiscopes.message('ParametersLabel');
propsSchema.LayoutGrid = [5 2];
propsSchema.RowStretch = [0 0 0 0 1];
propsSchema.ColStretch = [0 1];
propsSchema.Items = {vis_lbl, vis, ...
    style_lbl, style, ...
    marker_lbl, marker, ...
    color_lbl, color};

% [EOF]
