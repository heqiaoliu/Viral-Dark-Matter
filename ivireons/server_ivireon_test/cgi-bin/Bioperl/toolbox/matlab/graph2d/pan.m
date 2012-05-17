function [out] = pan(arg1,arg2)
%PAN Interactively pan the view of a plot
%  PAN ON turns on mouse-based panning.
%  PAN XON turns on x-only panning
%  PAN YON turns on y-only panning
%  PAN OFF turns it off.
%  PAN by itself toggles the state.
%
%  PAN(FIG,...) works on specified figure handle.
%
%  H = PAN(FIG) returns the figure's pan mode object for customization.
%        The following properties can be modified using set/get:
%
%        ButtonDownFilter <function_handle>
%        The application can inhibit the zoom operation under circumstances
%        the programmer defines, depending on what the callback returns. 
%        The input function handle should reference a function with two 
%        implicit arguments (similar to handle callbacks):
%        
%             function [res] = myfunction(obj,event_obj)
%             % OBJ        handle to the object that has been clicked on.
%             % EVENT_OBJ  handle to event object (empty in this release).
%             % RES        a logical flag to determine whether the zoom
%                          operation should take place or the 
%                          'ButtonDownFcn' property of the object should 
%                          take precedence.
%
%        ActionPreCallback <function_handle>
%        Set this callback to listen to when a pan operation will start.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object.
%
%             The event object has the following read only 
%             property:
%             Axes             The handle of the axes that is being panned.
%
%        ActionPostCallback <function_handle>
%        Set this callback to listen to when a pan operation has finished.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object. The object has the same
%                          properties as the EVENT_OBJ of the
%                          'ModePreCallback' callback.
%
%        Enable  'on'|{'off'}
%        Specifies whether this figure mode is currently 
%        enabled on the figure.
%
%        FigureHandle <handle>
%        The associated figure handle. This property supports GET only.
%
%        Motion 'horizontal'|'vertical'|{'both'}
%        The type of panning for the figure.
%
%        UIContextMenu <handle>
%        Specifies a custom context menu to be displayed during a
%        right-click action.
%
%  FLAGS = isAllowAxesPan(H,AXES)
%       Calling the function ISALLOWAXESPAN on the pan object, H, with a
%       vector of axes handles, AXES, as input will return a logical array
%       of the same dimension as the axes handle vector which indicate
%       whether a pan operation is permitted on the axes objects.
%
%  setAllowAxesPan(H,AXES,FLAG)
%       Calling the function SETALLOWAXESPAN on the pan object, H, with
%       a vector of axes handles, AXES, and a logical scalar, FLAG, will
%       either allow or disallow a pan operation on the axes objects.
%
%  INFO = getAxesPanMotion(H,AXES)
%       Calling the function GETAXESPANMOTION on the pan object, H, with 
%       a vector of axes handles, AXES, as input will return a character
%       cell array of the same dimension as the axes handle vector which
%       indicates the type of pan operation for each axes. Possible values
%       for the type of operation are 'horizontal', 'vertical' or 'both'.
%
%  setAxesPanMotion(H,AXES,STYLE)
%       Calling the function SETAXESPANMOTION on the pan object, H, with a
%       vector of axes handles, AXES, and a character array, STYLE, will
%       set the style of panning on each axes.
%
%  EXAMPLE 1:
%
%  plot(1:10);
%  pan on
%  % pan on the plot
%
%  EXAMPLE 2:
%
%  plot(1:10);
%  h = pan;
%  set(h,'Motion','horizontal','Enable','on');
%  % pan on the plot in the horizontal direction.
%
%  EXAMPLE 3:
%
%  ax1 = subplot(2,2,1);
%  plot(1:10);
%  h = pan;
%  ax2 = subplot(2,2,2);
%  plot(rand(3));
%  setAllowAxesPan(h,ax2,false);
%  ax3 = subplot(2,2,3);
%  plot(peaks);
%  setAxesPanMotion(h,ax3,'horizontal');
%  ax4 = subplot(2,2,4);
%  contour(peaks);
%  setAxesPanMotion(h,ax4,'vertical');
%  % pan on the plots.
%
%  EXAMPLE 4: (copy into a file)
%      
%  function demo
%  % Allow a line to have its own 'ButtonDownFcn' callback.
%  hLine = plot(rand(1,10));
%  set(hLine,'ButtonDownFcn','disp(''This executes'')');
%  set(hLine,'Tag','DoNotIgnore');
%  h = pan;
%  set(h,'ButtonDownFilter',@mycallback);
%  set(h,'Enable','on');
%  % mouse click on the line
%
%  function [flag] = mycallback(obj,event_obj)
%  % If the tag of the object is 'DoNotIgnore', then return true.
%  objTag = get(obj,'Tag');
%  if strcmpi(objTag,'DoNotIgnore')
%     flag = true;
%  else
%     flag = false;
%  end
%
%   EXAMPLE 5: (copy into a file)
%
%   function demo
%   % Listen to pan events
%   plot(1:10);
%   h = pan;
%   set(h,'ActionPreCallback',@myprecallback);
%   set(h,'ActionPostCallback',@mypostcallback);
%   set(h,'Enable','on');
%
%   function myprecallback(obj,evd)
%   disp('A pan is about to occur.');
%
%   function mypostcallback(obj,evd)
%   newLim = get(evd.Axes,'XLim');
%   msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim));
%
%  Use LINKAXES to link panning across multiple axes.
%
%  See also ZOOM, ROTATE3D, LINKAXES.

