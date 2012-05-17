function selected = set_selected(this, selected)
%SET_SELECTED   PreSet function for the 'selected' property.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/12/26 22:21:26 $

set(this, 'privSelectedFilters', selected);

sende = false;
if isempty(selected)
    set(this, 'privCurrentFilter', 0);
    sende = true;
else
    if ~any(this.CurrentFilter == selected) || this.CurrentFilter == 0
        set(this, 'privCurrentFilter', min(selected));

        sende = true;
    end
end

if sende
    % Send the event announcing that a new filter was selected.
    send(this, 'NewFilter', handle.EventData(this, 'NewFilter'));
end

% [EOF]
