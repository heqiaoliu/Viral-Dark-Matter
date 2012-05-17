function attachlisteners(this)
%ATTACHLISTENERS

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:19:05 $

filtutils = get(this, 'FilterUtils');

l = [ ...
        handle.listener(filtutils, [filtutils.findprop('ShowReference'), ...
        filtutils.findprop('PolyphaseView') filtutils.findprop('Filters')], ...
        'PropertyPostSet', @lclfilter_listener) ...
        handle.listener(this.FilterUtils, filtutils.findprop('SOSViewOpts'), ...
        'PropertyPostSet', @sosview_listener); ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = get(this, 'Filters');
if length(Hd) == 1
    if isa(Hd.Filter, 'dfilt.abstractsos')
        lclfilter_listener(this, eventData);
    end
end

% ----------------------------------------------------------
function lclfilter_listener(this, eventData)

captureanddraw(this, 'both');

% [EOF]
