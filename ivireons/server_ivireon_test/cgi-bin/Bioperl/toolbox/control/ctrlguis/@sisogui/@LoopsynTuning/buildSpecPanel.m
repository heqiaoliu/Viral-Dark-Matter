function Handles = buildSpecPanel(this)
%BUILDSPECPANEL  Build the Specification panel of a tuning method.

%   Author(s): C. Buhr
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/04/21 03:07:53 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;
import com.mathworks.toolbox.control.dialogs.*;
import com.mathworks.toolbox.control.sisogui.*;

% Specification Panel
SpecPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
SpecPanel.setLayout(java.awt.CardLayout());

BlankCard = utBuildSpecialSpec(this, this.Name, 'BlankCard');

RobustRequiredCard = utBuildSpecialSpec(this, this.Name, 'RobustRequiredCard', ...
    xlate('Robust Control Toolbox is required for this tuning method.'));

NotTunableCard = utBuildSpecialSpec(this, this.Name, 'NotTunableCard', ...
    sprintf('Loop shaping method cannot be applied to a compensator with any constraints on its pole(s), zero(s), or gain.'));

ImproperPlantCard = utBuildSpecialSpec(this, this.Name, 'ImproperPlant',...
    sprintf('The selected tuning method cannot be applied to this compensator. The open-loop model with respect to this compensator has more zeros than poles.'));

FRDPlantCard = utBuildSpecialSpec(this, this.Name, 'FRDPlant',...
    ctrlMsgUtils.message('Control:compDesignTask:AutomatedTuningFRDPlant'));


TuningPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
TuningPanel.setName('LoopSyn');
title = BorderFactory.createTitledBorder(xlate(' Specifications '));
TuningPanel.setBorder(title);

% common properties of GBC 
GBc = GridBagConstraints; 
GBc.insets=Insets(5,10,5,10); 
GBc.fill = GridBagConstraints.HORIZONTAL; 

%% Selection Panel
SelectionPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.LEFT));
% Row 1 
GBc.anchor = GridBagConstraints.EAST; 
GBc.gridx = 0; 
GBc.gridy = 0; 
GBc.gridwidth = 1; 
GBc.weightx = 0; 
TuningPanel.add(SelectionPanel,GBc); 
% Selection Label
LabelTitle = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Tuning preference:'));
SelectionPanel.add(LabelTitle);

% Target Bandwidth
RadioBandwidth = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',sprintf('Target bandwidth'));
RadioBandwidth.setName('RadioBandwidth');
RadioBandwidth.doClick;
h = handle(RadioBandwidth, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalShowCard this 'TargetBandwidth'};
SelectionPanel.add(RadioBandwidth);

% Target Loop Shape
RadioLoopShape = javaObjectEDT('com.mathworks.mwswing.MJRadioButton',sprintf('Target loop shape'));
RadioLoopShape.setName('RadioLoopShape');
h = handle(RadioLoopShape, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalShowCard this 'TargetLoopShape'};
SelectionPanel.add(RadioLoopShape);

% Create Button group
BtnGroup = javaObjectEDT('javax.swing.ButtonGroup');
BtnGroup.add(RadioBandwidth);
BtnGroup.add(RadioLoopShape);
 
% Create Card panels
LoopShapeCardHandles = LocalBuildTargetLoopSpecPanel(this);
BandwidthCardHandles = LocalBuildBandwidthSpecPanel(this);

% Create the card panel
CardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
CardPanel.setLayout(java.awt.CardLayout());
CardPanel.add(LoopShapeCardHandles.Panel,'TargetLoopShape');
CardPanel.add(BandwidthCardHandles.Panel,'TargetBandwidth');
% Row 2 
GBc.anchor = GridBagConstraints.EAST; 
GBc.gridx = 0; 
GBc.gridy = 1; 
GBc.gridwidth = 1; 
GBc.weightx = 0; 
TuningPanel.add(CardPanel,GBc) 

% filler panel 
FillerPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel'); 
GBc.anchor = GridBagConstraints.WEST; 
GBc.gridx = 0; 
GBc.gridy = 2; 
GBc.weighty = 1; 
GBc.gridwidth = 1; 
TuningPanel.add(FillerPanel, GBc); 

