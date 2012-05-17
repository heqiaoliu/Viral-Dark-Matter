function movedown(this)
%MOVEDOWN   Move the selected filters down the list.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:52 $

sf = sort(get(this, 'SelectedFilters'));

hv = get(this, 'Data');

% If the last selected filter is already at the bottom, return early.
if sf(end) == length(hv)
    return;
end

% Loop over the selected and move them all down one.
for indx = length(sf):-1:1
    selected_data = hv.elementat(sf(indx));
    down_data     = hv.elementat(sf(indx)+1);
    hv.replaceelementat(selected_data, sf(indx)+1);
    hv.replaceelementat(down_data, sf(indx));
end

% Make sure that the selected and current filter indexes are updated as
% well.  Use the PRIV so that "newFilter" is not sent.
set(this, 'privSelectedFilters', sf+1, ...
    'privCurrentFilter', this.CurrentFilter+1);

% Send the internal event to update the GUI.
send(this, 'NewData');

% [EOF]
