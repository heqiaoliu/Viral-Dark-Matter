function attachlisteners(this, fcn)
%ATTACHLISTENERS   Attach the WhenRenderedListeners

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/06 16:11:32 $

filtutils = get(this, 'FilterUtils');

l = handle.listener(filtutils, [filtutils.findprop('Filters'), ...
    filtutils.findprop('ShowReference') filtutils.findprop('PolyphaseView')], ...
    'PropertyPostSet', {@filters_listener, fcn});
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% ------------------------------------------------------------------
function filters_listener(this, eventStruct, fcn)

feval(fcn, this)

% [EOF]
