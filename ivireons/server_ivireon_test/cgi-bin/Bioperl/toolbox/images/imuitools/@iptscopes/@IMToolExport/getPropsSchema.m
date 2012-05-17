function panel = getPropsSchema(hCfg, hDlg) %#ok<INUSD>
%GetPropsSchema Construct dialog panel for IMTool properties.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/04/27 19:48:30 $

imtool_exp.Name           = 'Open new Image Tool window for each export';
imtool_exp.Tag            = 'NewIMTool';
imtool_exp.Type           = 'checkbox';
imtool_exp.Source         = findProp(hCfg.PropertyDb,'NewIMTool');
imtool_exp.ObjectProperty = 'Value';
imtool_exp.RowSpan        = [1 1];
imtool_exp.ColSpan        = [1 1];

panel.Type       = 'group';
panel.Name       = 'Export to Image Tool Options';
panel.LayoutGrid = [2 1];
panel.RowStretch = [0 1];
panel.ColStretch = 0;
panel.Items      = {imtool_exp};

% [EOF]
