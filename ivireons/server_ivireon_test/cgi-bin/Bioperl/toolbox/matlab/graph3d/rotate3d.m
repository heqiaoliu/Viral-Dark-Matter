function out=rotate3d(varargin)
%ROTATE3D Interactively rotate the view of a 3-D plot.
%   ROTATE3D ON turns on mouse-based 3-D rotation.
%   ROTATE3D OFF turns if off.
%   ROTATE3D by itself toggles the state.
%
%   ROTATE3D(FIG,...) works on the figure FIG.
%   ROTATE3D(AXES,...) works on the axis AXES.
%
%   H = ROTATE3D(FIG) returns the figure's rotate3d mode object for 
%                     customization.
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
%             % RES        a logical flag to determine whether the rotate
%                          operation should take place or the 
%                          'ButtonDownFcn' property of the object should 
%                          take precedence.
%
%        ActionPreCallback <function_handle>
%        Set this callback to listen to when a rotate operation will start.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object.
%
%             The event object has the following read only 
%             property:
%             Axes         The handle of the axes that is being rotated.
%
%        ActionPostCallback <function_handle>
%        Set this callback to listen to when a rotate operation has finished.
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
%        RotateStyle {'orbit'}|'box'
%        Sets the method of rotation. 'orbit' rotates the entire axes.
%        'box' rotates a plot-box outline of the axes.
%
%        UIContextMenu <handle>
%        Specifies a custom context menu to be displayed during a
%        right-click action.
%
%   FLAGS = isAllowAxesRotate(H,AXES)
%       Calling the function ISALLOWAXESROTATE on the rotate3d object, 
%       H, with a vector of axes handles, AXES, as input will return a 
%       logical array of the same dimension as the axes handle vector 
%       which indicate whether a rotate operation is permitted on the 
%       axes objects.
%
%   setAllowAxesRotate(H,AXES,FLAG)
%       Calling the function SETALLOWAXESROTATE on the rotate3d object, 
%       H, with a vector of axes handles, AXES, and a logical scalar, 
%       FLAG, will either allow or disallow a rotate operation on the 
%       axes objects.
%
%   EXAMPLE 1:
%
%   surf(peaks);
%   rotate3d on
%   % rotate the plot
%
%   EXAMPLE 2:
%
%   surf(peaks);
%   h = rotate3d;
%   set(h,'RotateStyle','box','Enable','on');
%   % Rotate the plot using the "Plot Box" rotate style.
%
%   EXAMPLE 3:
%
%   ax1 = subplot(1,2,1);
%   surf(peaks);
%   h = rotate3d;
%   ax2 = subplot(1,2,2);
%   surf(membrane);
%   setAllowAxesRotate(h,ax2,false);
%   % rotate the plots.
%
%   EXAMPLE 4: (copy into a file)
%      
%   function demo
%   % Allow a line to have its own 'ButtonDownFcn' callback.
%   hLine = plot(rand(1,10));
%   set(hLine,'ButtonDownFcn','disp(''This executes'')');
%   set(hLine,'Tag','DoNotIgnore');
%   h = rotate3d;
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
%   % Listen to rotate events
%   surf(peaks);
%   h = rotate3d;
%   set(h,'ActionPreCallback',@myprecallback);
%   set(h,'ActionPostCallback',@mypostcallback);
%   set(h,'Enable','on');
%
%   function myprecallback(obj,evd)
%   disp('A rotation is about to occur.');
%
%   function mypostcallback(obj,evd)
%   newView = round(get(evd.Axes,'View'));
%   msgbox(sprintf('The new view is [%d %d].',newView));
%
%   See also ZOOM, PAN.

%   rotate3d on enables  text feedback
%   rotate3d ON disables text feedback.

%   Revised by Rick Paxson 10-25-96
%   Clay M. Thompson 5-3-94
%   Copyright 1984-2010 The MathWorks, Inc.

% rotate style is '-view' | '-orbit'
% Undocumented syntax used by TOOLSMENUFCN
%  ROTATE3D(FIG,'setstyle',STYLE); where STYLE = '-view'|'-orbit
%  OUT = ROTATE3D(FIG,'getstyle')  '-view'|'-orbit'

if nargin>=1
    if ishghandle(varargin{1})
        hTarget = varargin{1};
        if ishghandle(hTarget,'figure')
            hFig = hTarget;
        elseif ishghandle(hTarget,'axes')
            hFig = ancestor(hTarget,'figure');
        else
            error('MATLAB:rotate3d:InvalidHandle', 'Invalid handle');
        end
    else
        hFig = gcf;
        hTarget = hFig;
    end
else
    hFig = gcf;
    hTarget = hFig;
end

if(nargin == 0)
    if nargout==0
        setState(hTarget,'toggle',getStyle(hFig));
    else
        out = localGetObj(hFig);
    end
elseif nargin==1
    arg = varargin{1};
    if any(ishghandle(arg))
        if nargout == 0
            setState(arg,'toggle',getStyle(hFig))
        else
            out = localGetObj(arg);
        end
    else
        % Short circuit the operation to prevent the rotate3d axes from being
        % created unnecessarily
        if strcmpi(arg,'off') && ~locIsOn(hFig)
            return;
        end
        switch(lower(arg)) % how much performance hit here
        case 'on'
            setState(hTarget,arg,getStyle(hFig));
        case 'off'
            setState(hTarget,arg,getStyle(hFig));
        otherwise
            error('MATLAB:rotate3d:ActionStringUnknown', 'Unknown action string.');
        end
    end
