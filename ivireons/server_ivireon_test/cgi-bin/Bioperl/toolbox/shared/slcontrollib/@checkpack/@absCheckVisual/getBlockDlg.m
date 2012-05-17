function dlg = getBlockDlg(this)
%
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:33 $

% GETBLOCKDLG return block dialog of the block this visualization is for
%

%Get handle to dialog
hBlk = this.Application.DataSource.BlockHandle;
dlgs = hBlk.getDialogSource.getOpenDialogs;
if isempty(dlgs)
   open_system(getFullName(hBlk),'mask');
   dlgs = hBlk.getDialogSource.getOpenDialogs;
   dlg  = dlgs{1};
   dlg.setActiveTab('tbpnlMain',0);
else
   dlg = dlgs{1};
end
end
