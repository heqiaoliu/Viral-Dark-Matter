function updateValidElementsTable(this)
% UPDATEVALIDELEMENTSTABLE  Enter a description here!
%
 
% Author(s): John W. Glass 04-Oct-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/01/26 01:58:24 $

%% Find the selected blocks in the tree
SelectedBlocks = cell(0,1);
NestedSearchTree(this.BlockTree);

%% Loop over the children to get the list of selected blocks
    function NestedSearchTree(node)
        %% Get the elements that are selected
        celldata = cell(node.ListData);
        ind_selected = find([celldata{:,1}]);
        SelectedBlocks = [SelectedBlocks;node.Blocks(ind_selected(:))];
        %% Clear the unapplied changes
        node.UnappliedSelectedElements = [];
        %% Loop over the children
        Children = node.getChildren;
        for ct = 1:length(Children)
            NestedSearchTree(Children(ct))
        end
    end

ValidElementsTableModel = this.Handles.ValidElementsTableModel;
if numel(SelectedBlocks) > 0
    %% Create the new table data
    ValidBlocksTableData = [num2cell(true(size(SelectedBlocks,1),1)),SelectedBlocks];

    %% Store the data
    this.ValidBlocksTableData = ValidBlocksTableData;
    ValidElementsTableModel.setData(ValidBlocksTableData);
else
    ValidElementsTableModel.clearRows;
end

end