%% Add individual specifcations panels to main panel
SpecPanel.add(BlankCard,'BlankCard');
SpecPanel.add(RobustRequiredCard,'RobustRequiredCard');
SpecPanel.add(NotTunableCard,'NotTunableCard');
SpecPanel.add(TuningPanel,'TuningPanel');
SpecPanel.add(ImproperPlantCard,'ImproperPlantCard');
SpecPanel.add(FRDPlantCard,'FRDPlantCard');

Handles = struct(...
    'Panel', SpecPanel, ...
    'CardPanel', CardPanel, ...
    'LoopShapeCardHandles', LoopShapeCardHandles, ...
    'LoopShapeRadioBtn',RadioLoopShape, ...
    'BandwidthCardHandles', BandwidthCardHandles, ...
    'BandwidthRadioBtn', RadioBandwidth);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions


%% Bandwidth specification panel
function Handles = LocalBuildBandwidthSpecPanel(this)

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;




BandwidthPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
BandwidthPanel.setName('BandwidthPanel');

% common properties of GBC
GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.fill = GridBagConstraints.HORIZONTAL;
GBc.weighty = 0;
GBc.weightx = 0;

% Row 1
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 0;
GBc.gridwidth = 1;
Label1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Target open-loop bandwidth:'));
BandwidthPanel.add(Label1, GBc);
% wc
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 0;
GBc.gridwidth = 1;
Edit_Bandwidth = javaObjectEDT('com.mathworks.mwswing.MJTextField');
Edit_Bandwidth.setName('Edit_Bandwidth');
BandwidthPanel.add(Edit_Bandwidth, GBc);
% empty label
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
FillJunk = javaObjectEDT('com.mathworks.mwswing.MJLabel',blanks(10));
BandwidthPanel.add(FillJunk, GBc);

% set listener
h = handle(Edit_Bandwidth, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalUpdateBandwidthTarget this};
h.FocusLostCallback = {@LocalUpdateBandwidthTarget this};

% Row 2
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 1;
GBc.gridwidth = 1;
Label2 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Desired controller order:'));
BandwidthPanel.add(Label2, GBc);
% slider
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 1;
GBc.gridwidth = 1;
GBc.weightx = 1;
Edit_CompensatorOrder = javaObjectEDT('com.mathworks.mwswing.MJSlider');
Edit_CompensatorOrder.setName('CompensatorOrder');
labelTable = Hashtable();
awtinvoke(Edit_CompensatorOrder,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
BandwidthPanel.add(Edit_CompensatorOrder, GBc);
% editbox
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 1;
GBc.gridwidth = GridBagConstraints.REMAINDER;
GBc.weightx = 0;
numberFormat = java.text.NumberFormat.getIntegerInstance();
formatter = javax.swing.text.NumberFormatter(numberFormat);
Edit_OrderField = javaObjectEDT('com.mathworks.mwswing.MJFormattedTextField',formatter);
Edit_OrderField.setName('Edit_OrderField');
BandwidthPanel.add(Edit_OrderField, GBc);

Handles = struct(...
    'Panel', BandwidthPanel, ...
    'Edit_TargetBandwidth', Edit_Bandwidth, ...
    'Edit_CompensatorOrder', Edit_CompensatorOrder, ...
    'Edit_OrderField', Edit_OrderField);


h = handle(Handles.Edit_CompensatorOrder, 'callbackproperties');
h.StateChangedCallback  = {@LocalSlider this};
h = handle(Handles.Edit_OrderField, 'callbackproperties');
h.ActionPerformedCallback  = {@LocalEditor this};
h = handle(Handles.Edit_OrderField, 'callbackproperties');
h.FocusLostCallback  = {@LocalEditor this};


%% TargetLoop specification panel
function Handles = LocalBuildTargetLoopSpecPanel(this)

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;
import com.mathworks.mwswing.*;


TargetShapePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
TargetShapePanel.setName('TargetShapePanel');

% common properties of GBC
GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.fill = GridBagConstraints.HORIZONTAL;
GBc.weighty = 0;
GBc.weightx = 0;

% Row 1
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 0;
GBc.gridwidth = 1;
Label1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Target open-loop shape (LTI):'));
TargetShapePanel.add(Label1, GBc);
% wc
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 0;
GBc.gridwidth = 1;
Edit_TargetShape = javaObjectEDT('com.mathworks.mwswing.MJTextField');
Edit_TargetShape.setName('Edit_TargetShape');
TargetShapePanel.add(Edit_TargetShape, GBc);
% empty label
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
FillJunk = javaObjectEDT('com.mathworks.mwswing.MJLabel','          ');
TargetShapePanel.add(FillJunk, GBc);

h = handle(Edit_TargetShape, 'callbackproperties');
h.ActionPerformedCallback  = {@LocalUpdateLoopShapeTarget this};
h.FocusLostCallback = {@LocalUpdateLoopShapeTarget this};

% Row 2
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 1;
GBc.gridwidth = 2;

FreqRangePanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.LEFT,0,0));
% FreqRangeCheckbox = MJCheckBox();
LabelFreqRange = javaObjectEDT('com.mathworks.mwswing.MJLabel',[sprintf('Frequency range for loop shaping [wmin,wmax]:'),'   ']);
Edit_FreqRange = javaObjectEDT('com.mathworks.mwswing.MJTextField','[0,inf]',10);
% awtinvoke(Edit_FreqRange,'setEnabled(Z)',false);
% FreqRangePanel.add(FreqRangeCheckbox);
FreqRangePanel.add(LabelFreqRange);
FreqRangePanel.add(Edit_FreqRange);
TargetShapePanel.add(FreqRangePanel, GBc);


