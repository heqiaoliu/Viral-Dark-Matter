function out = zoom(varargin)
%ZOOM   Zoom in and out on a 2-D plot.
%   ZOOM with no arguments toggles the zoom state.
%   ZOOM(FACTOR) zooms the current axis by FACTOR.
%       Note that this does not affect the zoom state.
%   ZOOM ON turns zoom on for the current figure.
%   ZOOM XON or ZOOM YON turns zoom on for the x or y axis only.
%   ZOOM OFF turns zoom off in the current figure.
%
%   ZOOM RESET resets the zoom out point to the current zoom.
%   ZOOM OUT returns the plot to its current zoom out point.
%   If ZOOM RESET has not been called this is the original
%   non-zoomed plot.  Otherwise it is the zoom out point
%   set by ZOOM RESET.
%
%   When zoom is on, click the left mouse button to zoom in on the
%   point under the mouse. Each time you click, the axes limits will be
%   changed by a factor of 2 (in or out).  You can also click and drag
%   to zoom into an area. It is not possible to zoom out beyond the plots'
%   current zoom out point.  If ZOOM RESET has not been called the zoom
%   out point is the original non-zoomed plot.  If ZOOM RESET has been
%   called the zoom out point is the zoom point that existed when it
%   was called. Double clicking zooms out to the current zoom out point -
%   the point at which zoom was first turned on for this figure
%   (or to the point to which the zoom out point was set by ZOOM RESET).
%   Note that turning zoom on, then off does not reset the zoom out point.
%   This may be done explicitly with ZOOM RESET.
%
%   ZOOM(FIG,OPTION) applies the zoom command to the figure specified
%   by FIG. OPTION can be any of the above arguments.
%
%   H = ZOOM(FIG) returns the figure's zoom mode object for customization.
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
%        Set this callback to listen to when a zoom operation will start.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object.
%
%             The event object has the following read only 
%             property:
%             Axes             The handle of the axes that is being zoomed.
%
%        ActionPostCallback <function_handle>
%        Set this callback to listen to when a zoom operation has finished.
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
%        The type of zooming for the figure.
%
%        Direction {'in'}|'out'
%        The direction of the zoom operation.
%
%        RightClickAction 'InverseZoom'|{'PostContextMenu'}
%        The behavior of a right-click action. A value of 'InverseZoom' 
%        will cause a right-click to zoom out. A value of 'PostContextMenu'
%        will display a context menu. This setting will persist between 
%        MATLAB sessions.
%
%        UIContextMenu <handle>
%        Specifies a custom context menu to be displayed during a
%        right-click action. This property is ignored if the
%        'RightClickAction' property has been set to 'InverseZoom'.
%
%   FLAGS = isAllowAxesZoom(H,AXES)
%       Calling the function ISALLOWAXESZOOM on the zoom object, H, with a
%       vector of axes handles, AXES, as input will return a logical array
%       of the same dimension as the axes handle vector which indicate
%       whether a zoom operation is permitted on the axes objects.
%
%   setAllowAxesZoom(H,AXES,FLAG)
%       Calling the function SETALLOWAXESZOOM on the zoom object, H, with
%       a vector of axes handles, AXES, and a logical scalar, FLAG, will
%       either allow or disallow a zoom operation on the axes objects.
%
%   INFO = getAxesZoomMotion(H,AXES)
%       Calling the function GETAXESZOOMMOTION on the zoom object, H, with 
%       a vector of axes handles, AXES, as input will return a character
%       cell array of the same dimension as the axes handle vector which
%       indicates the type of zoom operation for each axes. Possible values
%       for the type of operation are 'horizontal', 'vertical' or 'both'.
%
%   setAxesZoomMotion(H,AXES,STYLE)
%       Calling the function SETAXESZOOMMOTION on the zoom object, H, with a
%       vector of axes handles, AXES, and a character array, STYLE, will
%       set the style of zooming on each axes.
%
%   EXAMPLE 1:
%
%   plot(1:10);
%   zoom on
%   % zoom in on the plot
%
%   EXAMPLE 2:
%
%   plot(1:10);
%   h = zoom;
%   set(h,'Motion','horizontal','Enable','on');
%   % zoom in on the plot in the horizontal direction.
%
%   EXAMPLE 3:
%
%   ax1 = subplot(2,2,1);
%   plot(1:10);
%   h = zoom;
%   ax2 = subplot(2,2,2);
%   plot(rand(3));
%   setAllowAxesZoom(h,ax2,false);
%   ax3 = subplot(2,2,3);
%   plot(peaks);
%   setAxesZoomMotion(h,ax3,'horizontal');
%   ax4 = subplot(2,2,4);
%   contour(peaks);
%   setAxesZoomMotion(h,ax4,'vertical');
%   % zoom in on the plots.
%
%   EXAMPLE 4: (copy into a file)
%       
%   function demo
%   % Allow a line to have its own 'ButtonDownFcn' callback.
%   hLine = plot(rand(1,10));
%   set(hLine,'ButtonDownFcn','disp(''This executes'')');
%   set(hLine,'Tag','DoNotIgnore');
%   h = zoom;
%   set(h,'ButtonDownFilter',@mycallback);
%   set(h,'Enable','on');
%   % mouse click on the line
%
%   function [flag] = mycallback(obj,event_obj)
%   % If the tag of the object is 'DoNotIgnore', then return true.
%   objTag = get(obj,'Tag');
%   if strcmpi(objTag,'DoNotIgnore')
%      flag = true;
%   else
%      flag = false;
%   end
%
%   EXAMPLE 5: (copy into a file)
%
%   function demo
%   % Listen to zoom events
%   plot(1:10);
%   h = zoom;
%   set(h,'ActionPreCallback',@myprecallback);
%   set(h,'ActionPostCallback',@mypostcallback);
%   set(h,'Enable','on');
%
%   function myprecallback(obj,evd)
%   disp('A zoom is about to occur.');
%
%   function mypostcallback(obj,evd)
%   newLim = get(evd.Axes,'XLim');
%   msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim));
%
%   Use LINKAXES to link zooming across multiple axes.
%
%   See also PAN, ROTATE3D, LINKAXES.
%

% Copyright 1993-2010 The MathWorks, Inc.

% Internal use undocumented syntax (this may be removed in a future
% release)
% Additional syntax not already dead in zoom help
%
% ZOOM(FIG,'UIContextMenu',...)
%    Specify UICONTEXTMENU for use in zoom mode
% ZOOM(FIG,'Constraint',...)
%    Specify constrain option:
%       'none'       - No constraint (default)
%       'horizontal' - Horizontal zoom only for 2-D plots
%       'vertical'   - Vertical zoom only for 2-D plots
% ZOOM(FIG,'Direction',...)
%    Specify zoom direction 'in' or 'out'
% OUT = ZOOM(FIG,'IsOn')
%    Returns true if zoom is on, otherwise returns false.
% OUT = ZOOM(FIG,'Constraint')
%    Returns 'none','horizontal', or 'vertical'
% OUT = ZOOM(FIG,'Direction')
%    Returns 'in' or 'out'

% Undocumented syntax that will never get documented
% (but we have to keep it around for legacy reasons)
% OUT = ZOOM(FIG,'getmode') 'in'|'out'|'off'
%

%   Note: zoom uses the figure buttondown and buttonmotion functions
%
%   ZOOM XON zooms x-axis only
%   ZOOM YON zooms y-axis only

%   ZOOM v6 off Switches to new zoom implementation
%   ZOOM v6 on Switches to old zoom implementation

%   ZOOM FILL scales a plot such that it is as big as possible
%   within the axis position rectangle for any azimuth and elevation.

% Undocumented switch to v6 zoom implementation. This will be removed.

if nargin==2 && ...
        ischar(varargin{1}) && ...
        strcmp(varargin{1},'v6') && ...
        ischar(varargin{2})
    if strcmp(varargin{2},'on')
        localSetV6Zoom(true);
    else
        localSetV6Zoom(false);
    end
    return;
end

% Bypass to v6 zoom
if localIsV6Zoom
    if nargout==0
        v6_zoom(varargin{:});
    else
        out = v6_zoom(varargin{:});
    end
    return;
end

% Parse input arguments
[target,action,action_data] = localParseArgs(nargout,varargin{:});

% Return early if target is not an axes or figure
if isempty(target) || ...
        (~ishghandle(target,'axes') && ~ishghandle(target,'figure'))
    return;
end
hFigure = ancestor(target,'figure');
if ishghandle(target,'axes')
    set(hFigure,'CurrentAxes',target);
end

% Return early if setting zoom off and there's no app data
% this avoids making any objects or setting app data when
% it doesn't need to. For example, hgload calls zoom(fig,'off')
appdata = getappdata(hFigure,'ZoomOnState');
if strcmp(action,'off') && isempty(appdata);
    return;
end

% Get the mode object
hMode = locGetMode(hFigure);

% Update zoom target in case it changed
hMode.ModeStateData.target = target;

% Get current axes
if ~ishghandle(hFigure)
    return;
end
hCurrentAxes = get(hFigure,'CurrentAxes');
if ~isempty(hCurrentAxes)
    b = hggetbehavior(hCurrentAxes,'Zoom','-peek');
    if ~isempty(b) &&  ishandle(b) && ~get(b,'Enable')
        hCurrentAxes = [];
    elseif isappdata(hCurrentAxes,'NonDataObject')
        hCurrentAxes = [];
    end
end

hCurrentAxes = localVectorizeAxes(hCurrentAxes);

