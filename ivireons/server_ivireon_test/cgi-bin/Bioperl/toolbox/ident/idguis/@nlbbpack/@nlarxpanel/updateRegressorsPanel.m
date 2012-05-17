function updateRegressorsPanel(this,m,Ind)
% update regressors
% m: handle to nlarxmodel
% Ind: output number for which regressor panel should be updated

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:41:47 $

if (Ind~=this.getCurrentOutputIndex)
   % data for non-visible output was changed
   return;
end

% update regressor table
rdata = this.computeStdRegTableData(Ind);
rdata = nlutilspack.matlab2java(rdata);
this.jRegTableModel.setData(rdata,[0,size(m,'nu')+1],0,size(rdata,1)-1);

% set custom reg note
cust = m.CustomReg;
msg = 'Note: Model has no custom regressors.';
msg1 = 'Note: Custom regressors exist for this output. Click on Edit Regressors... to view/modify them.';
if (this.isSingleOutput && ~isempty(cust)) || (~this.isSingleOutput && ~isempty(cust{Ind}))
    msg = msg1;
elseif ~this.isSingleOutput
    msg = 'Note: Model has no custom regressors for this output.';
end

this.jMainPanel.setCutomRegNote(msg); %event-thread method
