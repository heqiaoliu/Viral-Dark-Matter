function active = getEnabledStruct(obj)
; %#ok Undocumented
% Gets all the enabled properties and their values as a struct

%   Copyright 2007 The MathWorks, Inc.

% Find the enabled properties, their names and values.
ind = find(obj.IsPropEnabled == true);

% Make sure to return an empty struct if there are no enabled properties.
if isempty(ind)
    active = struct([]);
    return;
end
names = obj.Names(ind);
values = obj.pSafeGet(ind);
% Create a struct whose field names are 'names', and field values are 'values'.
active = cell2struct(values(:), names(:), 1);

