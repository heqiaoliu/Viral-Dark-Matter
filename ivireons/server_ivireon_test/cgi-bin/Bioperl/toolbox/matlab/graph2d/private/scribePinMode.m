function hMode = scribePinMode(hFig)
% Create and set up a one-shot mode object to perform object pinning.

%   Copyright 2006-2008 The MathWorks, Inc.

% The flow of this mode is as follows: A user may click on a scribe object
% in order to pin it. Alternatively, a user may click on a pin and drag it
% to associate it with a different affordance. On a button-up, pins are
% re-pinned to maintain consistency with the underlying scribe objects.
% During the running of the mode, the cursor turns into a pin.

if isa(handle(hFig),'hg.figure')
    hFig = plotedit(hFig,'getmode');
end

hMode = getuimode(hFig,'Standard.ScribePin');
if ~isempty(hMode)
    return;
end

hMode = uimode(hFig,'Standard.ScribePin');

% Specify that the mode is a one-shot mode. This means that the mode will
% turn itself off after completing execution.
hMode.IsOneShot = true;

% The WindowButtonDownFcn property will begin the creation of the object
set(hMode,'WindowButtonDownFcn',{@localPinWindowButtonDownFcn,hMode});
set(hMode,'ModeStartFcn',{@localModeStartFcn,hMode});
set(hMode,'ModeStopFcn',{@localModeStopFcn,hMode});

%-----------------------------------------------------------------------%
function localModeStartFcn(hMode)
% Set up the mode. In this case, all we do is set the cursor of the figure.
% To a pin

hFig = hMode.FigureHandle;
scribecursors(hFig,10);
% Show selection handles for all selected objects:
hObjs = getselectobjects(hFig);
set(hObjs,'Selected','on');
% Update the pin toggle button
hPinTog = uigettool(hFig,'Annotation.Pin');
set(hPinTog,'State','on');

%-----------------------------------------------------------------------%
function localModeStopFcn(hMode)
% Exit the mode. In this case, deselect the selected objects (this will
% maintain consistency with the other sub-modes).

hFig = hMode.FigureHandle;
% Turn off selection handles for all selected objects:
hObjs = getselectobjects(hFig);
set(hObjs,'Selected','off');
% Update the pin toggle button
hPinTog = uigettool(hFig,'Annotation.Pin');
set(hPinTog,'State','off');

%-----------------------------------------------------------------------%
function localPinWindowButtonDownFcn(obj,evd,hMode) %#ok<INUSL>
% If we clicked on a pin, enter the pin drag mode.
% If we clicked on a scribe object (or an object with a pin property), pin
% the object. To determine where to pin, we check the "PinAff" property.
% This will be used to pin the annotation to the axes. If we clicked on an
% affordance, pin that particular affordance.

currObj = handle(hittest(obj));
currPoint = get(obj,'CurrentPoint');
% Convert the current point to pixels
currPoint = hgconvertunits(obj,[currPoint 0 0],get(obj,'Units'),'Pixels',obj);
currPoint = currPoint(1:2);

% Find out what we have clicked on, a scribe object, an affordance, or a
% pin:
if isprop(currObj,'Pin') %Scribe object
    moveType = currObj.findMoveMode(currPoint);
    % Convert the enumerated type to either an affordance index or zero.
    pinAff = localConvertMoveType(moveType);
    % If the move mode is "mouseover" (i.e. the pin affordance is 0) and we
    % are over a pin, then we are dealing with the center affordance. This
    % is true only of 2-D objects (objects with a scalar pin).
    if pinAff == 0 && ~isempty(currObj.Pin) && isscalar(currObj.Pin) && ishghandle(currObj.Pin)
        if localOverPin(obj,currObj.Pin,currPoint)
            pinAff = 9;
        end
    end
    if pinAff == 0
       localPinObject(currObj);
       hObjs = getselectobjects(obj);
       set(hObjs,'Selected','off');
       selectobject(currObj,'replace');
       set(currObj,'Selected','on');
    else
        hPin = localGetPin(currObj,pinAff);
        if isempty(hPin)
            localPinObject(currObj,pinAff);
        else
            set(hMode,'WindowButtonMotionFcn',{@localMovePin,hPin});
            set(hMode,'WindowButtonUpFcn',{@localMoveComplete,hMode,hPin});
        end
    end