% Parse various zoom options
change_ui = [];
switch lower(action)

    case 'on'
        localChangeConstraint(hMode,'none');
        change_ui = 'on';

    case 'xon'
        localChangeConstraint(hMode,'horizontal');
        change_ui = 'on';

    case 'yon'
        localChangeConstraint(hMode,'vertical');
        change_ui = 'on';

    case 'getmode'
        if localIsZoomOn(hMode)
            out = hMode.ModeStateData.Direction;
        else
            out = 'off';
        end
    case 'constraint'
        out = hMode.ModeStateData.Constraint;
    case 'direction'
        out = hMode.ModeStateData.Direction;
    case 'ison'
        out = localIsZoomOn(hMode);
    case 'getstyle' %TBD: Remove
        out = hMode.ModeStateData.Constraint;
    case 'getdirection' %TBD: Remove
        out = hMode.ModeStateData.Direction;
    case 'toggle'
        if localIsZoomOn(hMode)
            change_ui = 'off';
        else
            change_ui = 'on';
        end

        % Undocumented legacy API, used by 'ident', [194435]
        % TBD: Consider removing
    case 'down'
        localStartDrag(hMode,'dorightclick',true);
        hLine = hMode.ModeStateData.LineHandles;
        if any(ishghandle(hLine))
            % Mimic rbbox, don't return until line handles are
            % removed
            waitfor(hLine(1));
        end

    case 'off'
        change_ui = 'off';
    case 'inmode'
        hX = uigettool(hFigure,'Exploration.ZoomX');
        if isempty(hX)
            localChangeDirection(hMode,'in');
        else
            hMode.ModeStateData.Direction = 'in';
            localChangeConstraint(hMode,'none');
        end
        change_ui = 'on';
    case 'inmodex'
        hX = uigettool(hFigure,'Exploration.ZoomX');
        if isempty(hX)
            localChangeDirection(hMode,'in');
        else
            hMode.ModeStateData.Direction = 'in';
            localChangeConstraint(hMode,'horizontal');
        end
        change_ui = 'on';
    case 'inmodey'
        hX = uigettool(hFigure,'Exploration.ZoomX');
        if isempty(hX)
            localChangeDirection(hMode,'in');
        else
            hMode.ModeStateData.Direction = 'in';
            localChangeConstraint(hMode,'vertical');
        end
        change_ui = 'on';        
    case 'outmode'
        localChangeDirection(hMode,'out');
        change_ui = 'on';
    case 'scale'
        if ~isempty(hCurrentAxes)
            % Register current axes view for reset view support
            resetplotview(hCurrentAxes,'InitializeCurrentView');
            hMode.fireActionPreCallback(localConstructEvd(hCurrentAxes));
            localApplyZoomFactor(hMode,hCurrentAxes,action_data,false);
        end
    case 'fill'
        if ~isempty(hCurrentAxes)
            localResetPlot(hCurrentAxes,hMode);
        end
    case 'reset'
        resetplotview(hCurrentAxes,'SaveCurrentView');
        for i=1:numel(hCurrentAxes)
            setappdata(hCurrentAxes(i),'zoom_zoomOrigAxesLimits',localComputeLimits(hCurrentAxes(i)));
        end
    case 'out'
        if ~isempty(hCurrentAxes)
            localResetPlot(hCurrentAxes,hMode);
        end
    case 'noaction'
        out = locGetObj(hFigure);
    case 'setzoomproperties'
        % undocumented
        localSetZoomProperties(hMode,action_data{:});
    otherwise
        error('MATLAB:zoom:unrecognizedinput','Unknown action string.');
end

% Update the user interface
if ~isempty(change_ui)
    localSetZoomState(hFigure,change_ui);
end

%-----------------------------------------------%
function hZoom = locGetObj(hFig)
% Return the zoom accessor object, if it exists.
hMode = locGetMode(hFig);
if ~isfield(hMode.ModeStateData,'accessor') ||...
        ~ishandle(hMode.ModeStateData.accessor)
    hZoom = graphics.zoom(hMode);
    hMode.ModeStateData.accessor = hZoom;
else
    hZoom = hMode.ModeStateData.accessor;
end

%-----------------------------------------------%
function localSetZoomProperties(hMode,varargin)
% Set the properties of the mode as specified by user input.
% The input is in the form of param/value pairs.
for i=1:2:nargin-1
    switch varargin{i}
        case 'UIContextMenu'
            if ~isempty(varargin{i+1}) && ~strcmpi(get(varargin{i+1},'Type'),'uicontextmenu')
                error('MATLAB:Zoom:InvalidContextMenu',...
                    'Handle must be a uicontextmenu.');
            end
            hMode.ModeStateData.CustomContextMenu = varargin{i+1};
        case 'Direction'
            localChangeDirection(hMode,varargin{i+1});
        case 'Constraint'
            localChangeConstraint(hMode,varargin{i+1});
        otherwise
            error('MATLAB:Zoom:InvalidProperty',...
                'Invalid property ''%s'' for zoom mode.',varargin{i});
    end
end

%-----------------------------------------------%
function localResetPlot(hAxes,hMode)

if ~all(ishghandle(hAxes))
   return;
end

% reset 2-D axes
if is2D(hAxes(1))
   origLim = axis(hAxes);
   resetplotview(hAxes,'ApplyStoredView');
   newLim = axis(hAxes);
   localCreate2DUndo(hAxes,origLim,newLim);
   
% reset 3-D axes  
else
   origVa = get(hAxes,'CameraViewAngle');
   origTarget = get(hAxes,'CameraTarget');
   resetplotview(hAxes,'ApplyStoredView');
   newVa = get(hAxes,'CameraViewAngle');
   newTarget = get(hAxes,'CameraTarget');
   localCreate3DUndo(hAxes,origVa,newVa,origTarget,newTarget);
end
hMode.fireActionPostCallback(localConstructEvd(hAxes));

%-----------------------------------------------%
function localSetZoomState(hFig,state)

if strcmp(state,'on')
    activateuimode(hFig,'Exploration.Zoom');
    % zoom off
elseif strcmp(state,'off')
    if isactiveuimode(hFig,'Exploration.Zoom')
        activateuimode(hFig,'');
    end
end

%-----------------------------------------------%
function [bool] = localIsZoomOn(hMode)
fig = hMode.FigureHandle;
bool = true;
if isempty(hMode.ParentMode)
    if ~isactiveuimode(fig,'Exploration.Zoom');
        bool = false;
    end
end

%-----------------------------------------------%
function [target,action,action_data] = localParseArgs(outputs,varargin)

target = [];
action = [];
action_data = [];
errstr = {'Zoom:InvalidSyntax','Invalid Syntax'};

% zoom  
if nargin==1
    target = gcf;
    if outputs==0
        action = 'toggle';
    else
        action = 'noaction';
    end

elseif nargin==2
    arg1 = varargin{1};

    if outputs==1
        if ishghandle(arg1)
            target = arg1;
            action = 'noaction';
        end
    else
        % zoom(SCALE)
        if isscalar(arg1) && isnumeric(arg1)
            target = gcf;
            action = 'scale';
            action_data = arg1;

            % zoom(OPTION)
        elseif ischar(arg1)
            target = gcf;
            action = arg1;

            % zoom(FIG)
        elseif isscalar(arg1) && ishghandle(arg1)
            if ishghandle(arg1,'figure')
                target = arg1;
                action = 'toggle';
            else
                error(errstr{:});
            end
        else
            error(errstr{:});
        end
    end
    
elseif nargin==3
    
    % zoom('newzoom',0)
    if ischar(varargin{1})
        target = gcf;
        action = varargin{1};
        action_data = varargin{2};
        
        % zoom(FIG,SCALE)
        % zoom(FIG,OPTION)
    elseif any(ishghandle(varargin{1}))
        target = varargin{1};
        arg2 = varargin{2};
        if ischar(arg2)
            action = arg2;
        elseif isnumeric(arg2)
            action = 'scale';
            action_data = arg2;
        end
    end

    % zoom(FIG,<parameter/value pairs>);
elseif nargin>=4
    target = varargin{1};
    arg2 = varargin{2};
    if any(ishghandle(target)) && ischar(arg2)
        action = 'setzoomproperties';
        action_data = varargin(2:end);
    end
end

target = handle(target);

%-----------------------------------------------%
function localSetV6Zoom(bool)
setappdata(0,'V6Zoom',bool);

%-----------------------------------------------%
function [bool] = localIsV6Zoom
bool = getappdata(0,'V6Zoom');

%-----------------------------------------------%
function localChangeDirection(hMode,newValue)
%Modify the User interface if the direction is changed while the mode is
%running.

if localIsZoomOn(hMode)
    if strcmp(newValue,'in')
        localUISetZoomIn(hMode.FigureHandle);
    elseif strcmp(newValue,'out')
        localUISetZoomOut(hMode.FigureHandle);
    else
        error('MATLAB:Zoom:InvalidDirection',...
            'Direction must either be ''in'' or ''out''');
    end
end
hMode.ModeStateData.Direction = newValue;

%-----------------------------------------------%
function localChangeConstraint(hMode,newValue)
%Modify the User interface if the constraint is changed while the mode is
%running.

newValue = lower(newValue);

if localIsZoomOn(hMode) && strcmpi(hMode.ModeStateData.Direction,'in')
    if strcmp(newValue,'none')
        localUISetZoomIn(hMode.FigureHandle);
    elseif strcmp(newValue,'horizontal')
        localUISetZoomInX(hMode.FigureHandle);
    elseif strcmp(newValue,'vertical')
        localUISetZoomInY(hMode.FigureHandle);
    else
        error('MATLAB:Zoom:InvalidConstraint',...
            'Constraint must either be ''vertical'',''horizontal'' or ''none''.');
    end
end
hMode.ModeStateData.Constraint = newValue;

