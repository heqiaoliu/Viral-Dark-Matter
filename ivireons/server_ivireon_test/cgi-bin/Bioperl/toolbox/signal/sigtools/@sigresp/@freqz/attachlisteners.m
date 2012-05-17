function attachlisteners(this)
%ATTACHLISTENERS   Attach the custom listeners.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:28 $

l = handle.listener(this, this.findprop('Spectrum'), 'PropertyPostSet', ...
    @spectrum_listener);
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% -------------------------------------------------------------------------
function spectrum_listener(this, eventData)

draw(this);

% [EOF]
