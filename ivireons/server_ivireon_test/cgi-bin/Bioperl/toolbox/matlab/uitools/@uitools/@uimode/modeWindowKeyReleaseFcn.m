function modeWindowKeyReleaseFcn(hMode,hFig,evd,hThis,newKeyUpFcn) %#ok
% Modify the window callback function as specified by the mode. Techniques
% to minimize mode interaction issues are used here.

%   Copyright 2007-2010 The MathWorks, Inc.

appdata = hThis.FigureState;

%Restore any key functions on the object we clicked on
if isfield(appdata,'CurrentKeyPressObj') && ~isempty(appdata.CurrentKeyPressObj.Handle) && ishandle(appdata.CurrentKeyPressObj.Handle)
    if isprop(appdata.CurrentKeyPressObj.Handle,'KeyPressFcn') && ~ishghandle(appdata.CurrentKeyPressObj.Handle,'figure')
        set(appdata.CurrentKeyPressObj.Handle,'KeyPressFcn',appdata.CurrentKeyPressObj.KeyPressFcn);
    end
end

hThis.FigureState = appdata;

%Execute the specified callback function
hgfeval(newKeyUpFcn,hFig,evd);
