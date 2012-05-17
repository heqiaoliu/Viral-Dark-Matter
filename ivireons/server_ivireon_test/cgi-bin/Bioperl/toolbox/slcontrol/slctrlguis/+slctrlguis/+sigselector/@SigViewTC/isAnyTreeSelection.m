function bool = isAnyTreeSelection(this)
% ISANYTREESELECTION  Return true if anything in the tree is selected
%
 
% Author(s): Erman Korkut 04-Mar-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:06 $

bool = false;
items = this.getItems;
for ct = 1:numel(items)
    % Determine bus vs. regular signal
    if strcmp(class(items{ct}),'slctrlguis.sigselector.SignalItem')
        % Regular signal
        if items{ct}.Selected
            bool = true;
            break;
        end
    else
        % Bus signal
        for ctc = 1:numel(items{ct}.Hierarchy)
            % Check root
            if items{ct}.Hierarchy(ctc).Selected
                bool = true;
                break;
            end
            % Check children recursively
            if LocalCheckBusElements(items{ct}.Hierarchy(ctc).Children)
                bool = true;
                break;
            end            
        end
    end
end

function bool = LocalCheckBusElements(bus)
bool = false;
for ct = 1:numel(bus)
    if bus(ct).Selected
        bool = true;
        break;
    end
    if ~isempty(bus(ct).Children)
        if LocalCheckBusElements(bus(ct).Children)
            bool = true;
            break;
        end
    end    
end
