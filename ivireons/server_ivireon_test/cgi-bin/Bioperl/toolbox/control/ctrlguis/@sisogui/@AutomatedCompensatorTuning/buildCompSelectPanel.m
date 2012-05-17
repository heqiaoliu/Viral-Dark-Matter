function Handles = buildCompSelectPanel(this)
%BUILDCOMPSELECTPANEL  Build the compensator selection panel of a tuning method.

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2009/11/09 16:22:24 $

import java.awt.*;
import javax.swing.* ;
import com.mathworks.toolbox.control.dialogs.*;
import com.mathworks.toolbox.control.sisogui.*;

%% Constant definitions
SPACE_CONSTANT = 5;

%% Create the combo box 
% for all the non-gain compensators plus 'all gain blocks'
ComboAll = javaObjectEDT('com.mathworks.toolbox.control.util.MJComboBoxForLongStrings');
ComboAll.setName('ComponentComboAutoTune')
ComboAll.setPreferredSize(Dimension(100,ComboAll.getPreferredSize.getHeight));
% set up call back
h = handle(ComboAll,'callbackproperties');
listener = handle.listener(h,'ActionPerformed',{@localCompChange this});

%% Create the compensator display (gain part)
GainLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel','');

%% Create the compensator display (pole/zero part)
PZLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel','', SwingConstants.LEFT);
PZStrip = javaObjectEDT('com.mathworks.mwswing.MJScrollStrip',SwingConstants.HORIZONTAL, PZLabel, true);

%% Create compensator selection panel: Combopanel
CompSelectPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel',GridBagLayout);
CompSelectPanel.setBorder(BorderFactory.createTitledBorder(xlate(' Compensator ')));

% Add combo box to CompSelectPanel
c = GridBagConstraints;
c.anchor  = GridBagConstraints.WEST;
c.fill    = GridBagConstraints.HORIZONTAL;
c.insets  = Insets(0,SPACE_CONSTANT,SPACE_CONSTANT,SPACE_CONSTANT); %top left bottom right
c.weightx = 0.2;
c.weighty = 0;
CompSelectPanel.add(ComboAll,c);

% Add '=' sign to CompSelectPanel
c.insets  = Insets(0,0,SPACE_CONSTANT,SPACE_CONSTANT);
c.weightx = 0;
EqualLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',sprintf('='));
CompSelectPanel.add(EqualLabel,c);

% Add gain label to CompSelectPanel
CompSelectPanel.add(GainLabel,c);

% Add PZ display panel to the CompSelectPanel
c.fill      = GridBagConstraints.BOTH;
c.weightx   = 1;
c.weighty   = 1;
CompSelectPanel.add(PZStrip,c);

% Handles to tab panel items
Handles = struct('Panel',               CompSelectPanel, ...
                'CompComboBox',         ComboAll, ...
                'CompComboBoxListener', listener, ...
                'CompGainLabel',        GainLabel, ...
                'CompEqualLabel',       EqualLabel, ...                 
                'CompPZLabel',          PZLabel);

%-------------------------Callback Functions------------------------

%-------------------------------------------------------------------------%
% Function: LocalCompChange
% Abstract: Update two tabs when users switch the compensator from one to
% another
%-------------------------------------------------------------------------%
function localCompChange(es,ed,this)
choice = awtinvoke(java(es),'getSelectedIndex()')+1;
if choice>0 && this.IdxC ~= choice
    this.IsOpenLoopPlantDirty = true;    
    this.IdxC = choice;
    this.refreshPanel;
end
