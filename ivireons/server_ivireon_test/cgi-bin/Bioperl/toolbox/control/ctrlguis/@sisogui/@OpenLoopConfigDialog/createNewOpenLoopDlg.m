function createNewOpenLoopDlg(this) 
% CREATENEWOPENLOOPDLG  Create the dialog to create a new loop opening.
%
 
% Author(s): John W. Glass 26-Sep-2005
% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/12/04 22:22:38 $

import com.mathworks.toolbox.control.explorer.*;
import java.awt.*;

% Create the dialog
Dialog = javaObjectEDT('com.mathworks.mwswing.MJDialog',this.Handles.Frame,false);
Dialog.setTitle(xlate('Select New Loop Opening'));
Dialog.setName('SelectNewLoopOpeningDialog');
cp = javaObjectEDT(Dialog.getContentPane);
cp.setLayout(java.awt.BorderLayout(5,5));

% Get the task node
SISOTaskNode = handle(getObject(getSelected(slctrlexplorer)));

% Create the explorer panel
node = SISOTaskNode.getSignalTree;
SignalInspectPanel = javaObjectEDT('com.mathworks.toolbox.control.explorer.ExplorerPanel',node.getTreeNodeInterface);
SignalInspectPanel.setStatusArea(false);

% Make the first node selected
SignalInspectPanel.setSelected(node.getTreeNodeInterface);

% Set the node in the explorer manager
TreeManager = explorer.ExplorerPanelTreeManager(node,SignalInspectPanel);

% Create a container panel
OpenLoopSplitPane = javaObjectEDT('com.mathworks.mwswing.MJPanel');
OpenLoopSplitPane.setLayout(BorderLayout(5,10));

% Create an instruction label
OpenLoopInstruct = javaObjectEDT('com.mathworks.mwswing.MJLabel', ...
    xlate(['Select an open-loop analysis point using ',...
                                    'the signal browser below:']));

% Create the help panel
OpenLoopHelpPanel = javaObjectEDT('com.mathworks.mlwidgets.help.HelpPanel'); 

% Set the initial help topic
mapfile = fullfile(docroot,'toolbox','slcontrol','slcontrol.map');
OpenLoopHelpPanel.displayTopic(mapfile,'select_open_loop_response_dialog');

% Create the main panel
OpenLoopSplitPane.add(OpenLoopInstruct,BorderLayout.NORTH);
OpenLoopSplitPane.add(SignalInspectPanel,BorderLayout.CENTER);
OpenLoopPanel = javaObjectEDT('com.mathworks.mwswing.MJSplitPane', ...
    1,OpenLoopSplitPane,OpenLoopHelpPanel);
OpenLoopPanel.setDividerLocation(0.65);
cp.add(OpenLoopPanel,BorderLayout.CENTER);

% Create the bottom button panel
OKButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('OK'));
OKButton.setName('OKButton');
CancelButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Cancel'));
CancelButton.setName('CancelButton');

ButtonPanel = javaObjectEDT('com.mathworks.mwswing.MJPanel');
ButtonPanel.setLayout(FlowLayout(FlowLayout.RIGHT))
ButtonPanel.add(OKButton);
ButtonPanel.add(CancelButton);
cp.add(ButtonPanel,BorderLayout.SOUTH);

% Store the handles
Handles = this.Handles;
Handles.TreeManager = TreeManager;
Handles.Dialog = Dialog;
Handles.SignalInspectPanel = SignalInspectPanel;
Handles.OpenLoopSplitPane = OpenLoopSplitPane;
Handles.OpenLoopInstruct = OpenLoopInstruct;
this.Handles = Handles;

% Set the callbacks
h = handle(OKButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalOKFcn this};

h = handle(CancelButton,'callbackproperties');
h.ActionPerformedCallback = {@LocalCloseFcn this};
                           
% Set the frame to a good size
Dialog.setSize(650,450);

% Show the dialog
Dialog.setLocationRelativeTo(this.Handles.Frame);
Dialog.show;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOKFcn(es,ed,this)

% Get the selected signal from the explorer dialog
Handles = this.Handles;
SignalInspectPanel = Handles.SignalInspectPanel;
selectednode = handle(getObject(SignalInspectPanel.getSelected));
dlg = selectednode.getDialogInterface;
row = dlg.getTable.getSelectedRow+1;

if ~isempty(row)
    SelectedSignal = selectednode.Signals{row};
    portdel = strfind(SelectedSignal,':');
    block = SelectedSignal(1:portdel-1);
    port = str2double(SelectedSignal(portdel+1:end));
   
    %% Add to the LoopOpenings structure
    this.LoopConfig(this.Target).LoopOpenings = [this.LoopConfig(this.Target).LoopOpenings,...
                         struct('BlockName',block,...
                                'PortNumber',port,...
                                'Status',true)];
end

% Disable the table listener
this.Handles.TableListener.Enabled = 'off';
this.refreshTable;
% Call drawnow to be sure that the queue is flushed
drawnow
% Re-Enable the listener
this.Handles.TableListener.Enabled = 'off';

% Close the frame
LocalCloseFcn(es,ed,this)

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCloseFcn(es,ed,this)

% Clean up the Open Loop Panel
Handles = this.Handles;
SignalInspectPanel = Handles.SignalInspectPanel;
TreeManager = Handles.TreeManager;
SignalInspectPanel.setSelected(TreeManager.Root.getTreeNodeInterface);
drawnow
ModelNode = TreeManager.Root.getChildren;
LocalRemoveListeners(ModelNode)
disconnect(ModelNode);
drawnow
delete(TreeManager);

% Take apart the Java dialog
Handles.OpenLoopSplitPane.remove(Handles.OpenLoopInstruct);
Handles.OpenLoopSplitPane.remove(Handles.SignalInspectPanel);

awtinvoke(SignalInspectPanel,'cleanup()')
cp = this.Handles.Dialog.getContentPane;
awtinvoke(cp,'removeAll()');
awtinvoke(this.Handles.Dialog,'dispose');
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRemoveListeners(Node)

removeListeners(Node);

Children = Node.getChildren;

for ct = numel(Children):-1:1;
    LocalRemoveListeners(Children(ct))
end
end