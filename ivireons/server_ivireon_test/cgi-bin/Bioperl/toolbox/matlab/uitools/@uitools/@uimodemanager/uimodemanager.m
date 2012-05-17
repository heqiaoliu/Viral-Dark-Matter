function [hThis] = uimodemanager(hFig)
% Constructor for the mode

%   Copyright 2005-2009 The MathWorks, Inc.

% Syntax: uitools.uimodemanager(figure)
if ~ishghandle(hFig,'figure')
    error('MATLAB:uimodes:modemanager:InvalidConstructor','First argument must be a figure handle');
end

% There can only be one mode manager per figure
if ~isprop(hFig,'ModeManager')
    if ~feature('HGUsingMATLABClasses')
        %Add an instance property to the figure which cannot be copied
        p = schema.prop(hFig,'ModeManager','handle');
        p.AccessFlags.Copy = 'off';
        p.AccessFlags.Serialize = 'off';
        p.Visible = 'off';
    else
        p = addprop(hFig,'ModeManager');
        p.Hidden = true;
        p.Transient = true;
    end
end
if isempty(get(hFig,'ModeManager')) || ~ishandle(get(hFig,'ModeManager'))
    % Constructor
    hThis = uitools.uimodemanager;
    hThis.FigureHandle = hFig;
    addlistener(hFig,'ObjectBeingDestroyed',@(obj,evd)(localDelete(hThis)));
    
    %To prevent odd behavior when copying, make sure the scribe callback
    %doesn't refer to a different figure:
    s = getappdata(hFig,'ScribeClearModeCallback');
    if ~isempty(s) && isequal(s{1},@set)
        if isa(handle(s{2}),'uitools.uimodemanager') && s{2}.FigureHandle ~= hFig
            rmappdata(hFig,'ScribeClearModeCallback');
        end
    end
    % Define listeners for window state
    window_prop = {'WindowButtonDownFcn',...
        'WindowButtonUpFcn',...
        'WindowScrollWheelFcn',...
        'WindowKeyPressFcn',...
        'WindowKeyReleaseFcn',...
        'KeyPressFcn',...
        'KeyReleaseFcn'};
    l = addlistener(hFig,window_prop,'PreSet',@(obj,evd)(localModeWarn(obj,evd,hThis)));
    l(end+1) = addlistener(hFig,window_prop,'PostSet',@(obj,evd)(localModeRestore(obj,evd,l(end),hThis)));
    localSetListenerStateOff(l);
    hThis.WindowListenerHandles = l;
    
    l = addlistener(hFig,'WindowButtonMotionFcn','PreSet',@(obj,evd)(localModeWarn(obj,evd,hThis)));
    l(end+1) = addlistener(hFig,'WindowButtonMotionFcn','PostSet',@(obj,evd)(localModeRestore(obj,evd,l(end),hThis)));
    localSetListenerStateOff(l);
    hThis.WindowMotionListenerHandles = l;
    
    set(hFig,'ModeManager',hThis);
else
    error('MATLAB:uimodes:modemanager:ExistingManager',...
        'Figure already contains a mode manager');
end

%------------------------------------------------------------------------%
function localModeWarn(hProp,evd,hThis)
hThis.PreviousWindowState = get(evd.AffectedObject,hProp.Name);
warning('MATLAB:modes:mode:InvalidPropertySet',...
    'Setting the "%s" property is not permitted while this mode is active.',hProp.Name);

%------------------------------------------------------------------------%
function localModeRestore(hProp,evd,listener,hThis)
localSetListenerStateOff(listener);
set(evd.AffectedObject,hProp.Name,hThis.PreviousWindowState);
localSetListenerStateOn(listener);

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

%------------------------------------------------------------------------%
function localDelete(hThis)
if ishandle(hThis)
    delete(hThis);
end