function index = getUserSelectedIndex(this) 
% GETUSERSELECTEDINDEX  Show the dialog and wait for the user to make a
% selection.
%
 
% Author(s): John W. Glass 06-Sep-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/03/13 17:41:07 $

% Show the dialog
javaMethodEDT('show',this.Handles.Dialog);

% Wait for the selected index to be set
waitfor(this,'SelectedIndex');
index = this.SelectedIndex;