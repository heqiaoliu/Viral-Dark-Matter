function this = applyTreeSelections(this,selectedids)
%

% APPLYTREESELECTIONS - Since currently the update event is not customizable, we directly
% write to database when the change is only a selection of a tree
% element so that we can avoid a full update. We do not want to
% perform a full update as a result of tree selection since this
% redraws the whole tree and makes multi-selection in DDG view not
% work properly.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:03 $

items = this.getItems;
% Mark the specified signals to be selected and all others not selected.
for ct = 1:numel(items) 
    % Determine a regular vs. bus signal
    if strcmp(class(items{ct}),'slctrlguis.sigselector.SignalItem')
        % Regular signal
        if any(items{ct}.TreeID == selectedids)
            items{ct}.Selected = true;
        else
            items{ct}.Selected = false;
        end
    else
        % Bus signal
        for ctc = 1:numel(items{ct}.Hierarchy)
            if any(items{ct}.Hierarchy(ctc).TreeID == selectedids)
                items{ct}.Hierarchy(ctc).Selected = true;
            else
                items{ct}.Hierarchy(ctc).Selected = false;
            end
            % Process children recursively
            items{ct}.Hierarchy(ctc).Children = LocalMarkBusElements(items{ct}.Hierarchy(ctc).Children,selectedids);
        end
    end          
end

% Write results directly to database to avoid the need for a full update.
this.Database.Items = items;

function bus = LocalMarkBusElements(bus,selectedids)
for ct = 1:numel(bus)
    if any(bus(ct).TreeID == selectedids)
        bus(ct).Selected = true;
    else
        bus(ct).Selected = false;
    end
    if ~isempty(bus(ct).Children)
        bus(ct).Children = LocalMarkBusElements(bus(ct).Children,selectedids);
    end
end

