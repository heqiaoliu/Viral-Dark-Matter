function this = customregeditdialog(regdialog)
% Regressor Editor Dialog object.
% nlarxpanelobj: handle to nlarxpanel udd object

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:24 $

this = nlbbpack.customregeditdialog;

this.RegDialog = regdialog;
this.NlarxPanel = regdialog.NlarxPanel;

%this.jMainPanel = h; %main Model Type panel
this.initialize;
