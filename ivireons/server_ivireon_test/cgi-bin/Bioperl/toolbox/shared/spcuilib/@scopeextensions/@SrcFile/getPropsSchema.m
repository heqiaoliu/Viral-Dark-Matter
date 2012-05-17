function panel = getPropsSchema(hCfg, hDlg) %#ok<INUSD>
%GetPropsSchema Construct dialog panel for SrcFile properties.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/04/27 19:54:14 $


% Recently opened file

connectFile.Name           = 'Default open file path:';
connectFile.Source         = findProp(hCfg.PropertyDb, 'LastConnectFileOpened');
connectFile.ObjectProperty = 'Value';
connectFile.Tag            = 'source_Files_LastConnectFileOpened';
connectFile.Type           = 'edit';
connectFile.RowSpan        = [1 1];
connectFile.ColSpan        = [1 1];

panel.Type = 'group';
panel.Name = 'File Source Options';
panel.LayoutGrid = [3 1];
panel.RowStretch = [0 0 1];
panel.Items = {connectFile};

% [EOF]