% Copyright 2002-2010 The MathWorks, Inc.

% Undocumented syntax
%  PAN(FIG,STYLE); where STYLE = 'x'|'y'|'xy', Note: syntax doesn't turn pan on like 'xon'
%  OUT = PAN(FIG,'getstyle')  'x'|'y'|'xy'
%  OUT = PAN(FIG,'ison')  true/false
%  PAN(FIG,'onkeepstyle'); maintains the last style used by pan mode. Used by
%  the GUI.

if nargin==0
    if nargout == 0
        fig = gcf; % caller did not specify handle
        locSetState(fig,'toggle');
    else
        fig = gcf;
        out = locGetObj(fig);
    end
elseif nargin==1
    if ishghandle(arg1)
            if nargout == 0
                locSetState(arg1,'toggle');
            else
                out = locGetObj(arg1);
            end
        else
        fig = gcf; % caller did not specify handle
        locSetState(fig,arg1);
    end
elseif nargin==2
    if ~ishghandle(arg1)
        error('MATLAB:pan:FigureUnknown', 'Unknown figure.');
    end
    switch arg2
        case 'getstyle'
            out = locGetStyle(arg1);
        case 'ison'
            out = locIsOn(arg1);
        otherwise
            locSetState(arg1,arg2);
    end
end

%-----------------------------------------------%
function hPan = locGetObj(hFig)
% Return the pan accessor object, if it exists.
hMode = locGetMode(hFig);
if ~isfield(hMode.ModeStateData,'accessor') ||...
        ~ishandle(hMode.ModeStateData.accessor)
    hPan = graphics.pan(hMode);
    hMode.ModeStateData.accessor = hPan;
else
    hPan = hMode.ModeStateData.accessor;
end

%-----------------------------------------------%
function [out] = locIsOn(fig)

out = isactiveuimode(fig,'Exploration.Pan');

%-----------------------------------------------%
function [out] = locGetStyle(fig)

hMode = locGetMode(fig);
out = hMode.ModeStateData.style;

%-----------------------------------------------%
function locSetState(target,state)
%Enables/disables panning callbacks
% target = figure || axes
% state = 'on' || 'off'

fig = ancestor(target,'figure');
hMode = locGetMode(fig);

if strcmpi(state,'xon')
    state = 'on';
    hMode.ModeStateData.style = 'x';
elseif strcmpi(state,'yon')
    state = 'on';
    hMode.ModeStateData.style = 'y';
elseif strcmpi(state,'x')
    hMode.ModeStateData.style = 'x';
    return; % All done
elseif strcmpi(state,'y')
    hMode.ModeStateData.style = 'y';
    return; % All done
elseif strcmpi(state,'xy')
    hMode.ModeStateData.style = 'xy';
    return; % All done
elseif strcmpi(state,'on')
    hMode.ModeStateData.style = 'xy';
elseif strcmpi(state,'onkeepstyle')
    state = 'on';
elseif strcmpi(state,'toggle')
    if locIsOn(fig)
        state = 'off';
    else
        state = 'on';
    end
end

if strcmpi(state,'on')
    activateuimode(fig,hMode.Name);
elseif strcmpi(state,'off')
    if locIsOn(fig)
        activateuimode(fig,'');
    end
else
    error('MATLAB:pan:unrecognizedinput','Unknown action string.');
end

%-----------------------------------------------%
function [hMode] = locGetMode(hFig)
hMode = getuimode(hFig,'Exploration.Pan');
if isempty(hMode)
    %Construct the mode object and set properties
    hMode = uimode(hFig,'Exploration.Pan');
    set(hMode,'WindowButtonDownFcn',{@locWindowButtonDownFcn,hMode});
    set(hMode,'WindowButtonUpFcn',{@locWindowButtonUpFcn,hMode});
    set(hMode,'WindowButtonMotionFcn',{@locWindowButtonMotionFcn,hMode});
    set(hMode,'WindowFocusLostFcn',{@locWindowFocusLostFcn,hMode});
    set(hMode,'KeyPressFcn',{@locKeyPressFcn,hMode});
    set(hMode,'KeyReleaseFcn',{@locKeyReleaseFcn,hMode});
    set(hMode,'ModeStartFcn',{@locDoPanOn,hMode});
    set(hMode,'ModeStopFcn',{@locDoPanOff,hMode});
    hMode.ModeStateData.axes = [];
    hMode.ModeStateData.orig_axlim = [];
    hMode.ModeStateData.last_pixel = [];
    hMode.ModeStateData.style = 'xy';
    hMode.ModeStateData.mouse = 'off';
    hMode.ModeStateData.lastKey = '';
    hMode.ModeStateData.CustomContextMenu = [];
end

%-----------------------------------------------%
function locWindowButtonDownFcn(obj,evd,hMode) %#ok<INUSL>
% Begin panning
if ~ishghandle(hMode.UIContextMenu)
    %We lost the context menu for some reason
    locUICreateDefaultContextMenu(hMode);