%-----------------------------------------------%
function [hMode] = locGetMode(hFig)
hMode = getuimode(hFig,'Exploration.Zoom');
if isempty(hMode)
    hMode = uimode(hFig,'Exploration.Zoom');
    set(hMode,'WindowButtonDownFcn',{@localWindowButtonDownFcn,hMode});
    set(hMode,'WindowButtonUpFcn',[]);
    set(hMode,'WindowButtonMotionFcn',{@localMotionFcn,hMode});
    set(hMode,'KeyPressFcn',{@localKeyPressFcn,hMode});
    set(hMode,'ModeStartFcn',{@localStartZoom,hMode});
    set(hMode,'ModeStopFcn',{@localStopZoom,hMode});
    set(hMode,'WindowScrollWheelFcn',{@localButtonWheelFcn,hMode});
    % Insert the default properties in the ModeStateData structure:
    % Property for storing the figure handle
    hMode.ModeStateData.Constraint = 'none';
    hMode.ModeStateData.Direction = 'in';
    hMode.ModeStateData.Target = [];
    hMode.ModeStateData.MaxViewAngle = 75;
    % Property for holding the RBBOX lines.
    hMode.ModeStateData.LineHandles = [];
    % Property holding the axes handles of the last zoomed-in axes
    hMode.ModeStateData.CurrentAxes = [];
    hMode.ModeStateData.MousePoint = [];
    hMode.ModeStateData.CameraViewAngle = [];
    hMode.ModeStateData.CustomContextMenu = [];
    hMode.ModeStateData.DoRightClick = getpref('MATLABZoom','RightClick','off');
end

%---------------------------------------------------------------------%
function localStartZoom(hMode)

hFigure = hMode.FigureHandle;

%Refresh context menu
hui = get(hMode,'UIContextMenu');
if ishghandle(hMode.ModeStateData.CustomContextMenu)
    set(hMode,'UIContextMenu',hMode.ModeStateData.CustomContextMenu);
elseif ishghandle(hui)
    delete(hui);
    set(hMode,'UIContextMenu','');
end

set(hMode,'WindowButtonUpFcn',[])
set(hFigure,'PointerShapeHotSpot',[5 5]);

% Turn on Zoom UI (i.e. toolbar buttons, menus)
% This must be called AFTER uiclear to avoid uiclear state munging
zoom_direction = hMode.ModeStateData.Direction;
switch zoom_direction
    case 'in'
        zoom_constraint = hMode.ModeStateData.Constraint;
        switch zoom_constraint
            case 'none'
                localUISetZoomIn(hFigure);
            case 'horizontal'
                localUISetZoomInX(hFigure);
            case 'vertical'
                localUISetZoomInY(hFigure);
        end
    case 'out'
        localUISetZoomOut(hFigure);
end

% Define appdata to avoid breaking code in
% scribefiglisten, hgsave, and figtoolset
setappdata(hFigure,'ZoomOnState','on');

%---------------------------------------------------------------------%
function localStopZoom(hMode)

hFigure = hMode.FigureHandle;

%Edge case, we turn off the zoom while in drag-mode:
hLines = hMode.ModeStateData.LineHandles;
if any(ishghandle(hLines))
    delete(hLines);
end

% Turn off Zoom UI (i.e. toolbar buttons, menus)
localUISetZoomOff(hFigure);

% Remove uicontextmenu
hui = get(hMode,'UIContextMenu');
if (~isempty(hui) && ishghandle(hui)) && ...
        (isempty(hMode.ModeStateData.CustomContextMenu) || ~ishghandle(hMode.ModeStateData.CustomContextMenu))
    delete(hui);
end

% Remove appdata to avoid breaking code in
% scribefiglisten, hgsave, and figtoolset
if isappdata(hFigure,'ZoomOnState');
    rmappdata(hFigure,'ZoomOnState');
end

%-----------------------------------------------%
function localButtonWheelFcn(hObj, evd, hMode) %#ok

hFigure = hMode.FigureHandle;
hAxes = locFindAxes(hFigure,evd);
if (isempty(hAxes)) || ~localInBounds(hAxes(1))
    return;
end

dir = evd.VerticalScrollCount;
if dir < 0
    zoom_factor = 2;
else
    zoom_factor = 0.5;
end

resetplotview(hAxes,'InitializeCurrentView');
hMode.fireActionPreCallback(localConstructEvd(hAxes));
localApplyZoomFactor(hMode,hAxes,zoom_factor,false)

%-----------------------------------------------%
function localWindowButtonDownFcn(hFigure,evd,hMode)

fig_sel_type = get(hFigure,'SelectionType');
fig_mod = get(hFigure,'CurrentModifier');

hAxes = locFindAxes(hFigure,evd);

if (isempty(hAxes)) || ~localInBounds(hAxes(1))
    if strcmp(fig_sel_type,'alt')
        hMode.ShowContextMenu = false;
    end
    return;
end

switch (lower(fig_sel_type))
    case 'alt' % right click
        % display context menu
        if strcmpi(hMode.ModeStateData.DoRightClick,'off')
            localGetContextMenu(hMode);
        else
            hMode.ShowContextMenu = false;
            hMode.fireActionPreCallback(localConstructEvd(hAxes));
            localStartDrag(hMode,evd,true);
        end
    otherwise % left click, center click, double click
        % Zoom out if user clicked on 'alt' or shift
        % ToDo: Remove "alt" in a future release
        if ~isempty(fig_mod) && isscalar(fig_mod) && ...
                (strcmp(fig_mod,'alt') || strcmp(fig_mod,'shift'))
            resetplotview(hAxes,'InitializeCurrentView');
            for i=1:numel(hAxes)
               localStoreLimits(hAxes(i));
            end
            switch hMode.ModeStateData.Direction
                case 'in'
                    hMode.fireActionPreCallback(localConstructEvd(hAxes));
                    localApplyZoomFactor(hMode,hAxes,.5,false);
                case 'out'
                    hMode.fireActionPreCallback(localConstructEvd(hAxes));
                    localApplyZoomFactor(hMode,hAxes,2,true);
            end
        else
            hMode.fireActionPreCallback(localConstructEvd(hAxes));
            localStartDrag(hMode,evd);
        end
end

%---------------------------------------------------%
function localStoreLimits(hAxes)

hAxesList = hAxes;
% We need to take linked axes into account.
if isappdata(hAxes,'graphics_linkaxes') && ~isempty(getappdata(hAxes,'graphics_linkaxes'))
    linkInfo = getappdata(hAxes,'graphics_linkaxes');
    if ishandle(linkInfo)
        hAxesList = [hAxesList double(get(linkInfo,'Targets'))];
    end
end
hAxesList = hAxesList(ishghandle(hAxesList));

for i=1:numel(hAxesList)
    limits = getappdata(hAxesList(i),'zoom_zoomOrigAxesLimits');
    if isempty(limits)
        limits = localComputeLimits(hAxesList(i));
        % Store the original axes limits for zoom. This is used
        % by zoom to prevent a zoom out that zooms further than
        % the original axes limits.
        setappdata(hAxesList(i),'zoom_zoomOrigAxesLimits',limits);
    end
end

%---------------------------------------------------%
function limits = localComputeLimits(hAxes)

    xlim = local_get_xlim(hAxes); xmin = xlim(1); xmax = xlim(2);
    ylim = local_get_ylim(hAxes); ymin = ylim(1); ymax = ylim(2);
    limits = [xmin xmax ymin ymax];
    
%---------------------------------------------------%
function xlim = local_get_xlim(ax)
%GET_XLIM Return equivalent linear scale xlim
xlim = get(ax,'xlim');
if strcmp(get(ax,'XScale'),'log'),
    xlim = log10(xlim);
end

%---------------------------------------------------%
function ylim = local_get_ylim(ax)
%GET_YLIM Return equivalent linear scale ylim
ylim = get(ax,'ylim');
if strcmp(get(ax,'YScale'),'log'),
    ylim = log10(ylim);
end
 
%---------------------------------------------------%
function localStartDrag(hMode,evd,dorightclick)
% Mouse Button Down Function

% By default, don't support right click zoom out
if nargin==1
  dorightclick = false;
end
hFig = get(hMode,'FigureHandle');
hAxesVector = locFindAxes(hFig,evd);
if ~isempty(hAxesVector),
   hMode.ModeStateData.CurrentAxes = hAxesVector;
 
   sel_type = get(hFig,'SelectionType');
   switch sel_type

       case 'normal' % left click        
         if strcmpi(hMode.ModeStateData.Direction,'out') && is2D(hAxesVector(1))
             localApplyZoomFactor(hMode,hAxesVector,.5,false);
         else
             localZoom(hMode,hAxesVector);
         end
                    
       case 'open' % double click
          % Reset top plot
          localResetPlot(hAxesVector,hMode);
         
       case 'alt' % right click
          % zoom out
          if dorightclick
              if strcmpi(hMode.ModeStateData.Direction,'in') && is2D(hAxesVector(1))
                  localApplyZoomFactor(hMode,hAxesVector,.5,false);
              else
                  localZoom(hMode,hAxesVector);
              end
          end
          
       case 'extend' % center click
          % Do nothing 
   end
end

%---------------------------------------------------%
function localZoom(hMode,hAxesVector)

resetplotview(hAxesVector,'InitializeCurrentView');
for i=1:numel(hAxesVector)
    localStoreLimits(hAxesVector(i));
end

% Call appropriate zoom method based on whether plot is
% 2-D or 3-D plot
if is2D(hAxesVector(1))
  localButtonDownFcn2D(hMode,hAxesVector);
else
  localButtonDownFcn3D(hMode,hAxesVector);
end

%-----------------------------------------------%
function localButtonDownFcn2D(hMode,hAxesVector)
% Button down function for 2-D zooming
localZoom2DIn(hMode,hAxesVector);

