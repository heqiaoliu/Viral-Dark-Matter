function updateLinearPanelforNewOutput(this)
% update all the nlhw linear panel to reflect the truth for current output

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:28 $

Ind = this.getCurrentOutputIndex;

% update orders table
rdata = this.computeLinearTableData(Ind);
rdata = nlutilspack.matlab2java(rdata);
this.jLinearTableModel.setData(rdata,0,size(rdata,1)-1);

this.ActiveOutputIndex = Ind;
