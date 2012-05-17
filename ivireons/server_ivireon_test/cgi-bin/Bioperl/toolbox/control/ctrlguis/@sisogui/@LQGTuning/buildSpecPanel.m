function Handles = buildSpecPanel(this)
%BUILDSPECPANEL  Build the Specification panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/04/21 03:07:48 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;


%% Build nominal IMC specification panel
% main panel
CardNominal = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CardNominal.setName('NominalLQG');
title = BorderFactory.createTitledBorder(xlate(' Specifications '));
CardNominal.setBorder(title);
% common properties of GBC
GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.fill = GridBagConstraints.HORIZONTAL;

% Row 1
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 0;
GBc.gridwidth = 1;
GBc.weightx = 0;
Label1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Controller response:'));
CardNominal.add(Label1, GBc);
% slider
GBc.anchor = GridBagConstraints.CENTER;
GBc.gridx = 1;
GBc.gridy = 0;
GBc.weightx = 1;
GBc.gridwidth = 1;
Slider_ControllerResponse = javaObjectEDT('com.mathworks.mwswing.MJSlider');
Slider_ControllerResponse.setName('LQGControllerResponse');
labelTable = Hashtable();
awtinvoke(Slider_ControllerResponse,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
CardNominal.add(Slider_ControllerResponse, GBc);
% empty label
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 0;
GBc.weightx = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
FillJunk1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',blanks(10));
CardNominal.add(FillJunk1, GBc);

% Row 2
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 1;
GBc.gridwidth = 1;
GBc.weightx = 0;
Label2 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Measurement noise:'));
CardNominal.add(Label2, GBc);
% slider
GBc.anchor = GridBagConstraints.CENTER;
GBc.gridx = 1;
GBc.gridy = 1;
GBc.gridwidth = 1;
GBc.weightx = 1;
Slider_MeasurementNoiseLevel = javaObjectEDT('com.mathworks.mwswing.MJSlider');
Slider_MeasurementNoiseLevel.setName('LQGMeasurementNoiseLevel');
labelTable = Hashtable();
awtinvoke(Slider_MeasurementNoiseLevel,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
CardNominal.add(Slider_MeasurementNoiseLevel, GBc);
% empty label
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 1;
GBc.weightx = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
FillJunk1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',blanks(10));
CardNominal.add(FillJunk1, GBc);

% Row 3
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 2;
GBc.gridwidth = 1;
GBc.weightx = 0;
Label3 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Desired controller order:'));
CardNominal.add(Label3, GBc);
% slider
GBc.anchor = GridBagConstraints.CENTER;
GBc.gridx = 1;
GBc.gridy = 2;
GBc.gridwidth = 1;
GBc.weightx = 1;
Slider_CompensatorOrder = javaObjectEDT('com.mathworks.mwswing.MJSlider');
Slider_CompensatorOrder.setName('LQGSliderOrder');
labelTable = Hashtable();
awtinvoke(Slider_CompensatorOrder,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
CardNominal.add(Slider_CompensatorOrder, GBc);
% editbox
% empty label
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 2;
GBc.weightx = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
numberFormat = java.text.NumberFormat.getIntegerInstance();
formatter = javax.swing.text.NumberFormatter(numberFormat);
Edit_CompensatorOrder = javaObjectEDT('com.mathworks.mwswing.MJFormattedTextField',formatter);
Edit_CompensatorOrder.setName('LQGEditOrder');
CardNominal.add(Edit_CompensatorOrder, GBc);

% filler panel
FillerPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 0;
GBc.gridy = 3;
GBc.weighty = 1;
GBc.gridwidth = 3;
CardNominal.add(FillerPanel, GBc);

%% Build special LQG specification panel
CardBlank = utBuildSpecialSpec(this, this.Name, 'Blank');
CardFixedDynamics = utBuildSpecialSpec(this, this.Name, 'FixedDynamics',...
    sprintf('LQG synthesis method cannot be applied to a compensator with fixed dynamics.'));
CardConstrained = utBuildSpecialSpec(this, this.Name, 'Constrained',...
    sprintf('LQG synthesis method cannot be applied to a compensator with any constraints on its pole(s), zero(s), or gain.'));
CardImproperPlant = utBuildSpecialSpec(this, this.Name, 'ImproperPlant',...
    sprintf('The selected tuning method cannot be applied to this compensator. The open-loop model with respect to this compensator has more zeros than poles.'));
CardFRDPlant = utBuildSpecialSpec(this, this.Name, 'FRDPlant',...
   ctrlMsgUtils.message('Control:compDesignTask:AutomatedTuningFRDPlant'));


%% Assemble the card panel
PCard = javaObjectEDT('com.mathworks.mwswing.MJPanel',CardLayout);
PCard.add(CardBlank, 'Blank');
PCard.add(CardFixedDynamics, 'FixedDynamics');
PCard.add(CardConstrained, 'Constrained');
PCard.add(CardImproperPlant, 'ImproperPlant');
PCard.add(CardNominal, 'Nominal');
PCard.add(CardFRDPlant, 'FRDPlant');

Handles = struct(...
    'Panel', PCard, ...
    'Slider_ControllerResponse', Slider_ControllerResponse, ...
    'Slider_MeasurementNoiseLevel', Slider_MeasurementNoiseLevel, ...
    'Slider_CompensatorOrder', Slider_CompensatorOrder, ...    
    'Edit_CompensatorOrder', Edit_CompensatorOrder);

% initialize slider
init_slider(Handles);

% set slider and text field callbacks
h = handle(Handles.Slider_CompensatorOrder,'callbackproperties');
h.StateChangedCallback = {@LocalSlider this};
h = handle(Handles.Edit_CompensatorOrder,'callbackproperties');
h.ActionPerformedCallback = {@LocalEditor this};
h.FocusLostCallback = {@LocalEditor this};

%% Order: slider and text field callbacks
function LocalSlider(es, ed, this)
% update order edit field
Handles = this.SpecPanelHandles;
value = awtinvoke(Handles.Slider_CompensatorOrder,'getValue()');
IsAdjusting = awtinvoke(Handles.Slider_CompensatorOrder,'getValueIsAdjusting()');
if IsAdjusting
    awtinvoke(Handles.Edit_CompensatorOrder,'setText',java.lang.String.valueOf(java.lang.Integer(value)));
else
    awtinvoke(Handles.Edit_CompensatorOrder,'setValue',java.lang.Integer(value));
end

function LocalEditor(es, ed, this)
% update order slider
Handles = this.SpecPanelHandles;
value = awtinvoke(Handles.Edit_CompensatorOrder,'getValue()');
minValue = awtinvoke(Handles.Slider_CompensatorOrder,'getMinimum()');
maxValue = awtinvoke(Handles.Slider_CompensatorOrder,'getMaximum()');
if value > maxValue
    awtinvoke(Handles.Edit_CompensatorOrder,'setValue',java.lang.Integer(maxValue));
    value = maxValue;
elseif value < minValue
    awtinvoke(Handles.Edit_CompensatorOrder,'setValue',java.lang.Integer(minValue));
    value = minValue;
end
awtinvoke(Handles.Slider_CompensatorOrder,'setValue(I)',value);

%% initialize two lqg performance sliders
function init_slider(Handles)
awtinvoke(Handles.Slider_ControllerResponse,'setMinimum(I)',0); 
awtinvoke(Handles.Slider_ControllerResponse,'setMaximum(I)',100);
awtinvoke(Handles.Slider_ControllerResponse,'setValue(I)',50);
labelTable = awtinvoke(Handles.Slider_ControllerResponse,'getLabelTable()');
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(0),javaObjectEDT('javax.swing.JLabel',xlate('Aggressive')));
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(100),javaObjectEDT('javax.swing.JLabel',xlate('Robust')));
awtinvoke(Handles.Slider_ControllerResponse,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
awtinvoke(Handles.Slider_ControllerResponse,'setMajorTickSpacing(I)',100);
awtinvoke(Handles.Slider_ControllerResponse,'setMinorTickSpacing(I)',25);    
awtinvoke(Handles.Slider_ControllerResponse,'setPaintTicks(Z)',true);
awtinvoke(Handles.Slider_ControllerResponse,'setPaintLabels(Z)',true);
awtinvoke(Handles.Slider_ControllerResponse,'setPaintTrack(Z)',true);

awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setMinimum(I)',0); 
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setMaximum(I)',100);
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setValue(I)',50);
labelTable = awtinvoke(Handles.Slider_MeasurementNoiseLevel,'getLabelTable()');
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(0), javaObjectEDT('javax.swing.JLabel',xlate('    Small    ')));
awtinvoke(labelTable,'put(Ljava.lang.Object;Ljava.lang.Object;)',java.lang.Integer(100),javaObjectEDT('javax.swing.JLabel',xlate('    Large    ')));
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setMajorTickSpacing(I)',100);
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setMinorTickSpacing(I)',25);    
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setPaintTicks(Z)',true);
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setPaintLabels(Z)',true);
awtinvoke(Handles.Slider_MeasurementNoiseLevel,'setPaintTrack(Z)',true);









