function hierarchy = utBuildTunableBlockHierarchy(this,ModelParameterMgr,tunedblocks)
% UTBUILDTUNABLEBLOCKHIERARCHY  Find hierarchy of tunable blocks in a
% model.
%
 
% Author(s): John W. Glass 04-Aug-2005
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/04/11 20:40:59 $

% Tree Creation: Find the unique subsystem and normal mode model references
% Get parent model and all of the referenced models
topmdl = ModelParameterMgr.Model;
[NormalRefModels,NormalRefParentBlocks] = getSingleInstanceNormalModeModels(ModelParameterMgr);
models = [topmdl;NormalRefModels];

UniqueParents = unique(regexprep(find_system(models,...
    'FollowLinks','on','LookUnderMasks','all',...
    'BlockType','SubSystem'),'\n',' '));
UniqueParents = [topmdl;sort([UniqueParents(:);NormalRefParentBlocks(:)])];

% Find all of the tuned block parents
Parents = regexprep(get_param(tunedblocks,'Parent'),'\n',' ');

% First Pass: Create the tree nodes
nodes = handle(NaN(numel(UniqueParents),1));
for ct = 1:numel(UniqueParents)
    switch class(get_param(UniqueParents{ct},'Object'))
        case 'Simulink.BlockDiagram'
            nodes(ct) = ControlDesignNodes.BlockExploreSubsystemMarker('root');
        case 'Simulink.ModelReference'
            nodes(ct) = ControlDesignNodes.BlockExploreSubsystemMarker('mdlref');
        case 'Simulink.SubSystem'
            nodes(ct) = ControlDesignNodes.BlockExploreSubsystemMarker('subsystem');    
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
                MdlRefBlk = NormalRefParentBlocks{strcmp(NodeParent,NormalRefModels)};
                ind_parent = strcmp(MdlRefBlk,UniqueParents);
            end

            % Find the blocks that are direct children
            ind_children = find(strcmp(Parents,UniqueParents{ct}));
            
            % Connect the nodes
            connect(nodes(ct), nodes(ind_parent), 'up');
    end

    % Create new variable for data
    nchild = length(ind_children);
    BlockListData = cell(nchild,2);
    BlockData = cell(nchild,1);
    
    % Create objects to be parented to the subsystem
    for ct2 = nchild:-1:1
        % Add all blocks to the list and set the default selection to be
        % false.
        BlockListData(ct2,:) = [{false},...
                        regexprep(get_param(tunedblocks{ind_children(ct2)},'Name'),'\n',' ')];
        % Store the full block name
        BlockData{ct2,1} = regexprep(tunedblocks{ind_children(ct2)},'\n',' ');
    end

    % Store the blocks in the subsystem node
    nodes(ct).ListData = BlockListData;
    nodes(ct).Blocks = BlockData;
end

% Return the root.
hierarchy = nodes(1);

