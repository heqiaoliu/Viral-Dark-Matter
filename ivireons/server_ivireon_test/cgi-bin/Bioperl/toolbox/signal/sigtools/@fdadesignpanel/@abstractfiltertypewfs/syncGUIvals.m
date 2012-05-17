function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS Sync the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2005/06/16 08:39:06 $

hfreqspecs = findhandle(h, whichframes(h));

if ~isempty(hfreqspecs),
    
    set(h, 'freqUnits', get(hfreqspecs, 'Units'));
    set(h, 'Fs', get(hfreqspecs, 'Fs'));
    
    set(h, setstrs(h), get(hfreqspecs, 'Values')');
end

% [EOF]