elseif nargin>=2
    arg2 = varargin{2};
    % Short circuit the operation to prevent the rotate3d axes from being
    % created unnecessarily
    if strcmpi(arg2,'off') && ~locIsOn(hFig)
        return;
    end
    if nargin<3
        rotatestyle = getStyle(hFig);
    else
        rotatestyle = varargin{3};
    end
    switch(lower(arg2)) % how much performance hit here
        case 'on'
            setState(hTarget,arg2,rotatestyle)
        case 'off'
            setState(hTarget,arg2,rotatestyle);
        case 'setstyle'
            setStyle(hTarget,rotatestyle);
        case 'getstyle'
            out = getStyle(hTarget);
            return;
        otherwise
            error('MATLAB:rotate3d:UnknownString', 'Unknown action string.');
    end
end

%----------------------------------
function hRotate = localGetObj(hObj)
% Return the rotate accessor object, if it exists.
hFig = ancestor(hObj,'figure');
hMode = locGetMode(hFig);
if ~isfield(hMode.ModeStateData,'accessor') ||...
        ~ishandle(hMode.ModeStateData.accessor)
    hRotate = graphics.rotate3d(hMode);
    hMode.ModeStateData.accessor = hRotate;
else
    hRotate = hMode.ModeStateData.accessor;
end

%----------------------------------
% Get the rotate style
function style = getStyle(target)

if ishghandle(target,'axes')
    fig = ancestor(target, 'figure');
else   % otherwise, allow any axis in this figure
    fig = target;
end
rotateMode = locGetMode(fig);
style = rotateMode.ModeStateData.rotatestyle;

%--------------------------------
% Set the rotate style.
function setStyle(target,rotatestyle)

if ishghandle(target,'axes')
    fig = ancestor(target, 'figure');
else   % otherwise, allow any axis in this figure
    fig = target;
end
rotateMode = locGetMode(fig);
rotateMode.ModeStateData.rotatestyle = rotatestyle;

%--------------------------------
% Set activation state. Options on, off
function setState(target,state,rotatestyle)

% if the target is an axis, restrict to that
if strcmp(get(target,'Type'),'axes')
    hAxes = target;
    fig = ancestor(hAxes, 'figure');
else   % otherwise, allow any axis in this figure
    hAxes = [];
    fig = target;
end
textState = 1;

% toggle
if(strcmp(state,'toggle'))
    if(locIsOn(fig))
        state = 'off';
    else
        state = 'on';
    end
% turn on
elseif (strcmpi(state,'on'))
    if(strcmp(state,'on'))
        textState = 1;
    else
        textState = 0;
    end
    state = 'on';
% turn off
elseif(strcmpi(state,'off'))
    state = 'off';
end

if strcmpi(state,'on')
    rotateMode = locGetMode(fig);
    rotateMode.ModeStateData.rotatestyle = rotatestyle;
    rotateMode.ModeStateData.destAxis = hAxes;
    rotateMode.ModeStateData.textState = textState;
    activateuimode(fig,'Exploration.Rotate3d');
else 
    if isactiveuimode(fig,'Exploration.Rotate3d')
        activateuimode(fig,'');
    end
end

%--------------------------------
function [out] = locIsOn(fig)

out = isactiveuimode(fig,'Exploration.Rotate3d');

%-----------------------------------------------%
function [rdata] = locGetMode(hFig)

rdata = getuimode(hFig,'Exploration.Rotate3d');
if isempty(rdata)
    rdata = uimode(hFig,'Exploration.Rotate3d');
    localRefreshStruct(rdata);
    set(rdata,'WindowButtonDownFcn',{@rotaButtonDownFcn,rdata});
    set(rdata,'WindowButtonUpFcn','');
    set(rdata,'WindowButtonMotionFcn',{@rotaUpMotionFcn,rdata});
    set(rdata,'WindowFocusLostFcn',{@locWindowFocusLostFcn,rdata});
    set(rdata,'KeyPressFcn',{@rotaKeyPressFcn,rdata});
    set(rdata,'KeyReleaseFcn',{@locKeyReleaseFcn,rdata});
    set(rdata,'ModeStartFcn',{@localDoRotateOn,rdata});
    set(rdata,'ModeStopFcn',{@localDoRotateOff,rdata});
end

%--------------------------------------------------------------------%
function localRefreshStruct(rdata)
%Refresh the mode data structure
hFig = rdata.FigureHandle;
rdata.UIContextMenu = localUICreateDefaultContextMenu(rdata);
plotedit(hFig,'locktoolbarvisibility');
curax = get(hFig,'currentaxes');
rdata.ModeStateData.destAxis = [];
rdata.ModeStateData.rotatestyle = '-orbit';
% Axis that is being rotated (target axis)
rdata.ModeStateData.targetAxis = [];
% Motion gain
rdata.ModeStateData.GAIN = 0.4;
% Point where the button down happened
rdata.ModeStateData.oldPt = [];
% Previous point
rdata.ModeStateData.prevPt = [];
rdata.ModeStateData.oldAzEl = [];
% Data points for the outline box.
rdata.ModeStateData.outlineData = [0 0 1 0;0 1 1 0;1 1 1 0;1 1 0 1;...
    0 0 0 1;0 0 1 0; 1 0 1 0;1 0 0 1;0 0 0 1;0 1 0 1;1 1 0 1;1 0 0 1;...
    0 1 0 1;0 1 1 0; NaN NaN NaN NaN;1 1 1 0;1 0 1 0]';
