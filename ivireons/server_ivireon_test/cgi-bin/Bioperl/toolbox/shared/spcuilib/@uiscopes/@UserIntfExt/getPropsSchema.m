function panel = getPropsSchema(hCfg, hDlg) %#ok<INUSD>
%GetPropsSchema Construct dialog panel for IMTool properties.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2010/03/31 18:44:28 $

%Title bar

if get(findProp(hCfg.PropertyDb, 'ShowFullPathAction'), 'Value')

    srcmode.Name           = 'Display the full source path in the title bar';
    srcmode.Type           = 'checkbox';
    srcmode.Source         = findProp(hCfg.PropertyDb, 'DisplayFullSourceName');
    srcmode.ObjectProperty = 'Value';
    srcmode.Tag            = 'DisplayFullSourcePath';
    srcmode.RowSpan        = [1 1];
    srcmode.ColSpan        = [1 3];
    items = {srcmode};
else
    items = {};
end

% MessageLog auto-open mode
autoopen.Name           = 'Open message log:';
autoopen.Type           = 'combobox';
autoopen.Source         = findProp(hCfg.PropertyDb, 'MessageLogAutoOpenMode');
autoopen.ObjectProperty = 'Value';
autoopen.Tag            = 'MessageLogOpens';
autoopen.RowSpan        = [2 2];
autoopen.ColSpan        = [1 3];

% NOTE:
% We do not provide a dialog widget for MessageLogDialogPosition.
% That's controlled only by moving the MessageLog dialog.

% % Clear preferences cache
% ccache.Name         = 'Clear extension cache';
% ccache.Type         = 'pushbutton';
% ccache.MatlabMethod = 'uiscopes.resetScopesDlg';
% ccache.Tag          = 'ClearExtensionCache';
% ccache.RowSpan      = [3 3];
% ccache.ColSpan      = [1 1];

% Define overall UserIntfExt properties panel
%
panel.Type       = 'group';
panel.Name       = 'General UI Options';
panel.LayoutGrid = [3 3];
panel.RowStretch = [0 0 1];
panel.ColStretch = [0 0 1];
panel.Items = [items {autoopen}];
% panel.Items = [items {autoopen,ccache}];


% [EOF]
