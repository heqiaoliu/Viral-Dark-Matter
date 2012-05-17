function initialize(this)
% initialize nlarxpanel object's properties

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:41:54 $

import com.mathworks.toolbox.ident.nnbbgui.*;

this.ActiveOutputIndex = this.NlarxPanel.getCurrentOutputIndex;
this.ActiveRegIndex = 1;
this.ModelCopy = this.NlarxPanel.NlarxModel;

% Get handle to model type combo
jh = this.NlarxPanel.jMainPanel.getRegressorEditorDialog;
this.jMainPanel = jh; %main java panel for this object

% widgets on regressor editor dialog
%this.jModelOutputCombo = jh.getOutputCombo;
this.jRegTypesCombo = jh.getRegTypesCombo;

% this.jCloseButton = jh.getCloseButton;
% this.jHelpButton = jh.getHelpButton;
% this.jAutoSelectCheckBox = jh.getAutoSelectCheckBox;

this.jStdRegTable = jh.getStdRegTable;
this.jCustomRegTable = jh.getCustomRegTable;
this.jStdTableModel = jh.getStdTableModel;
this.jCustomTableModel = jh.getCustomTableModel;

% this.jAddCustomRegButton = jh.getAddCustomRegButton;
% this.jImportCustomRegButton = jh.getImportCustomRegButton;
% this.jDeleteCustomRegButton = jh.getDeleteCustomRegButton;

this.CustomRegEditDialog = nlbbpack.customregeditdialog(this);

% update outputs combo
%this.setOutputCombo;

this.attachListeners;
