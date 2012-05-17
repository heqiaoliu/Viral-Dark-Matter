function this = SelectNewLoopDlg(updatefcn,loopdata,ParentFrame,SISOTaskNode)
% Builds specified tab

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:45:47 $

this = jDialogs.SelectNewLoopDlg;

%% Store the constructor data
this.updatefcn = updatefcn;
this.SISOTaskNode = SISOTaskNode;
this.mapfile = fullfile(docroot,'toolbox','slcontrol','slcontrol.map');;
this.Handles.ParentFrame = ParentFrame;
this.loopdata = loopdata;

%% Build and show the dialog
this.build;
