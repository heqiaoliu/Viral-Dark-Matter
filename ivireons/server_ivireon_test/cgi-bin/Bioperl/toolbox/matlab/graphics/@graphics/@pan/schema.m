function schema
% pan class: This class provides access to properties of the
% pan mode in MATLAB

%   Copyright 2006-2009 The MathWorks, Inc.

hPk = findpackage('graphics');
hExistingClass = findclass(hPk,'exploreaccessor');
cls = schema.class(hPk,'pan',hExistingClass);

% The pan class provides additional properties and methods specific to pan
% mode.

% Enumeration Style Type
if (isempty(findtype('StyleChoice')))
    schema.EnumType('StyleChoice',{'horizontal','vertical','both'});
end

p = schema.prop(cls,'Motion','StyleChoice');
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
    case 'horizontal'
        hThis.ModeHandle.ModeStateData.style = 'x';
        newValue = valueProposed;
    case 'vertical'
        hThis.ModeHandle.ModeStateData.style = 'y';
        newValue = valueProposed;
    case 'both'
        hThis.ModeHandle.ModeStateData.style = 'xy';
        newValue = valueProposed;
end

%------------------------------------------------------------------------%
function valueToCaller = localGetStyle(hThis,~)
% Get the style property from the mode
styleChoice = hThis.ModeHandle.ModeStateData.style;
switch styleChoice
    case 'x'
        valueToCaller = 'horizontal';
    case 'y'
        valueToCaller = 'vertical';
    case 'xy'
        valueToCaller = 'both';
end

%-----------------------------------------------%
function valueToCaller = localGetContextMenu(hThis,~)
valueToCaller = hThis.ModeHandle.ModeStateData.CustomContextMenu;

%-----------------------------------------------%
function newValue = localSetContextMenu(hThis,valueProposed)
if strcmpi(hThis.Enable,'on')
    error('MATLAB:graphics:pan:ReadOnlyRunning',...
        'The ''UIContextMenu'' property may be set only when pan is not on.');
end
if ~isempty(valueProposed) && ~ishghandle(valueProposed,'uicontextmenu')
    error('MATLAB:graphics:pan:InvalidContextMenu',...
    'Handle must be a uicontextmenu.');
end
newValue = valueProposed;
    hThis.ModeHandle.ModeStateData.CustomContextMenu = valueProposed;
