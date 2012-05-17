function [hThis] = rotate3d(hMode)
% Constructor for the rotate3d mode accessor

%   Copyright 2006-2009 The MathWorks, Inc.

% Syntax: graphics.rotate3d(mode)
if ~ishandle(hMode) || ~isa(hMode,'uitools.uimode')
    error('MATLAB:graphics:rotate3d:InvalidConstructor','First argument must be a handle to rotate3d mode');
end
if ~strcmpi(hMode.Name,'Exploration.Rotate3d')
    error('MATLAB:graphics:rotate3d:InvalidConstructor','First argument must be a handle to rotate3d mode');
end
if isfield(hMode.ModeStateData,'accessor') && ...
        ishandle(hMode.ModeStateData.accessor)
    error('MATLAB:graphics:rotate3d:AccessorExists','Mode already contains an accessor.');
end
% Constructor
hThis = graphics.rotate3d;

set(hThis,'ModeHandle',hMode);

% Add a listener on the figure to destroy this object upon figure deletion
addlistener(hMode.FigureHandle,'ObjectBeingDestroyed',@(obj,evd)(delete(hThis)));