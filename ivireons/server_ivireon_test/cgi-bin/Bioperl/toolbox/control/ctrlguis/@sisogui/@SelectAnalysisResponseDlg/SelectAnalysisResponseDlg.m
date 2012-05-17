function this = SelectAnalysisResponseDlg(updatefcn,loopdata,ParentFrame)
% Constructor for SelectAnalysisResponseDlg

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:42:04 $

this = sisogui.SelectAnalysisResponseDlg;

%% Store the constructor data
this.updatefcn = updatefcn;
this.loopdata = loopdata;
this.mapfile = fullfile(docroot,'toolbox','slcontrol','slcontrol.map');
this.Handles.ParentFrame = ParentFrame;

%% Build and show the dialog
this.build;
