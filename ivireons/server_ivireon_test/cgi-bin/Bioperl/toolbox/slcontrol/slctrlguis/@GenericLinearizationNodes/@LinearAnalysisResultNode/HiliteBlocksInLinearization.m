function HiliteBlocksInLinearization(this,mode)
% HiliteBlocksInLinearization - Highlights the blocks that contribute to a
% linearization.
%   Copyright 2003-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/04/11 20:41:17 $

% Get the blocks in the linearization path
BlocksInPathByName = this.BlocksInPathByName;

% If this property is empty then we need to populate the data.  This is a
% result of a change between versions.  
if isempty(BlocksInPathByName)
    BlocksInPathByName = cell(0,1);
    node = this.InspectorNode;
    % Use the nested function below to get the data.
    nestFindBlocks(node)
    this.BlocksInPathByName = BlocksInPathByName;
end

    function nestFindBlocks(node)
        for ct = 1:length(node.Blocks)
            if strcmp(node.Blocks(ct).InLinearizationPath,'Yes')
                BlocksInPathByName{end+1,:} = node.Blocks(ct).getFullBlockName;
            end
        end
        Children = node.getChildren;
        for ct = 1:length(Children)
            nestFindBlocks(Children(ct))
        end
    end

% If the number of results is greater then 1 we need to index into the
% blocks in path by name.  Handle compatibility.  Before R2010b we only
% returned a single blocks in path result.  In R2010b we returned multiple
% results when users performed multiple snapshot linearizations.
if numel(this.ModelJacobian) > 1 && ~isempty(BlocksInPathByName) && iscell(BlocksInPathByName{1})
    BlocksInPathByName = BlocksInPathByName{this.Dialog.getSelectedModelIndex};
elseif iscell(BlocksInPathByName)
    BlocksInPathByName = BlocksInPathByName{1};
end

% Hilite the blocks in the linearization.  
for ct2 = 1:length(BlocksInPathByName)
    try %#ok<TRYNC>
        set_param(BlocksInPathByName{ct2},'HiliteAncestors',mode);
    end
end

end
