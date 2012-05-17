function showDlgTab(this,tabName) 
% SHOWDLGTAB open the block dialog with a specified tab showing
%
 
% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:51 $

%Find tab to show
switch tabName
   case 'tabLinearization'
      idx = 0;
   case 'tabBounds'
      idx = 1;
   case 'tabLogging'
      idx = 2;
   case 'tabAssertion'
      idx = 3;
   otherwise
      idx = 0;
end

%Show dialog and tab
dlg = this.getBlockDlg;
dlg.setActiveTab('tbpnlMain',idx);
show(dlg);
end