end
fig = hMode.FigureHandle;
ax = locFindAxes(fig,evd);
sel_type = lower(get(fig,'SelectionType'));

if isempty(ax) || ~ishghandle(ax(1)) || ~localInBounds(ax(1))
    if strcmp(sel_type,'alt')
        hMode.ShowContextMenu = false;
    end
    return;
end

% If a key is pressed, force it to end:
if ~isempty(hMode.ModeStateData.lastKey)
    locEndKey(ax,hMode);
    hMode.ModeStateData.lastKey = '';
end

% Register view with axes for "Reset to Original View" support
resetplotview(ax,'InitializeCurrentView');

switch sel_type
    case 'normal' % left click
        hMode.ModeStateData.axes = ax;
        setptr(fig,'closedhand');
        hMode.ModeStateData.mouse = 'down';
        hMode.fireActionPreCallback(localConstructEvd(ax));
    case 'open' % double click (left or right)
        locReturnHome(ax,hMode);
        hMode.ModeStateData.mouse = 'off';
    case 'alt' % right click
        % do nothing

    case 'extend' % center click
        % do nothing
end

if is2D(ax(1))
    % Store original axis limits
    axLim = axis(ax);
    if ~iscell(axLim)
        axLim = {axLim};
    end
    hMode.ModeStateData.orig_axlim = axLim;
    hMode.ModeStateData.is2D = true;
else
    % Store the original camera position and target
    camTar = get(ax,'CameraTarget');
    camPos = get(ax,'CameraPosition');
    if ~iscell(camTar)
        camTar = {camTar};
        camPos = {camPos};
    end
    hMode.ModeStateData.orig_target = camTar;
    hMode.ModeStateData.orig_pos = camPos;
    hMode.ModeStateData.is2D = false;
end

if ~isempty(findobj(ax,'Type','image'))
    hMode.ModeStateData.hasImage = true;
    lims = cell(1,numel(ax));
    for i = 1:numel(ax)
        lims{i} = objbounds(ax(i));
    end
    hMode.ModeStateData.imageBounds = lims;
else
    hMode.ModeStateData.hasImage = false;
end

%-----------------------------------------------%
function targetInBounds = localInBounds(hAxes)
%Check if the user clicked within the bounds of the axes. If not, do
%nothing.
targetInBounds = true;
tol = 3e-16;
cp = get(hAxes,'CurrentPoint');
XLims = get(hAxes,'XLim');
if ((cp(1,1) - min(XLims)) < -tol || (cp(1,1) - max(XLims)) > tol) && ...
        ((cp(2,1) - min(XLims)) < -tol || (cp(2,1) - max(XLims)) > tol)
    targetInBounds = false;
end
YLims = get(hAxes,'YLim');
if ((cp(1,2) - min(YLims)) < -tol || (cp(1,2) - max(YLims)) > tol) && ...
        ((cp(2,2) - min(YLims)) < -tol || (cp(2,2) - max(YLims)) > tol)
    targetInBounds = false;
end
ZLims = get(hAxes,'ZLim');
if ((cp(1,3) - min(ZLims)) < -tol || (cp(1,3) - max(ZLims)) > tol) && ...
        ((cp(2,3) - min(ZLims)) < -tol || (cp(2,3) - max(ZLims)) > tol)
    targetInBounds = false;
end
%-----------------------------------------------%
function locReturnHome(ax,hMode)
% Fit plot to axes
resetplotview(ax,'ApplyStoredView');
hMode.fireActionPostCallback(localConstructEvd(ax));

%-----------------------------------------------%
function locDoPan(ax,newlim)

% Pan
for i = 1:length(ax)
    axis(ax(i),newlim{i});
end

%------------------------------------------------%
function locCreate2DUndo(ax,origlim,newlim)
% Create command structure

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
hFig = ancestor(ax(1),'Figure');
proxyVal = getProxyValueFromHandle(ax);

cmd.Function = @locDo2DUndo;
cmd.Varargin = {hFig,proxyVal,newlim};
cmd.Name = 'Pan';
cmd.InverseFunction = @locDo2DUndo;
cmd.InverseVarargin = {hFig,proxyVal,origlim};

% Register with undo
uiundo(hFig,'function',cmd);

%-----------------------------------------------%
function locDo2DUndo(hFig,proxyVal,newlim)

ax = getHandleFromProxyValue(hFig,proxyVal);
for i = 1:length(ax)
    if ishghandle(ax(i))
        axis(ax(i),newlim{i});
    end
end

%-----------------------------------------------%
function locDoPan3D(ax,newtar,newpos)

% Pan
loc3DPan(ax,newtar,newpos);

%------------------------------------------------%
function locCreate3DUndo(ax,origtar,newtar,origpos,newpos)
% Create command structure

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
hFig = ancestor(ax(1),'Figure');
proxyVal = getProxyValueFromHandle(ax);

cmd.Function = @locDo3DUndo;
cmd.Varargin = {hFig,proxyVal,newtar,newpos};
cmd.Name = 'Pan';
cmd.InverseFunction = @locDo3DUndo;
cmd.InverseVarargin = {hFig,proxyVal,origtar,origpos};

