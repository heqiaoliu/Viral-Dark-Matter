function panel = getPropsSchema(hCfg, hDlg) %#ok<INUSD>
%GetPropsSchema Construct dialog panel for SrcFile properties.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/10/29 16:08:43 $


% Recently opened file

open = uiscopes.getWidgetSchema(hCfg, 'OpenSimulinkModel', 'checkbox', 1, 1);

[probing_lbl, probing] = uiscopes.getWidgetSchema(hCfg, 'ProbingSupport', 'combobox', 2, 1);
probing.Entries = {uiscopes.message('SignalLines'), uiscopes.message('SignalLinesOrBlocks')};

% Define overall UserIntfExt properties panel
%
panel.Type       = 'group';
panel.Name       = 'Simulink Source Options';
panel.LayoutGrid = [3 2];
panel.RowStretch = [0 0 1];
panel.Items = {open, probing_lbl, probing};

% [EOF]