rdata.ModeStateData.textBoxText = [];
rdata.ModeStateData.textState = 1;
%where do we put the X at zmin or zmax? 0 means zmin, 1 means zmax.
rdata.ModeStateData.crossPos = 0;
rdata.ModeStateData.scaledData = rdata.ModeStateData.outlineData;
% If we are here with a valid rotate axes, delete it.
if isfield(rdata.ModeStateData,'rotateAxes') && ...
        ~isempty(rdata.ModeStateData.rotateAxes) && ...
        ishghandle(rdata.ModeStateData.rotateAxes)
    delete(rdata.ModeStateData.rotateAxes);
end
if ~feature('HGUsingMATLABClasses')
    extraPV = {'Drawmode','fast'};
else
    extraPV = {};
end
rdata.ModeStateData.rotateAxes = axes('Parent',hFig,'Visible','off',...
    'HandleVisibility','off','HitTest','off',extraPV{:});
set(rdata.ModeStateData.rotateAxes,'Tag','MATLAB_Rotate3D_Axes');
set(rdata.ModeStateData.rotateAxes,'Visible','off');
nondataobj = [];
setappdata(rdata.ModeStateData.rotateAxes,'NonDataObject',nondataobj);
if ~feature('HGUsingMATLABClasses')
    extraPV = {'EraseMode','xor'};
else
    extraPV = {};
end
rdata.ModeStateData.outlineObj = line(rdata.ModeStateData.outlineData(1,:),...
    rdata.ModeStateData.outlineData(2,:),rdata.ModeStateData.outlineData(3,:), ...
    'Parent',rdata.ModeStateData.rotateAxes,'Visible','off','HandleVisibility','off', ...
    'Clipping','off',extraPV{:});
rdata.ModeStateData.mouse = 'off';
rdata.ModeStateData.Key = false;
rdata.ModeStateData.lastKey = '';
rdata.ModeStateData.origView = [];
rdata.ModeStateData.CustomContextMenu = [];

% Make text box.
fig_color = get(hFig, 'Color');

% if the figure color is 'none', setting the uicontrol
% backgroundcolor to white and the foreground accordingly.
if strcmp(fig_color, 'none')
    fig_color = [1 1 1];
end
rdata.ModeStateData.textBoxText = uicontrol('parent',hFig,'Units','Pixels',...
    'Position',[2 2 130 20],'Visible','off', ...
    'Style','text','BackgroundColor', fig_color,'HandleVisibility','off');
% For reverse compatibility:
tempData.textBoxText = rdata.ModeStateData.textBoxText;
set(rdata.ModeStateData.rotateAxes,'UserData',tempData);

set(double(hFig),'currentaxes',curax);

%--------------------------------------------------------------------%
function localDoRotateOn(rdata)
% Turn on rotate3d toolbar button and menu item
set(uigettool(rdata.FigureHandle,'Exploration.Rotate'),'State','on');
set(findall(rdata.FigureHandle,'Tag','figMenuRotate3D'), 'Checked','on' );

% Define appdata to avoid breaking code in
% scribefiglisten, hgsave, and figtoolset
setappdata(rdata.FigureHandle,'Rotate3dOnState','on');

%Refresh context menu
hui = get(rdata,'UIContextMenu');
if ~isempty(rdata.ModeStateData.CustomContextMenu) && ishghandle(rdata.ModeStateData.CustomContextMenu)
    set(rdata,'UIContextMenu',rdata.ModeStateData.CustomContextMenu);
else
    if ishghandle(hui)
        delete(hui);
    end
    rdata.UIContextMenu = localUICreateDefaultContextMenu(rdata);
end


%--------------------------------------------------------------------%
function localDoRotateOff(rdata)
% Turn off rotate3d toolbar button and menu item
set(uigettool(rdata.FigureHandle,'Exploration.Rotate'),'State','off');
set(findall(rdata.FigureHandle,'Tag','figMenuRotate3D'), 'Checked','off' );

% Remove appdata to avoid breaking code in
% scribefiglisten, hgsave, and figtoolset
if isappdata(rdata.FigureHandle,'Rotate3dOnState')
    rmappdata(rdata.FigureHandle,'Rotate3dOnState');
end
hui = rdata.UIContextMenu;
if (~isempty(hui) && ishghandle(hui)) && ...
        (isempty(rdata.ModeStateData.CustomContextMenu) || ~ishghandle(rdata.ModeStateData.CustomContextMenu))
    delete(hui);
    rdata.UIContextMenu = '';
end

%--------------------------------------------------------------------%
% Button down callback
function rotaButtonDownFcn(hFig,evd,rotaObj)

