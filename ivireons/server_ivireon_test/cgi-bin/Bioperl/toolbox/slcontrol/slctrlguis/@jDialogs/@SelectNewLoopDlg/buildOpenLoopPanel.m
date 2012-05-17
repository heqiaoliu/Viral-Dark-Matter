function OpenLoopSplitPane = buildOpenLoopPanel(this)
% BUILDOPENLOOPPANEL Builds the open loop selection panel

%   Authors: John Glass
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.5 $ $Date: 2008/12/04 23:27:58 $

% Create the explorer panel
node = this.SISOTaskNode.getSignalTree;
SignalInspectPanel = javaObjectEDT('com.mathworks.toolbox.control.explorer.ExplorerPanel',node.getTreeNodeInterface);
SignalInspectPanel.setStatusArea(false);

% Make the first node selected
SignalInspectPanel.setSelected(node.getTreeNodeInterface);

% Create a container panel
OpenLoopSplitPane = javaObjectEDT('com.mathworks.mwswing.MJPanel');
BorderLayout = javaObjectEDT('java.awt.BorderLayout',5,10);
OpenLoopSplitPane.setLayout(BorderLayout);

% Create an instruction label
OpenLoopInstruct = javaObjectEDT('com.mathworks.mwswing.MJLabel',...
                    xlate(['Select an open-loop analysis point using ',...
                                    'the signal browser below:']));

% Get the explorer manager
TreeManager = explorer.ExplorerPanelTreeManager(node,SignalInspectPanel);

% Create the main panel
OpenLoopSplitPane.add(OpenLoopInstruct,BorderLayout.NORTH);
OpenLoopSplitPane.add(SignalInspectPanel,BorderLayout.CENTER);

% Store handles
Handles = this.Handles;
Handles.OpenLoopSplitPane = OpenLoopSplitPane;
Handles.OpenLoopInstruct = OpenLoopInstruct;
Handles.SignalInspectPanel = SignalInspectPanel;
Handles.TreeManager = TreeManager;
this.Handles = Handles;