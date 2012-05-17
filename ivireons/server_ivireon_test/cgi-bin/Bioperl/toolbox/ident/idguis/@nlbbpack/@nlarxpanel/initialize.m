function initialize(this)
% initialize nlarxpanel object's properties

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:12:50 $

import com.mathworks.toolbox.ident.nnbbgui.*;

this.ActiveOutputIndex = 1;

% Get handle to model type combo
jh = this.jMainPanel; %main java panel for this object
this.jModelOutputCombo = jh.getOutputCombo;
this.jApplySettingsCheckBox = jh.getApplySettingsCheckBox;

% widgets on regressors panel
this.jInferDelayButton = jh.getInferDelayButton;
this.jEditRegButton = jh.getEditRegButton;
this.jRegTable = jh.getNlarxTable;
this.jRegTableModel = jh.getNlarxTableModel;

% widgets on model properties panel
this.jNonlinCombo = jh.getNonlinCombo;
this.jIncludeLinearModelCheckBox = jh.getIncludeLinearModelCheckBox;

% set default model
this.updateModel(this.createDefaultModel);

% find out if data has multiple output channels; if so, set the combo box
m = nlutilspack.getMessengerInstance;
if length(m.getOutputNames)>1
    this.isSingleOutput = false;
    jh.addMIMOOptionsInstructionsPanel;
    this.setOutputCombo;
end

% update instruction string
this.jMainPanel.setHowToFillTableLabel(m.getOutputNames{1}); % event-thread method

% set std regressor table
this.updateRegressorsPanel(this.NlarxModel,1);

% rdata = this.computeStdRegTableData;
% rdata = nlutilspack.matlab2java(rdata);
% this.jRegTableModel.setData(rdata,[0,length(m.getInputNames)+1],0,size(rdata,1)-1);

% create all options objects
LocalCreateOptionsObjects(this);

% nonlinearity (model) options object 
this.updateCurrentNonlinOptionsPanel;

% regressor editor dialog object
this.RegEditDialog = nlbbpack.regeditdialog(this);

% attach listeners to the java controls 
this.attachListeners;

%--------------------------------------------------------------------------
function LocalCreateOptionsObjects(this)

Names = cell(this.jMainPanel.getKnownNonlinTypeIDs);
for k = 1:length(Names)
    Name = Names{k};
    jh = this.jMainPanel.getModelPropsPanel(java.lang.String(Name));
    this.NonlinOptionsPanels.(Name) = this.createNonlinOptionsObject(jh,Name);
end
