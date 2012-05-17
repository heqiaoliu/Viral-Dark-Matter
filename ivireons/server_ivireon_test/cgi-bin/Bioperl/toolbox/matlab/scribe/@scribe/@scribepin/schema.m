function schema
%SCHEMA defines the danScribe.scribepin schema
%

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $  $  $

hPk = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');
% The pin object inherits from line
cls = schema.class(hPk, 'scribepin', hgPk.findclass('line'));

% The pin may be connected to an object or an axes. In the case of an
% object, store a handle to it.
p = schema.prop(cls,'PinnedObject','handle');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% Store the handle of the object being pinned.
p = schema.prop(cls,'Target','handle');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% Keep track of whether the pin is enabled or not.
p = schema.prop(cls,'Enable','on/off');
p.FactoryValue = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% Store the listeners required to keep the pin operational.
p = schema.prop(cls,'Listeners','handle vector');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% Keep track of which affordance we are maintaining. This is an index into
% the affordance array of the object
p = schema.prop(cls,'Affordance','MATLAB array');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';
p.SetFunction = @localChangeAffordance;

% Store an additional set of listeners to keep the pin in the correct
% location on the screen
p = schema.prop(cls,'AffordanceListeners','handle vector');
p.AccessFlags.Init = 'off';
p.AccessFlags.Serialize = 'off';
p.Visible = 'off';

% The pin needs to keep track of the correspondence between the point it is
% rendering in the scribe axes and the point it represents in data space.
p = schema.prop(cls,'DataPosition','MATLAB array');
p.FactoryValue = [0 0 0];
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

% The pin needs to keep track of which axes the data is contained in.
p = schema.prop(cls,'DataAxes','handle');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';

% Keep an internal flag to determine whether we are sending an update call
p = schema.prop(cls,'UpdateInProgress','bool');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.FactoryValue = false;

%---------------------------------------------------------------%
function valueStored = localChangeAffordance(hThis, valueProposed)
% Install listeners on the affordance to keep the pin affordance in sync
% with the scribe object.

valueStored = valueProposed;
hTarget = hThis.Target;
pinAff = hTarget.Srect(valueProposed);
set(hThis,'XData',get(pinAff,'XData'));
set(hThis,'YData',get(pinAff,'YData'));
set(hThis,'ZData',get(pinAff,'ZData'));
% Since we may be bound to an invisible affordance (for example the center
% of a 2-D object or an object whose "SelectionHighlight" property is set
% to "off", get the "Visible" property from the object
if strcmpi(hTarget.Visible,'on')
    set(hThis,'Visible',get(hTarget,'Selected'));
end

l = handle.listener(pinAff, findprop(pinAff,'XData'), ...
    'PropertyPostSet', {@localMatchProperty, hThis, 'XData'});
l(end+1) = handle.listener(pinAff, findprop(pinAff,'YData'), ...
    'PropertyPostSet', {@localMatchProperty, hThis, 'YData'});
l(end+1) = handle.listener(pinAff, findprop(pinAff,'ZData'), ...
    'PropertyPostSet', {@localMatchProperty, hThis, 'ZData'});
props = findprop(hTarget,'Visible');
props(end+1) = findprop(hTarget,'Selected');
l(end+1) = handle.listener(hTarget, props, ...
    'PropertyPostSet', {@localSetVisible, hThis});

hThis.AffordanceListeners = l;

%---------------------------------------------------------------%
function localSetVisible(src, evd, hThis) %#ok<INUSL>
% Set the "Visible" property of the pin based on the "Visible" and
% "Selected" properties of the target

hTarget = evd.AffectedObject;
if strcmpi(hTarget.Visible,'on')
    set(hThis,'Visible',hTarget.Selected);
else
    set(hThis,'Visible','off');
end

%---------------------------------------------------------------%
function localMatchProperty(src, evd, hThis, propName) %#ok<INUSL>
% Link the property of the pin with the new value returned by the listener

set(hThis,propName,evd.NewValue);
% We also need to repin the object if an update is not in progress
if ~hThis.UpdateInProgress
    hFig = ancestor(hThis,'Figure');
    point = [hThis.XData hThis.YData];
    point = hgconvertunits(hFig,[point 0 0],'Normalized','Pixels',hFig);
    point = point(1:2);
    
    % The pinned object may have changed, which we must take into account.
    pinobj = [];
    % Turn off the hittest property of this group to find out if we are over an
    % object
    hitState = get(hThis.Target,'HitTest');
    set(hThis.Target,'HitTest','off');
    obj = handle(hittest(hFig,point));
    set(hThis.Target,'HitTest',hitState);
    if ~isempty(obj) && ~isa(obj,'scribe.scribeobject') && ...
            ~strcmpi(get(obj,'tag'),'DataTipMarker')
        type = get(obj,'type');
        if strcmpi(type,'surface')||strcmpi(type,'patch')||strcmpi(type,'line')
            pinobj = obj;
        end
    end
    if ~isempty(pinobj) && ~isequal(handle(ancestor(pinobj,'Axes')),hThis.DataAxes)
        pinobj = [];
    end
    
    repin(hThis,point,hThis.DataAxes,pinobj);
end