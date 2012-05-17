function Node = getNode(this)
% getNode  Gets tree node for SISOTool

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:51:01 $

Node = this.SISOTaskNode;

if isempty(Node);
    %% Create the project explorer
    [projectframe,workspace] = slctrlexplorer;

    %% Get the default nodes
    sisotask = controlnodes.SISODesignConfiguration('SISO Design Task',sisodb);
    sisotask.Label = sisotask.createDefaultName('SISO Design Task', workspace);

    %% Add the SISO Task node to the workspace
    workspace.addNode(sisotask);

    %% Make the SISO Task the selected node
    projectframe.setSelected(sisotask.getTreeNodeInterface);

    %% Show the explorer frame
    if ~projectframe.isVisible
        awtinvoke(projectframe,'setVisible(Z)',true);
    end

    %% Set the project dirty flag
    project.Dirty = 1;
    
    Node = sisotask;
    this.SISOTaskNode = sisotask;
end