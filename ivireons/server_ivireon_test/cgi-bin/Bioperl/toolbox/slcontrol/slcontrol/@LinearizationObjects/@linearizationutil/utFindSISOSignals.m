function topnode = utFindSISOSignals(this,ModelParameterMgr)
% UTFINDSISOSIGNALS  Find the single element signals in a model. 
%
 
% Author(s): John W. Glass 04-Aug-2005
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2010/04/11 20:41:03 $

% Create the model parameter manager
models = ModelParameterMgr.getUniqueNormalModeModels;
topmdl = ModelParameterMgr.Model;
[NormalRefModels,NormalRefParentBlocks] = getSingleInstanceNormalModeModels(ModelParameterMgr);

% Find the valid single element double valued signals
signals = find_system(models,'FindAll','on','type','port',...
                    'PortType','outport',...
                    'CompiledPortWidth',1,...
                    'CompiledPortDataType','double');

% Get the list of parent blocks
parentblocks = get_param(signals,'Parent');
if ~iscell(parentblocks)
    parentblocks = {parentblocks};
end
Parents = regexprep(get_param(parentblocks,'Parent'),'\n',' ');

% Tree Creation: Find the unique subsystem parents
UniqueParents = unique(regexprep(find_system(models,...
    'FollowLinks','on','LookUnderMasks','all',...
    'BlockType','SubSystem'),'\n',' '));
UniqueParents = sort([topmdl;UniqueParents(:);NormalRefParentBlocks(:)]);

% First Pass: Create the tree nodes
nodes = handle(NaN(numel(UniqueParents),1));
for ct = 1:numel(UniqueParents)
    switch class(get_param(UniqueParents{ct},'Object'))
        case 'Simulink.BlockDiagram'
            topnode = ControlDesignNodes.SignalExploreSubsystemMarker('root');
            nodes(ct) = topnode;
        case 'Simulink.ModelReference'
            nodes(ct) = ControlDesignNodes.SignalExploreSubsystemMarker('mdlref');
        case 'Simulink.SubSystem'
            nodes(ct) = ControlDesignNodes.SignalExploreSubsystemMarker('subsystem');    
    end
    nodes(ct).Label = get_param(UniqueParents{ct},'Name');
end

% Second Pass: Connect the nodes and set child data
for ct = 1:length(UniqueParents)
    % Find the parent node
    NodeParent = regexprep(get_param(UniqueParents{ct},'Parent'),'\n',' ');
    
    switch class(get_param(UniqueParents{ct},'Object'))
        case 'Simulink.BlockDiagram'
            % Find the blocks that are direct children
            ind_children = find(strcmp(Parents,UniqueParents{ct}));
            
        case 'Simulink.ModelReference'
            % Connect the subsystem to its parent
            if isa(get_param(NodeParent,'Object'),'Simulink.BlockDiagram') && ...
                  ~strcmp(NodeParent,topmdl)
                ind_mdlblk = strcmp(NodeParent,NormalRefModels);
                ind_parent = strcmp(NormalRefParentBlocks{ind_mdlblk},UniqueParents);
            else
            ind_parent = strcmp(NodeParent,UniqueParents);
            end

            % Find the blocks that are direct children
            ind_children = find(strcmp(Parents,get_param(UniqueParents{ct},'ModelName')));
            
            % Connect the nodes
            connect(nodes(ct), nodes(ind_parent), 'up');
        case 'Simulink.SubSystem'
            % Connect the subsystem to its parent
            ind_parent = strcmp(NodeParent,UniqueParents);

            if ~any(ind_parent)
                indrefblk = strcmp(NodeParent,NormalRefModels);
                if ~any(indrefblk)
                    continue;
                end
                MdlRefBlk = NormalRefParentBlocks{indrefblk};
                ind_parent = strcmp(MdlRefBlk,UniqueParents);
            end

            % Find the blocks that are direct children
            ind_children = find(strcmp(Parents,UniqueParents{ct}));
            
            % Connect the nodes
            connect(nodes(ct), nodes(ind_parent), 'up');
    end

    % Create an empty default list model
    nchild = length(ind_children);
    
    % Create new variable for data
    SignalListData = cell(nchild,1);
    SignalData = cell(nchild,1);
    
    % Create objects to be parented to the subsystem
    for ct2 = nchild:-1:1
        % Add all blocks to the list
        SignalListData{ct2,:} = sprintf('%s:%d',...
                    regexprep(get_param(parentblocks{ind_children(ct2)},'Name'),'\n',' '),...
                    get_param(signals(ind_children(ct2)),'PortNumber'));
        % Store the full block name
        SignalData{ct2,1} = sprintf('%s:%d',...
                    regexprep(parentblocks{ind_children(ct2)},'\n',' '),...
                    get_param(signals(ind_children(ct2)),'PortNumber'));
    end
    
    % Store the blocks in the subsystem node
    nodes(ct).ListData = SignalListData;
    nodes(ct).Signals = SignalData;
end
