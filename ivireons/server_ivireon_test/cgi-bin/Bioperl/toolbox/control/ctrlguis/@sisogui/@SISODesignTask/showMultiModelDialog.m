function showMultiModelDialog(this)
% showExportDialog Open export dialog

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 16:59:08 $

% Opens export dialog
MultiModelDialog = this.MultiModelDialog;
if isempty(MultiModelDialog)
   % Create export dialog
   this.MultiModelDialog = sisogui.MultiModelDialog(this.Parent);
   setLocationRelativeTo(this.MultiModelDialog.Frame, slctrlexplorer);
else
   % Bring it up front
   MultiModelDialog.Frame.setMinimized(false);
   MultiModelDialog.Frame.setVisible(false);
   MultiModelDialog.Frame.setVisible(true);
end




