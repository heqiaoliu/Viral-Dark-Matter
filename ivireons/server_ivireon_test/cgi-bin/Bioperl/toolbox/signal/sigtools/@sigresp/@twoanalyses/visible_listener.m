function visible_listener(hObj, eventData)
%VISIBLE_LISTENER Listener to the visible property

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:30:21 $

analysisaxis_visible_listener(hObj, eventData);

% The responses will always be rendered if the tworesps is rendered.
set(hObj.Analyses, 'Visible', hObj.Visible);

set(get(gettopaxes(hObj), 'XLabel'), 'Visible', 'Off');

h = get(hObj, 'Handles');

if isa(hObj.Analyses, 'sigresp.freqaxis'),
    setcoincidentgrid(h.axes);
else
    set(getline(hObj), 'Visible', 'On');
    set(h.axes, 'YLimMode', 'Auto');
    ylim = get(h.axes, 'YLim');
    set(getline(hObj), 'Visible', hObj.Visible);
    ylim = [ylim{:}];
    set(h.axes, 'YLim', [min(ylim), max(ylim)]);
end

% [EOF]