% Register with undo
uiundo(hFig,'function',cmd);

%------------------------------------------------%
function locDo3DUndo(hFig,proxyVal,newtar,newpos)

ax = getHandleFromProxyValue(hFig,proxyVal);
for i = 1:length(ax)
    if ishghandle(ax(i))
        loc3DPan(ax(i),newtar{i},newpos{i});
    end
end

%-----------------------------------------------%
function loc3DPan(ax,newtar,newpos)

if ~iscell(newtar)
    newtar = {newtar};
    newpos = {newpos};
end

set(ax,{'CameraTarget'},newtar);
set(ax,{'CameraPosition'},newpos);

%-----------------------------------------------%
function locWindowButtonUpFcn(obj,evd,hMode) %#ok
% Stop panning

if ~strcmp(hMode.ModeStateData.mouse,'off')
    setptr(hMode.FigureHandle,'hand');
    hMode.fireActionPostCallback(localConstructEvd(hMode.ModeStateData.axes));
end

% Axes may be empty if we are double clicking
ax = hMode.ModeStateData.axes;
if ~isempty(ax) && ishghandle(ax(1))
    if hMode.ModeStateData.is2D
        newlim = axis(ax);
        origlim = hMode.ModeStateData.orig_axlim;
        if ~iscell(newlim)
            newlim = {newlim};
        end
        % Assumption for plotyy plots - If we pan one axes, we pan both
        % axes.
        if ~isequal(newlim{1},origlim{1})
            locDoPan(ax,newlim);
            locCreate2DUndo(ax,origlim,newlim);
            hMode.ModeStateData.orig_axlim = newlim;
            if strcmp(hMode.ModeStateData.mouse,'dragging')
                localThrowEndDragEvent(ax(1));
            end
        end
    else
        newtar = get(ax,'CameraTarget');
        newpos = get(ax,'CameraPosition');
        if ~iscell(newtar)
            newtar = {newtar};
            newpos = {newpos};
        end
        origtar = hMode.ModeStateData.orig_target;
        origpos = hMode.ModeStateData.orig_pos;
        if ~isequal(newtar{1},origtar{1}) || ~isequal(newpos{1},origpos{1})
            locDoPan3D(ax,newtar,newpos);
            locCreate3DUndo(ax,origtar,newtar,origpos,newpos);
            hMode.ModeStateData.orig_target = newtar;
            hMode.ModeStateData.orig_pos = newpos;
            if strcmp(hMode.ModeStateData.mouse,'dragging')
                localThrowEndDragEvent(ax(1));
            end
        end
    end
end

% Clear all transient pan state
hMode.ModeStateData.mouse = 'off';
hMode.ModeStateData.axes = [];
hMode.ModeStateData.last_pixel = [];

%-----------------------------------------------%
function locWindowButtonMotionFcn(obj,evd,hMode) %#ok
% This gets called every time we move the mouse in pan mode,
% regardless of whether any buttons are pressed.
fig = hMode.FigureHandle;
ax = hMode.ModeStateData.axes;

% Get current point in pixels
curr_units = hgconvertunits(fig,[0 0 evd.CurrentPoint],...
    'pixels',get(fig,'Units'),fig);
curr_units = curr_units(3:4);

if strcmp(hMode.ModeStateData.mouse,'off')
    set(evd.Source,'CurrentPoint',curr_units);
    hAx = locFindAxes(evd.Source,evd);
    if ~isempty(hAx) && localInBounds(hAx(1))
        setptr(fig,'hand');
    else
        setptr(fig,'arrow');
    end
    return;
end

if isempty(ax) || ~ishghandle(ax(1))
    return;
end

% Only pan if we have a previous pixel point
ok2pan = ~isempty(hMode.ModeStateData.last_pixel);
%The point in the event data is already in pixels
curr_pixel = evd.CurrentPoint;

if ok2pan
    if strcmp(hMode.ModeStateData.mouse,'down')
        localThrowBeginDragEvent(ax(1));
        hMode.ModeStateData.mouse = 'dragging';
    end

    delta_pixel = curr_pixel - hMode.ModeStateData.last_pixel;
 
    % Check to see if the axes has a constraint
    localBehavior = hggetbehavior(ax(1),'Pan','-peek');
    if ~isempty(localBehavior)
        style = locChooseStyle(localBehavior.Style,hMode.ModeStateData.style);
    else
        style = hMode.ModeStateData.style;
    end
    locDataPan(ax,delta_pixel(1),delta_pixel(2),style,hMode);
end

hMode.ModeStateData.last_pixel = curr_pixel;

%-----------------------------------------------%
function style = locChooseStyle(axStyle, figStyle)
% Reconcile the axes constraint with the figure constraint
if ~strcmpi(axStyle,'both')
    if strcmp(axStyle,'horizontal')
        % If the constraints conflict, do nothing
        if ~strcmpi(figStyle,'y')
            style = 'x';
        else
            style = 'none';
        end
    else
        % If the constraints conflict, do nothing
        if ~strcmpi(figStyle,'x')
            style = 'y';
        else
            style = 'none';
        end
    end
else
    style = figStyle;
end


%-----------------------------------------------%
function locKeyPressFcn(obj,evd,hMode) %#ok
% Pan if the user clicks on arrow keys

