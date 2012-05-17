function this = regeditdialog(nlarxpanelobj)
% Regressor Editor Dialog object.
% nlarxpanelobj: handle to nlarxpanel udd object

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:34 $

this = nlbbpack.regeditdialog;

this.NlarxPanel = nlarxpanelobj;

%this.jMainPanel = h; %main Model Type panel
this.initialize;

