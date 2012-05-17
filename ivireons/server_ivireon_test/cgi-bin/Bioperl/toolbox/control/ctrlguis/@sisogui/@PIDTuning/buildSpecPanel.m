function Handles = buildSpecPanel(this)
%BUILDSPECPANEL  Build the Specification panel used for PID tuning.

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2010/04/11 20:29:56 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;

%% Main panel
CardNominal = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
title = BorderFactory.createTitledBorder([' ' ctrlMsgUtils.message('Control:compDesignTask:strSpecifications') ' ']);
CardNominal.setBorder(title);
gbc           = javaObjectEDT('java.awt.GridBagConstraints');
gbc.fill      = java.awt.GridBagConstraints.BOTH;
gbc.gridwidth = 1;
gbc.gridx     = 0;
gbc.gridy     = 0;
gbc.insets    = java.awt.Insets(0,0,0,0);
gbc.weightx   = 1;
gbc.weighty   = 1;
ScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane');
ScrollPane.setBorder(javax.swing.border.EmptyBorder(0,0,0,0))
ScrollPane.setVerticalScrollBarPolicy(ScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
CardNominal.add(ScrollPane,gbc);
PP_PID = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
PP_PID.setName('NorminalPID');

% common properties of GBC
GBc = javaObjectEDT('java.awt.GridBagConstraints');
GBc.insets = Insets(5,10,5,10);
GBc.fill = GridBagConstraints.HORIZONTAL;

%% Row 1: Tuning Methods Combobox
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 0;
GBc.gridwidth = 1;
LabelTitle = javaObjectEDT('com.mathworks.mwswing.MJLabel',ctrlMsgUtils.message('Control:compDesignTask:strDesignMethodLabel'));
PP_PID.add(LabelTitle, GBc);
% combobox
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
PIDComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox');
for ct = 1:length(this.TuningMethods)
    PIDComboBox.addItem(this.TuningMethods(ct).Desc);
end
PIDComboBox.setName('PIDComboBox');
PP_PID.add(PIDComboBox, GBc);

%% Individual Card Panel 1: Robust Response Time
hRRT = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
title = BorderFactory.createTitledBorder([' ' ctrlMsgUtils.message('Control:compDesignTask:strPIDoptions') ' ']);
hRRT.setBorder(title);
% Row 1
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 0;
GBc.gridwidth = 1;
LabelTitle = javaObjectEDT('com.mathworks.mwswing.MJLabel',ctrlMsgUtils.message('Control:compDesignTask:strPIDTypeLabel'));
hRRT.add(LabelTitle, GBc);
% P
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRRT1 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','P');
RadioRRT1.setName('RadioRRT1');
hRRT.add(RadioRRT1, GBc);
% I
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRRT2 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','I');
RadioRRT2.setName('RadioRRT2');
hRRT.add(RadioRRT2, GBc);
% PI
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 3;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRRT3 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','PI');
RadioRRT3.setName('RadioRRT3');
hRRT.add(RadioRRT3, GBc);
% PD
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 4;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRRT4 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','PD');
RadioRRT4.setName('RadioRRT4');
hRRT.add(RadioRRT4, GBc);
% PID
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 5;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRRT5 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','PID');
RadioRRT5.setName('RadioRRT5');
hRRT.add(RadioRRT5, GBc);
% Row 2
% checkbox
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 1;
GBc.gridwidth = 5;
CheckboxRRT = javaObjectEDT('com.mathworks.mwswing.MJCheckBox',ctrlMsgUtils.message('Control:compDesignTask:strPIDFilter'));
CheckboxRRT.setName('CheckboxRRT');
hRRT.add(CheckboxRRT, GBc);
% Row 3
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 2;
GBc.gridwidth = 1;
LabelTitle = javaObjectEDT('com.mathworks.mwswing.MJLabel',ctrlMsgUtils.message('Control:compDesignTask:strPIDOptionLabel'));
hRRT.add(LabelTitle, GBc);
% combobox
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 2;
GBc.gridwidth = 5;
OptionComboBox = javaObjectEDT('com.mathworks.mwswing.MJComboBox');
OptionComboBox.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDInteractivePanel1'));
OptionComboBox.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDInteractivePanel2'));
OptionComboBox.setName('OptionComboBox');
hRRT.add(OptionComboBox, GBc);
% Row 4
% interactive design panel
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 3;
GBc.gridwidth = 6;
DesignObjRRT = pidtool.ControllerDesignPanelAdvanced;
SliderPanel = DesignObjRRT.Handles.Panel;
SliderPanel.setBorder(javax.swing.border.EmptyBorder(0,0,0,0));
GBc.weighty = 1;
hRRT.add(SliderPanel, GBc);
GBc.weighty = 0;
% Row 5
% reset button
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 3;
GBc.gridy = 4;
GBc.gridwidth = 3;
ResetButton = javaObjectEDT('com.mathworks.mwswing.MJButton',ctrlMsgUtils.message('Control:compDesignTask:strPIDResetButton2'));
ResetButton.setName('ResetButton');
hRRT.add(ResetButton, GBc);

%% Individual Card Panel 2: Rule based
hRule = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
title = BorderFactory.createTitledBorder([' ' ctrlMsgUtils.message('Control:compDesignTask:strPIDoptions') ' ']);
hRule.setBorder(title);
% Row 1
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 0;
GBc.gridwidth = 1;
LabelTitle = javaObjectEDT('com.mathworks.mwswing.MJLabel',ctrlMsgUtils.message('Control:compDesignTask:strPIDTypeLabel'));
hRule.add(LabelTitle, GBc);
% P
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRule1 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','P');
RadioRule1.setName('RadioRule1');
hRule.add(RadioRule1, GBc);
% PI
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRule2 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','PI');
RadioRule2.setName('RadioRule2');
hRule.add(RadioRule2, GBc);
% PID
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 3;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRule3 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton','PID');
RadioRule3.setName('RadioRule3');
hRule.add(RadioRule3, GBc);
% PIDF
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 4;
GBc.gridy = 0;
GBc.gridwidth = 1;
RadioRule4 = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',ctrlMsgUtils.message('Control:compDesignTask:strPIDDesignFilter'));
RadioRule4.setName('RadioRule4');
hRule.add(RadioRule4, GBc);
% Row 2: formula selection
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 1;
GBc.gridwidth = 1;
LabelTitle = javaObjectEDT('com.mathworks.mwswing.MJLabel',ctrlMsgUtils.message('Control:compDesignTask:strPIDFormulaLabel'));
hRule.add(LabelTitle, GBc);
% combobox
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 1;
GBc.gridwidth = GridBagConstraints.REMAINDER;
ComboBoxRule = javaObjectEDT('com.mathworks.mwswing.MJComboBox');
ComboBoxRule.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDFormula1'));
ComboBoxRule.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDFormula2'));
ComboBoxRule.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDFormula3'));
ComboBoxRule.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDFormula4'));
ComboBoxRule.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDFormula5'));
ComboBoxRule.addItem(ctrlMsgUtils.message('Control:compDesignTask:strPIDFormula6'));
ComboBoxRule.setName('ComboBoxRule');
hRule.add(ComboBoxRule, GBc);
% Row 3: dummy panel
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 2;
GBc.gridwidth = 1;
GBc.weighty = 1;
hRule.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'), GBc);
GBc.weighty = 0;

%% Build Card Panel
PreferenceCard = javaObjectEDT('com.mathworks.mwswing.MJPanel',CardLayout);
PreferenceCard.add(hRRT,this.TuningMethods(1).Name);
PreferenceCard.add(hRule,this.TuningMethods(2).Name);
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 0;
GBc.gridy = 1;
GBc.gridwidth = GridBagConstraints.REMAINDER;
GBc.insets = Insets(5,5,5,10);
PP_PID.add(PreferenceCard, GBc);

%% filler panel
FillerPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 0;
GBc.gridy = 2;
GBc.weighty = 1;
GBc.insets = Insets(0,0,0,0);
GBc.gridwidth = GridBagConstraints.REMAINDER;
PP_PID.add(FillerPanel, GBc);

%% Add to main panel 
ScrollPane.setViewportView(PP_PID);     

%% Group the radio buttons
% RRT
GroupTypeRRT = javaObjectEDT('javax.swing.ButtonGroup');
GroupTypeRRT.add(RadioRRT1);
GroupTypeRRT.add(RadioRRT2);
GroupTypeRRT.add(RadioRRT3);
GroupTypeRRT.add(RadioRRT4);
GroupTypeRRT.add(RadioRRT5);
RadioRRT3.setSelected(true);
CheckboxRRT.setSelected(true);
DesignObjRRT.setVisible(false);
ResetButton.setVisible(false);
% Rule
GroupTypeRule = javaObjectEDT('javax.swing.ButtonGroup');
GroupTypeRule.add(RadioRule1);
GroupTypeRule.add(RadioRule2);
GroupTypeRule.add(RadioRule3);
GroupTypeRule.add(RadioRule4);
RadioRule2.setSelected(true);


%% Build special specification panel
CardBlank = utBuildSpecialSpec(this, this.Name, 'Blank');
CardConstrained = utBuildSpecialSpec(this, this.Name, 'Constrained',...
    ctrlMsgUtils.message('Control:compDesignTask:strPIDNoConstrained'));
CardImproperPlant = utBuildSpecialSpec(this, this.Name, 'ImproperPlant',...
    ctrlMsgUtils.message('Control:compDesignTask:strPIDNoImproperPlant'));

%% Assemble the card panel
PCard = javaObjectEDT('com.mathworks.mwswing.MJPanel',CardLayout);
PCard.add(CardBlank, 'Blank');
PCard.add(CardConstrained, 'Constrained');
PCard.add(CardImproperPlant, 'ImproperPlant');
PCard.add(CardNominal, 'Nominal');

%% Handles
Handles = struct(...
    'Panel', PCard, ...
    'PreferenceCard',PreferenceCard, ...    
    'PIDComboBox', PIDComboBox, ...
    'ComboBoxRule', ComboBoxRule, ...
    'CheckboxRRT', CheckboxRRT,...
    'OptionComboBox',OptionComboBox,...
    'ResetButton',ResetButton,...
    'GroupTypeRRT', GroupTypeRRT,...
    'GroupTypeRule', GroupTypeRule);
this.DesignObjRRT = DesignObjRRT;
    
%% Add callbacks
h = handle(PIDComboBox,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDComboBoxChange, this};
h = handle(OptionComboBox,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDModeChangeRRT, this};
h = handle(ResetButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDResetButtonRRT, this};

h = handle(RadioRRT1,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDTypeChange, this, false};
h = handle(RadioRRT2,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDTypeChange, this, false};
h = handle(RadioRRT3,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDTypeChange, this, true};
h = handle(RadioRRT4,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDTypeChange, this, true};
h = handle(RadioRRT5,'callbackproperties');
h.ActionPerformedCallback = {@LocalPIDTypeChange, this, true};


function LocalPIDComboBoxChange(~,~,this)
Handles = this.SpecPanelHandles;
idx = awtinvoke(Handles.PIDComboBox,'getSelectedIndex()');
awtinvoke(Handles.PreferenceCard.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
    Handles.PreferenceCard,java.lang.String(this.TuningMethods(idx+1).Name));


function LocalPIDTypeChange(~,~,this,IsPIPDPID)
this.DesignObjRRT.setPMVisible(IsPIPDPID);
if IsPIPDPID
    this.SpecPanelHandles.ResetButton.setLabel(ctrlMsgUtils.message('Control:compDesignTask:strPIDResetButton2'));
else
    this.SpecPanelHandles.ResetButton.setLabel(ctrlMsgUtils.message('Control:compDesignTask:strPIDResetButton1'));
end

function LocalPIDModeChangeRRT(~,~,this)
idx =  this.SpecPanelHandles.OptionComboBox.getSelectedIndex;
this.DesignObjRRT.setVisible(idx~=0);
this.SpecPanelHandles.ResetButton.setVisible(idx~=0);

function LocalPIDResetButtonRRT(~,~,this)
utUpdateFastDesign(this);


