function openExportDlg(h,manager)

% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2005/07/14 15:25:09 $

%% Show the (singleton) export dialog (file chooser)
dlg = tsguis.allExportdlg;
dlg.initialize('file',manager.Figure,{h});
