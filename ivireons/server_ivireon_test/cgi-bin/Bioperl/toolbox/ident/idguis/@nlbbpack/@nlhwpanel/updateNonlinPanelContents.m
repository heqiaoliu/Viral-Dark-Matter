function updateNonlinPanelContents(this)
% update the table on i/o NL panel for nlhw models

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:29 $
% Written by Rajiv Singh.

m = nlutilspack.getMessengerInstance;
rdata = this.computeNonlinTableData;
rdata = nlutilspack.matlab2java(rdata);
this.jNonlinTableModel.setData(rdata,[0,length(m.getInputNames)+1],0,size(rdata,1)-1);