function nodes = getDefaultNodes(this)
% GETDEFAULTNODES  Return list of required component names.

% Author(s): John Glass
% Revised: 
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/01/26 01:58:13 $

%% Create a folder node for each design snapshot
folder = controlnodes.DesignSnapshotFolder('Design Shapshots');

%% Create a node storing the original design
originalnode = ControlDesignNodes.TunedBlockSnapshot('Initial Design');
C = this.design.loopdata.C; 
for ct = numel(C):-1:1
    Ccopy(ct) = copy(C(ct));
end
originalnode.TunedBlocks = Ccopy;

%% Connect the initial design node to the folder
folder.addNode(originalnode);

%% Create a copy of the operating point node used for the design
opnode = OperatingConditions.ControlDesignOperConditionValuePanel(copy(this.design.OpPoint),xlate('Design Operating Point'));
opnode.Editable = 0;

nodes = [folder;opnode];