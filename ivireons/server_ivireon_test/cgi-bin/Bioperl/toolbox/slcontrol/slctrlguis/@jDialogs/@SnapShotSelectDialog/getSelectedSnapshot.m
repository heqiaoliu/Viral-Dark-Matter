function snapshot = getSelectedSnapshot(this) 
% GETSELECTEDSNAPSHOT  Show the dialog and wait for the user to make a
% selection.
%
  
% Author(s): John W. Glass 06-Sep-2006
%   Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2009/05/23 08:21:50 $

% Show the dialog
javaMethodEDT('show',this.Handles.Dialog);

% Wait for the selected index to be set
% waitfor(this,'SelectedSnapshot');
snapshot = this.SelectedSnapshot;
