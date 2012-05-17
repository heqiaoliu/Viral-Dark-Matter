function newValue = setCallbackFcn(hThis, valueProposed, propToChange)
% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are inserted here.

%   Copyright 2005-2010 The MathWorks, Inc.

newValue = valueProposed;
%If the mode is on, this change should be reflected in the figure
%callbacks
if strcmp(hThis.Enable,'on')
    %Disable listeners
    mmgr = uigetmodemanager(hThis.FigureHandle);
    enableState = mmgr.WindowListenerHandles(1).Enabled;
    if (ischar(enableState) && strcmpi(enableState,'on')) || ...
            (islogical(enableState) && enableState)
        mmgrEnableFunction = @localSetListenerStateOn;
    else
        mmgrEnableFunction = @localSetListenerStateOff;
    end
    localSetListenerStateOff(mmgr.WindowListenerHandles);
    windowListEnableState = hThis.WindowListenerHandles(1).Enabled;
    if (ischar(windowListEnableState) && strcmpi(windowListEnableState,'on')) || ...
            (islogical(windowListEnableState) && windowListEnableState)
        windowListEnableFunction = @localSetListenerStateOn;
    else
        windowListEnableFunction = @localSetListenerStateOff;
    end
    localSetListenerStateOff(hThis.WindowListenerHandles);
    switch propToChange
        case 'WindowButtonDownFcn'
            if ~feature('HGUsingMATLABClasses')
                set(hThis.FigureHandle,propToChange,{@localModeWindowButtonDownFcn,hThis,newValue});
            end
        case 'WindowButtonUpFcn'
            if ~feature('HGUsingMATLABClasses')
                set(hThis.FigureHandle,propToChange,{@localModeWindowButtonUpFcn,hThis,newValue});
            end
        case 'WindowKeyPressFcn'
            set(hThis.FigureHandle,propToChange,{@localModeWindowKeyPressFcn,hThis,newValue});
        case 'WindowKeyReleaseFcn'
            set(hThis.FigureHandle,propToChange,{@localModeWindowKeyReleaseFcn,hThis,newValue});           
        otherwise
            set(hThis.FigureHandle,propToChange,newValue);
    end
    %Enable listeners
    mmgrEnableFunction(mmgr.WindowListenerHandles);
    windowListEnableFunction(hThis.WindowListenerHandles);
end

%------------------------------------------------------------------------%
function localModeWindowButtonDownFcn(hFig,evd,hThis,newButtonDownFcn)

hThis.modeWindowButtonDownFcn(hFig,evd,hThis,newButtonDownFcn);

%------------------------------------------------------------------------%
function localModeWindowButtonUpFcn(hFig,evd,hThis,newButtonUpFcn)

hThis.modeWindowButtonUpFcn(hFig,evd,hThis,newButtonUpFcn);

%------------------------------------------------------------------------%
function localModeWindowKeyPressFcn(hFig,evd,hThis,newButtonDownFcn)

hThis.modeWindowKeyPressFcn(hFig,evd,hThis,newButtonDownFcn);

%------------------------------------------------------------------------%
function localModeWindowKeyReleaseFcn(hFig,evd,hThis,newButtonUpFcn)

hThis.modeWindowKeyReleaseFcn(hFig,evd,hThis,newButtonUpFcn);

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