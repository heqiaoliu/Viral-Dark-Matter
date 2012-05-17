function startscribepinning(fig,onoff)
%STARTSCRIBEPINNING Turn annotation pinning mode on or off.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $  $

% find the togglebutton
pintogg = uigettool(fig,'Annotation.Pin');

scribeaxes = findScribeLayer(fig);

% if scribeaxes has no shapes or none of those shapes
% are rectangle, ellipse, textbox or arrow, then there is nothing to pin, so turn
% the pinning toggle off, set the cursor to an arrow and return
if isempty(get(scribeaxes,'Children'))
    if ~isempty(pintogg)
        set(pintogg,'state','off');
    end
    scribecursors(fig,0); 
    return;
end

% if this is being called by the toggle with just a fig arg and the toggle
% is now off, or called from elsewhere with onoff of 'off', turn pinning
% off. Otherwise turn it on.
if (nargin<2 && strcmpi(get(pintogg,'state'),'off')) || ...
        (nargin>1 && ischar(onoff) && strcmpi(onoff,'off'))
    pinning_onoff(fig,scribeaxes,pintogg,'off');
else
    pinning_onoff(fig,scribeaxes,pintogg,'on');
end

%----------------------------------------------------------------%
function pinning_onoff(fig,scribeaxes,pintogg,onoff)

hPlotEdit = plotedit('getmode');
if strcmpi(onoff,'on')
    % set scribeaxes pin mode
    scribeaxes.PinMode = 'on';
    % be sure plotedit is on
    plotedit('on');
    activateuimode(hPlotEdit,'Standard.ScribePin');
else
    scribeaxes.PinMode = 'off';
    activateuimode(hPlotEdit,'');
    % turn togglebutton off
    if ~isempty(pintogg)
        set(pintogg,'state','off');
    end
    scribecursors(fig,0); 
end

%----------------------------------------------------------------%