function schema
% brush class: This class provides access to properties of the
% brush mode in MATLAB

%   Copyright 2007 The MathWorks, Inc.

hPk = findpackage('graphics');
hExistingClass = findclass(hPk,'exploreaccessor');
cls = schema.class(hPk,'brush',hExistingClass);

p = schema.prop(cls,'Color','lineColorType');
set(p,'SetFunction',@localSetColor);
set(p,'GetFunction',@localGetColor);
p.AccessFlags.Init = 'off';

%------------------------------------------------------------------------%
function newValue = localSetColor(hThis,valueProposed)
    
brush(hThis.FigureHandle,valueProposed)
newValue = valueProposed;

%------------------------------------------------------------------------%
function valueToCaller = localGetColor(hThis,valueStored)
% Get the Color property from the mode
valueToCaller = hThis.ModeHandle.ModeStateData.color;