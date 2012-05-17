function schema
%SCHEMA defines the abstract class for all scribe objects.
%

%   Copyright 2006 The MathWorks, Inc. 
%   $  $  $

% Define a "MoveMode" enumerated type:

if isempty(findtype('MoveModeType'))
    schema.EnumType('MoveModeType',...
        {'mouseover','topleft','topright','bottomright',...
        'bottomleft','left','top','right','bottom','none'});
end

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
% All scribe objects inherit from an hggroup
cls = schema.class(pkg, 'scribeobject', hgPk.findclass('hggroup'));

% COMMON SCRIBE SHAPE PROPERTIES
% Shape type. 
% To add new shape types: Modify the enumerated type defined in the package
% schema file and add a new entry into annotation.m
p = schema.prop(cls,'ShapeType','ScribeShapeType');
p.AccessFlags.Serialize = 'on'; 
p.AccessFlags.PublicSet = 'off'; 
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.Init = 'off';
p.Visible = 'off';

% The current method of movement. This property specifies the current state
% of an object with respect to the mouse. This may be "mousover" (none),
% "drag", or dragging one of the 8 affordences of the object.
p = schema.prop(cls,'MoveMode','MoveModeType');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.AccessFlags.Init = 'on'; 
p.FactoryValue = 'mouseover';
p.Visible = 'off';

% Selected shadows the GObject Selected property on purpose so
% that HG doesn't draw the built-in selection handles.
p = schema.prop(cls,'Selected','on/off');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';
p.SetFunction = @localSetSelected;

% All annotations contain a "Color" property. It is the responsibility of
% subclasses to register properties that should interact with the "Color"
% property as entries into the "ColorProps" property vector.
p = schema.prop(cls,'ColorProps','string vector');
p.FactoryValue = {};
p.Visible = 'off';

p = schema.prop(cls,'Color','rectangleEdgeColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultLineColor');
p.SetFunction = @localSetColor;

% All annotations may be pinned to an axes. The pin property is a handle
% vector containing the pins. The abstract subclass will define the shape
% of this vector.
p = schema.prop(cls,'Pin','handle vector');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.AccessFlags.AbortSet = 'off';

% In order to keep track of pins for serialization purposes, we will keep
% track of which pins exist using a logical vector. It is the
% responsibility of the subclass to make sure the value of this property is
% consistent.
p = schema.prop(cls,'PinExists','MATLAB array');
p.Visible = 'off';
p.AccessFlags.Serialize = 'on';

% A pin is linked to an affordance of the annotation. We will store this
% information in an additional property representing the indices into the
% affordance vector.
p = schema.prop(cls,'PinAff','NReals');
p.Visible = 'off';
p.AccessFlags.PublicSet = 'on';
p.AccessFlags.Serialize = 'on';

% All annotation have a "Units" property. It is of type "figureUnitsType".
% Note: Setting this property has a side-effect of changing the position.
% This property must therefore be defined before the "Position" property.
p = schema.prop(cls,'Units','figureUnitsType');
p.FactoryValue = 'normalized';
p.SetFunction = @localSetUnits;

% All annotations have a position property. This is always represented as
% position rectangle. The abstract sub-classes may hide this property and 
% add ghost properties that return information based on the position. They 
% may also install set functions on this property.
p = schema.prop(cls,'Position','axesPositionType');
% These numbers come from the existing scribe defaults
p.FactoryValue = [0.3 0.3 0.1 0.1];
p.AccessFlags.AbortSet = 'off';

% Internal helper property "UpdateInProgress" is set whenever a property is set
% as a side-effect. This prevents side-effect sets from mucking with the
% "Mode"-property of an object.
p = schema.prop(cls,'UpdateInProgress','bool');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.FactoryValue = false;

% We have to be aware if the object changed position due to the figure
% resizing or other reason (important for text box).
p = schema.prop(cls,'FigureResize','bool');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.FactoryValue = false;

% All annotations have an "Afsize" property. This stores the size of the
% sphere of influence (in pixels) around an affordance.
p = schema.prop(cls,'Afsize','double');
p.FactoryValue = 6;
p.AccessFlags.Init = 'on';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible='off';

