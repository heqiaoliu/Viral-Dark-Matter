function schema

% Copyright 2003-2006 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'ploteditbehavior');

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'Plotedit';

% Indicates if an object is dragable and resizeable
p = schema.prop(cls,'EnableMove','bool');
p.FactoryValue = true;

% Indicates if an object is dragable by clicking in the interior
p = schema.prop(cls,'AllowInteriorMove','bool');
p.FactoryValue = false;

% Indicates if an object is selectable
p = schema.prop(cls,'EnableSelect','bool');
p.FactoryValue = true;

% Callback for mouse-over cursor control
p = schema.prop(cls,'MouseOverFcn','MATLAB array');
p.FactoryValue = [];

% Callback for plot-edit button down
p = schema.prop(cls,'ButtonDownFcn','MATLAB array');
p.FactoryValue = [];

% Callback for plot-edit button up
p = schema.prop(cls,'ButtonUpFcn','MATLAB array');
p.FactoryValue = [];

% Indicates object should keep context menu in plotedit mode
p = schema.prop(cls,'KeepContextMenu','MATLAB array');
p.FactoryValue = false;

% Callback for plot-edit mouse movement - set this when you
% need custom motion or drag events while in plotedit mode.
p = schema.prop(cls,'MouseMotionFcn','MATLAB array');
p.FactoryValue = [];

% Indicates if an object is visible to plotedit - overrides all
% above settings
p = schema.prop(cls,'Enable','bool');
p.FactoryValue = true;

listener = handle.listener(cls,p,'PropertyPostSet',@doEnableAction);
setappdata(0,'PloteditBehaviorEnableListener',listener);

% Enable copy-to-clipboard action to copy this object (shared by cut)
p = schema.prop(cls,'EnableCopy','bool');
p.FactoryValue = true;

% Enable paste-from-clipboard action to paste into container
p = schema.prop(cls,'EnablePaste','bool');
p.FactoryValue = true;

% Enable delete action 
p = schema.prop(cls,'EnableDelete','bool');
p.FactoryValue = true;

p = schema.prop(cls,'Serialize','MATLAB array');
p.FactoryValue = true;
p.AccessFlags.Serialize = 'off';

function doEnableAction(hSrc, eventData)
h = eventData.affectedObject;
val = get(h,'Enable');
set(h,'EnableSelect',val);
set(h,'EnableMove',val);
set(h,'EnableCopy',val);
set(h,'EnablePaste',val);
set(h,'EnableDelete',val);