if ~ishghandle(rotaObj.UIContextMenu)
    %We lost the context-menu and are likely in a bad state.
    localRefreshStruct(rotaObj);
end

axes_found = 0; %#ok

% Activate axes by making it gca
% This is legacy behavior, removing might break code
ax = localFindAxes(hFig,evd);
sel_type = lower(get(hFig,'selectiontype'));
if ~isempty(ax) && localInBounds(ax)
    axes_found = 1;
    set(hFig,'currentaxes',ax);
else
    if strcmp(sel_type,'alt')
        rotaObj.ShowContextMenu = false;
    end
    return;
end

if axes_found==0
    if strcmp(sel_type,'alt')
        rotaObj.ShowContextMenu = false;
    end
    return;
end

rotaObj.ModeStateData.mouse = 'on';
if ~isempty(rotaObj.ModeStateData.lastKey)
    locEndKey(ax,rotaObj);
    rotaObj.ModeStateData.lastKey = '';
end

if (~(isempty(rotaObj.ModeStateData.destAxis)) && rotaObj.ModeStateData.destAxis ~= ax)
    if strcmp(sel_type,'alt')
        rotaObj.ShowContextMenu = false;
    end    
    return;
end

rotaObj.ModeStateData.targetAxis = ax;

% Register view with axes for "Reset to Original View" support
resetplotview(localVectorizeAxes(ax),'InitializeCurrentView');

% Reset plot if double click
if strcmpi(sel_type,'open')
    rotaObj.fireActionPreCallback(localConstructEvd(rotaObj.ModeStateData.targetAxis));
    resetplotview(localVectorizeAxes(ax),'ApplyStoredView');
    rotaObj.fireActionPostCallback(localConstructEvd(rotaObj.ModeStateData.targetAxis));
    return;
end

if strcmp(sel_type,'alt')
    % Make sure the appropriate entries in the context menu are checked
    stretchHandle = findall(rotaObj.UIContextMenu,'Tag','StretchToFill');
    fixedHandle = findall(rotaObj.UIContextMenu,'Tag','FixedAspectRatio');
    if strcmp(get(ax,'DataAspectRatioMode'),'auto')
        set(stretchHandle,'Checked','on');
        set(fixedHandle,'Checked','off');
    else
        set(stretchHandle,'Checked','off');
        set(fixedHandle,'Checked','on');
    end
    plotBoxHandle = findall(rotaObj.UIContextMenu,'Tag','Rotate_Fast');
    continuousHandle = findall(rotaObj.UIContextMenu,'Tag','Rotate_Continuous');
    if strcmp(rotaObj.ModeStateData.rotatestyle,'-orbit')
        set(plotBoxHandle,'Checked','off');
        set(continuousHandle,'Checked','on');
    else
        set(plotBoxHandle,'Checked','on');
        set(continuousHandle,'Checked','off');
    end
    return;
end

currPt = get(hFig,'CurrentPoint');
currPt = hgconvertunits(hFig,[currPt 0 0],get(hFig,'Units'),'Pixels',hFig);
rotaObj.ModeStateData.oldPt = currPt(1:2);
rotaObj.ModeStateData.prevPt = rotaObj.ModeStateData.oldPt;
rotaObj.ModeStateData.oldAzEl = get(rotaObj.ModeStateData.targetAxis,'View');
rotaObj.ModeStateData.origAzEl = rotaObj.ModeStateData.oldAzEl;

% Map azel from -180 to 180.
rotaObj.ModeStateData.oldAzEl = rem(rem(rotaObj.ModeStateData.oldAzEl+360,360)+180,360)-180;
if abs(rotaObj.ModeStateData.oldAzEl(2))>90
    % Switch az to other side.
    rotaObj.ModeStateData.oldAzEl(1) = rem(rem(rotaObj.ModeStateData.oldAzEl(1)+180,360)+180,360)-180;
    % Update el
    rotaObj.ModeStateData.oldAzEl(2) = sign(rotaObj.ModeStateData.oldAzEl(2))*(180-abs(rotaObj.ModeStateData.oldAzEl(2)));
end

setOutlineObjToFitAxes(rotaObj);
copyAxisProps(rotaObj.ModeStateData.targetAxis,rotaObj.ModeStateData.rotateAxes);

if(rotaObj.ModeStateData.oldAzEl(2) < 0)
    rotaObj.ModeStateData.CrossPos = 1;
    set(rotaObj.ModeStateData.outlineObj,'ZData',rotaObj.ModeStateData.scaledData(4,:));
else
    rotaObj.ModeStateData.CrossPos = 0;
    set(rotaObj.ModeStateData.outlineObj,'ZData',rotaObj.ModeStateData.scaledData(3,:));
end

if(rotaObj.ModeStateData.textState)
    fig_color = get(hFig,'Color');
    % if the figure color is 'none', setting the uicontrol
    % backgroundcolor to white and the foreground accordingly.
    if strcmp(fig_color, 'none')
        fig_color = [1 1 1];
    end
    c = sum([.3 .6 .1].*fig_color);
    % Make sure the box appears in a reasonable place compared to the axes:
    set(rotaObj.ModeStateData.textBoxText,'Parent',get(ax,'Parent'));
    set(rotaObj.ModeStateData.textBoxText,'BackgroundColor',fig_color);
    if(c > .5)
        set(rotaObj.ModeStateData.textBoxText,'ForegroundColor',[0 0 0]);
    else
        set(rotaObj.ModeStateData.textBoxText,'ForegroundColor',[1 1 1]);
    end
    set(rotaObj.ModeStateData.textBoxText,'Visible','on');
