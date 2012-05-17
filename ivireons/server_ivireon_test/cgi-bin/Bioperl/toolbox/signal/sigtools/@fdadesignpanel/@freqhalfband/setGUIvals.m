function setGUIvals(hObj, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2005/06/16 08:40:07 $

h = findhandle(hObj, whichframes(hObj));

if ~isempty(h),
    set(h, 'Units', get(hObj, 'freqUnits'));
    set(h, 'Fs', get(hObj, 'Fs'));
    
    if strncmpi(h.Units, 'normalized', 10),
        text = {'wc    =    1/2'};
    else
        text = {'Fc    =    Fs/4'};
    end
    
    set(h, 'Text', text);
end

% [EOF]
