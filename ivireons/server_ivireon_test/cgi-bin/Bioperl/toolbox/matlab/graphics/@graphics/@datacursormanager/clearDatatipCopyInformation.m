function clearDatatipCopyInformation(hThis)
% Removes serialized datatip information from targets

%   Copyright 2008 The MathWorks, Inc.


% Get a handle to the data tips:
hDatatips = hThis.DataCursors;

if isempty(hDatatips)
    return;
end

for i=1:numel(hDatatips)
    currCursor = hDatatips(i).DataCursorHandle;
    hTarget = get(currCursor,'Target');
    if isappdata(double(hTarget),'DatatipInformation')
        rmappdata(double(hTarget),'DatatipInformation');
    end
end