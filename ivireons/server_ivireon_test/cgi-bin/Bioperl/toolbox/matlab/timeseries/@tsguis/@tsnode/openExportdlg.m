function openExportdlg(h,manager)

% Copyright 2004-2005 The MathWorks, Inc.

%% Show the (singleton) export dialog (file chooser)
dlg = tsguis.allExportdlg;
dlg.initialize('file',manager.Figure,{h});