end

if strcmpi(rotaObj.ModeStateData.rotatestyle,'-view')
    set(rotaObj.ModeStateData.outlineObj,'Visible','on');
end

rotaObj.fireActionPreCallback(localConstructEvd(rotaObj.ModeStateData.targetAxis));
set(rotaObj,'WindowButtonMotionFcn',{@rotaMotionFcn,rotaObj});
set(rotaObj,'WindowButtonUpFcn',{@rotaButtonUpFcn,rotaObj});

%--------------------------------------------------------------------%
% Button up callback
function rotaButtonUpFcn(hFig,evd,rotaObj) %#ok<INUSL>

set([rotaObj.ModeStateData.outlineObj rotaObj.ModeStateData.textBoxText],'Visible','off');
rotaObj.ModeStateData.oldAzEl = get(rotaObj.ModeStateData.rotateAxes,'View');
set(rotaObj,'WindowButtonMotionFcn',{@rotaUpMotionFcn,rotaObj});
set(rotaObj,'WindowButtonUpFcn','');
rotaObj.ModeStateData.mouse = 'off';

% Get axes
hAxes = rotaObj.ModeStateData.targetAxis;

% If the axes is empty, short-circuit:
if isempty(hAxes) || ~ishghandle(hAxes)
    return;
end

% Call 'view' command
origView = rotaObj.ModeStateData.origAzEl;
newView = rotaObj.ModeStateData.oldAzEl;

% Set the view
view(hAxes,newView);

if ~rotaObj.ModeStateData.Key
    localCreateUndo(hAxes,origView,newView);
end
rotaObj.ModeStateData.Key = false;
rotaObj.fireActionPostCallback(localConstructEvd(rotaObj.ModeStateData.targetAxis));

%--------------------------------------------------------------------%
function rotaKeyPressFcn(obj,evd,hMode) %#ok
% Rotate if the user clicks on arrow keys

consumekey = false;

% Exit early if invalid event data
if ~isstruct(evd) || ~isfield(evd,'Key') || ...
        isempty(evd.Key) || ~isfield(evd,'Character')
    return;
end

% Parse key press
fig = hMode.FigureHandle;
ax = get(fig,'CurrentAxes');
if ishghandle(ax)
    b = hggetbehavior(ax,'Rotate3d','-peek');
    if any(ishandle(b)) && ~get(b,'Enable')
        % ignore this axes
        ax = [];
        % 'NonDataObject' & 'unrotatable' are legacy flags
    elseif isappdata(ax,'unrotatable') ...
            || isappdata(ax,'NonDataObject')
        ax = [];
    end
end

% If the mouse is active, the mouse wins
if ~strcmpi(hMode.ModeStateData.mouse,'off')
    return;
end

if ishghandle(ax)
    % Make sure there is something to undo to:
    if ~strcmpi(hMode.ModeStateData.lastKey,evd.Key) && locIsArrowKey(evd.Key)
        % If we are changing keys, capture this
        if ~isempty(hMode.ModeStateData.lastKey)
            locEndKey(ax,hMode);
        end
        hMode.ModeStateData.origView = get(ax,'View');
        hMode.ModeStateData.lastKey = evd.Key;
    end

    switch evd.Key
        case 'leftarrow'
            hMode.ModeStateData.targetAxis = ax;
            resetplotview(localVectorizeAxes(ax),'InitializeCurrentView');
            hMode.fireActionPreCallback(localConstructEvd(ax));
            hMode.ModeStateData.origAzEl = get(ax,'View');
            view(hMode.ModeStateData.rotateAxes, hMode.ModeStateData.origAzEl + [2 0]);
            hMode.ModeStateData.Key = true;
            rotaButtonUpFcn(fig,[],hMode);  consumekey = true;
            hMode.fireActionPostCallback(localConstructEvd(ax));
        case 'rightarrow'
            hMode.ModeStateData.targetAxis = ax;
            resetplotview(localVectorizeAxes(ax),'InitializeCurrentView');
            hMode.fireActionPreCallback(localConstructEvd(ax));
            hMode.ModeStateData.origAzEl = get(ax,'View');
            view(hMode.ModeStateData.rotateAxes, hMode.ModeStateData.origAzEl + [-2 0]);
            hMode.ModeStateData.Key = true;
            rotaButtonUpFcn(fig,[],hMode);  consumekey = true;
            hMode.fireActionPostCallback(localConstructEvd(ax));
        case 'uparrow'
            hMode.ModeStateData.targetAxis = ax;
            resetplotview(localVectorizeAxes(ax),'InitializeCurrentView');
            hMode.fireActionPreCallback(localConstructEvd(ax));
            hMode.ModeStateData.origAzEl = get(ax,'View');
            view(hMode.ModeStateData.rotateAxes, hMode.ModeStateData.origAzEl + [0 -2]);
            hMode.ModeStateData.Key = true;
            rotaButtonUpFcn(fig,[],hMode);  consumekey = true;
            hMode.fireActionPostCallback(localConstructEvd(ax));
        case 'downarrow'
            hMode.ModeStateData.targetAxis = ax;            
            resetplotview(localVectorizeAxes(ax),'InitializeCurrentView');
            hMode.fireActionPreCallback(localConstructEvd(ax));
            hMode.ModeStateData.origAzEl = get(ax,'View');
            view(hMode.ModeStateData.rotateAxes, hMode.ModeStateData.origAzEl + [0 2]);
            hMode.ModeStateData.Key = true;
            rotaButtonUpFcn(fig,[],hMode);  consumekey = true;
            hMode.fireActionPostCallback(localConstructEvd(ax));
        case 'z'
            if strcmpi(evd.Modifier,'control')
                consumekey = true;
                hUndoMenu = findall(fig,'Type','UIMenu','Tag','figMenuEditUndo');
                if isempty(hUndoMenu)
                    % Undo command
                    uiundo(hMode.FigureHandle,'execUndo');
                end
                % Reset the target axis:
                hMode.ModeStateData.targetAxis = [];    
            end
        case 'y'
            if strcmpi(evd.Modifier,'control')
                consumekey = true;
                hRedoMenu = findall(fig,'Type','UIMenu','Tag','figMenuEditRedo');
                if isempty(hRedoMenu)
                    % Redo command
                    uiundo(hMode.FigureHandle,'execRedo');
                end
                % Reset the target axis:
                hMode.ModeStateData.targetAxis = [];
            end
    end
