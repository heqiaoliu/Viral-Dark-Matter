function createLine(hThis,varargin)
% Create and set up a scribe line

%   Copyright 2006 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject1D;

% Define the shape type:
hThis.ShapeType = 'line';

% Angle of the line
dx = hThis.X(2) - hThis.X(1);
dy = hThis.Y(2) - hThis.Y(1);
theta = atan2(dy,dx);
costh = cos(theta); sinth = sin(theta);
% Length of whole shape in normal coordinates:
nlength = sqrt((hThis.X(1) - hThis.X(2))^2 + (hThis.Y(1) - hThis.Y(2))^2);
% Unfortate x,y vectors for line part
x = [0, nlength];
y = [0, 0];
% Rotate by theta and translate by hThis.X(1),hThis.Y(1)
xx = x.*costh - y.*sinth + hThis.X(1);
yy = x.*sinth + y.*costh + hThis.Y(1);
% Create the lne segment
hThis.LineHandle = hg.line('XData',xx,'YData',yy,'Parent',double(hThis),...
    'Interruptible','off','HitTest','off','HandleVisibility','off');

% The Selection Handles must always be on top in the child order:
hChil = findall(double(hThis));
set(hThis,'Children',[hChil(3:end);hChil(2)]);

% Define the properties which should listen to the "Color" property
hThis.ColorProps{end+1} = 'LineColor';

% Set the Edge Color Property to correspond to the "Color" property of the
% line.
hThis.EdgeColorProperty = 'Color';
hThis.EdgeColorDescription = 'Color';

% Install a property listener on the "Position" property:
l = handle.listener(hThis,hThis.findprop('Position'), ...
    'PropertyPostSet', @localChangePosition);
hThis.PropertyListeners(end+1) = l;

% Set properties passed by varargin
set(hThis,varargin{:});

%---------------------------------------------------------------------%
function localChangePosition(hProp,eventData) %#ok
% Update the line data to be in line with the position

hThis = eventData.affectedObject;
if ~hThis.UpdateInProgress
    hThis.UpdateInProgress = true;
    hLine = hThis.LineHandle;
    % Extract the X and Y coordinates in normalized units and apply them to the
    % line.
    set(hLine,'XData',hThis.NormX,...
        'YData',hThis.NormY);
    hThis.UpdateInProgress = false;
end
