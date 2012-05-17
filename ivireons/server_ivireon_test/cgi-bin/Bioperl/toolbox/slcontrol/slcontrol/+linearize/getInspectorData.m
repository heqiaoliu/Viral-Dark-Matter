function TopTreeNode = getInspectorData(ModelParameterMgr,root,J)
% GETINSPECTORDATA  Create the linearization inspector tree.
 
% Author(s): John W. Glass 10-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/04/11 20:40:35 $

% Get the first element of Jacobian data.  It is assumed and is the case
% that the Jacobian structure will always be the same.  Only A,B,C,D will
% be different.
J1 = J(1);

% Create an empty block list
BlockNameList = cell(size(J1.Mi.BlockHandles));

% Get the block handles and the other information such as sample time.
BlockHandles = J1.Mi.BlockHandles;
BlocksInPath = J1.Mi.BlocksInPath;
InputIdx = [J1.Mi.InputIdx;size(J1.B,2)];
OutputIdx = [J1.Mi.OutputIdx;size(J1.C,1)];
StateIdx = [J1.Mi.StateIdx;size(J1.A,1)];
SampleTimes = J1.Ts(1:length(J1.A));
BlockAnalyticFlags = J1.Mi.BlockAnalyticFlags;

% Find the hidden buffers and remove carriage
for ct = 1:length(BlockNameList)
    b = get_param(J1.Mi.BlockHandles(ct),'Object');
    if b.isSynthesized
        BlockHandles(ct) = 0;
    else
        BlockNameList{ct} = regexprep(getfullname(BlockHandles(ct)),'\n',' ');
    end
end
SynthesizedBlocks = (BlockHandles == 0);
BlockHandles(SynthesizedBlocks) = [];
BlockAnalyticFlags(SynthesizedBlocks) = [];
BlocksInPath(SynthesizedBlocks) = [];
    
% Remove carriage return from root
root = regexprep(root,'\n',' ');

% Tree Creation: Find the unique subsystem and normal mode model references
[MdlRefParents,MdlRefModels] = getNormalModeBlocks(slcontrol.Utilities,root);

% Find the unique model references blocks and replace with hidden normal
% mode model references.
uMdlRefParents = unique(MdlRefParents);

for ct = 1:numel(uMdlRefParents)
    blk = uMdlRefParents{ct};
    blkmdl = bdroot(blk);
    if ~strcmp(blkmdl,ModelParameterMgr.Model)
        ind = find(strcmp(blk,MdlRefParents));
        for ct2 = 2:numel(ind)
            hiddenblk = sprintf('%s%d%s',blk(1:numel(blkmdl)),ct2-2,blk(numel(blkmdl)+1:end));
            MdlRefParents{ind(ct2)} = hiddenblk;
        end
    end
end

for ct = 1:numel(MdlRefParents)
    MdlRefModels{ct} = get_param(MdlRefParents{ct},'NormalModeModelName');
end
models = [root;MdlRefModels];

% Tree Creation: Find the unique subsystem parents
UniqueParents = unique(regexprep(find_system(models,...
    'FollowLinks','on','LookUnderMasks','all',...
    'BlockType','SubSystem'),'\n',' '));

% Remove For Each subsystems since we cannot report the individual block
% linearizations for a For Each subsystem.  We will report only 
for ct = numel(UniqueParents):-1:1
    if ~isempty(find_system(UniqueParents{ct},'SearchDepth',1,'BlockType','ForEach'))
        UniqueParents(ct) = [];
    end
end
UniqueParents = unique([root;UniqueParents(:);MdlRefParents(:)]);

% If the system being linearized is not a container block then do not
% populate the linearization inspector.
if numel(UniqueParents) == 1
    blkobj = get_param(UniqueParents,'Object');
    if ~isa(blkobj{1},'Simulink.BlockDiagram') && ...
            ~isa(blkobj{1},'Simulink.ModelReference') && ...
            ~isa(blkobj{1},'Simulink.SubSystem')
        return
    end
end

% Get the parents to all of the block handles
Parents = regexprep(get_param(BlockHandles,'Parent'),'\n',' ');

% Get the blocks that were replaced
if ~isfield(J1.Mi,'Replacements') || isempty(J1.Mi.Replacements)
    Replacements = [];
else
    Replacements = {J1.Mi.Replacements.Name};
end

% Get the block replacement parents
RepParents = get_param(Replacements,'Parent');
ind_rep_parents = strcmp(get_param(Replacements,'BlockType'),'SubSystem');
RepSubSystemParents = RepParents(ind_rep_parents);
RepSubSystems = Replacements(ind_rep_parents);

