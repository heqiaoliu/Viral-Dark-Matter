function visible_listener(this, eventData)
%VISIBLE_LISTENER   Listener to 'visible'.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:30:16 $

set(this.FigureHandle, 'Visible', this.Visible);

% [EOF]
