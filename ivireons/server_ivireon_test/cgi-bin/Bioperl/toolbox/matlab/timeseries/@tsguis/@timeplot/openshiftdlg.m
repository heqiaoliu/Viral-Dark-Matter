function openshiftdlg(h)

% Copyright 2004-2005 The MathWorks, Inc.

%% Show the (singleton) selection dialog

dlg = tsguis.shiftdlg(h.Parent);
dlg.Visible = 'on';
figure(dlg.Figure)
