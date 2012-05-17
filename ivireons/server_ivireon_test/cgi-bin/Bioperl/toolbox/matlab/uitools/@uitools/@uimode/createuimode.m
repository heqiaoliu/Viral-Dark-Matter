function hThis = createuimode(hThis,hFig,name)
% Constructor for the uimode

%   Copyright 2006-2009 The MathWorks, Inc.

% Syntax: uimodes.mode(figure)
if ~ishghandle(hFig,'figure')
    error('MATLAB:uimode:uimode:InvalidConstructor','First argument must be a figure handle');
end
if ~ischar(name)
    error('MATLAB:uimode:uimde:InvalidConstructor','Second argument must be a string');
end

% Begin defining properties of the mode
hThis.FigureHandle = hFig;
addlistener(hFig,'ObjectBeingDestroyed',@(obj,evd)(localDelete(hThis)));
hThis.Name = name;
hThis.WindowMotionFcnListener = addlistener(hFig,'WindowButtonMotion',@localNoop);
localSetListenerStateOff(hThis.WindowMotionFcnListener);
% Set up the listener that takes care of suspending UIControl and UITable objects.
hThis.UIControlSuspendListener = addlistener(hFig,'WindowButtonMotion',@localNoop);
localSetListenerStateOff(hThis.UIControlSuspendListener);
hThis.UIControlSuspendListener.Callback = @(obj,evd)(localUIEvent(obj,evd,hThis));

if usejava('awt')
    % Suspend the JavaFrame warning:
    [ lastWarnMsg lastWarnId ] = lastwarn; 
    oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    hFrame = handle(get(hFig,'JavaFrame'));
    
    % Restore the warning state:
    warning(oldstate);
    lastwarn(lastWarnMsg,lastWarnId);
    
    hAxisComponent = handle(hFrame.getAxisComponent);
    hThis.UIControlSuspendJavaListener = handle.listener(hAxisComponent,'FocusLost',@localNoop);
    hThis.UIControlSuspendJavaListener.Enable = 'off';
    hThis.UIControlSuspendJavaListener.Callback = @(obj,evd)(localUIEvent(obj,evd,hThis));
end

% Set up a delete listener that cleans up UIContextMenus after the mode
% object is delete
hThis.DeleteListener = handle.listener(hThis,'ObjectBeingDestroyed',@localCleanUp);

% Set up listeners to deal with the ButtonDownFilter mechanism:
% Define listeners for window state
window_prop = {'WindowButtonDownFcn',...
    'WindowButtonUpFcn',...
    'WindowScrollWheelFcn',...
    'WindowKeyPressFcn',...
    'WindowKeyReleaseFcn',...
    'KeyPressFcn',...
    'KeyReleaseFcn'};
l = addlistener(hFig,window_prop,'PreSet',@(obj,evd)(localPrepareCallback(obj,evd,hThis)));
l(end+1) = addlistener(hFig,window_prop,'PostSet',@(obj,evd)(localRestoreCallback(obj,evd,l(end),hThis)));
localSetListenerStateOff(l);
hThis.WindowListenerHandles = l;

%-------------------------------------------------------------------------%
function localPrepareCallback(hProp,evd,hThis)
hThis.PreviousWindowState = get(evd.AffectedObject,hProp.Name);
if strcmpi(hProp.Name,'WindowButtonUpFcn')
    hThis.UserButtonUpFcn = evd.NewValue;
end

%-------------------------------------------------------------------------%
function localRestoreCallback(hProp,evd,listener,hThis)
localSetListenerStateOff(listener);
set(evd.AffectedObject,hProp.Name,hThis.PreviousWindowState);
localSetListenerStateOn(listener);

%-------------------------------------------------------------------------%
function localCleanUp(hMode,evd) %#ok<INUSD>
% Delete context-menus associated with a mode when the mode is deleted, as
% well as any sub-modes

if ~isempty(hMode.UIContextMenu) && ishghandle(hMode.UIContextMenu)
    delete(hMode.UIContextMenu);
end
% Delete any submodes as well
for childMode = hMode.RegisteredModes
    if ishandle(childMode)
        delete(childMode)
    end
end

%-------------------------------------------------------------------------%
function localUIEvent(obj,evd,hMode) %#ok<INUSL>
% Suspends a UIControl or UITable object while the mouse is over it. The 
% control will be unsuspended when the mouse is no longer on top or the 
% figure loses focus.

% If the "FigureState" property of the mode is empty, return early as it
% means we are not ready for the event yet.
figureState = hMode.FigureState;
if isempty(figureState) || ~isstruct(figureState)
    return;
end

if isprop(evd,'CurrentObject')
    currObj = evd.CurrentObject;
else
    currObj = [];
end

if isequal(currObj,handle(figureState.LastObject))
    return;
end

if ~isempty(figureState.LastObject) && ...
        ishghandle(figureState.LastObject) && ...
        (ishghandle(figureState.LastObject,'uicontrol') || ishghandle(figureState.LastObject,'uitable'))
    set(figureState.LastObject,'Enable',figureState.UIEnableState);
end

if isprop(evd,'CurrentObject')
    currObj = evd.CurrentObject;
else
    currObj = [];
end
if ~isempty(currObj) && (ishghandle(currObj,'uicontrol') || ishghandle(currObj,'uitable'))
    enableState = get(currObj,'Enable');
    figureState.UIEnableState = enableState;
    if strcmpi(enableState,'on')
        set(currObj,'Enable','Inactive');
    end
end

figureState.LastObject = currObj;
if ~isempty(hMode.FigureState) && isstruct(hMode.FigureState)
    hMode.FigureState = figureState;
end

%-------------------------------------------------------------------------%
function localNoop(varargin)
% This space intentionally left blank

%------------------------------------------------------------------------%
function localSetListenerStateOn(hList)
if feature('HGUsingMATLABClasses')
    onVal = repmat({true},size(hList));
    [hList.Enabled] = deal(onVal{:});
else
    set(hList,'Enabled','on');
end

%------------------------------------------------------------------------%
function localSetListenerStateOff(hList)
if feature('HGUsingMATLABClasses')
    offVal = repmat({false},size(hList));
    [hList.Enabled] = deal(offVal{:});
else
    set(hList,'Enabled','off');
end

%-------------------------------------------------------------------------%
function localDelete(hThis)
if ishandle(hThis)
    delete(hThis);
end