% Exit early if invalid event data
if ~isobject(evd) && (~isstruct(evd) || ~isfield(evd,'Key') || ...
        isempty(evd.Key) || ~isfield(evd,'Character'))
    return;
end

% If the mouse is down, return early:
if ~strcmp(hMode.ModeStateData.mouse,'off')
    return;
end

% Parse key press
fig = hMode.FigureHandle;
ax = get(fig,'CurrentAxes');
ax = localVectorizeAxes(ax);
if ~isempty(ax) && ishghandle(ax(1))
    b = hggetbehavior(ax(1),'Pan','-peek');
    if ~isempty(b) &&  ishandle(b) && ~get(b,'Enable')
        % ignore this axes
        ax = [];
    elseif isappdata(ax(1),'NonDataObject')
        ax = [];
    end
end

consumekey = false;
if ~isempty(ax) && ishghandle(ax(1))
    key = evd.Key;
    if strcmp(key, 'leftarrow')
        localKeyPressFcnModeHandler(hMode, ax, evd);
        localHandleArrowKey(hMode, ax, -1, 0);
        consumekey = true;
    elseif strcmp(key, 'rightarrow')
        localKeyPressFcnModeHandler(hMode, ax, evd);
        localHandleArrowKey(hMode, ax, 1, 0);
        consumekey = true;
    elseif strcmp(key, 'uparrow')
        localKeyPressFcnModeHandler(hMode, ax, evd);
        localHandleArrowKey(hMode, ax, 0, 1);
        consumekey = true;
    elseif strcmp(key, 'downarrow')
        localKeyPressFcnModeHandler(hMode, ax, evd);
        localHandleArrowKey(hMode, ax, 0, -1);
        consumekey = true;
    elseif strcmp(key, 'z') && all(strcmpi(evd.Modifier,'control'))
        hUndoMen = findall(fig,'Type','UIMenu','Tag','figMenuEditUndo');
        if isempty(hUndoMen)
            localKeyPressFcnModeHandler(hMode, ax, evd);
            % Undo command
            uiundo(hMode.FigureHandle,'execUndo');
        end
        % Indicate to the mode that we did not explicitly operate
        % on an axes:
        hMode.ModeStateData.axes = [];
        consumekey = true;
    elseif strcmp(key, 'y') && all(strcmpi(evd.Modifier,'control'))
        hRedoMen = findall(fig,'Type','UIMenu','Tag','figMenuEditRedo');
        if isempty(hRedoMen)
            localKeyPressFcnModeHandler(hMode, ax, evd);
            % Redo command
            uiundo(hMode.FigureHandle,'execRedo');
        end
        % Indicate to the mode that we did not explicitly operate
        % on an axes:
        hMode.ModeStateData.axes = [];        
        consumekey = true;
    end
end
if ~consumekey
    graph2dhelper('forwardToCommandWindow',fig,evd);
end

%------------------------------------------------%
function hMode = localKeyPressFcnModeHandler(hMode, ax, evd)
% Store the axes
hMode.ModeStateData.axes = ax;
% Make sure there is something to undo to:
if ~strcmpi(hMode.ModeStateData.lastKey,evd.Key) && locIsArrowKey(evd.Key)
    % If we are changing keys, capture this
    if ~isempty(hMode.ModeStateData.lastKey)
        locEndKey(ax,hMode);
    end
    if ~is2D(ax(1))
        camTar = get(ax,'CameraTarget');
        camPos = get(ax,'CameraPosition');
        if ~iscell(camTar)
            camTar = {camTar};
            camPos = {camPos};
        end
        hMode.ModeStateData.orig_target = camTar;
        hMode.ModeStateData.orig_pos = camPos;
    else
        currLim = axis(ax);
        if ~iscell(currLim)
            currLim = {currLim};
        end
        hMode.ModeStateData.orig_axlim = currLim;
    end
    hMode.ModeStateData.lastKey = evd.Key;
end

%------------------------------------------------%
function localHandleArrowKey(hMode, ax, deltaX, deltaY)
resetplotview(ax,'InitializeCurrentView');
hMode.fireActionPreCallback(localConstructEvd(ax));
% Check to see if the axes has a constraint
localBehavior = hggetbehavior(ax(1),'Pan','-peek');
if ~isempty(localBehavior)
    style = locChooseStyle(localBehavior.Style,hMode.ModeStateData.style);
else
    style = hMode.ModeStateData.style;
end
hMode.ModeStateData.is2D = is2D(ax);
if ~isempty(findobj(ax,'Type','image'))
    hMode.ModeStateData.hasImage = true;
    lims = cell(1,numel(ax));
    for i = 1:numel(ax)
        lims{i} = objbounds(ax(i));
    end
    hMode.ModeStateData.imageBounds = lims;
else
    hMode.ModeStateData.hasImage = false;
end
locDataPan(ax,deltaX,deltaY,style,hMode);
hMode.fireActionPostCallback(localConstructEvd(ax));

%------------------------------------------------%
function res = locIsArrowKey(key)
% Returns true if the key is an arrow key:

res = false;
if strcmpi(key,'uparrow') || strcmpi(key,'downarrow') || ...
        strcmpi(key,'leftarrow') || strcmpi(key,'rightarrow')
    res = true;
