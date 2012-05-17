function build(this,task) 
% BUILD Create the block selection dialog
%
 
% Author(s): John W. Glass 05-Aug-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2008/12/04 23:27:55 $

% Create the dialog
Dialog = javaObjectEDT('com.mathworks.mwswing.MJDialog', slctrlexplorer);
Dialog.setTitle(xlate('Select Blocks to Tune'));
this.Dialog = Dialog;

% Create the explorer panel
node = task.BlockTree;
BlockInspectPanel = javaObjectEDT('com.mathworks.toolbox.control.explorer.ExplorerPanel',...
                                    node.getTreeNodeInterface);
BlockInspectPanel.setStatusArea(false);
this.BlockInspectPanel = BlockInspectPanel;

% Create the help panel
HelpPanel = javaObjectEDT('com.mathworks.mlwidgets.help.HelpPanel'); 
scdguihelp('select_blocks_to_tune_dialog',HelpPanel);
this.HelpPanel = HelpPanel;

% Create the main panel
SplitPanel = javaObjectEDT('com.mathworks.mwswing.MJSplitPane',1,BlockInspectPanel,HelpPanel);
SplitPanel.setDividerLocation(0.7);
cp = javaObjectEDT(Dialog.getContentPane);
BorderLayout = javaObjectEDT('java.awt.BorderLayout');
cp.setLayout(BorderLayout);
cp.add(SplitPanel,BorderLayout.CENTER);
this.SplitPanel = SplitPanel;

% Set the node in the explorer manager
this.ExplorerPanelTreeManager = explorer.ExplorerPanelTreeManager(node,BlockInspectPanel); 

% Make the first node selected
BlockInspectPanel.setSelected(node.getTreeNodeInterface);

% Create the buttons below
OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('OK'));
OKButton.setName('OKButton');
h = handle(OKButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalOKFcn, task, this};

CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Cancel'));
CancelButton.setName('CancelButton');
h = handle(CancelButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelFcn, task, this};

ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
FlowLayout = javaObjectEDT('java.awt.FlowLayout');
FlowLayout.setAlignment(FlowLayout.RIGHT)
ButtonPanel.setLayout(FlowLayout)
ButtonPanel.add(OKButton);
ButtonPanel.add(CancelButton);
cp.add(ButtonPanel,BorderLayout.SOUTH);

% Add closing callback for the frame
h = handle(Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalCancelFcn, task, this};

% Set the frame to a good size
Dialog.setSize(800,425);

% Add listener for the case where the design task node is destroyed.
this.Listeners = handle.listener(handle(getObject(getSelected(slctrlexplorer))), 'ObjectBeingDestroyed',...
                                    {@LocalDisposeFcn,this});

% Show the dialog
Dialog.setLocationRelativeTo(slctrlexplorer);
Dialog.show;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDisposeFcn(es,ed,this)

% Turn off the glass pane
Explorer = slctrlexplorer;
Explorer.setBlocked(false,[]);

% Delete the listeners
this.BlockInspectPanel.setSelected(this.ExplorerPanelTreeManager.Root.getTreeNodeInterface);
drawnow
BlockNode = this.ExplorerPanelTreeManager.Root.getChildren;
if ~isempty(BlockNode)
    LocalRemoveListeners(BlockNode)
    disconnect(BlockNode);
end
drawnow
delete(this.ExplorerPanelTreeManager);

% Close the frame
javaMethodEDT('dispose',this.HelpPanel);
javaMethodEDT('removeAll',this.SplitPanel);
javaMethodEDT('cleanup',this.BlockInspectPanel)
cp = this.Dialog.getContentPane;
javaMethodEDT('removeAll',cp);
javaMethodEDT('dispose',this.Dialog);

% Clean up object
delete(this.Listeners);
delete(this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRemoveListeners(BlockNode)

removeListeners(BlockNode);

Children = BlockNode.getChildren;

for ct = numel(Children):-1:1;
    LocalRemoveListeners(Children(ct))
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKFcn(es,ed,task,this)

% Update the table
updateValidElementsTable(task);

% Close the frame
LocalDisposeFcn(es,ed,this)

% Set the project dirty flag
task.setDirty;

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelFcn(es,ed,task,this)

% Clear the unapplied changes
LocalSearchTree(task.BlockTree);

% Close the frame
LocalDisposeFcn(es,ed,this)
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSearchTree(node)
% Uncheck the blocks that the user has selected in task dialog.
UnappliedSelectedElements = node.UnappliedSelectedElements;
ind = find(UnappliedSelectedElements);
for ct = 1:numel(ind)
    node.ListData{ct,1} = ~node.ListData{ct,1};
end
% Clear the unapplied changes
node.UnappliedSelectedElements = [];
% Loop over the children
Children = node.getChildren;
for ct = 1:length(Children)
    LocalSearchTree(Children(ct))
end
end
