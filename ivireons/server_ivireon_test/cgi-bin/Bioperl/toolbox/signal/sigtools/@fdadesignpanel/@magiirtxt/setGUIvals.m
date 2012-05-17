function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the gui values

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2007/03/13 19:50:19 $

frames = whichframes(h);
g = findhandle(h, frames{:});

set(g, 'Text', {'The attenuation at cutoff', '', 'frequencies is fixed at 3 dB', ...
        '','(half the passband power)'});

% [EOF]
