function initialize(this)
% initialize nlarxpanel object's properties

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:53:34 $

import com.mathworks.toolbox.ident.nnbbgui.*;

%this.ActiveOutputIndex = 1;

% Get handle to model type combo
jh = this.RegDialog.jMainPanel.createCustomRegEditorDialog;
this.jMainPanel = jh; %main java panel for this object

% widgets on regressor editor dialog
this.jModelOutputCombo = jh.getOutputCombo;
%this.jCloseButton = jh.getCloseButton;
this.jHelpButton = jh.getHelpButton;
this.jCreateButton = jh.getCreateButton;
this.jRefreshButton = jh.getRefreshButton;
this.jCrossTermsCheckBox = jh.getCrossTermsCheckBox;
this.jButtonGroup = jh.getRegButtonGroup;
this.jOneAtATimeTable = jh.getOneAtATimeModeTable;
this.jBatchTable = jh.getBatchModeTable;
this.jExpressionEdit = jh.getExpressionEdit;

% update the contents of regressor dialog tables
this.updateDialogContents;

this.attachListeners;