%---------------------------------------------------%
function localZoom2DIn(hMode,hAxesVector)

hFig = get(hMode,'FigureHandle');

% Get current point in pixels
figPoint = get(hFig,'CurrentPoint');
new_pt = hgconvertunits(hFig,[0 0 figPoint],...
    get(hFig,'Units'),'pixels',hFig);
hMode.ModeStateData.MousePoint = new_pt(3:4);

% First element in the currentAxes is the axes on the 
% top (on which the lines are drawn).
hAxes = hAxesVector(1);

% Get the current point on this axes
cp = get(hAxes, 'CurrentPoint'); cp = cp(1,1:2);

numAx = length(hAxesVector);
cpMulAxes = zeros(numAx-1,2);
% Get the current point on the other axes too (multiple axes case).
% This will be passed as an argument to the mousebtnupfcn of the zoom
% object where the new axes limits are set.
for k = 2:numAx
    cpAxes = get(hAxesVector(k), 'CurrentPoint');
    cpMulAxes(k-1,:) = cpAxes(1,1:2);
end

x  = ones(2,4) * cp(1);
y  = ones(2,4) * cp(2);

% Display rbbox lines in top axes
hRbboxAxes = hAxesVector(1);

% Get zoom lines
hLines = hMode.ModeStateData.LineHandles;
if all(isempty(hLines)) || all(~ishghandle(hLines))
   hLines = localCreateZoomLines(hRbboxAxes,x,y);
   hMode.ModeStateData.LineHandles = hLines;
else
   set(hLines,'xdata',x(:,1),'ydata',y(:,1)); 
end

%For "zoom('down')" syntax to work:
if ~localIsZoomOn(hMode)
    obj = hFig;
else
    obj = hMode;
end

% Set the window button motion and up fcn's.
origMotionFcn = get(obj,'WindowButtonMotionFcn');

