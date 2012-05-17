function [hThis] = brush(hMode)
% Constructor for the brush mode accessor

%   Copyright 2007-2009 The MathWorks, Inc.

% Syntax: graphics.brush(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error('MATLAB:graphics:brush:InvalidConstructor','First argument must be a handle to brush mode');
end
if ~strcmpi(hMode.Name,'Exploration.Brushing')
    error('MATLAB:graphics:brush:InvalidConstructor','First argument must be a handle to brush mode');
end
if ~isempty(hMode.ModeStateData.accessor) && ...
        ishandle(hMode.ModeStateData.accessor)
    error('MATLAB:graphics:brush:AccessorExists','Mode already contains an accessor.');
end
% Constructor
hThis = graphics.brush;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));