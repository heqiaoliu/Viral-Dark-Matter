function initialize(this)
% initialize nlarxpanel object's properties

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:19 $
% Written by Rajiv Singh.

import com.mathworks.toolbox.ident.nnbbgui.*;

this.ActiveOutputIndex = 1;

% Get handle to model type combo
jh = this.jMainPanel; %main java panel for this object

% linear block tab
this.jInferDelayButton = jh.getInferDelayButton;
this.jLinearTable = jh.getLinearTable;
this.jLinearTableModel = jh.getLinearTableModel;
this.jModelOutputCombo = jh.getOutputCombo;
this.jApplySettingsCheckBox = jh.getApplySettingsCheckBox;

% nonlinear options tab
this.jNonlinTable = jh.getNonlinTable;
this.jNonlinTableModel = jh.getNonlinTableModel;

% set default model
this.NlhwModel = this.createDefaultModel;

% find out if data has multiple output channels; if so, set the combo box
% in the linear block tab
m = nlutilspack.getMessengerInstance;
if length(m.getOutputNames)>1
    this.isSingleOutput = false;
    jh.addChooseOutputPanel;
    this.setOutputCombo;
end

if length(m.getInputNames)>1
     this.isSingleInput = false;
end

% set linear orders table
this.updateLinearPanelforNewOutput;

% nonlinear options table
this.updateNonlinPanelContents;

% create wavenet options handler
this.WavenetAdvancedOptions = nloptionspack.advancedwavenet(this); 

% attach listeners to the java controls 
this.attachListeners;
