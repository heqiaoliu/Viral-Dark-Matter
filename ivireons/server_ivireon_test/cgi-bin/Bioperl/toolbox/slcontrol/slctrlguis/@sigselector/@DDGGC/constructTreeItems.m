function [items,name] = constructTreeItems(this)
%

% CONSTRUCTTREEITEMS - Construct the tree items & ids to set the tree in
% getDialogSchema given the current value of current signals and filter
% text.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:13 $

% Get the current data
% cursig = this.TCPeer.getItems;
ddgtreedata = this.TCPeer.getDDGTreeData;
filter = this.TCPeer.getFilterText;

% Construct the name
opts = this.TCPeer.getOptions;
name = opts.RootName;    
if ~isempty(filter)
    name = [name DAStudio.message('Slcontrol:sigselector:FilteredTreeTitle')];
end

% Apply filter
if isempty(filter)
    % Show everything if filter is empty
    items = ddgtreedata.AllItems;
else
    items = LocalApplyFilter(filter,ddgtreedata);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalApplyFilter
%  Returns the filtered items
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filtitems = LocalApplyFilter(filter,ddgtreedata)
% Find IDs of items that are matching the filtering query.
matchingIDs = find(~cellfun(@isempty,strfind(ddgtreedata.ItemNames,filter)));
% Based on locations of matching items, find the ids for the nodes that
% will need to be shown.
ids2show = LocalFindIDsToShow(matchingIDs,ddgtreedata.ParentHash);
% Get the filtered items in cell format for DDG tree
filtitems = LocalGetFilteredItems(ddgtreedata.AllItems,ddgtreedata.AllIDs,ids2show);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFindIDsToShow
%  Returns the IDs of the nodes that need to be shown in tree to be able to
%  show all the items that match filtering, i.e., includes all ancestors of
%  a matching node.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ids2show = LocalFindIDsToShow(matchingIDs,parenthash)
ids2show = [];
for ct = 1:numel(matchingIDs)
    parentIDs = parenthash{matchingIDs(ct)};
    ids2show = [ids2show parentIDs];
end
ids2show = unique(ids2show);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalGetFilteredItems
%  Returns the filtered items in cell array format for DDG tree.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filtitems = LocalGetFilteredItems(allitems,allids,ids2show)
filtitems = {};
num_items = numel(allitems);
% Traverse the all items recursively and add each node to the filtered
% items if its ID is in the list of IDs to show.
for ct = 1:num_items
    if ischar(allitems{ct})
        % This is a node, get its ID
        thisid = allids{ct};
        % Check if it is supposed to be shown
        if any(thisid == ids2show)
            % Show this node
            filtitems = [filtitems allitems(ct)];
            % Dive into its children, if any
            if (ct ~= num_items) && iscell(allitems{ct+1})
                % Find all subnodes to be shown 
                filtitemsinbus = LocalGetFilteredItems(allitems{ct+1},allids{ct+1},ids2show);
                % Add if anything found inside
                if ~isempty(filtitemsinbus)
                    filtitems = [filtitems {filtitemsinbus}];
                end
            end
        else
            % This is not a node, rather a subhierarchy for another node.
            continue;
        end
    end
end













   
    



