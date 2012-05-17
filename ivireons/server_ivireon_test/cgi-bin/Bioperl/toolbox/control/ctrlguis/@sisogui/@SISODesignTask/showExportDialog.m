function showExportDialog(this)
% showExportDialog Open export dialog

%   Author(s): C. Buhr
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:10:35 $

% Opens export dialog
ExportFrame = this.ExportDialog;
if isempty(ExportFrame)
   % Create export dialog
   this.ExportDialog = this.Parent.exportdlg;
else
   % Bring it up front
   ExportFrame.setMinimized(false);
   ExportFrame.setVisible(false);
   ExportFrame.setVisible(true);
end



