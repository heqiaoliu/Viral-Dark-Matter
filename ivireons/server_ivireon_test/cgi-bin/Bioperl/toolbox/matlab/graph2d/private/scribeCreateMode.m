function hMode = scribeCreateMode(hFig)
% Create and set up a one-shot mode object to perform object creation.

%   Copyright 2006-2009 The MathWorks, Inc.

if ishghandle(hFig,'figure')
    hFig = plotedit(hFig,'getmode');
end

hMode = getuimode(hFig,'Standard.ScribeCreate');
if ~isempty(hMode)
    return;
end

hMode = uimode(hFig,'Standard.ScribeCreate');

% Specify that the mode is a one-shot mode. This means that the mode will
% turn itself off after completing execution.
hMode.IsOneShot = true;

% The WindowButtonDownFcn property will begin the creation of the object
set(hMode,'WindowButtonDownFcn',{@localCreateWindowButtonDownFcn,hMode});
set(hMode,'ModeStartFcn',{@localModeStartFcn,hMode});
set(hMode,'ModeStopFcn',{@localModeStopFcn,hMode});

% Set up the state date for the mode.
% The name of the object type to be created:
hMode.ModeStateData.ObjectName = '';

% Set up the initial button down point
hMode.ModeStateData.InitialPoint = [0 0];

%-------------------------------------------------------------------------%
function localModeStartFcn(hMode)
% Set up the environment for the mode.

hFig = hMode.FigureHandle;
% Set the figure's pointer to a crosshair:
set(hFig,'pointer','crosshair');
% Signal that we are ready to begin creating:
hMode.ModeStateData.CreationInProgress = false;

%-------------------------------------------------------------------------%
function localModeStopFcn(hMode)
% Clean up the mode for the next call

hMode.ModeStateData.ObjectName = '';
fig = double(hMode.FigureHandle);
% Turn off toggles:
t = [...
    uigettool(fig,'Annotation.InsertRectangle'),...
    uigettool(fig,'Annotation.InsertEllipse'),...
    uigettool(fig,'Annotation.InsertTextbox'),...
    uigettool(fig,'Annotation.InsertDoubleArrow'),...
    uigettool(fig,'Annotation.InsertArrow'),...
    uigettool(fig,'Annotation.InsertTextArrow'),...
    uigettool(fig,'Annotation.InsertLine'),...
    uigettool(fig,'Annotation.Pin')];
set(t,'State','off');

%-------------------------------------------------------------------------%
function localCreateWindowButtonDownFcn(obj,evd,hMode) %#ok<INUSL>
% Start the creation of the annotation

if isempty(hMode.ModeStateData.ObjectName)
    return;
end

if hMode.ModeStateData.CreationInProgress
    return;
end

hMode.ModeStateData.CreationInProgress = true;

% First, deselect everything in the figure.
deselectall(obj);

% Make sure the scribe layer is on top:
hScribeAxes = graph2dhelper('findScribeLayer',obj);
if ~feature('HGUsingMATLABClasses')
    hScribeAxes.methods('stackScribeLayersWithChild',[],true);
end

% Create an annotation based on the current position and location:
figPoint = get(obj,'CurrentPoint');
% Store the initial point:
point = hgconvertunits(obj,[figPoint 0 0],get(obj,'Units'),'Pixels',obj);
point = point(1:2);
hMode.ModeStateData.InitialPoint = point;
% Convert the point into normalized units:
point = hgconvertunits(obj,[figPoint 0 0],get(obj,'Units'),'Normalized',obj);
point = point(1:2);
point(2) = point(2) - 0.001;
hAnnotation = handle(annotation(hMode.FigureHandle,hMode.ModeStateData.ObjectName,...
    'Position',[point(1) point(2) 0.001 0.001]));
% Set the move mode of the annotation.
if feature('HGUsingMATLABClasses')
    if isa(hAnnotation,'scribeTwo.scribeobject2D')
        hAnnotation.MoveStyle = 'bottomleft';
    elseif  isa(hAnnotation,'scribeTwo.scribeobject1D')
        hAnnotation.MoveStyle = 'topright';
    end    
else
    if isa(hAnnotation,'scribe.scribeobject2D') 
        hAnnotation.MoveMode = 'bottomleft';
    elseif isa(hAnnotation,'scribe.scribeobject1D')
        hAnnotation.MoveMode = 'topright';
    end
end
% Set the annotation to be selected
set(hAnnotation,'Selected','on');
% Set the button up and button motion functions of the creation.
scribeax = graph2dhelper('findScribeLayer',obj);
if strcmpi('on',getappdata(ancestor(scribeax,'figure'),'scribegui_snaptogrid')) && ...
        isappdata(ancestor(scribeax,'figure'),'scribegui_snapgridstruct')
    set(hMode,'WindowButtonMotionFcn',{@localSnapResizeObject,hAnnotation});
