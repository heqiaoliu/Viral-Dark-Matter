function IndividualElementResponsePanel = buildOpenLoopPanel(this)
%BUILDOPENLOOPPANEL  Builds the open loop panel dialog.

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2006/01/26 01:47:26 $

import com.mathworks.mwswing.*;
import java.awt.*;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the select compensator panel
IndividualElementPanel = MJPanel;

%% Create the widgets
IndividualElement = MJLabel(xlate('Tuned Block'));

% Get the controllers to tune
loopdata = this.loopdata;
IndividualElementSelect = MJComboBox(get(loopdata.C,{'Name'}));

%% Create the grid bag layout
IndividualElementPanel.setLayout(GridBagLayout);
gbc           = GridBagConstraints;
gbc.insets    = Insets(10,5,0,5);
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.fill      = GridBagConstraints.HORIZONTAL;
gbc.gridwidth = GridBagConstraints.REMAINDER;
gbc.weighty = 0;
gbc.weightx = 1;

%% Add the components
IndividualElementPanel.add(IndividualElement,gbc);
IndividualElementPanel.add(IndividualElementSelect,gbc);
gbc.weighty = 1;
gbc.fill      = GridBagConstraints.BOTH;
IndividualElementPanel.add(MJPanel,gbc);

if (loopdata.getconfig == 0);
    %% Create the help panel
    IndividualElementHelpPanel = com.mathworks.mlwidgets.help.HelpPanel;
    % Set the initial help topic
    IndividualElementHelpPanel.displayTopic(this.mapfile,'tuned_block_response_embedded_help');

    %% Create the main panel
    IndividualElementResponsePanel = MJSplitPane(1,IndividualElementPanel,IndividualElementHelpPanel);
    IndividualElementResponsePanel.setDividerLocation(0.65);
else
    IndividualElementResponsePanel = IndividualElementPanel;
end

%% Store the handles that are needed
Handles = this.Handles;
Handles.IndividualElementSelect = IndividualElementSelect;
this.Handles = Handles;