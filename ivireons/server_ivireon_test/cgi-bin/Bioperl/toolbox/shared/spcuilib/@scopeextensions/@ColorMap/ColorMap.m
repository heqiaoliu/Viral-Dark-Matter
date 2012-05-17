function this = ColorMap(hVideo)
%ColorMap Constructor for uiscopes.ColorMap
% Manages updates to open dialog when property values change
% Installs listener of MPlay GUI to close dialog automatically

% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/03/09 19:33:01 $

this = scopeextensions.ColorMap;

this.Visual = hVideo;

% Initialize DialogBase properties
this.initExt('Colormap', hVideo.Application);

hRange = hVideo.findProp('UseDataRange');
hMin   = hVideo.findProp('DataRangeMin');
hMax   = hVideo.findProp('DataRangeMax');
hMapEx = hVideo.findProp('ColorMapExpression');

this.UserRangeProp     = hRange;
this.UserRangeMinProp  = hMin;
this.UserRangeMaxProp  = hMax;
this.MapExpressionProp = hMapEx;

% Set up the defaults
set(this, 'DataType', 'uint8');

this.setHelpArgs(this.hAppInst.ScopeCfg.getHelpArgs('ColorMap'));

this.PropListeners = [ ...
    handle.listener(hMapEx, hMapEx.findprop('Value'), 'PropertyPostSet', ...
    @(h, ev) lclColorMapExpressionChanged(this)); ...
    handle.listener(hRange, hRange.findprop('Value'), 'PropertyPostSet', ...
    @(h, ev) set(this, 'UserRange', hRange.Value)); ...
    handle.listener(hMin, hMin.findprop('Value'), 'PropertyPostSet', ...
    @(h, ev) updateScaling(this)); ...
    handle.listener(hMax, hMax.findprop('Value'), 'PropertyPostSet', ...
    @(h, ev) updateScaling(this))];

lclColorMapExpressionChanged(this);

% -------------------------------------------------------------------------
function lclColorMapExpressionChanged(this)

% Check that the map expression is valid.
[success, errmsg, mapValues] = validateMapExpression(this);
if ~success
    return;
end

% Set the new color map values evaluated in validateMapExpression.
set(this, 'HiddenMap', mapValues);

% [EOF]
