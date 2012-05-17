function clearModes(hThis)
% Delete all registered modes for the figure.

%   Copyright 2006 The MathWorks, Inc.

for hMode = hThis.RegisteredModes
    delete(hMode);
end