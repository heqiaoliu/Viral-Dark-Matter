function createScribeObject(hThis,varargin)
% Create and set up a scribe object

%   Copyright 2006-2008 The MathWorks, Inc.

% Set up listeners

% For reverse compatibility reasons, appdata must be set:
setappdata(double(hThis),'scribeobject','on');

% Add a listener to the "Position" property
% Set up listeners
l = handle.listener(hThis,hThis.findprop('Position'),...
    'PropertyPostSet',@localSetPosition);

% Listen to the "Visible" property of the object:
l(end+1) = handle.listener(hThis,hThis.findprop('Visible'),...
    'PropertyPostSet',@localChangedVisible);

% Listen to the "SelectionHighlight" property of the object:
l(end+1) = handle.listener(hThis,hThis.findprop('SelectionHighlight'),...
    'PropertyPostSet',@localChangeSelectionHighlight);

% Listen to the "Position" property of the figure:
hFig = handle(ancestor(hThis,'Figure'));
l(end+1) = handle.listener(hFig,hFig.findprop('Position'),...
    'PropertyPreSet',{@localPreparePosition,hThis});
l(end+1) = handle.listener(hFig,hFig.findprop('Position'),...
    'PropertyPostSet',{@localUpdatePosition,hThis});


hThis.PropertyListeners = l;

% Set properties passed by varargin
set(hThis,varargin{:});

%--------------------------------------------------------------------%
function localSetPosition(hProp,eventData) %#ok
hThis = eventData.affectedObject;

hThis.updateSelectionHandles;

%---------------------------------------------------------%
function localUpdatePosition(hProp,eventData,hThis) %#ok
% Restore the "Position" property when the figure size changes

hThis.FigureResize = true;
hThis.Position = hThis.StoredPosition;
hThis.FigureResize = false;

%---------------------------------------------------------%
function localPreparePosition(hProp,eventData,hThis) %#ok
% Cache the "Position" property when the figure size changes

hThis.StoredPosition = hThis.Position;

%---------------------------------------------------------%
function localChangeSelectionHighlight(hProp,eventData) %#ok
% Keep track of selection highlights when modifying the
% "SelectionHighlight" property.

h = eventData.affectedObject;
if strcmpi(eventData.NewValue,'on') 
    if strcmpi(h.Visible,'on')
        set(h.Srect,'Visible',h.Selected);
    end
else
    set(h.Srect,'Visible','off');
end        

%---------------------------------------------------------%
function localChangedVisible(hProp,eventData) %#ok
% Keep track of selection highlights when making an object visible

h = eventData.affectedObject;
if strcmpi(eventData.NewValue,'on')
    if strcmpi(h.SelectionHighlight,'on')
        set(h.Srect,'Visible',h.Selected);
    else
        set(h.Srect,'Visible','off');
    end
end