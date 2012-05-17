function modeWindowButtonUpFcn(~,hFig,evd,hThis,newButtonUpFcn)
% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2005-2010 The MathWorks, Inc.

appdata = hThis.FigureState;

%Check for multiple buttons down
appdata.numButtonsDown = appdata.numButtonsDown - 1;
appdata.numButtonsDown = max(appdata.numButtonsDown,0);
hThis.FigureState = appdata;
if appdata.numButtonsDown ~= 0
    return;
end

appdata = hThis.FigureState;

%Restore any button functions on the object we clicked on
if isfield(appdata,'CurrentObj') && ~isempty(appdata.CurrentObj.Handle) && ...
        ishghandle(appdata.CurrentObj.Handle) && isprop(appdata.CurrentObj.Handle,'ButtonDownFcn') && ...
        ~isequal(appdata.CurrentObj.ButtonDownFcn,get(appdata.CurrentObj.Handle,'ButtonDownFcn'))
    set(appdata.CurrentObj.Handle,'ButtonDownFcn',appdata.CurrentObj.ButtonDownFcn);
end

hThis.FigureState = appdata;

% If the mode had filtered the button down and we have a button-up function
% that must be fired, call it instead of the mode's callback.
hM = uigetmodemanager(hFig);
localSetListenerStateOff(hThis.WindowListenerHandles);
localSetListenerStateOn(hM.WindowListenerHandles);
if ~isempty(hThis.UserButtonUpFcn)
    hFig = hThis.FigureHandle;
    try
        hgfeval(hThis.UserButtonUpFcn,double(hFig),[])
    catch
        warning('MATLAB:uitools:uimode:callbackerror',...
            'An error occurred during the mode callback.');
    end
    hThis.UserButtonUpFcn = '';
    return;
end

% Execute the specified callback function
hgfeval(newButtonUpFcn,hFig,evd);

% Deal with the context menu. Depending on the platform, the context-menu
% may be attached to the object that the mouse is over, or the object that
% was initially clicked. We will handle both cases.
if appdata.doContext
    obj = localHittest(hFig,evd);
    if isfield(appdata,'CurrentObj') && ~isequal(obj,appdata.CurrentObj.Handle)
        if isprop(obj,'UIContextMenu')
            appdata.CurrentContextMenuObj.Handle = obj;
            appdata.CurrentContextMenuObj.UIContextMenu = get(obj,'UIContextMenu');
            set(obj,'UIContextMenu',hThis.UIContextMenu);
        end
        hThis.FigureState = appdata;
    end
end

% If the mode (or one of its ancestors) is a one-shot mode, exit the mode:
hMode = hThis;
while ~isempty(hMode)
    if hMode.IsOneShot
        hParentMode = hMode.ParentMode;
        if isempty(hParentMode)
            activateuimode(hThis.FigureHandle,'');
        else
            if isequal(hParentMode.CurrentMode,hMode)
                activateuimode(hParentMode,'');
            end
        end
    end
    hMode = hMode.ParentMode;
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

%-----------------------------------------------------------------------%
function obj = localHittest(hFig,evd)
if feature('HGUsingMATLABClasses')
    obj = plotedit({'hittestHGUsingMATLABClasses',hFig,evd});
else
    obj = handle(hittest(hFig));
end
