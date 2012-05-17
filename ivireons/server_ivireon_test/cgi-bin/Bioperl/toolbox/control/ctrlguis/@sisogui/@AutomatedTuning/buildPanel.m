function h = buildPanel(this)
%BUILDPANELS  Build all the panels for the automated tuning functions.

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/12/04 22:22:02 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;


% Create the main panel
MainPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',java.awt.BorderLayout(5,5));

% Create the card panel
MethodManagers = this.MethodManagers;
len = length(MethodManagers);
CardPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',false);
CardPanel.setLayout(java.awt.CardLayout());
for ct=1:len
    CardPanel.add(MethodManagers(ct).getPanel,MethodManagers(ct).getName);
end

% Create the method combobox and label
MethodComboNames = cell(len,1);
for ct = 1:len
    MethodComboNames{ct} = MethodManagers(ct).getDesc;
end
MethodCombo = javaObjectEDT('com.mathworks.toolbox.control.util.MJComboBoxForLongStrings' ,...
    MethodComboNames);
MethodCombo.setName('MethodComboAutoTune');
h = handle(MethodCombo,'callbackproperties');
h.ActionPerformedCallback = {@LocalMethodSelect, this};
MethodLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',xlate('Design method:'));

% Create method panel for method combo and add components
MethodPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',java.awt.GridBagLayout);
gbc         = GridBagConstraints;
gbc.insets  = Insets(5,5,5,5);
gbc.anchor  = GridBagConstraints.WEST;
gbc.fill    = GridBagConstraints.HORIZONTAL;
% label
gbc.weightx = 0;
gbc.gridx   = 0;
MethodPanel.add(MethodLabel,gbc);
% combo
gbc.weightx = 1;
gbc.gridx   = 1;
MethodPanel.add(MethodCombo,gbc);
% string
gbc.gridwidth = GridBagConstraints.REMAINDER;
gbc.weightx = 1;
gbc.gridx   = 2;
MethodPanel.add(javaObjectEDT('com.mathworks.mwswing.MJLabel'),gbc);

% Add everything to the main panel
MainPanel.add(MethodPanel,BorderLayout.NORTH);
MainPanel.add(CardPanel,BorderLayout.CENTER);

this.CardPanel = CardPanel;
this.MainPanel = MainPanel;
this.MethodCombo = MethodCombo;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalMethodSelect %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalMethodSelect(es,ed,this)
% show card panel
ct = awtinvoke(java(es),'getSelectedIndex()')+1;
this.idxMethod = ct;
% get handle to the card panel
awtinvoke(this.CardPanel.getLayout,'show',this.CardPanel,this.MethodManagers(ct).getName);
% force panel refresh
this.MethodManagers(ct).refreshPanel;
