function updateForNewInitialModel(this,Model)
% update nlarxpanel to reflect data for new Model.
% Model: idnlarx object. 

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 06:12:53 $

% first, make init_model compliant to data I/O.
messenger = nlutilspack.getMessengerInstance('OldSITBGUI'); %singleton
ze = messenger.getCurrentEstimationData;
Model.uname = ze.uname;
Model.yname = ze.yname;
this.updateModel(Model);

% update panels for current output only (others will be updated upon
% selection); updates nloptions object's "Object" too.
this.updatePanelsforNewOutput;
