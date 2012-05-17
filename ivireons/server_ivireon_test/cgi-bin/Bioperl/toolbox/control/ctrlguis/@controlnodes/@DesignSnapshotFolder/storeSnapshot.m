function storeSnapshot(this)
% STORESNAPSHOT  Store a snapshot of a design
%
 
% Author(s): John W. Glass 31-Oct-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/08/29 08:21:50 $

%% Get the snapshot folder
snapshotfolder = this;

%% Get the SISOTask node
sisotask = getSISOTaskNode(this);

%% Store the design
sisodb = sisotask.sisodb;
sisodb.LoopData.History = [sisodb.LoopData.History; sisodb.LoopData.exportdesign];

%% Create a new design snapshot node 
strDesignLabel = ctrlMsgUtils.message('Control:compDesignTask:strDesignLabel');
if isequal(sisodb.LoopData.getconfig,0)
    snapshotnode = ControlDesignNodes.DesignSnapshot(strDesignLabel);
else    
    snapshotnode = controlnodes.DesignSnapshot(strDesignLabel);
end
snapshotnode.Description = ctrlMsgUtils.message('Control:compDesignTask:strDesignSnapshot');

%% Get a default name
snapshotnodelabel = snapshotnode.createDefaultName(strDesignLabel, snapshotfolder);
sisodb.LoopData.History(end).Name = snapshotnodelabel;
snapshotnode.Label = snapshotnodelabel;
snapshotfolder.addNode(snapshotnode)

%% Add the node to the tree
Frame = slctrlexplorer;
Frame.expandNode(snapshotfolder.getTreeNodeInterface)

%% Put up a dialog notifying the user that the design has been stored.
msg = ctrlMsgUtils.message('Control:compDesignTask:strStoreDesignMessage',snapshotnodelabel);
javaMethodEDT('showMessageDialog','com.mathworks.mwswing.MJOptionPane',...
                        slctrlexplorer, msg, xlate('Simulink Control Design'),...
                        com.mathworks.mwswing.MJOptionPane.INFORMATION_MESSAGE);
                    