% h = handle(FreqRangeCheckbox, 'callbackproperties');
% h.ActionPerformedCallback  = @(es,ed) LocalUpdateCheckBox(this);
h = handle(Edit_FreqRange, 'callbackproperties');
h.ActionPerformedCallback  = {@LocalUpdateFreqRange this};
h.FocusLostCallback = {@LocalUpdateFreqRange this};

% Row 3
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 2;
GBc.gridwidth = 1;
Label2 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Desired controller order:'));
TargetShapePanel.add(Label2, GBc);
% slider
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 2;
GBc.gridwidth = 1;
GBc.weightx = 1;
Edit_CompensatorOrder = javaObjectEDT('com.mathworks.mwswing.MJSlider');
Edit_CompensatorOrder.setName('CompensatorOrder');
labelTable = Hashtable();
awtinvoke(Edit_CompensatorOrder,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
TargetShapePanel.add(Edit_CompensatorOrder, GBc);
% editbox
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 2;
GBc.gridwidth = GridBagConstraints.REMAINDER;
GBc.weightx = 0;
numberFormat = java.text.NumberFormat.getIntegerInstance();
formatter = javax.swing.text.NumberFormatter(numberFormat);
Edit_OrderField = javaObjectEDT('com.mathworks.mwswing.MJFormattedTextField',formatter);
Edit_OrderField.setName('Edit_OrderField');
TargetShapePanel.add(Edit_OrderField, GBc);

Handles.Panel = TargetShapePanel;
Handles = struct(...
    'Panel', TargetShapePanel, ...
    'Edit_FreqRange', Edit_FreqRange,...% 'CheckBox_FreqRange', FreqRangeCheckbox,... 
    'Edit_TargetShape', Edit_TargetShape, ...
    'Edit_CompensatorOrder', Edit_CompensatorOrder, ...
    'Edit_OrderField', Edit_OrderField);

% initialize order slider and text field
h = handle(Handles.Edit_CompensatorOrder, 'callbackproperties');
h.StateChangedCallback  = {@LocalSlider this};
h = handle(Handles.Edit_OrderField, 'callbackproperties');
h.ActionPerformedCallback  = {@LocalEditor this};
h = handle(Handles.Edit_OrderField, 'callbackproperties');
h.FocusLostCallback  = {@LocalEditor this};

%%
function LocalShowCard(es, ed, this, Card)
awtinvoke(this.SpecPanelHandles.CardPanel.getLayout,'show(Ljava.awt.Container;Ljava.lang.String;)',...
        this.SpecPanelHandles.CardPanel,java.lang.String(Card));
this.TuningPreference{this.idxC} = Card; 
this.refreshSpecPanel;

    
%% Order: slider and text field callbacks
function LocalSlider(es, ed, this)
if strcmp(this.TuningPreference{this.idxC},'TargetLoopShape')
    Handles = this.SpecPanelHandles.LoopShapeCardHandles;
else
    Handles = this.SpecPanelHandles.BandwidthCardHandles;
end
value = awtinvoke(Handles.Edit_CompensatorOrder,'getValue()');
IsAdjusting = awtinvoke(Handles.Edit_CompensatorOrder,'getValueIsAdjusting()');
if IsAdjusting
    awtinvoke(Handles.Edit_OrderField,'setText',java.lang.String.valueOf(java.lang.Integer(value)));
else
    awtinvoke(Handles.Edit_OrderField,'setValue',java.lang.Integer(value));
    if strcmp(this.TuningPreference{this.idxC},'TargetLoopShape')
        this.TargetLoopShapeData(this.idxC).TargetOrder = value;
    else
        this.TargetBandwidthData(this.idxC).TargetOrder = value;
    end
end

%% Update slider edit box
function LocalEditor(es, ed, this)
if strcmp(this.TuningPreference{this.idxC},'TargetLoopShape')
    Handles = this.SpecPanelHandles.LoopShapeCardHandles;
else
    Handles = this.SpecPanelHandles.BandwidthCardHandles;
end
value = awtinvoke(Handles.Edit_OrderField,'getValue()');
minValue = awtinvoke(Handles.Edit_CompensatorOrder,'getMinimum()');
maxValue = awtinvoke(Handles.Edit_CompensatorOrder,'getMaximum()');
if value > maxValue
    awtinvoke(Handles.Edit_OrderField,'setValue',java.lang.Integer(maxValue));
    value = maxValue;
elseif value < minValue
    awtinvoke(Handles.Edit_OrderField,'setValue',java.lang.Integer(minValue));
    value = minValue;
end
awtinvoke(Handles.Edit_CompensatorOrder,'setValue(I)',value);
if strcmp(this.TuningPreference{this.idxC},'TargetLoopShape')
    this.TargetLoopShapeData(this.idxC).TargetOrder = value;
else
    this.TargetBandwidthData(this.idxC).TargetOrder = value;
end

%% update user specified freq range check box
% function LocalUpdateCheckBox(this)
% Checked = awtinvoke(this.SpecPanelHandles.LoopShapeCardHandles.CheckBox_FreqRange,'isSelected()');
% this.TargetLoopShapeData(this.idxC).UseSpecifiedFreqRange = Checked;
% awtinvoke(this.SpecPanelHandles.LoopShapeCardHandles.Edit_FreqRange,'setEnabled(Z)',Checked)



%% Update target transfer function
function LocalUpdateLoopShapeTarget(es, ed, this)

NewValue = awtinvoke(this.SpecPanelHandles.LoopShapeCardHandles.Edit_TargetShape,'getText()');
try 
    NewLTI = evalin('base',NewValue);
    if isa(NewLTI,'lti') && issiso(NewLTI)
        this.TargetLoopShapeData(this.idxC).TargetLoopShape = NewValue;
        this.refreshSpecPanel;
    else
        this.refreshSpecPanel;
        errordlg('Target loop shape must be a valid single-input single-output LTI object.')
    end
catch
    this.refreshSpecPanel;
    errordlg('Target loop shape must be a valid single-input single-output LTI object.')
end


%% Update target bandwidth
function LocalUpdateBandwidthTarget(es, ed, this)

NewValue = awtinvoke(this.SpecPanelHandles.BandwidthCardHandles.Edit_TargetBandwidth,'getText()');
try
    NewBandwidth = evalin('base',NewValue);
    if isa(NewBandwidth,'double') && NewBandwidth > 0
        this.TargetBandwidthData(this.idxC).TargetBandwidth = NewValue;
        this.refreshSpecPanel;
    else
        this.refreshSpecPanel;
        errordlg('Target bandwidth must be a positive value.')
    end
catch
    this.refreshSpecPanel;
    errordlg('Target bandwidth must be a positive value.')
end


%% Update target frequency range function
function LocalUpdateFreqRange(es, ed, this)
NewValue = awtinvoke(this.SpecPanelHandles.LoopShapeCardHandles.Edit_FreqRange,'getText()');
if isa(evalin('base',NewValue),'double')
    this.TargetLoopShapeData(this.idxC).SpecifiedFreqRange = NewValue;
end