% First Pass: Create the tree nodes
nodes = handle(NaN(numel(UniqueParents),1));
for ct = numel(UniqueParents):-1:1
    if ~any(strcmp(UniqueParents{ct},Replacements))
        switch class(get_param(UniqueParents{ct},'Object'))
            case 'Simulink.BlockDiagram'
                nodes(ct) = GenericLinearizationNodes.SubsystemMarker('root');
            case 'Simulink.ModelReference'
                nodes(ct) = GenericLinearizationNodes.SubsystemMarker('mdlref');
            case 'Simulink.SubSystem'
                nodes(ct) = GenericLinearizationNodes.SubsystemMarker('subsystem');
        end
        if strcmp(UniqueParents{ct},root)
            TopTreeNode = nodes(ct);
        end
        nodes(ct).Label = get_param(UniqueParents{ct},'Name');
    else
        % Remove any subsystem or model reference replaced by a user.
        nodes(ct) = [];
        UniqueParents(ct) = [];
    end
end

% Second Pass: Connect the nodes and set child data
for ct = 1:length(UniqueParents)
    % Find the parent node
    NodeParent = regexprep(get_param(UniqueParents{ct},'Parent'),'\n',' ');
    
    switch class(get_param(UniqueParents{ct},'Object'))
        case 'Simulink.BlockDiagram'
            % Find the blocks that are direct children
            ind_children = find(strcmp(Parents,UniqueParents{ct}));
            ind_rep_subsys_children = find(strcmp(RepSubSystemParents,UniqueParents{ct}));
        case 'Simulink.ModelReference'
            % Connect the subsystem to its parent
            if isa(get_param(NodeParent,'Object'),'Simulink.BlockDiagram') && ...
                  ~strcmp(NodeParent,root)
                ind_mdlblk = strcmp(NodeParent,MdlRefModels);
                ind_parent = strcmp(MdlRefParents{ind_mdlblk},UniqueParents);
            else
                ind_parent = strcmp(NodeParent,UniqueParents);
            end

            % Find the blocks that are direct children
            mdlName = get_param(UniqueParents{ct},'ModelName');
            ind_children = find(strcmp(Parents,mdlName));
            ind_rep_subsys_children = find(strcmp(RepSubSystemParents,mdlName));
            
            % Connect the nodes
            connect(nodes(ct), nodes(ind_parent), 'up');
        case 'Simulink.SubSystem'
            % Connect the subsystem to its parent
            ind_parent = strcmp(NodeParent,UniqueParents);

            if ~any(ind_parent)
                ind_ref = strcmp(NodeParent,MdlRefModels);
                if any(ind_ref)
                    ind_parent = strcmp(MdlRefParents{ind_ref},UniqueParents);
                else
                    ind_parent = [];
                end
            end

            % Find the blocks that are direct children
            ind_children = find(strcmp(Parents,UniqueParents{ct}));
            ind_rep_subsys_children = find(strcmp(RepSubSystemParents,UniqueParents{ct}));
            
            % Connect the nodes
            if ~isempty(ind_parent)
                connect(nodes(ct), nodes(ind_parent), 'up');
            end
    end

    % Remove any block that has a linearization specified by the user.
    ind_rep = ind_children;
    for child_ct = numel(ind_children):-1:1
        BlockName = getfullname(BlockHandles(ind_children(child_ct)));
        if any(strcmp(BlockName,Replacements))
            ind_children(child_ct) = [];
        else
            ind_rep(child_ct) = [];
        end
    end
    
    % Remove any subsystem, signal viewer scope, normal model mdl ref blocks in the linearization
    Block_Type = get_param(BlockHandles(ind_children),'BlockType');
    ind_subsys = find(strcmp(Block_Type,'SubSystem'));
    
    % Find any For Each subsystem and be sure to report its linearization
    % result.
    for ct2 = numel(ind_subsys):-1:1
        if ~isempty(find_system(BlockHandles(ind_children(ind_subsys(ct2))),'SearchDepth',1,'BlockType','ForEach'))
            ind_subsys(ct2) = [];
        end
    end
    
    % Find any model references and be sure to report any accelerated mode
    % model references.
    ind_mdlref = find(strcmp(Block_Type,'ModelReference'));
    for ct2 = numel(ind_mdlref):-1:1
        if ~strcmp(get_param(BlockHandles(ind_children(ind_mdlref(ct2))),'SimulationMode'),'Normal')
            ind_mdlref(ct2) = [];
        end
    end
    ind_scope = find(strcmp(Block_Type,'Scope'));
    if ~isempty(ind_scope)
        for ct2 = length(ind_scope):-1:1
            if strcmp(get_param(BlockHandles(ind_children(ind_scope(ct2))),'IOType'),'none')
                ind_scope(ct2) = [];
            end
        end
    end
    ind_children([ind_subsys(:);ind_scope(:);ind_mdlref(:)]) = [];

    % Create an empty default list model
    nnormal_child = numel(ind_children);
    nrep_child = numel(ind_rep);
    nrep_subsys = numel(ind_rep_subsys_children);
    nchild = nnormal_child + nrep_child + nrep_subsys;
    BlockListData = cell(nchild,1);

    % Create empty objects for the tree structure
    Block = GenericLinearizationNodes.BlockInspectorLinearization;

    % Create objects to be parented to the subsystem
    ChildBlocks = handle(NaN(nchild,1));
    for ct2 = 1:nnormal_child
        ChildBlocks(ct2) = Block.copy;

        % Find the index in the original list
        ind_original = find(J1.Mi.BlockHandles == BlockHandles(ind_children(ct2)));
        if (StateIdx(ind_original) ~= StateIdx(ind_original+1))
            indx = StateIdx(ind_original):(StateIdx(ind_original+1)-1);
        else
            indx = [];
        end
        if (InputIdx(ind_original) ~= InputIdx(ind_original+1))
            indu = InputIdx(ind_original):(InputIdx(ind_original+1)-1);
        else
            indu = [];
        end
        if (OutputIdx(ind_original) ~= OutputIdx(ind_original+1))
            indy = OutputIdx(ind_original):(OutputIdx(ind_original+1)-1);
        else
            indy = [];
        end

        % Store the sample times
        ChildBlocks(ct2).SampleTimes = SampleTimes(indx);
        if BlocksInPath(ind_children(ct2))
            ChildBlocks(ct2).InLinearizationPath = 'Yes';
        else
            ChildBlocks(ct2).InLinearizationPath = 'No';
        end
        
        % Store each of the block's linearizations
        ChildBlocks(ct2).setIOIndices(indx,indu,indy);
        ChildBlocks(ct2).FullBlockName = getfullname(BlockHandles(ind_children(ct2)));
        ChildBlocks(ct2).Jacobian = BlockAnalyticFlags(ind_children(ct2)).jacobian.type;

        % Add all blocks to the list
        BlockListData{ct2} = regexprep(get_param(BlockHandles(ind_children(ct2)),'Name'),'\n',' ');
    end

    % Handle block replacements
    for rep_ct = 1:nrep_child
        BlockPath = getfullname(BlockHandles(ind_rep(rep_ct)));
        BlockListData{rep_ct+nnormal_child} = regexprep(get_param(BlockPath,'Name'),'\n',' ');
        Block = GenericLinearizationNodes.BlockInspectorLinearizationUserReplacedBlock(BlockPath);
        
        % Get the index to the block in the full Jacobian.  This data is
        % used to determine if a block is part of the linearization path.
        % Find the index in the original list
        ind_original = find(J1.Mi.BlockHandles == BlockHandles(ind_rep(rep_ct)));

        if (InputIdx(ind_original) ~= InputIdx(ind_original+1))
            indu = InputIdx(ind_original):(InputIdx(ind_original+1)-1);
        else
            indu = [];
        end
        if (OutputIdx(ind_original) ~= OutputIdx(ind_original+1))
            indy = OutputIdx(ind_original):(OutputIdx(ind_original+1)-1);
        else
            indy = [];
        end

        Block.setIOIndices(indu,indy);
        ChildBlocks(rep_ct+nnormal_child) = Block;
    end    
    
    % Handle subsystems that were replaced by the user
    CurrentRepSubsystems = RepSubSystems(ind_rep_subsys_children);
    for rep_ct = 1:nrep_subsys
        BlockPath = CurrentRepSubsystems{nrep_subsys};
        BlockListData{rep_ct+nnormal_child+nrep_child} = regexprep(get_param(BlockPath,'Name'),'\n',' ');
        Block = GenericLinearizationNodes.BlockInspectorLinearizationUserReplacedBlock(BlockPath);
        Block.InLinearizationPath = 'N/A';
        ChildBlocks(rep_ct+nnormal_child+nrep_child) = Block;
    end

    % Store the blocks in the subsystem node
    nodes(ct).Blocks = ChildBlocks;
    nodes(ct).ListData = BlockListData;
end