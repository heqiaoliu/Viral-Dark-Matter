function buildPanel(this)
%BUILDPANEL  Build the main panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2009/08/29 08:21:51 $

import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;


%% Build DesignButton Panel
DesignButton = javaObjectEDT('com.mathworks.mwswing.MJButton',sprintf('Optimize Compensators...'));
DesignButton.setName('btnOptimize')
DesignButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',FlowLayout(FlowLayout.RIGHT));
DesignButtonPanel.add(DesignButton);
% set button callback
h = handle(DesignButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalResponseOptimization this};

%% Build Main Panel
% main panel
OptimPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
loweredetched = BorderFactory.createEtchedBorder(EtchedBorder.LOWERED);
title = BorderFactory.createTitledBorder(loweredetched,sprintf('Optimization Based Tuning'));
OptimPanel.setBorder(title);
% Description text
str = sprintf([...
    'You can use optimization-based tuning to create an initial compensator ',...
    'design or to refine the current compensator design:\n\n', ...
    'Graphically specify design requirements for your system by positioning ',...
    'bounds on design or analysis plots such as Bode, Nichols, or Step Response. ',...
    'Then, use optimization-based methods to automatically tune compensator ',...
    'elements to satisfy the design requirements. Compensator elements that ', ...
    'are tunable via optimization-based tuning include gains, poles, and zeros.\n\n\n',...
    'Requires the Simulink Design Optimization product.']);
Label = javaObjectEDT('com.mathworks.mwswing.MJTextPane');
Label.setText(str);
Label.setEditable(false);
Label.setBackground(OptimPanel.getBackground);
Label.setForeground(OptimPanel.getForeground);
% Create the grid bag layout
OptimPanel.setLayout(GridBagLayout);
gbc           = GridBagConstraints;
gbc.insets    = Insets(10,5,0,5);
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.fill      = GridBagConstraints.HORIZONTAL;
gbc.gridwidth = GridBagConstraints.REMAINDER;
gbc.weighty   = 0;
gbc.weightx   = 1;
% Add components to panel
gbc.gridx   = 0;
gbc.gridy   = 0;
OptimPanel.add(Label,gbc);
gbc.gridy   = 1;
gbc.weighty = 1;
gbc.fill    = GridBagConstraints.BOTH;
OptimPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),gbc);  %White space to fill panel
gbc.weighty = 0;
gbc.gridy   = 2;
gbc.anchor  = GridBagConstraints.SOUTHEAST;
gbc.fill    = GridBagConstraints.NONE;
OptimPanel.add(DesignButtonPanel,gbc);

%% Set Properties
this.DesignButton = DesignButton;
this.MainPanel = OptimPanel;

%% Design Button Callback
function LocalResponseOptimization(~,~,this)
% Callback to display response optimization dialog
sisodb = this.Parent.Parent;
if license('test','simulink_design_optim') && ~isempty(ver('sldo'))
   if ishandle(sisodb.ResponseOptimization)
      %Switch to existing node
      sisodb.ResponseOptimization.show;
   else
      %Check if have SRO node but hasn't been activated (e.g. from a load)
      node = sisodb.getNode.down;
      foundSRO = false;
      while ~isempty(node)
         if isa(node,'srosisotoolgui.sropnl')
            node.show;
            node = [];
            foundSRO = true;
         else
            node = node.right;
         end
      end
      if ~foundSRO
         %Create node for first time
         sisodb.ResponseOptimization = srosisotoolgui.sropnl(sisodb);
         %Add node to CTEM
         sisodb.getNode.addNode(sisodb.ResponseOptimization);
         %Display node
         sisodb.ResponseOptimization.show;
      end
   end
else
    str = sprintf('Optimization based tuning of compensators requires the Simulink Design Optimization product.');
    this.utDisplayMessage('warning',str);
end


