function schema
% zoom class: This class provides access to properties of the
% zoom mode in MATLAB

%    Copyright 2002-2009 The MathWorks, Inc.

hPk = findpackage('graphics');
hExistingClass = findclass(hPk, 'exploreaccessor');
cls = schema.class(hPk,'zoom',hExistingClass);

% The zoom class provides additional properties and methods specific to
% zoom mode.

% Add new enumeration type
if isempty(findtype('in/out'))
    schema.EnumType('in/out',{'in','out'});
end

% Add new Right Click Enumeration type
if isempty(findtype('RightClickActionType'))
    schema.EnumType('RightClickActionType',{'InverseZoom','PostContextMenu'});
end

% Enumeration style type
if isempty(findtype('StyleChoice'))
    schema.EnumType('StyleChoice',{'horizontal','vertical','both'});
end

p = schema.prop(cls,'Motion','StyleChoice');
set(p,'SetFunction',@localSetStyle);
set(p,'GetFunction',@localGetStyle);
p.AccessFlags.Init = 'off';

p = schema.prop(cls,'Direction','in/out');
set(p,'SetFunction',@localSetDirection);
set(p,'GetFunction',@localGetDirection);
p.AccessFlags.Init = 'off';

p = schema.prop(cls,'RightClickAction','RightClickActionType');
set(p,'SetFunction',@localSetRightClickZoomOut);
set(p,'GetFunction',@localGetRightClickZoomOut);
p.AccessFlags.Init = 'off';

p = schema.prop(cls,'UIContextMenu','MATLAB array');
set(p,'SetFunction',@localSetContextMenu);
set(p,'GetFunction',@localGetContextMenu);
p.AccessFlags.Init = 'off';

%-----------------------------------------------%
function valueToCaller = localGetRightClickZoomOut(hThis,~)
if strcmpi(hThis.ModeHandle.ModeStateData.DoRightClick,'on')
    valueToCaller = 'InverseZoom';
else
    valueToCaller = 'PostContextMenu';
end

%-----------------------------------------------%
function newValue = localSetRightClickZoomOut(hThis,valueProposed)
newValue = valueProposed;
% Save the right click zoom option as a preference
if strcmpi(valueProposed,'InverseZoom')
    hThis.ModeHandle.ModeStateData.DoRightClick = 'on';
    setpref('MATLABZoom','RightClick','on');
else
    hThis.ModeHandle.ModeStateData.DoRightClick = 'off';
    setpref('MATLABZoom','RightClick','off');
end

%-----------------------------------------------%
function valueToCaller = localGetStyle(hThis,~)
% Get the current zoom style
constraint = hThis.ModeHandle.ModeStateData.Constraint;
if strcmpi(constraint,'none')
    valueToCaller = 'both';
else
    valueToCaller = constraint;
end

%-----------------------------------------------%
function newValue = localSetStyle(hThis,valueProposed)
% Set the current zoom style
newValue = valueProposed;
if strcmpi(valueProposed,'both')
    valueProposed = 'none';
end
% If the mode is running and the direction is "in", update the UI:
if isactiveuimode(hThis.FigureHandle,'Exploration.Zoom')
    if strcmpi(hThis.ModeHandle.ModeStateData.Direction,'in')
        localUIChangeConstraint(hThis.FigureHandle,valueProposed);
    end
end
hThis.ModeHandle.ModeStateData.Constraint = valueProposed;

%-----------------------------------------------%
function valueToCaller = localGetDirection(hThis,~)
% Get the current direction of the mode
valueToCaller = hThis.ModeHandle.ModeStateData.Direction;

%-----------------------------------------------%
function newValue = localSetDirection(hThis,valueProposed)
% Modify the User interface if the direction is changed while the mode is
% running.

hMode = hThis.ModeHandle;
newValue = valueProposed;

if isactiveuimode(hMode.FigureHandle,'Exploration.Zoom')
    if strcmp(valueProposed,'in')
        xTool = uigettool(hMode.FigureHandle,'Exploration.ZoomX');
        if isempty(xTool)
            localUISetZoomIn(hMode.FigureHandle);
        else
            localUIChangeConstraint(hMode.FigureHandle,hMode.ModeStateData.Constraint);
        end
    else
        localUISetZoomOut(hMode.FigureHandle);
    end
end
hMode.ModeStateData.Direction = newValue;

%-----------------------------------------------%
function valueToCaller = localGetContextMenu(hThis,~)
valueToCaller = hThis.ModeHandle.ModeStateData.CustomContextMenu;

%-----------------------------------------------%
function newValue = localSetContextMenu(hThis,valueProposed)
if strcmpi(hThis.Enable,'on')
    error('MATLAB:graphics:zoom:ReadOnlyRunning',...
        'The ''UIContextMenu'' property may be set only when zoom is not on.');
end
if ~isempty(valueProposed) && ~ishghandle(valueProposed,'uicontextmenu')
    error('MATLAB:graphics:zoom:InvalidContextMenu',...
    'Handle must be a uicontextmenu.');
end
newValue = valueProposed;
hThis.ModeHandle.ModeStateData.CustomContextMenu = valueProposed;

%-----------------------------------------------%
function localUIChangeConstraint(fig,constraint)
% Change the UI to match the constraint.

switch constraint
    case 'none'
        localUISetZoomIn(fig);
    case 'horizontal'
        localUISetZoomInX(fig);
    case 'vertical'
        localUISetZoomInY(fig);
end

%-----------------------------------------------%
function localUISetZoomIn(fig)
set(uigettool(fig,'Exploration.ZoomIn'),'State','on');
set(uigettool(fig,'Exploration.ZoomOut'),'State','off');
set(uigettool(fig,'Exploration.ZoomX'),'State','off');
set(uigettool(fig,'Exploration.ZoomY'),'State','off');

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

%-----------------------------------------------%
function localUISetZoomOut(fig)
set(uigettool(fig,'Exploration.ZoomIn'),'State','off');
set(uigettool(fig,'Exploration.ZoomOut'),'State','on');
set(uigettool(fig,'Exploration.ZoomX'),'State','off');
set(uigettool(fig,'Exploration.ZoomY'),'State','off');