function Handles = buildSpecPanel(this)
%BUILDSPECPANEL  Build the Specification panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/04/21 03:07:40 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import java.util.* ;


%% Build nominal IMC specification panel
% main panel
CardNominal = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CardNominal.setName('NominalIMC');
title = BorderFactory.createTitledBorder(xlate(' Specifications '));
CardNominal.setBorder(title);
% common properties of GBC
GBc = GridBagConstraints;
GBc.insets=Insets(5,10,5,10);
GBc.fill = GridBagConstraints.HORIZONTAL;

% Row 1
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridy = 0;
GBc.gridwidth = 1;
GBc.weightx = 0;
Label1 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Dominant closed-loop time constant:'));
CardNominal.add(Label1, GBc);
% tau
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 0;
GBc.gridwidth = 1;
Edit_DominantTimeConstant = javaObjectEDT('com.mathworks.mwswing.MJTextField');
Edit_DominantTimeConstant.setName('IMCTimeConstant');
CardNominal.add(Edit_DominantTimeConstant, GBc);
% empty label
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
CardNominal.add(javaObjectEDT('com.mathworks.mwswing.MJLabel',blanks(10)), GBc);

% Row 2
% label
GBc.anchor = GridBagConstraints.EAST;
GBc.gridx = 0;
GBc.gridy = 1;
GBc.gridwidth = 1;
GBc.weightx = 0;
Label2 = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('Desired controller order:'));
CardNominal.add(Label2, GBc);
% slider
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 1;
GBc.gridy = 1;
GBc.gridwidth = 1;
GBc.weightx = 1;
Slider_CompensatorOrder = javaObjectEDT('com.mathworks.mwswing.MJSlider');
Slider_CompensatorOrder.setName('IMCSliderOrder');
labelTable = Hashtable();
awtinvoke(Slider_CompensatorOrder,'setLabelTable(Ljava.util.Dictionary;)',labelTable);
CardNominal.add(Slider_CompensatorOrder, GBc);
% editbox
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 2;
GBc.gridy = 1;
GBc.weightx = 0;
GBc.gridwidth = GridBagConstraints.REMAINDER;
numberFormat = java.text.NumberFormat.getIntegerInstance();
formatter = javax.swing.text.NumberFormatter(numberFormat);
Edit_CompensatorOrder = javaObjectEDT('com.mathworks.mwswing.MJFormattedTextField',formatter);
Edit_CompensatorOrder.setName('IMCEditOrder');
CardNominal.add(Edit_CompensatorOrder, GBc);

% filler panel
FillerPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
GBc.anchor = GridBagConstraints.WEST;
GBc.gridx = 0;
GBc.gridy = 2;
GBc.weighty = 1;
GBc.gridwidth = 3;
CardNominal.add(FillerPanel, GBc);

%% Build special IMC specification panel
CardBlank = utBuildSpecialSpec(this, this.Name, 'Blank');
CardFixedDynamics = utBuildSpecialSpec(this, this.Name, 'FixedDynamics',...
    sprintf('IMC tuning method cannot be applied to a compensator with fixed dynamics.'));
CardConstrained = utBuildSpecialSpec(this, this.Name, 'Constrained',...
    sprintf('IMC tuning method cannot be applied to a compensator with any constraints on its pole(s), zero(s), or gain.'));
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
    'Edit_DominantTimeConstant', Edit_DominantTimeConstant, ...
    'Slider_CompensatorOrder', Slider_CompensatorOrder, ...
    'Edit_CompensatorOrder', Edit_CompensatorOrder);

% initialize order slider and text field with 10
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

