function openselectdlg(h)

% Copyright 2004 The MathWorks, Inc.

%% Show the (singleton) selection dialog
dlg = tsguis.selectrules(h.Parent);

%% Target the dialog and show it
dlg.update; % Make sure the selected time series match those in this view
dlg.Visible = 'on';
figure(double(dlg.Figure))
 
