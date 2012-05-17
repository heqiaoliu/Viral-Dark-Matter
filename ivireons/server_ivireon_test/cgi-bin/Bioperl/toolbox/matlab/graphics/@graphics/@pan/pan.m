function [hThis] = pan(hMode)
% Constructor for the pan mode accessor

%   Copyright 2006-2009 The MathWorks, Inc.

% Syntax: graphics.pan(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error('MATLAB:graphics:pan:InvalidConstructor','First argument must be a handle to pan mode');
end
if ~strcmpi(hMode.Name,'Exploration.Pan')
    error('MATLAB:graphics:pan:InvalidConstructor','First argument must be a handle to pan mode');
end
if isfield(hMode.ModeStateData,'accessor') && ...
        ishandle(hMode.ModeStateData.accessor)
    error('MATLAB:graphics:pan:AccessorExists','Mode already contains an accessor.');
end
% Constructor
hThis = graphics.pan;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));