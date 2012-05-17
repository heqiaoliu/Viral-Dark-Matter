function regMode = getuimode(hThis,name)
% Given the name of a mode, return the mode object, providing it has been
% used and is registered with the mode.

%   Copyright 2006 The MathWorks, Inc.

allRegisteredModes = hThis.RegisteredModes;
regMode = [];
for i = 1:length(allRegisteredModes)
    if strcmpi(allRegisteredModes(i).Name,name)
        regMode = allRegisteredModes(i);
        break;
    end
end