end

if ~consumekey
    graph2dhelper('forwardToCommandWindow',fig,evd);
end

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

ax = hMode.ModeStateData.targetAxis;
rotateExecuted = false;
if ~isempty(ax) && ishghandle(ax)
    % We are only concerned with the arrow keys:
    newKey = evd.Key;
    if locIsArrowKey(newKey) && strcmpi(newKey, hMode.ModeStateData.lastKey)
        rotateExecuted = true;
    end
end
if rotateExecuted
    locEndKey(ax,hMode)
    hMode.ModeStateData.lastKey = '';
    % Update the view information:
    hMode.ModeStateData.origView = get(ax,'View');
    hMode.ModeStateData.targetAxis = [];
end

%------------------------------------------------%
function locWindowFocusLostFcn(obj,evd,hMode) %#ok<INUSL>
% Focus lost callback. This will reset the figure state with respect to the
% key presses

if ~ishandle(hMode)
    return;
end
ax = hMode.ModeStateData.targetAxis;
if ~isempty(ax) && ishghandle(ax)
    locEndKey(ax,hMode)
    hMode.ModeStateData.lastKey = '';
    % Update the view information:
    hMode.ModeStateData.origView = get(ax,'View');
    hMode.ModeStateData.targetAxis = [];    
end

%------------------------------------------------%
function locEndKey(ax,hMode)
% Register a key release with undo

newView = get(ax,'View');
origView = hMode.ModeStateData.origView;
if ~isempty(origView) && ~isequal(origView,newView)
    localCreateUndo(ax,origView,newView);
end

%--------------------------------------------------------------------%
function localCreateUndo(hAxes,origView,newView)
% Register with undo

hFig = ancestor(hAxes,'figure');
% We need to be robust against axes deletions. To this end, operate in
% terms of the object's proxy value.
proxyVal = plotedit({'getProxyValueFromHandle',hAxes});

cmd.Function = @localDoUndo;
cmd.Varargin = {hFig,proxyVal,newView};
cmd.Name = 'Rotate';
cmd.InverseFunction = @localDoUndo;
cmd.InverseVarargin = {hFig,proxyVal,origView};
uiundo(hFig,'function',cmd);

%--------------------------------------------------------------------%
function localDoUndo(hFig,proxyVal,newView)

hAxes = plotedit({'getHandleFromProxyValue',hFig,proxyVal});
if ishghandle(hAxes)
    view(hAxes,newView);
end

%--------------------------------------------------------------------%
function rotaUpMotionFcn(obj,evd,rotaObj) %#ok

hFigure = evd.Source;
% Get current point in figure units
curr_units = hgconvertunits(hFigure,[0 0 evd.CurrentPoint],...
    'pixels',get(hFigure,'Units'),hFigure);
curr_units = curr_units(3:4);
    
set(hFigure,'CurrentPoint',curr_units);
hAx = localFindAxes(hFigure,evd);
if ~isempty(hAx) && localInBounds(hAx)
    if (~(isempty(rotaObj.ModeStateData.destAxis)) && rotaObj.ModeStateData.destAxis ~= hAx)
        setptr(hFigure,'arrow');
    else
        setptr(hFigure,'rotate');
    end
else
    setptr(hFigure,'arrow');
end

%--------------------------------------------------------------------%
% Mouse motion callback
function rotaMotionFcn(obj,evd,rotaObj) %#ok<INUSL>

if strcmp(rotaObj.ModeStateData.rotatestyle,'-orbit')
    localRotateOrbitMotionFcn(rotaObj,evd);
else
    localRotateViewMotionFcn(rotaObj,evd);
end

%--------------------------------------------------------------------%
function localRotateViewMotionFcn(rotaObj,evd)
% Change the axes view as the user moves the mouse

