function h = tworesps(firstresp, secondresp)
%TWORESPS Abstract class

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.7 $  $Date: 2007/12/14 15:17:22 $

error(nargchk(1,2,nargin,'struct'));

switch length(firstresp)
    case 1
        error(nargchk(2,2,nargin,'struct'));
        resps = [firstresp, secondresp];
    case 2
        resps = firstresp;
    otherwise
        error(generatemsgid('InvalidDimensions'),'TWORESPS does not support more than 2 responses.');
end

h = filtresp.tworesps;
h.FilterUtils = filtresp.filterutils;
findclass(findpackage('dspopts'), 'sosview'); % g 227896
addprops(h, h.FilterUtils);

set(h, 'Filters', [resps(1).Filters]);
for indx = 1:length(resps), unrender(resps(indx)); end
set(h, 'Analyses', resps);

l = handle.listener(h, [h.findprop('Filters'), h.findprop('Title'), ...
    h.findprop('ShowReference') h.findprop('PolyphaseView'), ...
    h.findprop('SOSViewOpts')], 'PropertyPreSet', @lclprop_listener);

set(l, 'CallbackTarget', h);
set(h, 'Listeners', l);

% ----------------------------------------------------------------------
function lclprop_listener(hObj, eventData)

set(hObj.Analyses, get(eventData.Source, 'Name'), get(eventData, 'NewValue'));

% [EOF]
