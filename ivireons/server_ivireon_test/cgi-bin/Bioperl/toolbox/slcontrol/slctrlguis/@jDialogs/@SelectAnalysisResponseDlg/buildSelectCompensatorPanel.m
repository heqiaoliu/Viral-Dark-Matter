function IndividualElementPanel = buildSelectCompensatorPanel(this) 
% BUILDSELECTCOMPENSATORPANEL  Builds the open loop panel dialog.
%
 
%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 23:27:54 $

import java.awt.*;

% Create the select compensator panel
IndividualElementPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');

% Create the widgets
IndividualElement = javaObjectEDT('com.mathworks.mwswing.MJLabel',xlate('Tuned Block'));

% Get the controllers to tune
loopdata = this.loopdata;
IndividualElementSelect = javaObjectEDT('com.mathworks.mwswing.MJComboBox',get(loopdata.C,{'Name'}));

% Create the grid bag layout
IndividualElementPanel.setLayout(GridBagLayout);
gbc           = GridBagConstraints;
gbc.insets    = Insets(10,5,0,5);
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.fill      = GridBagConstraints.HORIZONTAL;
gbc.gridwidth = GridBagConstraints.REMAINDER;
gbc.weighty = 0;
gbc.weightx = 1;

% Add the components
IndividualElementPanel.add(IndividualElement,gbc);
IndividualElementPanel.add(IndividualElementSelect,gbc);
gbc.weighty = 1;
gbc.fill      = GridBagConstraints.BOTH;
IndividualElementPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),gbc);

% Store the handles that are needed
Handles = this.Handles;
Handles.IndividualElementSelect = IndividualElementSelect;
this.Handles = Handles;