function updatePanelsforNewOutput(this)
% update all the nlarx panels to reflect the truth for current output

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:53:55 $

Ind = this.getCurrentOutputIndex;

m = this.NlarxModel;
ynames = get(m,'OutputName');

% update instruction string
this.jMainPanel.setHowToFillTableLabel(ynames{Ind}); % event-thread method

% update regresor table
this.updateRegressorsPanel(m,Ind);
% rdata = this.computeStdRegTableData(Ind);
% rdata = nlutilspack.matlab2java(rdata);
% this.jRegTableModel.setData(rdata,[0,size(m,'nu')+1],0,size(rdata,1)-1);

% update nonlinearity and its options
this.updateCurrentNonlinOptionsPanel;

% update regressor editor dialog, if it is visible
if this.RegEditDialog.jMainPanel.isVisible
    this.RegEditDialog.updateDialogContents;
end

% update custom regressor dialog, if it is visible
if this.RegEditDialog.CustomRegEditDialog.jMainPanel.isVisible
    this.RegEditDialog.CustomRegEditDialog.updateDialogContents;
end
