function schema
%SCHEMA defines the scribe.COLORBAR schema
%
%  See also PLOTEDIT

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $  $

pkg   = findpackage('scribe'); % Scribe package
hgPk = findpackage('hg');  % Handle Graphics package
h = schema.class(pkg, 'colorbar', hgPk.findclass('axes'));

% ENUM TYPES
if isempty(findtype('ColorbarLocationPreset'))
    schema.EnumType('ColorbarLocationPreset',{...
        'North','South','East','West', ...
        'NorthOutside','SouthOutside','EastOutside','WestOutside', ...
        'manual'});
end  
if isempty(findtype('ColorbarOrientationPreset'))
    schema.EnumType('ColorbarOrientationPreset',...
                                        {'HorizontalTop','HorizontalBottom','VerticalLeft','VerticalRight'});
end

% STYLE PROPERTIES
p = schema.prop(h,'EdgeColor','axesColorType');
p.AccessFlags.Init = 'on';
p.FactoryValue = get(0,'DefaultAxesXColor');
p.Visible = 'off';

p = schema.prop(h,'Image','MATLAB array');
p.AccessFlags.Init = 'on';
p.FactoryValue = [];
p.Visible = 'off';

p = schema.prop(h,'ColormapMoveInitialMap','MATLAB array');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'BaseColormap','MATLAB array');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'CmapNodeIndices','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'CmapNodeFrx','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'MovingNodeIndex','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'MovingNodeFrx','NReals');
p.AccessFlags.Init = 'off';
p.Visible = 'off';

p = schema.prop(h,'Location','ColorbarLocationPreset');
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Init = 'on';
p.FactoryValue = 'EastOutside';
p.SetFunction = @localSetLocation;

% implement orientation prop using new HG
% model for handling modes with public access to 
% propName and propNameMode, but private 
% access to propNameI, which maintains the true
% state of the property for internal object use.
p = schema.prop(h,'Orientation','ColorbarOrientationPreset');
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Serialize = 'off'; %only serialize the internal property and the Mode
p.AccessFlags.Init = 'off'; %GET queries OrienationI, so no need to init.
p.SetFunction = @localSetOrientation;
p.GetFunction = @localGetOrientation;
p.Visible = 'off';

p = schema.prop(h,'OrientationI','ColorbarOrientationPreset');
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Init = 'off'; % Location setter will set this on construction in scribe.colorbar
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.Visible = 'off';

p = schema.prop(h,'OrientationMode','axesXLimModeType');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'auto';
p.Visible = 'off';

% Keeping track of whether the user changed the X and Y Colors:
p = schema.prop(h,'XColorMode','axesXLimModeType');
p.Visible = 'off';
p.FactoryValue = 'auto';

% Keeping track of whether the user changed the X and Y Colors:
p = schema.prop(h,'YColorMode','axesXLimModeType');
p.Visible = 'off';
p.FactoryValue = 'auto';

% Keeping track of whether the user changed the X and Y Colors:
p = schema.prop(h,'EdgeColorMode','axesXLimModeType');
p.Visible = 'off';
p.FactoryValue = 'auto';

% editing colormap from colorbar
p = schema.prop(h,'Editing','on/off');
p.AccessFlags.Init = 'on';
p.FactoryValue = 'off';
p.Visible = 'off';

% peer axes
p = schema.prop(h,'Axes','handle');
p.Visible = 'off';

% delete proxy for peer axes
p = schema.prop(h,'DeleteProxy','handle');
p.Visible = 'off';

pl = schema.prop(h, 'PropertyListeners', 'handle vector');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicSet = 'off';
pl.Visible = 'off';

pl = schema.prop(h, 'DeleteListener', 'handle');
pl.AccessFlags.Serialize = 'off';
pl.AccessFlags.PublicGet = 'off';
pl.AccessFlags.PublicSet = 'off';
p.Visible = 'off';

%-----------------------------------------------------------
% Set/Get Functions

%
% Location
%
function valStored = localSetLocation(h,valProposed)
valStored = valProposed;

% note that setting the location to manual has no ripple effect,
% so this case is omitted.
switch valProposed
    case {'North','SouthOutside'}
        setprivateprop(h, 'OrientationI', 'HorizontalBottom');
    case {'NorthOutside','South'}
        setprivateprop(h, 'OrientationI', 'HorizontalTop');
    case {'East','WestOutside'}
        setprivateprop(h, 'OrientationI', 'VerticalLeft');
    case {'EastOutside','West'}
        setprivateprop(h, 'OrientationI', 'VerticalRight');
end

%
% Orientation
%
function valStored = localSetOrientation(h,valProposed)
valStored = valProposed;

setprivateprop(h,'OrientationI',valProposed);
set(h,'Location','manual');
set(h,'OrientationMode','manual');

function valToCaller = localGetOrientation(h,valStored)
valToCaller = getprivateprop(h,'OrientationI');

