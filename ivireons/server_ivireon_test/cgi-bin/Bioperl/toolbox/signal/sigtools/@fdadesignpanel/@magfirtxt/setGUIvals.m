function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the gui values

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2005/06/16 08:41:16 $

frames = whichframes(h);
g = findhandle(h, frames{:});

set(g, 'Text', {'The attenuation at cutoff', '', 'frequencies is fixed at 6 dB', ...
        '','(half the passband gain)'});

% [EOF]
