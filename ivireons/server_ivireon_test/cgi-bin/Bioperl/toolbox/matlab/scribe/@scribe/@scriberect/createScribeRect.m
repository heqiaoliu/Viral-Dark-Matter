function createScribeRect(hThis,varargin)
% Create and set up a scribe rectangle

%   Copyright 2006 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject2D;

% Define the shape type:
hThis.ShapeType = 'rectangle';

% Create the main rectangle.
pos = hThis.Position;
x1 = pos(1);
x2 = pos(1)+pos(3);
y1 = pos(2);
y2 = pos(2)+pos(4);
px = [x1 x2;x1 x2];
py = [y1 y1;y2 y2];
pz = [0 0;0 0];

hThis.FaceHandle = hg.surface('EdgeColor','none','FaceColor','flat',...
    'CData',NaN,'FaceLighting','none','Parent',double(hThis),...
    'HitTest','off','Interruptible','off','XData',px,'YData',py,...
    'ZData',pz,'HandleVisibility','off');

hThis.RectHandle = hg.rectangle('EdgeColor',hThis.EdgeColor,...
    'LineStyle',hThis.LineStyle,'LineWidth',hThis.LineWidth,...
    'Parent',double(hThis),'HitTest','off','Interruptible','off',...
    'Position',pos,'HandleVisibility','off');

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

% Intall a property listener on the "Image" property:
l = handle.listener(hThis,hThis.findprop('Image'), ...
    'PropertyPostSet', @localChangeImage);
hThis.PropertyListeners(end+1) = l;

% Set properties passed by varargin
set(hThis,varargin{:});

%-------------------------------------------------------------------%
function localChangeImage(hProp, eventData) %#ok
% Set the interior of a rectangle to be an image
% This should be in a set-function, but this appears to cause a SegV (in
% M-code at least).

hThis = eventData.affectedObject;
valueProposed = hThis.Image;
if ~isempty(hThis.FaceHandle)
    faceHandle = double(hThis.FaceHandle);
    if isempty(valueProposed)
        set(faceHandle,'FaceColor',hThis.FaceColor);
        set(faceHandle,'CDataMapping','Scaled');
    else
        set(faceHandle,'FaceColor','texturemap',...
            'CDataMapping','Direct'); 
        % We need to flip the Y-Data of the image:
        valueProposed = valueProposed(end:-1:1,:,:);                
        set(faceHandle,'CData',valueProposed);        
    end
end

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
    set(hThis.FaceHandle,'XData',px,'YData',py,'ZData',pz);
    set(hThis.RectHandle,'Position',pos);
    hThis.UpdateInProgress = false;
end