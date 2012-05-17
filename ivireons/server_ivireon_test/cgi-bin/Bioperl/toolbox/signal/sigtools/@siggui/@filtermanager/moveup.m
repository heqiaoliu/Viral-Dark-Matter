function moveup(this)
%MOVEUP   Move the selected filters up the list.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:53 $

sf = sort(get(this, 'SelectedFilters'));

% If the first selected filter is already at the top, return early.
if sf(1) == 1
    return;
end

hv = get(this, 'Data');

% Loop over the selected and move them all up one.
for indx = 1:length(sf)
    selected_data = hv.elementat(sf(indx));
    up_data       = hv.elementat(sf(indx)-1);
    hv.replaceelementat(selected_data, sf(indx)-1);
    hv.replaceelementat(up_data, sf(indx));
end

% Make sure that the selected and current filter indexes are updated as
% well.  Use the PRIV so that "newFilter" is not sent.
set(this, 'privSelectedFilters', sf-1, ...
    'privCurrentFilter', this.CurrentFilter-1);

% Send the internal event to update the GUI.
send(this, 'NewData');

% [EOF]
