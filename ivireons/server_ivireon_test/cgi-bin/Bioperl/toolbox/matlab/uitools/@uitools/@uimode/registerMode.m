function hMode = registerMode(hThis,hMode)
% Register a mode with this mode to be composed.

%   Copyright 2006 The MathWorks, Inc.

% Specify that this mode is being composed
hMode.ParentMode = hThis;

if isempty(hThis.RegisteredModes)
    hThis.RegisteredModes = hMode;
else
    hThis.RegisteredModes(end+1) = hMode;
end