end

%------------------------------------------------%
function locKeyReleaseFcn(obj,evd,hMode) %#ok
% Key Release callback

ax = hMode.ModeStateData.axes;
panExecuted = false;
if ~isempty(ax) && ishghandle(ax(1))
    % We are only concerned with the arrow keys:
    newKey = evd.Key;
    if locIsArrowKey(newKey) && strcmpi(newKey, hMode.ModeStateData.lastKey)
        panExecuted = true;
    end
end

if panExecuted
    locEndKey(ax,hMode)
    hMode.ModeStateData.lastKey = '';
end

%------------------------------------------------%
function locWindowFocusLostFcn(obj,evd,hMode) %#ok
% Focus lost callback. This will reset the figure state with respect to the
% key presses

if ~ishandle(hMode)
    return;
end
ax = hMode.ModeStateData.axes;
if ~isempty(ax) && ishghandle(ax(1))
    locEndKey(ax,hMode)
    hMode.ModeStateData.lastKey = '';
end

%------------------------------------------------%
function locEndKey(ax,hMode)
% Register a key release with undo

if ~is2D(ax)
    newtar = get(ax,'CameraTarget');
    newpos = get(ax,'CameraPosition');
    if ~iscell(newtar)
        newtar = {newtar};
        newpos = {newpos};
    end
    origtar = hMode.ModeStateData.orig_target;
    origpos = hMode.ModeStateData.orig_pos;
    if ~isequal(newtar{1},origtar{1}) || ~isequal(newpos{1},origpos{1})
        locCreate3DUndo(ax,origtar,newtar,origpos,newpos);
        hMode.ModeStateData.orig_target = newtar;
        hMode.ModeStateData.orig_pos = newpos;
    end
else
    newlim = axis(ax);
    if ~iscell(newlim)
        newlim = {newlim};
    end
    origlim = hMode.ModeStateData.orig_axlim;
    if ~isequal(newlim{1},origlim{1})
        locCreate2DUndo(ax,origlim,newlim);
        hMode.ModeStateData.orig_axlim = newlim;        
    end
end

%-----------------------------------------------%
function locDataPan(axVector,delta_pixel1,delta_pixel2,style,hMode)
% This is where the panning computation occurs.

hFig = ancestor(axVector(1),'Figure');
range_pixel = cell(size(axVector));
for i = 1:length(axVector)
    range_pixel{i} = hgconvertunits(hFig,get(axVector(i),'Position'),...
        get(axVector(i),'Units'),'Pixels',hFig);
end

% Assumption - If the first plotyy axes is 2D, then all plotyy axes are 2D.
if hMode.ModeStateData.is2D
    for i = 1:length(axVector)
        ax = axVector(i);
        [abscissa, ordinate] = locGetOrdinate(ax);

        orig_lim1 = get(ax,[abscissa,'lim']);
        orig_lim2 = get(ax,[ordinate,'lim']);      

        curr_lim1 = orig_lim1;
        curr_lim2 = orig_lim2;

        % For log plots, transform to linear scale
        if strcmp(get(ax,[abscissa,'scale']),'log')
            is_abscissa_log = true;
            curr_lim1 = log10(curr_lim1);
        else
            is_abscissa_log = false;
        end
        if strcmp(get(ax,[ordinate,'scale']),'log')
            is_ordinate_log = true;
            curr_lim2 = log10(curr_lim2);
        else
            is_ordinate_log = false;
        end
        
        if ~all(isfinite(curr_lim1)) || ~all(isfinite(curr_lim2)) ...
            || ~all(isreal(curr_lim1)) || ~all(isreal(curr_lim2))

            % The following code has been taken from zoom.m
            % If any of the public limits are inf then we need the actual limits
            % by getting the hidden deprecated RenderLimits.
            oldstate = warning('off','MATLAB:HandleGraphics:NonfunctionalProperty:RenderLimits');
            renderlimits = get(ax,'RenderLimits');
            warning(oldstate);
            curr_lim1 = renderlimits(1:2);
            if is_abscissa_log
                curr_lim1 = log10(curr_lim1);
            end
            curr_lim2 = renderlimits(3:4);
            if is_ordinate_log
                curr_lim2 = log10(curr_lim2);
            end
        end

        range_data1 = abs(diff(curr_lim1));
        range_data2 = abs(diff(curr_lim2));

        pixel_width = range_pixel{i}(3);
        pixel_height = range_pixel{i}(4);

        delta_data1 = delta_pixel1 * range_data1 / pixel_width;
        delta_data2 = delta_pixel2 * range_data2 /  pixel_height;

        % Consider direction of axis: [{'normal'|'reverse'}]
        dir1 = get(ax,sprintf('%sdir',abscissa(1)));
        if strcmp(dir1,'reverse')
            new_lim1 = curr_lim1 + delta_data1;
        else
            new_lim1 = curr_lim1 - delta_data1;
        end

        dir2 = get(ax,sprintf('%sdir',ordinate(1)));
        if strcmp(dir2,'reverse')
            new_lim2 = curr_lim2 + delta_data2;
        else
            new_lim2 = curr_lim2 - delta_data2;
        end

        % For log plots, untransform limits
        if is_abscissa_log
            new_lim1 = 10.^new_lim1;
            curr_lim2 = 10.^curr_lim2; %#ok
        end
        if is_ordinate_log
            curr_lim1 = 10.^curr_lim1; %#ok
            new_lim2 = 10.^new_lim2;
        end

        if hMode.ModeStateData.hasImage % Determine axis limits for image
            lims = hMode.ModeStateData.imageBounds{i};
            x = lims(1:2);
            y = lims(3:4);
            %If we are within the bounds of the image to begin with. This is to
            %prevent odd behavior if we panned outside the bounds of the image
            if x(1) <= orig_lim1(1) && x(2) >= orig_lim1(2) &&...
                    y(1) <= orig_lim2(1) && y(2) >= orig_lim2(2)
                dx = new_lim1(2) - new_lim1(1);
                if new_lim1(1) < x(1)
                    new_lim1(1) = x(1);
                    new_lim1(2) = new_lim1(1) + dx;
                end
                if new_lim1(2) > x(2)
                    new_lim1(2) = x(2);
                    new_lim1(1) = new_lim1(2) - dx;
                end
                dy = new_lim2(2) - new_lim2(1);
                if new_lim2(1) < y(1)
                    new_lim2(1) = y(1);
                    new_lim2(2) = new_lim2(1) + dy;
                end
                if new_lim2(2) > y(2)
                    new_lim2(2) = y(2);
                    new_lim2(1) = new_lim2(2) - dy;
                end
            end
        end

        % Set new limits
        if strcmp(style,'x')
            set(ax,[abscissa,'lim'],new_lim1);
            set(ax,[ordinate,'lim'],orig_lim2);
        elseif strcmp(style,'y')
            set(ax,[abscissa,'lim'],orig_lim1);
            set(ax,[ordinate,'lim'],new_lim2);
        elseif strcmp(style,'xy')
            set(ax,[abscissa,'lim'],new_lim1);
            set(ax,[ordinate,'lim'],new_lim2);
        end
    end

