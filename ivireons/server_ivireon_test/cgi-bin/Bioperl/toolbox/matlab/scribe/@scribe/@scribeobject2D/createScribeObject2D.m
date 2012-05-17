function createScribeObject2D(hThis,varargin)
% Create and set up a 1-D scribe object

%   Copyright 2006 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject;

% Set up the affordances. For 2-D objects, the affordances correspond to
% the edges and corners of the bounding box. There is also an invisible
% selection handle in the center
% Preallocate a handle vector:
hAf = handle(zeros(1,9)-1);
% Given the position, compute the bounding box.
lx = hThis.Position(1); 
rx = hThis.Position(1)+hThis.Position(3); 
cx = hThis.Position(1)+hThis.Position(3)/2;
px = [lx rx rx lx lx cx rx cx cx];
uy = hThis.Position(2); 
ly = hThis.Position(2)+hThis.Position(4);
cy = hThis.Position(2)+hThis.Position(4)/2;
py = [uy ly uy ly cy uy cy ly cy];
tags = {'bottomleft','topright','bottomright','topleft','left','bottom','right','top','center'};
for i=1:length(hAf)
    hAf(i) = hg.line('XData', px(i), 'YData', py(i), ...
        'LineWidth', 0.01, 'Color', [0 0 0], 'Marker', 'square', ...
        'MarkerSize', hThis.Afsize, 'MarkerFaceColor', [0 0 0], ...
        'MarkerEdgeColor', [1 1 1], 'Parent', double(hThis), ...
        'Visible', 'off', 'Interruptible', 'off','HitTest','off',...
        'HandleVisibility','off','Tag',tags{i},...
        'IncludeRenderer','off','XLimInclude','off','YLimInclude','off',...
        'ZLimInclude','off');
end
hThis.Srect = hAf;

% There is one pin for 2-D annotations.
hThis.PinExists = false;

% The bottom-left affordance may be pinned by default. Capture this in the 
% PinAff property
hThis.PinAff = 1;

% Add a listener to the "Pin" property
l = handle.listener(hThis,hThis.findprop('Pin'),...
    'PropertyPostSet',@localSetPin);
hThis.PropertyListeners(end+1) = l;
% Since the center selection handle should not be visible, add a listener
% to its "Visible" property to ensure that it always remains invisible.
hCenterAff = hThis.Srect(end);
l = handle.listener(hCenterAff,hCenterAff.findprop('Visible'),...
    'PropertyPostSet',@(obj,evd)(set(hCenterAff,'Visible','off')));
hThis.PropertyListeners(end+1) = l;

% Set properties passed by varargin
set(hThis,varargin{:});

%--------------------------------------------------------------------%
function localSetPin(hProp,eventData) %#ok
% When a pin is added, we must maintain the invariant that a 2-D object
% only have one pin at a time.

hThis = eventData.affectedObject;
if isempty(hThis.Pin)
    hThis.PinExists = false;
    return;
end
if isscalar(hThis.Pin)
    hThis.PinAff = hThis.Pin.Affordance;
else
    delete(hThis.Pin(1));
    hThis.Pin = hThis.Pin(end);
    hThis.PinAff = hThis.Pin.Affordance;
end
hThis.PinExists = true;