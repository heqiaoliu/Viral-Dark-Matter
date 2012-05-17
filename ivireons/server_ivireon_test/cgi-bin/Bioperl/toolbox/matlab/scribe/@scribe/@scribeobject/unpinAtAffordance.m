function unpinAtAffordance(hThis, affNum)
% Unpin a scribe object at the given affordance

%   Copyright 2006-2008 The MathWorks, Inc.

hPins = hThis.Pin;
% Loop through the pins searching for a pin at a given affordance. Delete
% the first occurrence
hPins = hPins(ishandle(hPins));
for i = 1:length(hPins)
    if hPins(i).Affordance == affNum
        delete(hPins(i));
        hPins(i) = [];
        break;
    end
end

hThis.Pin = hPins;