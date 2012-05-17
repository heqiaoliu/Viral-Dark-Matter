function createScribeEllipse(hThis,varargin)
% Create and set up a scribe ellipse

%   Copyright 2006 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject2D;

% Define the shape type:
hThis.ShapeType = 'ellipse';

% Create the main rectangle.
pos = hThis.Position;
x1 = pos(1);
x2 = pos(1)+pos(3);
y1 = pos(2);
y2 = pos(2)+pos(4);
px = [x1 x2;x1 x2];
py = [y1 y1;y2 y2];
pz = [0 0;0 0];

% Create bounding rectangle
hThis.BoundingRectHandle = hg.surface('EdgeColor','none', ...
    'FaceColor', 'none', 'CData', NaN, 'FaceLighting','none', ...
    'Parent', double(hThis), 'Interruptible','off', 'HitTest', 'off', ...
    'HandleVisibility', 'off', 'XData', px, 'YData', py, 'ZData', pz);

% Create ellipse (rectangle)
hThis.EllipseHandle = hg.rectangle('curvature', [1 1], ...
    'Parent', double(hThis), 'Interruptible','off', ...
    'Position', pos, 'HitTest', 'off', 'HandleVisibility', 'off');

% The Selection Handles must always be on top in the child order:
hChil = findall(double(hThis));
set(hThis,'Children',[hChil(4:end);hChil(2:3)]);

% Define the properties which should listen to the "Color" property
hThis.ColorProps{end+1} = 'EdgeColor';

% Set the Edge Color Property to correspond to the "Color" property of the
% line.
hThis.EdgeColorProperty = 'Color';
hThis.EdgeColorDescription = 'Color';
% Set the Face Color Property to correspond to the "Color" property of the
% line.
hThis.FaceColorProperty = 'FaceColor';
hThis.FaceColorDescription = 'Face Color';

% Install a property listener on the "Position" property:
l = handle.listener(hThis,hThis.findprop('Position'), ...
    'PropertyPostSet', @localChangePosition);
hThis.PropertyListeners(end+1) = l;

% Set properties passed by varargin
set(hThis,varargin{:});

%---------------------------------------------------------------------%
function localChangePosition(hProp,eventData) %#ok
% Update the rectangle data to be in line with the position

hThis = eventData.affectedObject;
if ~hThis.UpdateInProgress
    hThis.UpdateInProgress = true;
    hFig = ancestor(hThis,'Figure');
    % Convert the position to normalized coordinates:
    pos = hgconvertunits(hFig,hThis.Position,hThis.Units,'Normalized',hFig);
    x1 = pos(1);
    x2 = pos(1)+pos(3);
    y1 = pos(2);
    y2 = pos(2)+pos(4);
    px = [x1 x2;x1 x2];
    py = [y1 y1;y2 y2];
    pz = [0 0;0 0];
    set(hThis.BoundingRectHandle,'XData',px,'YData',py,'ZData',pz);
    set(hThis.EllipseHandle,'Position',pos);
    hThis.UpdateInProgress = false;
end