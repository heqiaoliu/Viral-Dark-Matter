function openExportDlg(h,manager)

% Copyright 2005 The MathWorks, Inc.

%% Show the (singleton) export dialog (file chooser)
dlg = tsguis.allExportdlg;
dlg.initialize('file',manager.Figure,{h});
