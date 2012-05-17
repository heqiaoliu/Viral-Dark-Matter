function createScribeObject1D(hThis,varargin)
% Create and set up a 1-D scribe object

%   Copyright 2006 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject;

% Set up the affordances. For 1-D objects, the affordances correspond to
% the start and end of the object (line, arrow, curve, etc)
% Preallocate a handle vector:
hAf = handle([-1 -1]);
tags = {'bottomleft','topright'};
for i=1:2
    hAf(i) = hg.line('XData', hThis.X(i), 'YData', hThis.Y(i), ...
        'LineWidth', 0.01, 'Color', [0 0 0], 'Marker', 'square', ...
        'MarkerSize', hThis.Afsize, 'MarkerFaceColor', [0 0 0], ...
        'MarkerEdgeColor', [1 1 1], 'Parent', double(hThis), ...
        'Visible', 'off', 'Interruptible', 'off','HitTest','off',...
        'HandleVisibility','off','Tag',tags{i},...
        'IncludeRenderer','off','XLimInclude','off','YLimInclude','off',...
        'ZLimInclude','off');
end
hThis.Srect = hAf;

% There are two pins for the 1-D annotations, 
hThis.PinExists = false(1,2);

% Both affordances may be pinned. Capture this in the PinAff property
hThis.PinAff = [1;2];

% Set up listeners
% Add a listener to the "Pin" property
l = handle.listener(hThis,hThis.findprop('Pin'),...
    'PropertyPostSet',@localSetPin);
hThis.PropertyListeners(end+1) = l;

% Set properties passed by varargin
set(hThis,varargin{:});

%--------------------------------------------------------------------%
function localSetPin(hProp,eventData) %#ok<INUSL>
% When the pins change, update the "PinExists" property

hThis = eventData.affectedObject;
hPins = eventData.NewValue;
hThis.PinExists = false(1,2);

for i = 1:length(hPins)
    if ishandle(hPins(i))
        hThis.PinExists(hPins(i).Affordance) = true;
    end
end