new_pt = evd.CurrentPoint;
old_pt = rotaObj.ModeStateData.oldPt;
dx = new_pt(1) - old_pt(1);
dy = new_pt(2) - old_pt(2);

new_azel = mappingFunction(rotaObj, dx, dy);
set(rotaObj.ModeStateData.rotateAxes,'View',new_azel);
if(new_azel(2) < 0 && rotaObj.ModeStateData.crossPos == 0)
    set(rotaObj.ModeStateData.outlineObj,'ZData',rotaObj.ModeStateData.scaledData(4,:));
    rotaObj.ModeStateData.crossPos = 1;
end
if(new_azel(2) > 0 && rotaObj.ModeStateData.crossPos == 1) 
    set(rotaObj.ModeStateData.outlineObj,'ZData',rotaObj.ModeStateData.scaledData(3,:));
    rotaObj.ModeStateData.crossPos = 0;
end
if(rotaObj.ModeStateData.textState)
    set(rotaObj.ModeStateData.textBoxText,'String',sprintf('Az: %4.0f El: %4.0f',new_azel));
end

%--------------------------------------------------------------------%
function localRotateOrbitMotionFcn(rotaObj,evd)
% Orbit the camera as the user moves the mouse

% Get necessary handles
hAxes = rotaObj.ModeStateData.targetAxis;

% Determine change in pixel position
pt = rotaObj.ModeStateData.oldPt;
% The event data current point is always passed in pixels.
new_pt = evd.CurrentPoint;
dx = new_pt(1) - pt(1);
dy = new_pt(2) - pt(2);

% Orbit the camera, assume z based coordinate system
new_azel = mappingFunction(rotaObj, dx, dy);
set(rotaObj.ModeStateData.rotateAxes,'View',new_azel);
set(hAxes,'View',new_azel);

% Update the azimuth/elevation display
if(rotaObj.ModeStateData.textState)
    axView = get(hAxes,'View');
    set(rotaObj.ModeStateData.textBoxText,'String',sprintf('Az: %4.0f El: %4.0f',axView));
end

% Required for doublebuffer 'on' to avoid flashing
drawnow expose;

% Update recent point for next time
rotaObj.ModeStateData.prevPt = new_pt;

%--------------------------------------------------------------------%
% Map a dx dy to an azimuth and elevation
function azel = mappingFunction(rotaObj, dx, dy)
delta_az = round(rotaObj.ModeStateData.GAIN*(-dx));
delta_el = round(rotaObj.ModeStateData.GAIN*(-dy));
azel(1) = rotaObj.ModeStateData.oldAzEl(1) + delta_az;
azel(2) = min(max(rotaObj.ModeStateData.oldAzEl(2) + 2*delta_el,-90),90);
if abs(azel(2))>90
    % Switch az to other side.
    azel(1) = rem(rem(azel(1)+180,360)+180,360)-180; % Map new az from -180 to 180.
    % Update el
    azel(2) = sign(azel(2))*(180-abs(azel(2)));
end

%--------------------------------------------------------------------%
% Scale data to fit target axes limits
function setOutlineObjToFitAxes(rotaObj)
ax = rotaObj.ModeStateData.targetAxis;
x_extent = get(ax,'XLim');
y_extent = get(ax,'YLim');
z_extent = get(ax,'ZLim');
X = rotaObj.ModeStateData.outlineData;
X(1,:) = X(1,:)*diff(x_extent) + x_extent(1);
X(2,:) = X(2,:)*diff(y_extent) + y_extent(1);
X(3,:) = X(3,:)*diff(z_extent) + z_extent(1);
X(4,:) = X(4,:)*diff(z_extent) + z_extent(1);

outlineObj = rotaObj.ModeStateData.outlineObj;
if isempty(outlineObj) || ~ishghandle(outlineObj)
    % If the outline object is invalid, we must refresh the structure.
    % First, we need to store the current state of the rotation:
    oldPt = rotaObj.ModeStateData.oldPt;
    prevPt = rotaObj.ModeStateData.prevPt;
    oldAzEl = rotaObj.ModeStateData.oldAzEl;
    origAzEl = rotaObj.ModeStateData.origAzEl;
    localRefreshStruct(rotaObj);
    rotaObj.ModeStateData.targetAxis = ax;
    rotaObj.ModeStateData.oldPt = oldPt;
    rotaObj.ModeStateData.prevPt = prevPt;
    rotaObj.ModeStateData.oldAzEl = oldAzEl;
    rotaObj.ModeStateData.origAzEl = origAzEl;
end
set(rotaObj.ModeStateData.outlineObj,'XData',X(1,:),'YData',X(2,:),'ZData',X(3,:));
rotaObj.ModeStateData.scaledData = X;

%-----------------------------------------------%
function evd = localConstructEvd(hAxes)
% Construct event data for post callback
evd.Axes = hAxes;

%--------------------------------------------------------------------%
% Copy properties from one axes to another.
function copyAxisProps(original, dest)
props = {
    'DataAspectRatio'
    'DataAspectRatioMode'
    'CameraViewAngle'
    'CameraViewAngleMode'
    'XLim'
    'YLim'
    'ZLim'
    'PlotBoxAspectRatio'
    'PlotBoxAspectRatioMode'
    'Units'
    'Position'
    'View'
    'Projection'
    'Parent'
    };
