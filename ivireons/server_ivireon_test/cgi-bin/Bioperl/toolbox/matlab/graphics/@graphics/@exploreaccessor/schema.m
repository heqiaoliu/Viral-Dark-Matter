function schema
% exploreaccessor class: This class is provides access to properties of the
% graphics explore modes in MATLAB

%   Copyright 2006-2009 The MathWorks, Inc.

hPk = findpackage('graphics');
cls = schema.class(hPk,'exploreaccessor');

% The majority of visible properties of this class are pass-through 
% properties to the mode being accessed and share names with the properties
% of the UIMODE object.

% Callback to determine whether the object's button down function should be
% used
p = schema.prop(cls,'ButtonDownFilter','MATLAB callback');
set(p,'SetFunction',{@localSetToMode,'ButtonDownFilter'});
set(p,'GetFunction',{@localGetFromMode,'ButtonDownFilter'});
p.AccessFlags.Init = 'off';

% Pre and post callback functions
p = schema.prop(cls,'ActionPreCallback','MATLAB callback');
set(p,'SetFunction',{@localSetToMode,'ActionPreCallback'});
set(p,'GetFunction',{@localGetFromMode,'ActionPreCallback'});
p.AccessFlags.Init = 'off';

p = schema.prop(cls,'ActionPostCallback','MATLAB callback');
set(p,'SetFunction',{@localSetToMode,'ActionPostCallback'});
set(p,'GetFunction',{@localGetFromMode,'ActionPostCallback'});
p.AccessFlags.Init = 'off';

% Enable property
p = schema.prop(cls,'Enable','on/off');
set(p,'SetFunction',@localSetEnable);
set(p,'GetFunction',@localGetEnable);
p.AccessFlags.Init = 'off';

% Figure Handle
p = schema.prop(cls,'FigureHandle','MATLAB array');
set(p,'GetFunction',{@localGetFromMode,'FigureHandle'});
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Init = 'off';

% Non-visible properties
% Handle to the mode object
p = schema.prop(cls,'ModeHandle','handle');
p.Visible = 'off';
p.AccessFlags.Init = 'off';

%------------------------------------------------------------------------%
function newValue = localSetToMode(hThis,valueProposed,propName)
% Set the mode property
    try
        set(hThis.ModeHandle,propName,valueProposed);
    catch ex
        rethrow(ex);
    end
newValue = valueProposed;

%------------------------------------------------------------------------%
function valueToCaller = localGetFromMode(hThis,valueStored,propName)
% Get the mode property
    try
        valueToCaller = get(hThis.ModeHandle,propName);
    catch ex
        rethrow(ex);
    end
if strcmpi(propName,'FigureHandle')
    valueToCaller = double(valueToCaller);
end

%------------------------------------------------------------------------%
function newValue = localSetEnable(hThis,valueProposed)
% Activate or deactivate the mode
hMode = hThis.ModeHandle;
try
    if strcmpi(valueProposed,'on')
        activateuimode(hThis.FigureHandle,hMode.Name);
    else
        activateuimode(hThis.FigureHandle,'');
    end
catch ex
    rethrow(ex);
end
newValue = valueProposed;

%------------------------------------------------------------------------%
function valueToCaller = localGetEnable(hThis,valueStored)
% Find out if the current mode is running
hMode = hThis.ModeHandle;
res = isactiveuimode(hThis.FigureHandle,hMode.Name);
if res
    valueToCaller = 'on';
else
    valueToCaller = 'off';
end