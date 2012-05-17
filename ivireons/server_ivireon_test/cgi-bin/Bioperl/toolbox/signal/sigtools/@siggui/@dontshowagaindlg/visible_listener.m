function visible_listener(this, eventData)
%VISIBLE_LISTENER   Listener to the visible property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:22:58 $

set(this.FigureHandle, 'Visible', this.Visible);

% [EOF]
