function panel = getPropsSchema(hCfg, ~)
%GETPROPSSCHEMA Get the propsSchema.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:20 $

[npoints_lbl, npoints] = uiscopes.getWidgetSchema(hCfg, 'PointsPerSignal', 'edit', 1, 1);

% Define overall UserIntfExt properties panel
panel.Type       = 'group';
panel.Name       = 'Data History Options';
panel.LayoutGrid = [2 2];
panel.RowStretch = [0 1];
panel.Items      = {npoints_lbl, npoints};

% [EOF]