values = get(original,props);
set(dest,props,values);

%--------------------------------------------------------------------%
function localUIContextMenuCallback(obj,~,rotaObj)

% Get axes handle
hFig = rotaObj.FigureHandle;
% If we are here, then we clicked on something contained in an
% axes. Rather than calling HITTEST, we will get this information
% manually.
hAxes = ancestor(rotaObj.FigureState.CurrentObj.Handle,'axes');
if isempty(hAxes)
    hAxes = get(hFig,'CurrentAxes');
    if isempty(hAxes)
        return;
    end
end

switch get(obj,'tag')
    case 'Reset';
        % Reset the number of buttons down
        rotaObj.fireActionPreCallback(localConstructEvd(rotaObj.ModeStateData.targetAxis));
        resetplotview(localVectorizeAxes(hAxes),'ApplyStoredView');
        rotaObj.fireActionPostCallback(localConstructEvd(rotaObj.ModeStateData.targetAxis));
    case 'SnapToXY';
        view(hAxes,0,90);
    case 'SnapToXZ';
        view(hAxes,0,0);
    case 'SnapToYZ';
        view(hAxes,90,0);
end

%--------------------------------------------------------------------%
function [hui] = localUICreateDefaultContextMenu(rotaObj)

hui = uicontextmenu('Parent',rotaObj.FigureHandle);

props = [];
props.Label = 'Reset to Original View';
props.Parent = hui;
props.Separator = 'off';
props.Tag = 'Reset';
props.Callback = {@localUIContextMenuCallback,rotaObj};
uimenu(props);

props = [];
props.Label = 'Go to X-Y view';
props.Parent = hui;
props.Tag = 'SnapToXY';
props.Separator = 'on';
props.Callback = {@localUIContextMenuCallback,rotaObj};
uimenu(props);

props = [];
props.Label = 'Go to X-Z view';
props.Parent = hui;
props.Tag = 'SnapToXZ';
props.Separator = 'off';
props.Callback = {@localUIContextMenuCallback,rotaObj};
uimenu(props);

props = [];
props.Label = 'Go to Y-Z view';
props.Parent = hui;
props.Tag = 'SnapToYZ';
props.Separator = 'off';
props.Callback = {@localUIContextMenuCallback,rotaObj};
uimenu(props);

props = [];
props.Label = 'Rotate Options';
props.Parent = hui;
props.Separator = 'on';
props.Callback = '';
u2 = uimenu(props);

props = [];
props.Label = 'Plot Box Rotate';
props.Parent = u2;
props.Separator = 'off';
props.Checked = 'off';
props.Tag = 'Rotate_Fast';
p(1) = uimenu(props);

props = [];
props.Label = 'Continuous Rotate';
props.Parent = u2;
props.Separator = 'off';
props.Checked = 'on';
props.Tag = 'Rotate_Continuous';
p(2) = uimenu(props);

set(p(1:2),'Callback',{@localSwitchRotateStyle,rotaObj});

props.Label = 'Stretch-to-Fill Axes';
props.Parent = u2;
props.Separator = 'on';
props.Tag = 'StretchToFill';
p(1) = uimenu(props);

props.Label = 'Fixed Aspect Ratio Axes';
props.Parent = u2;
props.Separator = 'off';
props.Tag = 'FixedAspectRatio';
p(2) = uimenu(props);

set(p(1:2),'Callback',{@localStretchToFill,rotaObj});

%--------------------------------------------------------------------%
function localStretchToFill(obj,~,rotaObj)
% Set stretch to fill on/off

% If we are here, then we clicked on something contained in an
% axes. Rather than calling HITTEST, we will get this information
% manually.
hAxes = ancestor(rotaObj.FigureState.CurrentObj.Handle,'axes');
if ~any(ishghandle(hAxes))
    return;
end

tag = get(obj,'Tag');
if strcmpi(tag,'FixedAspectRatio')
    axis(hAxes,'vis3d');
elseif strcmpi(tag,'StretchToFill')
    axis(hAxes,'normal');
end

%--------------------------------------------------------------------%
function localSwitchRotateStyle(obj,evd,rotaObj) %#ok
% Switch rotate style

tag = get(obj,'Tag');

% Radio buttons
if strcmp(tag,'Rotate_Continuous')
    rotaObj.ModeStateData.rotatestyle = '-orbit';
elseif strcmp(tag,'Rotate_Fast')
    rotaObj.ModeStateData.rotatestyle = '-view';
end

%--------------------------------------------------------------------%
function [ax] = localFindAxes(fig,evd)
% Return the axes that the mouse is currently over
% Return empty if no axes found (i.e. axes has hidden handle)

if ~any(ishghandle(fig))
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
   b = hggetbehavior(candidate_ax,'Rotate3d','-peek');
   if any(ishandle(b)) && ~get(b,'Enable')
        % ignore this axes      

   % 'NonDataObject' & 'unrotatable' are legacy flags   
   elseif ~isappdata(candidate_ax,'unrotatable') ...
              && ~isappdata(candidate_ax,'NonDataObject')
       ax = candidate_ax;
       break;
   end
end

%--------------------------------------------------------------------%
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