else
    set(hMode,'WindowButtonMotionFcn',{@localResizeObject,hAnnotation});
end
set(hMode,'WindowButtonUpFcn',{@localCreateComplete,hMode,hAnnotation});

%-----------------------------------------------------------------------%
function localSnapResizeObject(obj,evd,hAnnotation)
% Since you can't resize multi-selected objects, just resize the first
% selected object. The resize will only take place if the snap to grid
% behavior will allow it.

% If the mouse is outside the bounds of the figure, return early.
currPoint = hgconvertunits(obj,[evd.CurrentPoint 0 0],'pixels','normalized',obj);
currPoint = currPoint(1:2);
if currPoint(1) < 0.0 || currPoint(1) > 1.0 || ...
       currPoint(2) < 0.0 || currPoint(2) > 1.0
   return;
end

% Get grid structure values
gridstruct = getappdata(obj,'scribegui_snapgridstruct');
xspace = gridstruct.xspace;
yspace = gridstruct.yspace;
influ = gridstruct.influence;

MoveType = hAnnotation.MoveMode;

% Given the point and the move type, we want to snap to either the nearest
% corner (for the corner move types) or the nearest horizontal or vertical
% line
currPoint = evd.CurrentPoint;

switch MoveType
    case {'topleft','topright','bottomleft','bottomright'}
        % e.g. moving the upper left affordance
        % changes the left x and upper y
        xPoint = false;
        yPoint = false;
        xoff = mod(currPoint(1),xspace);
        yoff = mod(currPoint(2),yspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            currPoint(1) = (round(currPoint(1)/xspace) * xspace);
            xPoint = true;
        end
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            currPoint(2) = (round(currPoint(2)/yspace) * yspace);
            yPoint = true;
        end
        % If we are not snapping to a corner, return
        if ~(xPoint && yPoint)
            return;
        end
    case {'left','right'}
        xPoint = false;
        xoff = mod(currPoint(1),xspace);
        if xoff>(xspace/2)
            xoff = xoff - xspace;
        end
        if xoff<influ
            currPoint(1) = (round(currPoint(1)/xspace) * xspace);
            xPoint = true;
        end
        % If we are not snapping to a line, return
        if ~xPoint
            return;
        end
    case {'top','bottom'}
        yPoint = false;
        yoff = mod(currPoint(2),yspace);
        if yoff>(yspace/2)
            yoff = yoff - yspace;
        end
        if yoff<influ
            currPoint(2) = (round(currPoint(2)/yspace) * yspace);
            yPoint = true;
        end
        % If we are not snapping to a line, return
        if ~yPoint
            return;
        end
    otherwise
        return;
end

hAnnotation.resize(currPoint);

%-------------------------------------------------------------------------%
function localResizeObject(obj,evd,hAnnotation)
% Resize the annotation based on the current point

% If the mouse is outside the bounds of the figure, return early.
currPoint = hgconvertunits(obj,[evd.CurrentPoint 0 0],'pixels','normalized',obj);
currPoint = currPoint(1:2);
if currPoint(1) < 0.0 || currPoint(1) > 1.0 || ...
       currPoint(2) < 0.0 || currPoint(2) > 1.0
   return;
end

hAnnotation.resize(evd.CurrentPoint);

%-------------------------------------------------------------------------%
function localCreateComplete(obj,evd,hMode,hAnnotation) %#ok<INUSL>
% Restore the callbacks and state of the mode.

set(hMode,'WindowButtonMotionFcn','');
set(hMode,'WindowButtonUpFcn','');

point = get(obj,'CurrentPoint');
point = hgconvertunits(obj,[point 0 0],get(obj,'Units'),'pixels',obj);
point = point(1:2);
origPoint = hMode.ModeStateData.InitialPoint;

% if point hasn't moved, set to good dflt pixel
if sum(abs(point - origPoint)) <= 1
    currPos = get(hAnnotation,'Position');
    defaultSize = [90 30];
    defaultSize = hgconvertunits(obj,[0 0 defaultSize],'Pixels',get(hAnnotation,'Units'),obj);
    currPos(3:4) = defaultSize(3:4);    
    set(hAnnotation,'Position',currPos);
    % If the annotation has a "FitBoxToText" property, set it to "on"
    if isprop(hAnnotation,'FitBoxToText')
        set(hAnnotation,'FitBoxToText','on');
    end
end

% Make sure the annotation is the only thing selected.
selectobject(hAnnotation,'replace');

% Add the creation to the undo stack
scribeccp(obj,'Create');

% If the object has an "Editing" property, set it to "on"
if isprop(hAnnotation,'Editing')
    set(hAnnotation,'Editing','on');
end