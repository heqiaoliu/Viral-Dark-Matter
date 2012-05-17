function treedata = constructDDGTreeData(sigs,hidebusroot)
%

% RESETSELECTEDFLAGS - utility function to be used in setItems
% method of selected signal viewer tool component. It sets all "Selected"
% fields to false. This is necessary in DDG as it does not allow
% pre-selection of tree nodes.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:04 $

% Get the list of all items and IDs in cell format that DDG tree uses from
% current signals. These don't change based on the state of the dialog (filter, selection).
[treedata.AllItems,treedata.AllIDs] = LocalGetAllItemsAndIDs(sigs,hidebusroot);

% Get flat lists for the string paths and item names in the order of
% appearance (hence IDs). String paths are attached to the tree as the user data and
% used when mapping selections made in the tree to IDs (see selectSignal
% method). Item name list is used when filtering.
[treedata.StringPaths,treedata.ItemNames] = LocalGetItemNamesAndPaths({},{},{},treedata.AllItems);

% Cache parent IDs for each ID in a cell array
treedata.ParentHash = LocalConstructParentIDsHashTable(sigs);
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalGetAllItemsAndIDs
%  Constructs and returns the full list of items and IDs in the cell format
%  that DDG tree requires given the current set of signals.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [items,ids] = LocalGetAllItemsAndIDs(cursig,hidebusroot)
items = {};
ids = {};
for ct = 1:numel(cursig)
    if strcmp(class(cursig{ct}),'slctrlguis.sigselector.BusItem')
        % Bus signal
        % Add parent - Use the name in the items object. If empty, use the
        % signal name at the top level. If it is also empty, then the
        % hierarchy will be listed starting from first level (which is
        % desirable in a block dialog showing a single bus.
        hier = cursig{ct}.Hierarchy;
        % Add parent if HideBusroot is false
        if ~hidebusroot
            items = [items {cursig{ct}.Name}];
            ids = [ids {hier.TreeID}];
            % Construct its hierarchy
            [itemsinbus,idsinbus] = LocalGetBusItemsAndIDs(hier.Children);
            % Add its hierarchy
            items = [items {itemsinbus}];
            ids = [ids {idsinbus}];
        else
            % Directly construct hierarchy ignoring parent
            [items,ids] = LocalGetBusItemsAndIDs(hier);
        end        
    else
        % Regular signal, add as new node
        items = [items {cursig{ct}.Name}];
        ids = [ids {cursig{ct}.TreeID}];
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalGetBusItemsAndIDs
%  Constructs and returns the list of items and IDs in the cell format
%  that DDG tree requires given a hierarchy structure for a bus signal
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [busitems,busids] = LocalGetBusItemsAndIDs(busstruct)
busitems = {};
busids = {};
s = busstruct;
for ct = 1:numel(s)    
    if isempty(s(ct).Children)
        % Hit the bottom, add it
        busitems = [busitems {s(ct).SignalName}];
        busids = [busids {s(ct).TreeID}];
    else
        % Recurse down
        [itms,ids] = LocalGetBusItemsAndIDs(s(ct).Children);
        busitems = [busitems {s(ct).SignalName,itms}];
        busids = [busids {s(ct).TreeID,ids}];
    end
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalGetItemNamesAndPaths
%  Constructs and returns the flat lists for full string paths (to be used
%  in tree selection) and for items names (to be used in filtering).
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [strpath,flatlist] = LocalGetItemNamesAndPaths(strpath,flatlist,curloc,items)
% Traverse the items tree (in cell format)
for ct = 1:numel(items)
    if ischar(items{ct})
        % This is a node, record its item name and full string path
        flatlist{end+1} = items{ct};
        % Replace slash character with double slashes as the method to get
        % the selection on a DDG tree does.
        str = regexprep(items{ct},{'/'},{'//'});
        % Construct the string path for items name and its location.
        if isempty(curloc)
            strpath{end+1} = str;
        else
            strpath{end+1} = [LocalFlatCurrentLocation(curloc) '/' str];
        end
    elseif iscell(items{ct})
        % This is a sub hierarchy, update the current location as you are
        % diving into a lower level.
        curloc{end+1} = regexprep(items{ct-1},{'/'},{'//'});
        % Construct list for this subhierarchy recursively.
        [strpath,flatlist] = LocalGetItemNamesAndPaths(strpath,flatlist,curloc,items{ct});
        % Remove the node for current location as we are jump back to the
        % upper level.
        curloc(end) = [];
    end    
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFlatCurrentLocation
%  Return the full single string for current location which is a cell array
%  of node names inserting slashes in between nodes.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalFlatCurrentLocation(curloc)
str = curloc{1};
for ct = 2:numel(curloc)
    str = [str '/' curloc{ct}];
end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalConstructParentIDsHashTable
%  Construct a cell hash where n^th element stores the parent IDs for the
%  node with ID n. This hash is used in filtering algorithm when deciding
%  the nodes to show given the nodes that match with the filter.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parenthash = LocalConstructParentIDsHashTable(sigs)
parenthash = {};
for ct = 1:numel(sigs)
    if strcmp(class(sigs{ct}),'slctrlguis.sigselector.SignalItem')
        % Regular signal
        parenthash{sigs{ct}.TreeID} = sigs{ct}.TreeID;
    else
        % Bus signal
        hier = sigs{ct}.Hierarchy;        
        for ctc = 1:numel(hier)        
            % Write down outer levels
            parenthash{hier(ctc).TreeID} = hier(ctc).TreeID;
            % Recurse down to the bus
            parenthash = LocalConstructHashForBus(parenthash,hier(ctc).Children,hier(ctc).TreeID);
        end        
    end
end           
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalConstructHashForBus
%  Construct the cell hash for a bus contents
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function parenthash = LocalConstructHashForBus(parenthash,hier,parentids)
for ct = 1:numel(hier)
    % Add the parents for this node
    parenthash{hier(ct).TreeID} = [parentids hier(ct).TreeID];
    % Recurse down if it has children
    if ~isempty(hier(ct).Children)
        parenthash = LocalConstructHashForBus(parenthash,hier(ct).Children,[parentids hier(ct).TreeID]);        
    end
end
end

        
