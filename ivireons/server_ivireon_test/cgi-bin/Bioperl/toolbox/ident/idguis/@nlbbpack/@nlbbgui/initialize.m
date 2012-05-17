function initialize(this)
% spawn java gui frame and attach listeners to active components 

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/07/18 15:52:52 $

% spawn nonlinear black box gui (java)

this.jGuiFrame = javaObjectEDT('com.mathworks.toolbox.ident.nnbbgui.NNBBGuiFrame'); %NNBBGuiFrame; %spawn nnbb (java) gui

this.ModelTypePanel = nlbbpack.modeltypepanel(this.getJavaModelTypePanel);

this.EstimationPanel = nlbbpack.estimationpanel(this.getJavaEstimationPanel);

% Get handle to the estimate button
this.jEstimateButton = this.jGuiFrame.getMainPanel.getEstButton;

% Attach listeners to the java controls 
this.attachListeners;

this.EstimationPanel.updateAlgorithmProperties(this.ModelTypePanel.getCurrentModel,this);
