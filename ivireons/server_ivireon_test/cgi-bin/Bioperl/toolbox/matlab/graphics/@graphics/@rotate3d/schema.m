function schema
% rotate3d class: This class provides access to properties of the
% rotate3d mode in MATLAB

%   Copyright 2006-2009 The MathWorks, Inc.

hPk = findpackage('graphics');
hExistingClass = findclass(hPk,'exploreaccessor');
cls = schema.class(hPk,'rotate3d',hExistingClass);

% The rotate3d class provides additional properties and methods specific to
% rotate3d mode.

% Enumeration Style Type
if (isempty(findtype('RotateStyle')))
    schema.EnumType('RotateStyle',{'box','orbit'});
end

p = schema.prop(cls,'RotateStyle','RotateStyle');
set(p,'SetFunction',@localSetStyle);
set(p,'GetFunction',@localGetStyle);
p.AccessFlags.Init = 'off';

p = schema.prop(cls,'UIContextMenu','MATLAB array');
set(p,'SetFunction',@localSetContextMenu);
set(p,'GetFunction',@localGetContextMenu);
p.AccessFlags.Init = 'off';

%------------------------------------------------------------------------%
function newValue = localSetStyle(hThis,valueProposed)
% Set the style property of the mode
switch valueProposed
    case 'box'
        hThis.ModeHandle.ModeStateData.rotatestyle = '-view';
        newValue = valueProposed;
    case 'orbit'
        hThis.ModeHandle.ModeStateData.rotatestyle = '-orbit';
        newValue = valueProposed;
end

%------------------------------------------------------------------------%
function valueToCaller = localGetStyle(hThis,~)
% Get the style property from the mode
styleChoice = hThis.ModeHandle.ModeStateData.rotatestyle;
switch styleChoice
    case '-view'
        valueToCaller = 'box';
    case '-orbit'
        valueToCaller = 'orbit';
end

%-----------------------------------------------%
function valueToCaller = localGetContextMenu(hThis,~)
valueToCaller = hThis.ModeHandle.ModeStateData.CustomContextMenu;

%-----------------------------------------------%
function newValue = localSetContextMenu(hThis,valueProposed)
if strcmpi(hThis.Enable,'on')
    error('MATLAB:graphics:rotate3d:ReadOnlyRunning',...
        'The ''UIContextMenu'' property may be set only when rotate3d is not on.');
end
if ~isempty(valueProposed) && ~ishghandle(valueProposed,'uicontextmenu')
    error('MATLAB:graphics:rotate3d:InvalidContextMenu',...
    'Handle must be a uicontextmenu.');
end
newValue = valueProposed;
    hThis.ModeHandle.ModeStateData.CustomContextMenu = valueProposed;
