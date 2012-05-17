function schema
% uimode class: This class is the basis of any interactive modes within
% the context of the MATLAB figure window.

%   Copyright 2005-2010 The MathWorks, Inc.

hPk = findpackage('uitools');
cls = schema.class(hPk,'uimode');

%Public properties which are inherited by other modes:
%Start by defining the mode callbacks
p = schema.prop(cls,'WindowButtonDownFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowButtonDownFcn'});

p = schema.prop(cls,'WindowButtonUpFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowButtonUpFcn'});

p = schema.prop(cls,'WindowButtonMotionFcn','MATLAB callback');
set(p,'SetFunction',{@setMotionFcn});

p = schema.prop(cls,'WindowKeyPressFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowKeyPressFcn'});

p = schema.prop(cls,'WindowKeyReleaseFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowKeyReleaseFcn'});

p = schema.prop(cls,'WindowScrollWheelFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'WindowScrollWheelFcn'});

p = schema.prop(cls,'KeyPressFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'KeyPressFcn'});

p = schema.prop(cls,'KeyReleaseFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'KeyReleaseFcn'});

%Undocumented focus lost callback
p = schema.prop(cls,'WindowFocusLostFcn','MATLAB callback');
set(p,'SetFunction',{@setJavaCallback,'FocusLost'});
p.Visible = 'off';

p = schema.prop(cls,'WindowJavaListeners','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

%Determine whether the mode will take control of the WindowButtonMotionFcn
%callback
p = schema.prop(cls,'WindowButtonMotionFcnInterrupt','MATLAB array'); %logical
set(p,'SetFunction',{@readOnlyWhileRunning,'WindowButtonMotionFcnInterrupt'});
set(p,'FactoryValue',false);

%Determine whether the mode will suspend UICONTROL object callbacks
p = schema.prop(cls,'UIControlInterrupt','MATLAB array'); %logical
set(p,'SetFunction',{@readOnlyWhileRunning,'UIControlInterrupt'});
set(p,'FactoryValue',false);

%Add a listener to take care of the UIControl suspension
p = schema.prop(cls,'UIControlSuspendListener','MATLAB array');
set(p,'Visible','off');

p = schema.prop(cls,'UIControlSuspendJavaListener','MATLAB array');
set(p,'Visible','off');

p = schema.prop(cls,'KeyPressFcn','MATLAB callback');
set(p,'SetFunction',{@setCallbackFcn,'KeyPressFcn'});

schema.prop(cls,'ModeStartFcn','MATLAB callback');

schema.prop(cls,'ModeStopFcn','MATLAB callback');

p = schema.prop(cls,'ShowContextMenu','MATLAB array'); %logical
set(p,'FactoryValue',true);

p = schema.prop(cls,'Name','MATLAB array');
p.AccessFlags.PublicSet = 'off';

% A mode may be specified to be a one-shot mode. This means that after a
% Button-Up event, the mode will be turned off.
p = schema.prop(cls,'IsOneShot','bool');
p.FactoryValue = false;
set(p,'SetFunction',{@readOnlyWhileRunning,'IsOneShot'});

p = schema.prop(cls,'UseContextMenu','on/off');
set(p,'FactoryValue','on');

p = schema.prop(cls,'FigureHandle','MATLAB array');
p.AccessFlags.PublicSet = 'off';

%Callback to determine whether the object's button down function should be
%used
schema.prop(cls,'ButtonDownFilter','MATLAB callback');

%Listeners in support of the ButtonDownFilter:
p = schema.prop(cls,'WindowListenerHandles', 'MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';

%Caches for the callback functions used during a filtered callback.
p = schema.prop(cls,'UserButtonUpFcn','MATLAB callback');
p.Visible = 'off';

p = schema.prop(cls, 'PreviousWindowState', 'MATLAB callback');
p.Visible = 'off';

%Pre and post callback functions
p = schema.prop(cls,'ActionPreCallback','MATLAB callback');
p.Visible = 'off';
p = schema.prop(cls,'ActionPostCallback','MATLAB callback');
p.Visible = 'off';

%Set the default context menu handle
schema.prop(cls,'UIContextMenu','MATLAB array');

%Determine whether the mode can be interrupted by another mode
p = schema.prop(cls,'Blocking','MATLAB array'); %logical
set(p,'FactoryValue',false);
p.Visible = 'off';

%Properties that can be inherited, but will not be visible
p = schema.prop(cls, 'WindowMotionFcnListener', 'MATLAB array');
p.Visible = 'off';

p = schema.prop(cls,'FigureState','MATLAB array');
p.Visible = 'off';

schema.prop(cls,'ModeStateData','MATLAB array');

p = schema.prop(cls,'Enable','on/off');
p.Visible = 'off';
set(p,'FactoryValue','off');
set(p,'SetFunction',@modeControl);

% Add a delete listener for the purpose of clearing context menus
p = schema.prop(cls,'DeleteListener','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Properties to facilitate mode composition:
% A mode may have a parent mode if it is being composed.
p = schema.prop(cls,'ParentMode','handle');
p.Visible = 'off';
set(p,'SetFunction',@localReparentMode);

% Similar to a mode manager, modes may have modes registered with them.
p = schema.prop(cls,'RegisteredModes','handle vector');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';

% If a mode is a container mode, it may have a default mode
p = schema.prop(cls,'DefaultUIMode','string');
p.Visible = 'off';

% A mode can only have one active child mode at a time.
p = schema.prop(cls,'CurrentMode','handle');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';

% Keep a record of listeners on the figure.
p = schema.prop(cls,'ModeListenerHandles','MATLAB array');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'off';

% Keep a binary flag around to keep track of whether we are busy activating
% or not.
p = schema.prop(cls,'BusyActivating','bool');
p.Visible = 'off';
p.AccessFlags.PublicGet = 'off';
p.FactoryValue = false;

%------------------------------------------------------------------------%
function newValue = localReparentMode(hThis,valueProposed)
% Reparent a mode object

% This property may only be set if the mode is not active
if strcmp(hThis.Enable,'on')
    error('MATLAB:uimodes:mode:ReadOnlyWhileRunning',...
        'The property "%s" is read-only while the mode is active.',propName);
end

% If the property is empty, we may be unparenting from the figure:
if isempty(hThis.ParentMode)
    hManager = uigetmodemanager(hThis.FigureHandle);
    unregisterMode(hManager,hThis);
else
    unregisterMode(hThis.ParentMode,hThis);
end

newValue = valueProposed;

%------------------------------------------------------------------------%
function newValue = readOnlyWhileRunning(hThis,valueProposed,propName)
%Enforce the property being read-only while the mode is active

if strcmp(hThis.Enable,'on')
    error('MATLAB:uimodes:mode:ReadOnlyWhileRunning',...
        'The property "%s" is read-only while the mode is active.',propName);
else
    newValue = valueProposed;
end

%----------------------------------------------------------------------%
function newValue = setMotionFcn(hThis, valueProposed)
% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

newValue = valueProposed;
if ~feature('HGUsingMATLABClasses')
    set(hThis.WindowMotionFcnListener,'Callback',valueProposed);
else
    hThis.WindowMotionFcnListener.Callback = @(obj,evd)(localEvaluateMotionCallback(obj,evd,valueProposed));
end

%----------------------------------------------------------------------%
function newValue = setJavaCallback(hThis, valueProposed, propName)
% Modify the window callback function as specified by the mode. Note: These
% properties are unprotected by a listener and may break if the java
% component's property is modified outside the context of the mode.

if ~usejava('awt')
    newValue = [];
    return;
end
newValue = hThis.setFigureCallback(hThis.FigureHandle,propName, valueProposed);

%----------------------------------------------------------------------%
function localEvaluateMotionCallback(obj,~,callback)
% First, we need to create the event data, which is empty by default. The
% event data has three components. The first is the current point in pixels.
% We will compute this based on the "PointerLocation" property of the root.
% The second is the object which the mouse is over (i.e. the result of
% hit testing). The third is the source (the figure).
rootPoint = get(0,'PointerLocation');
rootPixelPoint = hgconvertunits(obj,[rootPoint 0 0],get(0,'Units'),'pixels',0);
rootPixelPoint = rootPixelPoint(1:2);
figPos = get(obj,'Position');
figPos = hgconvertunits(obj,figPos,get(obj,'Units'),'pixels',0);

% If the frame is docked, figPos is expressed relative to the group frame.
% In this case the figPos to the lower left frame position to the get
% real screen location.
if strcmpi(get(obj,'WindowStyle'),'docked')
    lastwarn = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    fp = get(obj,'javaFrame');
    warning(lastwarn);
    p = java.awt.Point(0,0);
    javax.swing.SwingUtilities.convertPointToScreen(p,fp.getAxisComponent);
    screenPos = get(0,'ScreenSize');
    figFramePos = [p.x (screenPos(4)-p.y)-fp.getAxisComponent.getSize.height];
    figPos(1:2) = figFramePos;
end

newEvd.CurrentPoint = rootPixelPoint - figPos(1:2);
newEvd.CurrentObject = plotedit({'hittestHGUsingMATLABClasses',obj,newEvd.CurrentPoint});
newEvd.Source = obj;

% Finally, evaluate the callback
hgfeval(callback,obj,newEvd);