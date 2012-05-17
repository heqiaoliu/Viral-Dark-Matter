function attachlisteners(this)
%ATTACHLISTENERS   Attach the WhenRenderedListeners to this object.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.5.4.11 $  $Date: 2006/06/27 23:38:07 $

twoanalyses_attachlisteners(this);

l = [ ...
    handle.listener(this, this.findprop('Filters'), 'PropertyPostSet', ...
        @lclfilters_listener); ...
    handle.listener(this, [this.findprop('SOSViewOpts') ...
        this.findprop('PolyphaseView') this.findprop('ShowReference')], ...
        'PropertyPostSet', @prop_listener); ...
    handle.listener(this.Filters, 'NewFs', @fs_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', [this.WhenRenderedListeners; l]);

% -------------------------------------------------------------------------
function fs_listener(this, eventData)

h = get(this, 'Handles');
title(h.axes(1), '');
title(h.axes(2), '');
updatetitle(this);
draw(this);

% -------------------------------------------------------------------------
function prop_listener(this, eventData)

h = get(this, 'Handles');
delete(get(h.axes(1), 'Title'));
delete(get(h.axes(2), 'Title'));
updatetitle(this);

draw(this);

% -------------------------------------------------------------------------
function lclfilters_listener(this, eventData)

l = get(this, 'WhenRenderedListeners');

l(end) = handle.listener(this.Filters, 'NewFs', @fs_listener);

set(this, 'WhenRenderedListeners', l);

deletehandle(this, 'legend');
draw(this);
updatelegend(this);

% [EOF]
