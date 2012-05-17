function values = pSafeGet(obj, ind)
; %#ok Undocumented
% Returns all the property values for the specified indices, and converts []
% into '' wherever necessary.  Always returns values as a cell array.

%   Copyright 2007 The MathWorks, Inc.

% DataLocation is of the type MATLAB array and if it's empty, we want to set it
% to the empty string.  It should be clear that we also want empty callbacks and
% strings to appear as empty strings.
needConversion = {'string', 'MATLAB callback', 'MATLAB array'};
values = obj.PropValue(ind);

needsTesting = find(cellfun(@isempty, values));
% Loop over all the empty values and replace them with '' where necessary.
for i = needsTesting
    if ismember(obj.Types(ind(i)), needConversion)
        values{i} = '';
    end
end