% Only perform this step if the zoom-state is changing (i.e, we are not
% stuck in drag-mode.
if ~iscell(origMotionFcn) || ~isequal(origMotionFcn{1}, @local2DButtonMotionFcn)
    set(obj, 'WindowButtonMotionFcn',...
        {@local2DButtonMotionFcn,hMode,obj});

    set(obj, 'WindowButtonUpFcn', ...
        {@local2DButtonUpFcn, ...
        hMode, ...
        cpMulAxes, ...
        origMotionFcn,obj});
end

%---------------------------------------------------%
function [hLines] = localCreateZoomLines(hAxes,x,y)

% Create the line for the RbBox.
lineprops.Parent = hAxes;
lineprops.Visible = 'on';
if ~feature('HGUsingMATLABClasses')
    lineprops.EraseMode = 'xor';
end
lineprops.LineWidth = 1;
lineprops.Color =   [0.65 0.65 0.65];
lineprops.Tag = '_TMWZoomLines';
lineprops.HandleVisibility = 'off';
lineprops.XLimInclude = 'off';
lineprops.YLimInclude = 'off';
lineprops.ZLimInclude = 'off';
lineprops.HitTest = 'off';

if get(0,'ScreenDepth') == 8,  
  lineprops.LineWidth = 1;
end

hLines = line(x,y,lineprops);

% Mark this object as non-data so that it is ignored 
% by various tools such as basic fitting.
hBehavior = hgbehaviorfactory('DataDescriptor');
set(hBehavior,'Enable',false);
hgaddbehavior(hLines,hBehavior);

%---------------------------------------------------%
function local2DButtonMotionFcn(~,evd,hMode,obj)
% Mouse Button Motion Function

% This zoom code originates from signal and simulink toolbox

hLines         = hMode.ModeStateData.LineHandles;
currentAxes    = hMode.ModeStateData.CurrentAxes;

fig = hMode.FigureHandle;
if isa(obj,'uitools.uimode')
    curr_units = hgconvertunits(fig,[0 0 evd.CurrentPoint],...
        'pixels',get(fig,'Units'),fig);
    curr_units = curr_units(3:4);
    set(evd.Source,'CurrentPoint',curr_units);
end

% The first axes in currentAxes is the one on the top. On this axes the
% lines are to be drawn.
cAx            = currentAxes(1);
cp             = get(cAx, 'CurrentPoint'); cp = cp(1,1:2);
xcp            = cp(1);
ycp            = cp(2);

% The first point of line 1 is always the zoom origin.
% Edge case - If the line handles are invalid, return early.
if isempty(hLines) || any(~ishghandle(hLines))
   return;
end

XDat   = get(hLines(1), 'XData');
YDat   = get(hLines(1), 'YData');
origin = [XDat(1), YDat(1)];

% Consider log plots
% TBD
isxlog = false; isylog = false;
if strcmpi(get(cAx,'XScale'),'log')
  isxlog = true;
end
if strcmpi(get(cAx,'YScale'),'log')
  isylog = true;
end
% Draw rbbox depending on mode.
switch(localChooseConstraint(hMode.ModeStateData.Constraint,cAx))
    case 'none',
        % Both x and y zoom.
        % RBBOX - lines:
        % 
        %          2
        %    o-------------
        %    |            |
        %  1 |            | 4
        %    |            |
        %    --------------
        %          3
        %
       
        % Set data for line 1.
        YDat = get(hLines(1),'YData');
        YDat(2) = ycp;
        set(hLines(1),'YData',YDat);
        
        % Set data for line 1.
        XDat = get(hLines(2),'XData');
        XDat(2) = xcp;
        set(hLines(2),'XData',XDat);
        
        % Set data for line 3.
        XDat = get(hLines(3),'XData');
        YDat = [ycp ycp];
        XDat(2) = xcp;
        set(hLines(3),'XData',XDat,'YData',YDat);

        % Set data for line 4.
        YDat = get(hLines(4),'YData');
        XDat = [xcp xcp];
        YDat(2) = ycp;
        set(hLines(4),'XData',XDat,'YData',YDat);
        
    case 'horizontal',
        % x only zoom.
        % RBBOX - lines (only 1-3 used):
        %   
        %    |     1      |
        %  2 o------------| 3 
        %    |            |
        %             
        
        % Set the end bracket lengths (actually the halfLength).
        YLim = get(get(fig,'CurrentAxes'), 'YLim');
        
        % Set data for line 1.
        XDat = get(hLines(1),'XData');
        XDat(2) = xcp;
        set(hLines(1),'XData',XDat);

        if isylog
          YLim = log10(YLim);
          origin = log10(origin);
        end

        endHalfLength = (YLim(2) - YLim(1)) / 30;
        YDat = [origin(2) - endHalfLength, origin(2) + endHalfLength];

        if isylog
          YDat = 10.^YDat;
        end

        % Set data for line 2.
        set(hLines(2), 'YData', YDat);
                
        % Set data for line 3.
        XDat = [xcp xcp];
        set(hLines(3), 'XData', XDat, 'YData', YDat);
        
    case 'vertical',
        % y only zoom.
        % RBBOX - lines (only 1-3 used):
        %    2
        %  --o--  
        %    |
        %  1 |
        %    |
        %  -----           
        %    3
        %
        
        % Set the end bracket lengths (actually the halfLength).
        XLim = get(get(fig,'CurrentAxes'), 'XLim');
        
        if isxlog
          XLim = log10(XLim);
          origin = log10(origin);
        end
        
        endHalfLength = (XLim(2) - XLim(1)) / 30;
        
        % Set data for line 1.
        YDat = get(hLines(1),'YData');
        YDat(2) = ycp;
        set(hLines(1),'YData',YDat);
        
        % Set data for line 2.
        XDat = [origin(1) - endHalfLength, origin(1) + endHalfLength];
        if isxlog
          XDat = 10.^XDat;
        end
        set(hLines(2), 'XData', XDat);
        
        % Set data for line 3.
        YDat = [ycp ycp];
        set(hLines(3), 'XData', XDat, 'YData', YDat);
end

%---------------------------------------------------%
function local2DButtonUpFcn(~, ~ ,hMode,cpMulAxes,origMotionFcn,obj)
% Mouse button up function
% This code originates from simulink zoom. 

hFig = get(hMode,'FigureHandle');

% This constant specifies the number of pixels the mouse
% must move in order to do a rbbox zoom.
POINT_MODE_MAX_PIXELS = 5; % pixels

% Get necessary handles
hLines     = hMode.ModeStateData.LineHandles;
currentAxes = hMode.ModeStateData.CurrentAxes;

% Get net mouse movement in pixels
orig_units = get(hFig,'Units');
set(hFig,'Units','Pixels');
fp = get(hFig,'CurrentPoint');
set(hFig,'Units',orig_units);
orig_fp = hMode.ModeStateData.MousePoint;
dpixel = abs(orig_fp-fp);

if ~isempty(hLines) && all(ishghandle(hLines))
    % The first point of line 1 is always the zoom origin.
    XDat   = get(hLines(1), 'XData');
    YDat   = get(hLines(1), 'YData');
    origin = [XDat(1), YDat(1)];
else
    dpixel = [POINT_MODE_MAX_PIXELS,POINT_MODE_MAX_PIXELS];
end

% Delete the RBBOX lines.
if ~isempty(hLines) && all(ishghandle(hLines))
    delete(hLines);
end

% Need to determine if we are in point-mode zoom or rbbox zoom. We will
% assume that the constraint of the top axes is the same constraint for all
% axes in the list:
constraintVal = localChooseConstraint(hMode.ModeStateData.Constraint,currentAxes(1));
pointMode = false;
if strcmpi(constraintVal,'none')
    pointMode = (dpixel(1) <= POINT_MODE_MAX_PIXELS) ...
                    && (dpixel(2) <= POINT_MODE_MAX_PIXELS);
elseif strcmpi(constraintVal,'horizontal')
    pointMode = dpixel(1)  <= POINT_MODE_MAX_PIXELS;
elseif strcmpi(constraintVal,'vertical')
    pointMode = dpixel(2) <= POINT_MODE_MAX_PIXELS;
end

if pointMode
    localApplyZoomFactor(hMode,currentAxes,2,true);
    set(obj,'WindowButtonMotionFcn',origMotionFcn);
    set(obj,'WindowButtonUpFcn','');
    hMode.ModeStateData.MousePoint = [];
    return;
end

% Loop through all the currentAxes and zoom-in each of them
% Get the current limits.
currentXLim = get(currentAxes,'XLim');
currentYLim = get(currentAxes,'YLim');
currLim = axis(currentAxes);
if ~iscell(currentXLim)
    currentXLim = {currentXLim};
    currentYLim = {currentYLim};
    currLim = {currLim};
end
newXLim = cell(size(currentXLim));
newYLim = cell(size(currentYLim));

for k = 1:length(currentAxes),
    cAx = currentAxes(k);
       
    % cpMulAxes is the zoom origin for multiple axes if any.
    if k > 1
        origin = cpMulAxes(k-1,:);
    end
    
    newXLim{k} = currentXLim{k};
    newYLim{k} = currentYLim{k};
    
    % Perform zoom operation based on zoom mode.
    switch(constraintVal)
        case 'none',
            %
            % Both x and y zoom.
            % RBBOX - lines:
            %
            %          2
            %    o-------------
            %    |            |
            %  1 |            | 4
            %    |            |
            %    --------------
            %          3
            %

            % Determine the end point of zoom operation.

            % Get current point.
            cp = get(cAx, 'CurrentPoint'); cp = cp(1,1:2);
            xcp = cp(1);
            ycp = cp(2);

            % Uncomment to clip rbbox zoom to current axes limits
            %if xcp > currentXLim(2),
            %    xcp = currentXLim(2);
            %end
            %if xcp < currentXLim(1),
            %    xcp = currentXLim(1);
            %end
            %if ycp > currentYLim(2),
            %    ycp = currentYLim(2);
            %end
            %if ycp < currentYLim(1),
            %    ycp = currentYLim(1);
            %end
            endPt = [xcp ycp];

            newXLim{k} = localGetNewXLim(cAx,origin,endPt);
            newYLim{k} = localGetNewYLim(cAx,origin,endPt);

        case 'horizontal',
            % x only zoom.
            % RBBOX - lines (only 1-3 used):
            %
            %    |     1      |
            %  2 o------------| 3
            %    |            |
            %
            %

            % Determine the end point of zoom operation.
            cp = get(cAx, 'CurrentPoint'); cp = cp(1,1:2);
            xcp = cp(1);

            % Uncomment to clip rbbox zoom to current axes limits
            % if xcp > currentXLim(2),
            %    xcp = currentXLim(2);
            % end
            % if xcp < currentXLim(1),
            %    xcp = currentXLim(1);
            % end

            endPt = [xcp origin(2)];

            newXLim{k} = localGetNewXLim(cAx,origin,endPt);
            newYLim{k} = currentYLim{k};

        case 'vertical',
            % y only zoom.
            % RBBOX - lines (only 1-3 used):
            %    2
            %  --o--
            %    |
            %  1 |
            %    |
            %  -----
            %    3
            %

            % Determine the end point of zoom operation.

            % End pt is the 2nd point of line 1.
            cp = get(cAx, 'CurrentPoint'); cp = cp(1,1:2);
            ycp = cp(2);

            % Uncomment to clip rbbox zoom to current axes limits
            % if ycp > currentYLim(2),
            %    ycp = currentYLim(2);
            % end
            % if ycp < currentYLim(1),
            %    ycp = currentYLim(1);
            % end

            endPt = [origin(1) ycp];

            newYLim{k} = localGetNewYLim(cAx,origin,endPt);
            newXLim{k} = currentXLim{k};
    end % switch        
end % for

localDoZoom2D(currentAxes,currentXLim,currentYLim,newXLim,newYLim);
% Fire mode post callback function:
hMode.fireActionPostCallback(localConstructEvd(currentAxes));

% Call drawnow to flush axes update since the next line, create2Dundo,
% will take a long time when called for the first time (class loading).
if ~feature('HGUsingMATLABClasses')
    drawnow expose
end
    
newLim = axis(currentAxes);
if ~iscell(newLim)
    newLim = {newLim};
end
% This runs slow the first time due to UDD class loading
localCreate2DUndo(currentAxes,currLim,newLim);

set(obj,'WindowButtonMotionFcn',origMotionFcn);
set(obj,'WindowButtonUpFcn','');

hMode.ModeStateData.MousePoint = [];

%----------------------------------------------------%
function [newXLim] = localGetNewXLim(hAxes,origin,endPt)

% Calculate the new X-Limits.
x_lim = [origin(1) endPt(1)];
if x_lim(1) > x_lim(2),
    x_lim = x_lim([2 1]);
end
            
% Set new Xlimits.
% NOTE: Check that the limits aren't equal.  This happens
%   at very small limits.  In this case, we do nothing.
%
if abs(x_lim(1) - x_lim(2)) > 1e-10*(abs(x_lim(1)) + abs(x_lim(2)))
     newXLim = x_lim;                
else
     newXLim = xlim(hAxes);
end

%----------------------------------------------------%
function [newYLim] = localGetNewYLim(hAxes,origin,endPt)

% Calculate the new Y-Limits.
y_lim = [origin(2) endPt(2)];
if y_lim(1) > y_lim(2),
    y_lim = y_lim([2 1]);
end
            
% Set new Ylimits.
% NOTE: Check that the limits aren't equal.  This happens
%   at very small limits.  In this case, we do nothing.
%
if abs(y_lim(1) - y_lim(2)) > 1e-10*(abs(y_lim(1)) + abs(y_lim(2)))
     newYLim = y_lim;                
else
     newYLim = ylim(hAxes);
end

%---------------------------------------------------%
function localButtonDownFcn3D(hMode,hAxesVector)
% Button down function for 3-D zooming

% Set the original camera view angle
% We'll need this for generating the undo/redo
% command object.
hMode.ModeStateData.CameraViewAngle = get(hAxesVector,'CameraViewAngle');

% Force axis to be 'vis3d' to avoid wacky resizing
axis(hAxesVector,'vis3d');

% Set the window button motion and up fcn's.
origMotionFcn = get(hMode,'WindowButtonMotionFcn');

set(hMode, 'WindowButtonMotionFcn',{@local3DButtonMotionFcn,hMode,hAxesVector});
set(hMode, 'WindowButtonUpFcn', {@local3DButtonUpFcn,hMode,hAxesVector,origMotionFcn});

%---------------------------------------------------%
function local3DButtonMotionFcn(~,eventData,hMode,hAxes)

% Get current point in pixels
new_pt = eventData.CurrentPoint;

starting_pt = hMode.ModeStateData.MousePoint;
if isempty(starting_pt)
   hMode.ModeStateData.MousePoint = new_pt;
else
    revertVa = false;
    vaOld = get(hAxes,'CameraViewAngle');
    if ~iscell(vaOld)
        vaOld = {vaOld};
    end
   % Determine change in pixel position
   xy = new_pt - starting_pt;
   
   % Heuristic for pixel change to camera zoom factor 
   q = max(-.9, min(.9, sum(xy)/70))+1;

   % heuristic avoids small view angles.
   MIN_VIEW_ANGLE = .001;
   MAX_VIEW_ANGLE = hMode.ModeStateData.MaxViewAngle;
   va = cell(size(hAxes));
   for i = 1:length(hAxes)
       camzoom(hAxes(i),q);
       va{i} = get(hAxes(i),'CameraViewAngle');
       %If the act of zooming puts us at an extreme, back the zoom out
       if ~((q>1 || va{i}<MAX_VIEW_ANGLE) && (va{i}>MIN_VIEW_ANGLE))
           revertVa = true;
       end
   end
   
   if revertVa
       set(hAxes,{'CameraViewAngle'},vaOld);
   end
   
   hMode.ModeStateData.MousePoint = new_pt;
end

%---------------------------------------------------%
function local3DButtonUpFcn(~, ~, hMode, hAxes, origMotionFcn)

% If the mouse position never moved then just zoom in
% on the mouse click
if isempty(hMode.ModeStateData.MousePoint)
   localOneShot3DZoom(hMode,hAxes); 
else
    % Add zoom operation to undo/redo stack
    origVa = hMode.ModeStateData.CameraViewAngle;
    newVa = get(hAxes,'CameraViewAngle');
    localCreate3DUndo(hAxes,origVa,newVa);
end

set(hMode,'WindowButtonUpFcn','');
set(hMode,'WindowButtonMotionFcn',origMotionFcn);

% Clear out Mouse Position
hMode.ModeStateData.MousePoint = [];

% Clear out original camera view angle
hMode.ModeStateData.CameraViewAngle = [];

% Fire mode post callback function:
hMode.fireActionPostCallback(localConstructEvd(hAxes));

%---------------------------------------------------%
function localOneShot3DZoom(hMode,hAxesVector)
% If button motion function never ran then do a 
% simple 3D zoom based on current mouse position

if strcmpi(hMode.ModeStateData.Direction,'in')
   zoomLeftFactor = 2;
   zoomRightFactor = 0.5;         
else
   zoomLeftFactor = 0.5;
   zoomRightFactor = 2;
end

% Determine new zoom factor based on mouse click
hFig = get(hMode,'FigureHandle');
switch get(hFig,'selectiontype')            
   case 'normal' % Left click
      fac = zoomLeftFactor;

   case 'open' % Double click
        % do nothing

   otherwise % Right click
      fac = zoomRightFactor;
end

% Actual zoom operation
axSize = size(hAxesVector);
newct = cell(axSize);
origct = cell(axSize);
origpos = cell(axSize);
origtar = cell(axSize);
origva = cell(axSize);
newva = cell(axSize);
for i = 1:length(hAxesVector)
    hAxes = hAxesVector(i);
    newct{i} = mean(get(hAxes,'CurrentPoint'),1);
    origct{i} = camtarget(hAxes);
    %Check to see if the new camera target is within the bounds of the axes. If
    %it is not, zoom based on the current target.
    targetInBounds = true;
    XLims = get(hAxes,'XLim');
    if newct{i}(1) < min(XLims) || newct{i}(1) > max(XLims)
        targetInBounds = false;
    end
    YLims = get(hAxes,'YLim');
    if newct{i}(2) < min(YLims) || newct{i}(2) > max(YLims)
        targetInBounds = false;
    end
    ZLims = get(hAxes,'ZLim');
    if newct{i}(3) < min(ZLims) || newct{i}(3) > max(ZLims)
        targetInBounds = false;
    end
    if targetInBounds
        origpos{i} = campos(hAxes);
        origtar{i} = camtarget(hAxes);
        ctDiff = newct{i} - get(hAxes,'CameraTarget');
        set(hAxes,'CameraTarget',newct{i});
        set(hAxes,'CameraPosition',get(hAxes,'CameraPosition') + ctDiff);
    end
    origva{i} = camva(hAxes);
    camzoom(hAxes,fac);
    newva{i} = camva(hAxes);

    MIN_VIEW_ANGLE = .001;
    MAX_VIEW_ANGLE = hMode.ModeStateData.MaxViewAngle;
    %If the act of zooming puts us at an extreme, back the zoom out
    if ~((fac>1 || newva{i}<MAX_VIEW_ANGLE) && (newva{i}>MIN_VIEW_ANGLE))
        set(hAxes,'CameraViewAngle',origva{i});
        if targetInBounds
            set(hAxes,'CameraTarget',origtar{i},'CameraPosition',origpos{i});
        end
    end
end

% Add operation to undo/redo stack
localCreate3DUndo(hAxesVector,origva,newva,origct,newct);

%-----------------------------------------------%
function localMotionFcn(obj,evd,hMode) %#ok

hFigure = evd.Source;
% Get current point in figure units
curr_units = hgconvertunits(hFigure,[0 0 evd.CurrentPoint],...
    'pixels',get(hFigure,'Units'),hFigure);
curr_units = curr_units(3:4);

set(hFigure,'CurrentPoint',curr_units);
hAx = locFindAxes(hFigure,evd);
if ~isempty(hAx) && localInBounds(hAx(1))
    if strcmp(hMode.ModeStateData.Direction,'in')
        setptr(hFigure,'glassplus');
    else
        setptr(hFigure,'glassminus');
    end
else
    setptr(hFigure,'arrow');
end

%-----------------------------------------------%
function localKeyPressFcn(hFigure,evd,hMode)

consumekey = false;

% Exit early if invalid conditions
if ~isstruct(evd) || ~isfield(evd,'Key') || ...
    isempty(evd.Key) || ~isfield(evd,'Character')
   return;
end

% Parse key press
zoomfactor = [];
switch evd.Key
    case 'uparrow'
        zoomfactor = 2;      
    case 'downarrow'
        zoomfactor = .5;    
    case 'alt'
        consumekey = true;
    case 'z'
        if strcmpi(evd.Modifier,'control')
            consumekey = true;
            hUndoMenu = findall(hFigure,'Type','UIMenu','Tag','figMenuEditUndo');
            if isempty(hUndoMenu)
                % Undo command
                uiundo(hMode.FigureHandle,'execUndo');
            end
        end
    case 'y'
        if strcmpi(evd.Modifier,'control')
            consumekey = true;
            hRedoMenu = findall(hFigure,'Type','UIMenu','Tag','figMenuEditRedo');
            if isempty(hRedoMenu)
                % Redo command
                uiundo(hMode.FigureHandle,'execRedo');
            end
        end
end

hFigure = get(hMode,'FigureHandle');
if ishghandle(hFigure)
    hAxes = get(hFigure,'CurrentAxes');
    if ishghandle(hAxes)
        hAxes = localVectorizeAxes(hAxes);
        b = hggetbehavior(hAxes(1),'Zoom','-peek');
        if ~isempty(b) &&  ishandle(b) && ~get(b,'Enable')
            hAxes = [];
        elseif isappdata(hAxes(1),'NonDataObject')
            hAxes = [];
        end
        if ~isempty(zoomfactor) && ishghandle(hAxes(1))
            consumekey = true;
            resetplotview(hAxes,'InitializeCurrentView');
            hMode.fireActionPreCallback(localConstructEvd(hAxes));
            localApplyZoomFactor(hMode,hAxes,zoomfactor,false);
        end
    end
end

if ~consumekey
    graph2dhelper('forwardToCommandWindow',hFigure,evd);
end

%-------------------------------------------%
function localApplyZoomFactor(hMode,hAxes,zoom_factor,useCurrentPoint)
% hAxes is an axes vector
% zoom_factor is a scalar double

if ~isempty(hAxes) && ishghandle(hAxes(1))
    if is2D(hAxes(1))
        localZoomFactor2D(hMode,hAxes,zoom_factor,useCurrentPoint)
    else
        if zoom_factor <= 0
            return;
        end
        localZoomFactor3D(hMode,hAxes,zoom_factor)
    end
end

% Fire mode post callback function:
hMode.fireActionPostCallback(localConstructEvd(hAxes));

%-------------------------------------------%
function p = local_get_currentpoint(ax)
%GET_CURRENTPOINT Return equivalent linear scale current point
p = get(ax,'currentpoint'); p = p(1,1:2);
if strcmp(get(ax,'XScale'),'log'),
    p(1) = log10(p(1));
end
if strcmp(get(ax,'YScale'),'log'),
    p(2) = log10(p(2));
end


%-------------------------------------------%
function localZoomFactor2D(hMode,hAxesVector,zoom_factor,useCurrentPoint)
% Most of the code here is from the original zoom function

if zoom_factor > 0
   m = 0;
else
   m = -1;
end

% Get bounding limits for zooming out.
currLim = axis(hAxesVector);
currXLim = get(hAxesVector,'XLim');
currYLim = get(hAxesVector,'YLim');
if ~iscell(currLim)
    currLim = {currLim};
    currXLim = {currXLim};
    currYLim = {currYLim};    
end
newXLim = cell(size(currXLim));
newYLim = cell(size(currYLim));
newLim = cell(size(currLim));
for i = 1:length(hAxesVector)
    newXLim{i} = currXLim{i};
    newYLim{i} = currYLim{i};
    hAxes = hAxesVector(i);
    localStoreLimits(hAxes);
    limits = getappdata(hAxes,'zoom_zoomOrigAxesLimits');
    isXLog = strcmpi(get(hAxes,'XScale'),'log');
    isYLog = strcmpi(get(hAxes,'YScale'),'log');

    if isXLog
        newXLim{i} = log10(newXLim{i});
    end
    if isYLog
        newYLim{i} = log10(newYLim{i});
    end

    if ~all(isfinite(newXLim{i})) || ~all(isfinite(newYLim{i})) ...
            || ~all(isreal(newXLim{i})) || ~all(isreal(newYLim{i}))
        % This code is duplicated in pan.m
        % If any of the public limits are inf then we need the actual limits
        % by getting the hidden deprecated RenderLimits.
        oldstate = warning('off','MATLAB:HandleGraphics:NonfunctionalProperty:RenderLimits');
        renderlimits = get(hAxes,'RenderLimits');
        warning(oldstate);
        newXLim{i} = renderlimits(1:2);
        if isXLog
            newXLim{i} = log10(newXLim{i});
        end
        newYLim{i} = renderlimits(3:4);
        if isYLog
            newYLim{i} = log10(newYLim{i});
        end
    end

    zoomConstraint = localChooseConstraint(hMode.ModeStateData.Constraint,hAxes);
    dx = diff(newXLim{i});
    dy = diff(newYLim{i});
    if useCurrentPoint
        pts = local_get_currentpoint(hAxes);
        center_x = pts(1);
        center_y = pts(2);
    else
        center_x = newXLim{i}(1) + dx/2;
        center_y = newYLim{i}(1) + dy/2;
    end

    % Calculate new x-limits
    if ~any(isinf(newXLim{i})) && (strcmpi(zoomConstraint,'horizontal') || strcmp(zoomConstraint,'none'))
        xmin = limits(1);
        xmax = limits(2);
        newdx = dx * (1/zoom_factor.^(m+1));
        newdx = min(newdx,xmax-xmin);
        % Limit zoom.
        center_x = max(center_x,xmin + newdx/2);
        center_x = min(center_x,xmax - newdx/2);
        newXLim{i} = [max(xmin,center_x-newdx/2) min(xmax,center_x+newdx/2)];
        
        % Check for log axes and return to linear values.
        if isXLog
            newXLim{i} = 10.^newXLim{i}(1:2);
        end
    else
        newXLim{i} = currXLim{i};
    end

    % Calculate new y-limits
    if ~any(isinf(newYLim{i})) && (strcmpi(zoomConstraint,'vertical') || strcmp(zoomConstraint,'none'))
        ymin = limits(3);
        ymax = limits(4);
        newdy = dy * (1/zoom_factor.^(m+1));
        newdy = min(newdy,ymax-ymin);
        % Limit zoom.
        center_y = max(center_y,ymin + newdy/2);
        center_y = min(center_y,ymax - newdy/2);
        newYLim{i} = [max(ymin,center_y-newdy/2) min(ymax,center_y+newdy/2)];
        
        % Check for log axes and return to linear values.
        if isYLog
            newYLim{i} = 10.^newYLim{i}(1:2);
        end
    else
        newYLim{i} = currYLim{i};
    end

    %Check for strangeness in the limits:
    if newXLim{i}(1) >= newXLim{i}(2)
        newXLim{i} = currXLim{i};
    end
    if newYLim{i}(1) >= newYLim{i}(2)
        newYLim{i} = currYLim{i};
    end
    newLim{i} = [newXLim{i},newYLim{i}];
end

localDoZoom2D(hAxesVector,currXLim,currYLim,newXLim,newYLim);
% Register with undo/redo
localCreate2DUndo(hAxesVector,currLim,newLim);

%-------------------------------------------%
function localDoZoom2D(hAxesVector,currXLim,currYLim,newXLim,newYLim)
% Check for axis equal and update axes limits as necessary

if ~iscell(currXLim)
    currXLim = {currXLim};
    currYLim = {currYLim};
    newXLim = {newXLim};
    newYLim = {newYLim};
end

for i = 1:length(hAxesVector)
    hAxes = hAxesVector(i);
    if strcmp(get(hAxes,'dataaspectratiomode'),'manual')
        olddx = diff(get(hAxes,'XLim'));
        olddy = diff(get(hAxes,'YLim'));
        ratio = olddx / olddy;
        dx = newXLim{i}(2)-newXLim{i}(1);
        dy = newYLim{i}(2)-newYLim{i}(1);
        % Convert the dx and dy into pixel units
        hFig = ancestor(hAxes,'Figure');
        % Since we are always dealing with 2-D axes, convert the data units
        % into normalized units by normalizing against the current limits of
        % the data.
        ndx = dx / olddx;
        ndy = dy / olddy;
        pixPosRect = hgconvertunits(hFig,get(hAxes,'Position'),get(hAxes,'Units'),'Pixels',hFig);
        pdx = pixPosRect(1) + pixPosRect(3)*ndx;
        pdy = pixPosRect(2) + pixPosRect(4)*ndy;
        % Use the larger axis of the zoom as a base, unless the other axes
        % hasn't moved.
        if (pdy > pdx && ~isequal(newYLim,get(hAxes,'YLim'))) || ...
                isequal(newXLim,get(hAxes,'XLim'))
            diffSize = ratio * dy;
            diffDiff = dx - diffSize;
            diffHalf = diffDiff / 2;
            newXLim{i}(1) = newXLim{i}(1) + diffHalf;
            newXLim{i}(2) = newXLim{i}(2) - diffHalf;
        else
            diffSize = dx / ratio;
            diffDiff = dy - diffSize;
            diffHalf = diffDiff / 2;
            newYLim{i}(1) = newYLim{i}(1) + diffHalf;
            newYLim{i}(2) = newYLim{i}(2) - diffHalf;
        end
        %If the camera view angle is set to be manual and axis equal has
        %been set, bad things may happen:
        set(hAxes,'CameraViewAngleMode','auto');
    end

    h = findobj(hAxes,'Type','image');
    if ~isempty(h)
        lims = objbounds(hAxes);
        x = lims(1:2);
        y = lims(3:4);
        %If we are within the bounds of the image to begin with. This is to
        %prevent odd behavior if we panned outside the bounds of the image
        if x(1) <= currXLim{i}(1) && x(2) >= currXLim{i}(2) &&...
                y(1) <= currYLim{i}(1) && y(2) >= currYLim{i}(2)
            dx = newXLim{i}(2) - newXLim{i}(1);
            if newXLim{i}(1) < x(1)
                newXLim{i}(1) = x(1);
                newXLim{i}(2) = newXLim{i}(1) + dx;
            end
            if newXLim{i}(2) > x(2)
                newXLim{i}(2) = x(2);
                newXLim{i}(1) = newXLim{i}(2) - dx;
            end
            dy = newYLim{i}(2) - newYLim{i}(1);
            if newYLim{i}(1) < y(1)
                newYLim{i}(1) = y(1);
                newYLim{i}(2) = newYLim{i}(1) + dy;
            end
            if newYLim{i}(2) > y(2)
                newYLim{i}(2) = y(2);
                newYLim{i}(1) = newYLim{i}(2) - dy;
            end
            % Edge case: If the zoom ends up outside the image bounds, clip to
            % the image.
            if newXLim{i}(1) < x(1)
                newXLim{i}(1) = x(1);
            end
            if newXLim{i}(2) > x(2)
                newXLim{i}(2) = x(2);
            end
            if newYLim{i}(1) < y(1)
                newYLim{i}(1) = y(1);
            end
            if newYLim{i}(2) > y(2)
                newYLim{i}(2) = y(2);
            end
        end
    end

    % Actual zoom operation
    newLim = [newXLim{i},newYLim{i}];
    axis(hAxes,newLim);
end

%-------------------------------------------%
function localZoomFactor3D(hMode,hAxes,zoom_factor)

% Actual zoom operation
origVa  = get(hAxes,'CameraViewAngle');
if ~iscell(origVa)
    origVa = {origVa};
end
newVa = cell(size(origVa));
doZoom = true;
for i = 1:length(hAxes)
    va_rad = origVa{i}*pi/360;
    %newVa = camva(hAxes)/zoom_factor;
    newVa{i} = atan(tan(va_rad)*(1/zoom_factor))*360/pi;

    % Limit view angle
    % heuristic avoids small view angles.
    MIN_VIEW_ANGLE = .001;
    MAX_VIEW_ANGLE = hMode.ModeStateData.MaxViewAngle;

    if ~((zoom_factor>1 || newVa{i}<MAX_VIEW_ANGLE) && (newVa{i}>MIN_VIEW_ANGLE))
        doZoom = false;
    end
end

if doZoom
    set(hAxes,{'CameraViewAngle'},newVa);
end

% Can't use camzoom since that breaks reverse compatibility
%camzoom(hAxes,zoom_factor); % sets view angle
%newVa = camva(hAxes);

% Register with undo/redo 
localCreate3DUndo(hAxes,origVa,newVa);

%-----------------------------------------------%
function evd = localConstructEvd(hAxes)
% Construct event data for post callback
evd.Axes = hAxes;

%-----------------------------------------------%
function localCreate2DUndo(hAxes,origLim,newLim)

hFigure = ancestor(hAxes(1),'figure');

if ~iscell(origLim)
    origLim = {origLim};
    newLim = {newLim};
end

% Don't add operations that don't change limits
% Assumption: if one axes didn't change, it is likely none of them did
if isequal(origLim{1},newLim{1})
  return;
end

% Determine undo stack name (this will appear in menu)
if all([origLim{1}(1),origLim{1}(3)] < [newLim{1}(1),newLim{1}(3)]) && ...
   all([origLim{1}(2),origLim{1}(4)] > [newLim{1}(2),newLim{1}(4)])
   name = 'Zoom In'; 
else
   name = 'Zoom Out';
end


% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
proxyVal = getProxyValueFromHandle(hAxes);

% Create command structure
cmd.Name = name;
cmd.Function = @localDo2DUndo;
cmd.Varargin = {hFigure,proxyVal,origLim,newLim};
cmd.InverseFunction = @localDo2DUndo;
cmd.InverseVarargin = {hFigure,proxyVal,newLim,origLim};

% Register with undo/redo
uiundo(hFigure,'function',cmd);

%---------------------------------------------------%
function localDo2DUndo(hFig,proxyVal,origLim,newLim)

hAxesVector = getHandleFromProxyValue(hFig,proxyVal);
for i=1:length(hAxesVector)
    hAxes = hAxesVector(i);
    if ishghandle(hAxes)
        localDoZoom2D(hAxes,origLim{i}(1:2),origLim{i}(3:4),newLim{i}(1:2),newLim{i}(3:4));
    end
end

%---------------------------------------------------%
function localCreate3DUndo(hAxes,origVa,newVa,origTarget,newTarget)

if nargin==3
   localViewAngleUndo(hAxes,origVa,newVa);
elseif nargin==5
   localTargetViewAngleUndo(hAxes,origVa,newVa,origTarget,newTarget);
end

%---------------------------------------------------%
function localTargetViewAngleUndo(hAxes,...
                                    origVa,newVa,...
                                    origCamTarget,newCamTarget)

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
hFigure = ancestor(hAxes(1),'figure');
proxyVal = getProxyValueFromHandle(hAxes);

if ~iscell(origVa)
    origVa = {origVa};
    newVa = {newVa};
end
if ~iscell(origCamTarget)
    origCamTarget = {origCamTarget};
    newCamTarget = {newCamTarget};
end

% Create command structure
cmd.Name = '3-D Zoom';
cmd.Function = @localUpdateCameraTargetViewAngle;
cmd.Varargin = {hFigure,proxyVal,newCamTarget,newVa};
cmd.InverseFunction = @localUpdateCameraTargetViewAngle;
cmd.InverseVarargin = {hFigure,proxyVal,origCamTarget,origVa};

uiundo(hFigure,'function',cmd);

%---------------------------------------------------%
function localUpdateCameraTargetViewAngle(hFig,proxyVal,t,va)

hAxes = getHandleFromProxyValue(hFig,proxyVal);

for i = 1:length(hAxes)
    if ishghandle(hAxes(i))
        camtarget(hAxes(i),t{i});
        camva(hAxes(i),va{i});
    end
end

%---------------------------------------------------%
function localViewAngleUndo(hAxes,origVa,newVa)

hFigure = ancestor(hAxes(1),'figure');

if ~iscell(origVa)
    origVa = {origVa};
    newVa = {newVa};
end

% Don't add operations that don't change limits
if isequal(origVa{1},newVa{1})
  return
end

% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
proxyVal = getProxyValueFromHandle(hAxes);

% Create command structure
cmd.Name = '3-D Zoom';
cmd.Function = @localDoViewAngleUndo;
cmd.Varargin = {hFigure,proxyVal,newVa};
cmd.InverseFunction = @localDoViewAngleUndo;
cmd.InverseVarargin = {hFigure,proxyVal,origVa};

% Register with undo/redo
uiundo(hFigure,'function',cmd);

%-----------------------------------------------%
function localDoViewAngleUndo(hFig,proxyVal,origVa)

hAxes = getHandleFromProxyValue(hFig,proxyVal);

for i = 1:length(hAxes)
    if ishghandle(hAxes(i))
        camva(hAxes(i),origVa{i});
    end
end

%-----------------------------------------------%
function [hui] = localUICreateDefaultContextMenu(hMode)
% Create default context menu
hFig = get(hMode,'FigureHandle');
props_context.Parent = hFig;
props_context.Tag = 'ZoomContextMenu';
props_context.Callback = {@localUIContextMenuCallback,hMode};
props_context.ButtonDown = {@localUIContextMenuCallback,hMode};
hui = uicontextmenu(props_context);

% Generic attributes for all zoom context menus
props.Callback = {@localUIContextMenuCallback,hMode};
props.Parent = hui;

props.Label = 'Zoom Out       Shift-Click';
props.Tag = 'ZoomInOut';
props.Separator = 'off';
uzoomout = uimenu(props); %#ok

% Full View context menu
props.Label = 'Reset to Original View';
props.Tag = 'ResetView';
props.Separator = 'off';
ufullview = uimenu(props); %#ok

% Zoom Constraint context menu
props.Callback = '';
props.Label = 'Zoom Options';
props.Tag = 'Constraint';
props.Separator = 'on';
uConstraint = uimenu(props);

props.Parent = uConstraint;

props.Callback = {@localUIContextMenuCallback,hMode};
props.Label = 'Unconstrained Zoom';
props.Tag = 'ZoomUnconstrained';
props.Separator = 'off';
uimenu(props);

props.Label = 'Horizontal Zoom (2-D Plots Only)';
props.Tag = 'ZoomHorizontal';
uimenu(props);

props.Label = 'Vertical Zoom (2-D Plots Only)';
props.Tag = 'ZoomVertical';
uimenu(props);

localUIContextMenuUpdate(hMode,hMode.ModeStateData.Constraint);

%-----------------------------------------------%
function localGetContextMenu(hMode)
% Create context menu

hui = get(hMode,'UIContextMenu');

if isempty(hui) || ~ishghandle(hui)
    hui = localUICreateDefaultContextMenu(hMode);
    set(hMode,'UIContextMenu',hui);
end
if isempty(hMode.ModeStateData.CustomContextMenu) || ~ishghandle(hMode.ModeStateData.CustomContextMenu)
    localUIUpdateContextMenuLabel(hMode);
end

if ~feature('HGUsingMATLABClasses')
    drawnow expose;
end

%-------------------------------------------------%
function localUIContextMenuCallback(obj,~,hMode)
tag = get(obj,'tag');

switch(tag)
    case 'ZoomInOut'
        % If we are here, then we clicked on something contained in an
        % axes. Rather than calling HITTEST, we will get this information
        % manually.
        hAxes = ancestor(hMode.FigureState.CurrentObj.Handle,'axes');
        resetplotview(hAxes,'InitializeCurrentView');
        arrayfun(@(x)(localStoreLimits(x)),hAxes);
        switch hMode.ModeStateData.Direction
            case 'in'
                hMode.fireActionPreCallback(localConstructEvd(hAxes));
                localApplyZoomFactor(hMode,hAxes,0.5,false);
            case 'out'
                hMode.fireActionPreCallback(localConstructEvd(hAxes));
                localApplyZoomFactor(hMode,hAxes,2,false);
        end
    case 'ResetView'
        % If we are here, then we clicked on something contained in an
        % axes. Rather than calling HITTEST, we will get this information
        % manually.
        hAxes = ancestor(hMode.FigureState.CurrentObj.Handle,'axes');
        hMode.fireActionPreCallback(localConstructEvd(hAxes));
        resetplotview(hAxes,'ApplyStoredView');
        hMode.fireActionPostCallback(localConstructEvd(hAxes));
    case 'ZoomContextMenu'
        localUIContextMenuUpdate(hMode,hMode.ModeStateData.Constraint);
    case 'ZoomUnconstrained'
        localUIContextMenuUpdate(hMode,'none');
    case 'ZoomHorizontal'
        localUIContextMenuUpdate(hMode,'horizontal');
    case 'ZoomVertical'
        localUIContextMenuUpdate(hMode,'vertical');
end

%-------------------------------------------------%
function localUIContextMenuUpdate(hMode,zoom_Constraint)

hFigure = get(hMode,'FigureHandle');
ux = findall(hFigure,'Tag','ZoomHorizontal','Type','UIMenu');
uy = findall(hFigure,'Tag','ZoomVertical','Type','UIMenu');
uxy = findall(hFigure,'Tag','ZoomUnconstrained','Type','UIMenu');

localChangeConstraint(hMode,zoom_Constraint)

switch(zoom_Constraint)

    case 'none'
        set(ux,'checked','off');
        set(uy,'checked','off');
        set(uxy,'checked','on');

    case 'horizontal'
        set(ux,'checked','on');
        set(uy,'checked','off');
        set(uxy,'checked','off');

    case 'vertical'
        set(ux,'checked','off');
        set(uy,'checked','on');
        set(uxy,'checked','off');
end

%-----------------------------------------------%
function localUISetZoomIn(fig)
set(uigettool(fig,'Exploration.ZoomIn'),'State','on');
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
set(uigettool(fig,'Exploration.ZoomX'),'State','off');
set(uigettool(fig,'Exploration.ZoomY'),'State','off');
set(findall(fig,'Tag','figMenuZoomIn'), 'Checked', 'on');
set(findall(fig,'Tag','figMenuZoomOut'),'Checked', 'off');

%-----------------------------------------------%
function localUISetZoomInX(fig)
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
hZoomX = uigettool(fig,'Exploration.ZoomX');
% If there is no X button, this is the same as in mode:
if isempty(hZoomX)
    set(uigettool(fig,'Exploration.ZoomIn'),'State','on');
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
else
    set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
    set(hZoomX,'State','on');
    set(uigettool(fig,'Exploration.ZoomY'),'State','off');
end
set(findall(fig,'Tag','figMenuZoomIn'), 'Checked', 'on');
set(findall(fig,'Tag','figMenuZoomOut'),'Checked', 'off');

%-----------------------------------------------%
function localUISetZoomInY(fig)
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
hZoomX = uigettool(fig,'Exploration.ZoomX');
% If there is no X button, this is the same as in mode:
if isempty(hZoomX)
    set(uigettool(fig,'Exploration.ZoomIn'),'State','on');
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
else
    set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
    set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
    set(hZoomX,'State','off');
    set(uigettool(fig,'Exploration.ZoomY'),'State','on');
end
set(findall(fig,'Tag','figMenuZoomIn'), 'Checked', 'on');
set(findall(fig,'Tag','figMenuZoomOut'),'Checked', 'off');

%-----------------------------------------------%
function localUISetZoomOut(fig)
set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
set(uigettool(fig,'Exploration.ZoomOut'),'State','on');
set(uigettool(fig,'Exploration.ZoomX'),'State','off');
set(uigettool(fig,'Exploration.ZoomY'),'State','off');
set(findall(fig,'Tag','figMenuZoomIn'), 'Checked', 'off');
set(findall(fig,'Tag','figMenuZoomOut'),'Checked', 'on');

%-----------------------------------------------%
function localUISetZoomOff(fig)
set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
set(uigettool(fig,'Exploration.ZoomX'),'State','off');
set(uigettool(fig,'Exploration.ZoomY'),'State','off');
set(findall(fig,'Tag','figMenuZoomIn'), 'Checked', 'off');
set(findall(fig,'Tag','figMenuZoomOut'),'Checked', 'off');

%-----------------------------------------------%
function localUIUpdateContextMenuLabel(hMode)

h = findobj(get(hMode,'UIContextMenu'),'Tag','ZoomInOut');
zoom_direction = hMode.ModeStateData.Direction;
if strcmp(zoom_direction,'in')
    set(h,'Label','Zoom Out       Shift-Click');
else
    set(h,'Label','Zoom In        Shift-Click');
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
function cons = localChooseConstraint(modeConstraint,hAx)
% Check to see if the axes has a constraint
localBehavior = hggetbehavior(hAx,'Zoom','-peek');
if isempty(localBehavior)
    cons = modeConstraint;
else
    % Reconcile the mode constraint with the axes constraint
    if ~strcmpi(localBehavior.Style,'both')
        if strcmpi(localBehavior.Style,'horizontal')
            if ~strcmpi(modeConstraint,'vertical')
                cons = 'horizontal';
            else
                cons = 'both';
            end
        else
            if ~strcmpi(modeConstraint,'horizontal')
                cons = 'vertical';
            else
                cons = 'both';
            end
        end
    else
        cons = modeConstraint;
    end
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
    b = hggetbehavior(candidate_ax,'Zoom','-peek');
    if ~isempty(b) &&  ishandle(b) && ~get(b,'Enable')
        % ignore this axes

        % 'NonDataObject' is a legacy flag defined in
        % datachildren file.
    elseif ~isappdata(candidate_ax,'NonDataObject')
        ax = candidate_ax;
        break;
    end
end

ax = localVectorizeAxes(ax);

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