else % 3-D
    % Force ax to be in vis3d to avoid wacky resizing
    axis(axVector,'vis3d');

    % For now, just do the same thing as camera toolbar panning.
    junk = nan;
    for i = 1:length(axVector)
        camdolly(axVector(i),-delta_pixel1,-delta_pixel2, junk, 'movetarget', 'pixels');
    end
end

%-----------------------------------------------%
function [abscissa, ordinate] = locGetOrdinate(ax)
% Pre-condition: 2-D plot
% Determines abscissa and ordinate as 'x','y',or 'z'

if ~feature('HGUsingMATLABClasses')
    test1 = (camtarget(ax)-campos(ax))==0;
    test2 = camup(ax)~=0;
    ind = find(test1 & test2);
    
    dim1 = ind(1);
    dim2 = xor(test1,test2);
    
    key = {'x','y','z'};
    
    abscissa = key{dim2};
    ordinate = key{dim1};
else
    abscissa = 'x';
    ordinate = 'y';
end

%-----------------------------------------------%
function [ax] = locFindAxes(fig,evd)
% Return the axes that the mouse is currently over
% Return empty if no axes found (i.e. axes has hidden handle)

if ~ishghandle(fig)
    return;
end

% Return all axes under the current mouse point
allHit = localHittest(fig,evd,'axes');
if ~isempty(allHit)
    allAxes = allHit(1);
else
    allAxes = [];
end
ax = [];

for i=1:length(allAxes),
    candidate_ax=allAxes(i);
    if strcmpi(get(candidate_ax,'HandleVisibility'),'off')
        % ignore this axes
        continue;
    end
    b = hggetbehavior(candidate_ax,'Pan','-peek');
    if ~isempty(b) &&  ishandle(b) && ~get(b,'Enable')
        % ignore this axes

        % 'NonDataObject' is a legacy flag defined in
        % datachildren function.
    elseif ~isappdata(candidate_ax,'NonDataObject')
        ax = candidate_ax;
        break;
    end
end

ax = localVectorizeAxes(ax);

%-----------------------------------------------%
function locDoPanOn(hMode)
fig = hMode.FigureHandle;
set(uigettool(fig,'Exploration.Pan'),'State','on');
set(findall(fig,'tag','figMenuPan'),'Checked','on');

% Remove when uitoolfactory is in place
set(findall(fig,'tag','figToolPan'),'State','on');

%Refresh context menu
hui = get(hMode,'UIContextMenu');
if ~isempty(hMode.ModeStateData.CustomContextMenu) && ishghandle(hMode.ModeStateData.CustomContextMenu)
    set(hMode,'UIContextMenu',hMode.ModeStateData.CustomContextMenu);
else
    if ishghandle(hui)
        delete(hui);
    end
    locUICreateDefaultContextMenu(hMode);
end

%-----------------------------------------------%
function locDoPanOff(hMode)
fig = hMode.FigureHandle;
set(uigettool(fig,'Exploration.Pan'),'State','off');
set(findall(fig,'tag','figMenuPan'),'Checked','off');