% All annotations have an "Srect" property. This stores the selection
% handles of the object.
p = schema.prop(cls,'Srect','handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.Visible='off';

% All annotations store a list of internal property listeners.
p = schema.prop(cls, 'PropertyListeners', 'handle vector');
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible = 'off';
p.FactoryValue = handle([]);

% All annotation types store a context menu for their class. This should be
% static on a per-subclass, per-figure basis. To avoid unnecessary 
% replecation and deletion, we will need to jump through a few hoops. 
% Hopefully, the subclasses will only need to implement a creation method 
% and everything else will work.
p = schema.prop(cls,'ScribeContextMenu','handle vector');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.GetFunction = @localGetScribeContextMenu;

% On the abstract level, there are additional context-menu entries for
% pinning and unpinning an annotation. Since these should only be visible
% in a scalar context, they will occupy a different property
p = schema.prop(cls,'PinContextMenu','handle vector');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';
p.GetFunction = @localGetPinContextMenu;

% In order to have units behave properly, we need to cache the position on
% a figure resize event. Store this cached position in a hidden property:
p = schema.prop(cls,'StoredPosition','axesPositionType');
p.Visible = 'off';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.Copy = 'off';

% In order to cooperate properly with the plot edit toolbar, annotations
% wil keep track of the meanings of certain properties. It is the
% responsibility of the subclass to maintain these in order to have an
% object operate correctly. If the properties are not set, the
% corresponding toolbar buttons will be disabled.
p = schema.prop(cls,'FaceColorProperty','string');
p.Visible = 'off';
p.FactoryValue = '';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'FaceColorDescription','string');
p.Visible = 'off';
p.FactoryValue = '';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'EdgeColorProperty','string');
p.Visible = 'off';
p.FactoryValue = '';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'EdgeColorDescription','string');
p.Visible = 'off';
p.FactoryValue = '';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'TextColorProperty','string');
p.Visible = 'off';
p.FactoryValue = '';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(cls,'TextColorDescription','string');
p.Visible = 'off';
p.FactoryValue = '';
p.AccessFlags.Serialize = 'off';
p.AccessFlags.PublicSet = 'off';

%---------------------------------------------------------------%
function valueStored = localSetSelected(hThis, valueProposed)

valueStored = valueProposed;
% Set the visibility of the affordances accordingly:
if ~strcmpi(hThis.SelectionHighlight,'off') && ~strcmpi(hThis.Visible,'off')
    set(hThis.Srect,'Visible',valueProposed);
end

%---------------------------------------------------------------%
function valueToCaller = localGetScribeContextMenu(hThis, valueStored)
% If we are busy deserializing, return early for performance reasons:

valueToCaller = valueStored;

if isappdata(0,'BusyDeserializing')
    return;
end

% If the plot edit mode context-menu hasn't been requested yet, return 
% early as well.
hFig = ancestor(hThis,'Figure');
hPlotEdit = plotedit(hFig,'getmode');
hMode = hPlotEdit.ModeStateData.PlotSelectMode;
if isempty(hMode.UIContextMenu) || ~ishandle(hMode.UIContextMenu)
    return;
end

% If the context menu hasn't been defined yet, construct it
valueToCaller = hThis.createScribeContextMenu(ancestor(hThis,'Figure'));

%---------------------------------------------------------------%
function valueToCaller = localGetPinContextMenu(hThis, valueStored)
% If we are busy deserializing, return early for performance reasons:

if isappdata(0,'BusyDeserializing')
    valueToCaller = valueStored;
    return;
end

% If the context menu hasn't been defined yet, construct it
valueToCaller = hThis.createPinContextMenu(ancestor(hThis,'Figure'));

%---------------------------------------------------------------%
function valueStored = localSetUnits(hThis, valueProposed)

valueStored = valueProposed;
% Get old units:
oldUnits = get(hThis,'Units');
oldPos = get(hThis,'Position');
if ~isempty(oldPos)
    hFig = ancestor(hThis,'figure');
    % Convert the position rectangle:
    newPos = hgconvertunits(hFig,oldPos,oldUnits,valueProposed,hFig);
    % Update the position property of the object
    hThis.UpdateInProgress = true;
    set(hThis,'Position',newPos);
    hThis.UpdateInProgress = false;
end

%---------------------------------------------------------------%
function valueStored = localSetColor(hThis, valueProposed)
% Set all the listening properties to the same color:
hThis.UpdateInProgress = true;
cellfun(@(prop)(set(hThis,prop,valueProposed)),hThis.ColorProps);
hThis.UpdateInProgress = false;
valueStored = valueProposed;