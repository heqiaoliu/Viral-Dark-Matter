function unregisterMode(hThis,hMode)
% Given a mode, remove it from the list of modes currently
% registered with the mode manager.

%   Copyright 2006 The MathWorks, Inc.

allRegisteredModes = hThis.RegisteredModes;
for i = 1:length(allRegisteredModes)
    if isequal(allRegisteredModes(i),hMode)
        allRegisteredModes(i) = [];
        break;
    end
end

hThis.RegisteredModes = allRegisteredModes;