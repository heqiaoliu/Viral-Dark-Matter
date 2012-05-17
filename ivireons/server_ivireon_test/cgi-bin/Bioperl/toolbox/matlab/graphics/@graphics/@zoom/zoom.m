function [hThis] = zoom(hMode)
% Constructor for the zoom mode accessor

%   Copyright 2002-2009 The MathWorks, Inc.

% Syntax: graphics.zoom(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error('MATLAB:graphics:zoom:InvalidConstructor','First argument must be a handle to pan mode');
end
if ~strcmpi(hMode.Name,'Exploration.Zoom')
    error('MATLAB:graphics:zoom:InvalidConstructor','First argument must be a handle to pan mode');
end
if isfield(hMode.ModeStateData,'accessor') && ...
        ishandle(hMode.ModeStateData.accessor)
    error('MATLAB:graphics:zoom:AccessorExists','Mode already contains an accessor.');
end
% Constructor
hThis = graphics.zoom;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));