end

%-----------------------------------------------------------------------%
function localMovePin(hFig,evd,hPin)
% Given the current point in normalized units, the closest affordance is
% the affordance with the smallest euclidean distance and which does not
% already contain a pin.

% Get the affordances:
hAff = hPin.Target.Srect;
allPins = hPin.Target.Pin;
% Convert the point to normalized coordinates
point = hgconvertunits(hFig,[evd.CurrentPoint 0 0],'Pixels','Normalized',hFig);
point = point(1:2);
affXData = cell2mat(get(hAff,'XData'));
affYData = cell2mat(get(hAff,'YData'));
% Compute the Euclidean distance:
affSquareX = (affXData - point(1)).^2;
affSquareY = (affYData - point(2)).^2;
affDist = sqrt(affSquareX + affSquareY);
% Now, find the minimum
[unused, minAff] = min(affDist);
% Make sure that there is no pin at the minimum affordance:
hAffordancePin = localGetPin(hPin.Target,minAff);
if ~isempty(hAffordancePin)
    return;
else
    hPin.Affordance = minAff;
    hPin.Target.Pin = allPins;
end

%-----------------------------------------------------------------------%
function localMoveComplete(hFig,evd,hMode,hPin) %#ok<INUSL>

% After the move is complete, repin the pin
point = [hPin.XData hPin.YData];
point = hgconvertunits(hFig,[point 0 0],'Normalized','Pixels',hFig);
point = point(1:2);

% The pinned object may have changed, which we must take into account.
pinobj = [];
% Turn off the hittest property of this group to find out if we are over an
% object
hitState = get(hPin.Target,'HitTest');
set(hPin.Target,'HitTest','off');
obj = handle(hittest(hFig,point));
set(hPin.Target,'HitTest',hitState);
if ~isempty(obj) && ~isa(obj,'danScribe.scribeobject') && ...
        ~strcmpi(get(obj,'tag'),'DataTipMarker')
    type = get(obj,'type');
    if strcmpi(type,'surface')||strcmpi(type,'patch')||strcmpi(type,'line')
        pinobj = obj;
    end
end
if ~isempty(pinobj) && ~isequal(handle(ancestor(pinobj,'Axes')),hPin.DataAxes)
    pinobj = [];
end

repin(hPin,point,hPin.DataAxes,pinobj);

% Reset the mode for the next time:
set(hMode,'WindowButtonMotionFcn','');
set(hMode,'WindowButtonUpFcn','');


%-----------------------------------------------------------------------%
function resPin = localGetPin(currObj,pinAff)
% Checks to see if we clicked on a pin

hPins = currObj.Pin;
resPin = [];
for i=1:length(hPins)
    if ishghandle(hPins(i)) && get(hPins(i),'Affordance') == pinAff
        resPin = hPins(i);
        break;
    end
end

%-----------------------------------------------------------------------%
function localPinObject(currObj,pinAff)
% Pins an object to the given affordance. If the affordance is not
% specified, the object is pinned at all pinnable affordances as specified
% by the "PinAff" property.

if nargin == 1
    pinAff = currObj.PinAff;
end

for i=1:length(pinAff)
    currObj.pinAtAffordance(pinAff(i));
end

%-----------------------------------------------------------------------%
function res = localOverPin(hFig,hPin,point)
% Returns true if the point in the figure is over the pin in question

set(hPin,'HitTest','on');
hObj = handle(hittest(hFig,point));
res = isequal(hObj, handle(hPin));
set(hPin,'HitTest','off');

%-----------------------------------------------------------------------%
function res = localConvertMoveType(moveType)
% Converts a move type to an affordance index

switch moveType
    case 'bottomleft'
        res = 1;
    case 'topright'
        res = 2;
    case 'bottomright'
        res = 3;
    case 'topleft'
        res = 4;
    case 'left'
        res = 5;
    case 'bottom'
        res = 6;
    case 'right'
        res = 7;
    case 'top'
        res = 8;
    otherwise
        res = 0;
end