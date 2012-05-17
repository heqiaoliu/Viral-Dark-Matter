function syncGUIvals(hObj, eventData) %#ok
%SYNCGUIVALS Sync the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:40:04 $

h = findhandle(hObj, whichframes(hObj));

if ~isempty(h),
    set(hObj, 'Fs', get(h, 'Fs'));
    set(hObj, 'freqUnits', get(h, 'Units'));
    set(hObj, 'freqSpecType', get(h, 'freqSpecType'));

    name = getdynamicname(h);
    set(hObj, name, get(h, name));
end

% [EOF]
