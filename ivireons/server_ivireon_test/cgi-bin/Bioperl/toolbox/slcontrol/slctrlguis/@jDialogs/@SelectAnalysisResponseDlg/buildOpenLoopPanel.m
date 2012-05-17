function OpenLoopPanel = buildOpenLoopPanel(this)
%BUILDOPENLOOPPANEL  Builds the open loop panel dialog.

%   Authors: John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2008/12/04 23:27:53 $

import java.awt.*;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the select compensator panel
OpenLoopPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');

% Create the widgets
OpenLoopLabel = javaObjectEDT('com.mathworks.mwswing.MJLabel',xlate('Open-Loop Response'));

% Get the controllers to tune
loopdata = this.loopdata;
OLResponses = get(loopdata.L,{'Description'});
% Determine the indices to the open loop responses
FeedbackFlag = get(loopdata.L,{'Feedback'});
OLResponses = OLResponses([FeedbackFlag{:}]);

if ~isempty(OLResponses)
    OpenLoopSelect = javaObjectEDT('com.mathworks.mwswing.MJComboBox',OLResponses);
else
    OpenLoopSelect = javaObjectEDT('com.mathworks.mwswing.MJComboBox');
    OpenLoopSelect.setEnabled(false);
end

% Create the grid bag layout
OpenLoopPanel.setLayout(GridBagLayout);
gbc           = GridBagConstraints;
gbc.insets    = Insets(10,5,0,5);
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.fill      = GridBagConstraints.HORIZONTAL;
gbc.gridwidth = GridBagConstraints.REMAINDER;
gbc.weighty = 0;
gbc.weightx = 1;

% Add the components
OpenLoopPanel.add(OpenLoopLabel,gbc);
OpenLoopPanel.add(OpenLoopSelect,gbc);
gbc.weighty = 1;
gbc.fill      = GridBagConstraints.BOTH;
OpenLoopPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),gbc);

% Store the handles that are needed
Handles = this.Handles;
Handles.OpenLoopSelect = OpenLoopSelect;
this.Handles = Handles;
