function this = SelectNewLoopDlg(updatefcn,loopdata,ParentFrame)
% Builds specified tab

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2005/11/15 00:50:15 $

this = sisogui.SelectNewLoopDlg;

%% Store the constructor data
this.updatefcn = updatefcn;
this.loopdata = loopdata;
this.mapfile = fullfile(docroot,'toolbox','slcontrol','slcontrol.map');
this.Handles.ParentFrame = ParentFrame;

%% Build and show the dialog
this.build;
