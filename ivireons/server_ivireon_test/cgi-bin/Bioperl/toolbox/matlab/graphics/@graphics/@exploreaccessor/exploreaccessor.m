function [hThis] = exploreaccessor(hMode)
% Constructor for the mode accessor

%   Copyright 2006 The MathWorks, Inc.

% Syntax: graphics.exploreaccessor(mode,name)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error('MATLAB:graphics:exploreaccessor:InvalidConstructor','First argument must be a handle to a mode');
end

% Constructor
hThis = graphics.exploreaccessor;

set(hThis,'ModeHandle',hMode);
hMode.ModeStateData.accessor = hThis;