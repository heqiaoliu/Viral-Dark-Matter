function updateForNewInitialModel(this,Model)
% update nlhwpanel to reflect data for new Model.
% Model: idnlhw object. 

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:13:11 $

% first, make init_model compliant to data I/O.
messenger = nlutilspack.getMessengerInstance('OldSITBGUI'); %singleton
ze = messenger.getCurrentEstimationData;
Model.uname = ze.uname;
Model.yname = ze.yname;
this.updateModel(Model);

% update for current output only; other will be set when combo-box
% selection changes
this.updateLinearPanelforNewOutput;
this.updateNonlinPanelContents;
