function modeWindowButtonDownFcn(~,hFig,evd,hThis,newButtonDownFcn)
% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2005-2010 The MathWorks, Inc.

% If we are in a bad state due to figure-copying, 
% or an invalid figure, try to recover gracefully:
if ~ishandle(hThis) || hFig ~= hThis.FigureHandle
    if ishghandle(hFig)
        set(hFig,'WindowButtonDownFcn','');
        set(hFig,'WindowButtonUpFcn','');
        set(hFig,'WindowKeyPressFcn','');
        set(hFig,'WindowKeyReleaseFcn','');
        set(hFig,'KeyPressFcn','');
        set(hFig,'KeyReleaseFcn','');
        set(hFig,'Pointer',get(0,'DefaultFigurePointer'));
        setappdata(hFig,'ScribeClearModeCallback','');
    end
    return;
end

appdata = hThis.FigureState;

appdata.numButtonsDown = appdata.numButtonsDown+1;
sel_type = get(hFig,'selectiontype');

%Maintain the number of keys down
if (appdata.numButtonsDown ~= 1)
    if strcmpi(sel_type,'extend')
        hThis.FigureState = appdata;
        return;
    else
        %We are in a bad state. Reset the number of buttons down before we
        %get into trouble
        appdata.numButtonsDown = 1;
    end
end

%Restore the context menu of the previously clicked object
if appdata.doContext
    if isfield(appdata,'CurrentObj') && ishghandle(appdata.CurrentObj.Handle)
        set(appdata.CurrentObj.Handle,'UIContextMenu',appdata.CurrentObj.UIContextMenu);
    end
    if isfield(appdata,'CurrentContextMenuObj') && ishghandle(appdata.CurrentContextMenuObj.Handle)
        set(appdata.CurrentContextMenuObj.Handle,'UIContextMenu',appdata.CurrentContextMenuObj.UIContextMenu);
    end
    appdata.doContext = false;
end

% Cache the "ButtonDownFcn" of the object. There are cases where it could
% accidentally get removed if we fail to cache it here:
h = localHittest(hFig,evd);
appdata.CurrentObj.Handle = h;
% Primitive graphics may not have a ButtonDownFcn
if isprop(h,'ButtonDownFcn')
    appdata.CurrentObj.ButtonDownFcn = get(h,'ButtonDownFcn');
else
    appdata.CurrentObj.ButtonDownFcn = [];
end
hThis.FigureState = appdata;

%If we clicked on a UIControl or UITable object, return unless we are 
%suspending the callback.
if isa(h,'uicontrol') || isa(h,'uitable')
    if ~hThis.UIControlInterrupt
        return;
    end
end

% If the mode contains an object whose callback needs to fire, return
if ~isempty(hThis.ButtonDownFilter)
    blockState = hThis.Blocking;
    hThis.Blocking = true;   
    try
        if hgfeval(hThis.ButtonDownFilter,h,[])
            hThis.Blocking = blockState;
            % It is possible that a button-down function would want to install its
            % own button up. To reduce command-window warnings and facilitate this,
            % we will temporarily turn off the mode manager's listeners and install
            % our own. With the exception of WindowButtonUpFcn, they will all be
            % no-ops.
            hM = uigetmodemanager(hThis.FigureHandle);
            localSetListenerStateOff(hM.WindowListenerHandles);
            localSetListenerStateOn(hThis.WindowListenerHandles);
            return;
        end
    catch %#ok<CTCH>
        warning('MATLAB:uitools:uimode:callbackerror',...
            'An error occurred during the mode callback.');
    end
    hThis.Blocking = blockState;
end

%Disable any button functions on the object we clicked on and register
%the context menu
if isprop(h,'ButtonDownFcn') && ~isequal(get(h,'ButtonDownFcn'),'')
   set(h,'ButtonDownFcn','');
end


%Execute the specified callback function
hgfeval(newButtonDownFcn,hFig,evd);

%Deal with the context menu
if strcmpi(sel_type,'alt') && isprop(h,'ButtonDownFcn')
    appdata.CurrentObj.UIContextMenu = get(h,'UIContextMenu');
    if strcmp(hThis.UseContextMenu,'off')
        appdata.doContext = false;
    else
        if hThis.ShowContextMenu
            set(h,'UIContextMenu',hThis.UIContextMenu);
        else
            set(h,'UIContextMenu','');
        end
        appdata.doContext = true;
    end
    hThis.ShowContextMenu = true;
end

hThis.FigureState = appdata;

%-----------------------------------------------------------------------%
function obj = localHittest(hFig,evd)
if feature('HGUsingMATLABClasses')
    obj = plotedit({'hittestHGUsingMATLABClasses',hFig,evd});
else
    obj = handle(hittest(hFig));
end

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