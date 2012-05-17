function ClosedLoopSignalPanel = buildClosedLoopPanel(this)
%BUILDCLOSEDLOOPPANEL  Builds the closed loop panel dialog.

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2008/12/04 22:24:02 $

import java.awt.*;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the closed loop panel
ClosedLoopSignalPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
loopdata = this.loopdata;

% Create the widgets
ClosedLoopInput = javaObjectEDT('com.mathworks.mwswing.MJLabel',xlate('Closed-Loop Input'));
ClosedLoopOutput = javaObjectEDT('com.mathworks.mwswing.MJLabel',xlate('Closed-Loop Output'));
BlockToTune = javaObjectEDT('com.mathworks.mwswing.MJLabel',xlate('Initial Block to Tune'));

% Get the input and output channel names
ClosedLoopInputSelect = javaObjectEDT('com.mathworks.mwswing.MJComboBox',loopdata.Input);
ClosedLoopInputSelect.setName('ClosedLoopInputSelect');
ClosedLoopOutputSelect = javaObjectEDT('com.mathworks.mwswing.MJComboBox',loopdata.Output);
ClosedLoopOutputSelect.setName('ClosedLoopOutputSelect');

% Get the blocks to tune
BlockToTuneSelect = javaObjectEDT('com.mathworks.mwswing.MJComboBox',get(loopdata.C,{'Name'}));
BlockToTuneSelect.setName('BlockToTuneSelect');

% Create the grid bag layout
ClosedLoopSignalPanel.setLayout(GridBagLayout);
gbc           = GridBagConstraints;
gbc.insets    = Insets(10,5,0,5);
gbc.anchor    = GridBagConstraints.NORTHWEST;
gbc.fill      = GridBagConstraints.HORIZONTAL;
gbc.gridwidth = GridBagConstraints.REMAINDER;
gbc.weighty = 0;
gbc.weightx = 1;

% Add the components
ClosedLoopSignalPanel.add(ClosedLoopInput,gbc);
ClosedLoopSignalPanel.add(ClosedLoopInputSelect,gbc);
ClosedLoopSignalPanel.add(ClosedLoopOutput,gbc);
ClosedLoopSignalPanel.add(ClosedLoopOutputSelect,gbc);
ClosedLoopSignalPanel.add(BlockToTune,gbc);
ClosedLoopSignalPanel.add(BlockToTuneSelect,gbc);
gbc.weighty = 1;
gbc.fill      = GridBagConstraints.BOTH;
ClosedLoopSignalPanel.add(javaObjectEDT('com.mathworks.mwswing.MJPanel'),gbc);

% Store the handles that are needed
Handles = this.Handles;
Handles.BlockToTuneSelect = BlockToTuneSelect;
Handles.ClosedLoopInputSelect = ClosedLoopInputSelect;
Handles.ClosedLoopOutputSelect = ClosedLoopOutputSelect;
this.Handles = Handles;