% Remove when uitoolfactory is in place
set(findall(fig,'tag','figToolPan'),'State','off');
hui = hMode.UIContextMenu;
if (~isempty(hui) && ishghandle(hui)) && ...
        (isempty(hMode.ModeStateData.CustomContextMenu) || ~ishghandle(hMode.ModeStateData.CustomContextMenu))
    delete(hui);
    hMode.UIContextMenu = '';
end

%-----------------------------------------------%
function [hui] = locUICreateDefaultContextMenu(hMode)
% Create default context menu

hFig = hMode.FigureHandle;

props = [];
props_context.Parent = hFig;
props_context.Tag = 'PanContextMenu';
props_context.Callback = {@locUIContextMenuCallback,hMode};
props_context.ButtonDownFcn = {@locUIContextMenuCallback,hMode};
hMode.UIContextMenu = uicontextmenu(props_context);
hui = hMode.UIContextMenu;

% Generic attributes for all pan context menus
props.Callback = {@locUIContextMenuCallback,hMode};
props.Parent = hui;

% Full View context menu
props.Label = 'Reset to Original View';
props.Tag = 'ResetView';
props.Separator = 'off';
ufullview = uimenu(props); %#ok

% Pan Constraint context menu
props.Callback = '';
props.Label = 'Pan Options';
props.Tag = 'Constraint';
props.Separator = 'on';
uConstraint = uimenu(props);

props.Parent = uConstraint;

props.Callback = {@locUIContextMenuCallback,hMode};
props.Label = 'Unconstrained Pan';
props.Tag = 'PanUnconstrained';
props.Separator = 'off';
uimenu(props);

props.Label = 'Horizontal Pan (Applies to 2-D Plots Only)';
props.Tag = 'PanHorizontal';
uimenu(props);

props.Label = 'Vertical Pan (Applies to 2-D Plots Only)';
props.Tag = 'PanVertical';
uimenu(props);

%-------------------------------------------------%
function locUIContextMenuCallback(obj,~,hMode)

tag = get(obj,'tag');

switch(tag)
    case 'PanContextMenu'
        locUIContextMenuUpdate(hMode,hMode.ModeStateData.style);
    case 'ResetView'
        % If we are here, then we clicked on something contained in an
        % axes. Rather than calling HITTEST, we will get this information
        % manually.
        hAxes = ancestor(hMode.FigureState.CurrentObj.Handle,'axes');
        hMode.fireActionPreCallback(localConstructEvd(hAxes));
        resetplotview(hAxes,'ApplyStoredView');
        hMode.fireActionPostCallback(localConstructEvd(hAxes));
    case 'PanUnconstrained'
        locUIContextMenuUpdate(hMode,'xy');
    case 'PanHorizontal'
        locUIContextMenuUpdate(hMode,'x');
    case 'PanVertical'
        locUIContextMenuUpdate(hMode,'y');
end

%-------------------------------------------------%
function locUIContextMenuUpdate(hMode,pan_Constraint)

hFig = hMode.FigureHandle;

ux = findall(hFig,'Tag','PanHorizontal','Type','UIMenu');
uy = findall(hFig,'Tag','PanVertical','Type','UIMenu');
uxy = findall(hFig,'Tag','PanUnconstrained','Type','UIMenu');

hMode.ModeStateData.style = pan_Constraint;

switch(pan_Constraint)
    case 'xy'
        set(ux,'checked','off');
        set(uy,'checked','off');
        set(uxy,'checked','on');

    case 'x'
        set(ux,'checked','on');
        set(uy,'checked','off');
        set(uxy,'checked','off');

    case 'y'
        set(ux,'checked','off');
        set(uy,'checked','on');
        set(uxy,'checked','off');
end

%-----------------------------------------------%
function evd = localConstructEvd(hAxes)
% Construct event data for post callback
evd.Axes = hAxes;

%-------------------------------------------------%
function localThrowBeginDragEvent(hObj)

% Throw BeginDrag event
hb = hggetbehavior(hObj,'Pan','-peek');
if ~isempty(hb) && ishandle(hb)
    sendBeginDragEvent(hb);
end

%-------------------------------------------------%
function localThrowEndDragEvent(hObj)

% Throw EndDrag event
hb = hggetbehavior(hObj,'Pan','-peek');
if ~isempty(hb) && ishandle(hb)
    sendEndDragEvent(hb);
end

%-----------------------------------------------%
function axList = localVectorizeAxes(hAx)
% Given an axes, return a vector representing any plotyy-dependent axes.
% Note: This code is implementation-specific and meant as a place-holder
% against the time when we have multiple data-spaces in one axes.

axList = hAx;
if ~isempty(axList)
    if isappdata(hAx,'graphicsPlotyyPeer')
        newAx = getappdata(hAx,'graphicsPlotyyPeer');
        if ishghandle(newAx)
            axList = [axList;newAx];
        end
    end
end

%-----------------------------------------------%
function obj = localHittest(hFig,evd,varargin)
if feature('HGUsingMATLABClasses')
    obj = plotedit([{'hittestHGUsingMATLABClasses',hFig,evd},varargin(:)]);
else
    obj = double(hittest(hFig,varargin{:}));
    % Ignore objects whose 'hittest' property is 'off'
    obj = obj(arrayfun(@(x)(strcmpi(get(x,'HitTest'),'on')),obj));
end