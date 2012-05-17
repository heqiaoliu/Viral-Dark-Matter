function update(this,varargin)
%% update tscollection node in response to actions that add or delete a
%% child (timeseries) node, or time vector change 
%% This function is a callback to the datachange event of
%% @tscollection.

%   Author(s): Rajiv Singh
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2006/06/27 23:11:46 $

T = this.Tscollection;
currentChildren = this.getChildren;
CurrentNames = get(currentChildren,{'Label'});
NewNames = T.gettimeseriesnames;

if length(CurrentNames) < length(NewNames)
    % new timeseries members have been added
    addedOnes = setdiff(NewNames,CurrentNames);
    for k = 1:length(addedOnes)
        tsNames = T.gettimeseriesnames;
        for j=1:numel(tsNames)
            if strcmp(addedOnes{k},tsNames{j})
                newTs = getInternalProp(T,[],tsNames{j}); 
                break;
            end
        end
        newNode = newTs.createTstoolNode(this);
        if ~isempty(newNode)
            newNode = this.addNode(newNode);
        end
        % Send tsstructure change event for the benefit of the views
        if ~isempty(this.getRoot)
             ed = tsexplorer.tstreeevent(this.getRoot,'add',newNode);
             this.getRoot.fireTsStructureChangeEvent(ed);
        end
    end
elseif length(CurrentNames) > length(NewNames)
    % Existing members has been deleted
    deletedOnes = setdiff(CurrentNames,NewNames);
    for k = 1:length(deletedOnes)
        deletedNode = find(currentChildren,'Label',deletedOnes{k});
        nodepath = constructNodePath(deletedNode);
        if ~isempty(deletedNode)
            this.removeNode(deletedNode);
        end
        if ~isempty(this.getRoot)
            ed = tsexplorer.tstreeevent(this.getRoot,'remove',deletedNode);
            this.getRoot.fireTsStructureChangeEvent(ed,nodepath);
        end
    end
else
    % Note: adding or deleting objects would cause the appropriate
    % callbacks for ObjectBeingDestroyed or ObjectBeingAdded events 
    % (see the getDialogSchema for @tscollectionNode)
    
    % In case en object is neither added nor destroyed (such as if time
    % data changes), the table needs to be updated.
    this.updatePanel(varargin{:});
end

