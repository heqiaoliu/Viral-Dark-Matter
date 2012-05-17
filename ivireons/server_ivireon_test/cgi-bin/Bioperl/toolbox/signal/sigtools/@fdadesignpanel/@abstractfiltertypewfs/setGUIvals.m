function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the GUI vals of the fsspecifier

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2005/06/16 08:39:05 $

hfreqspecs = findhandle(h, whichframes(h));

if ~isempty(hfreqspecs),

    % Cache the fs so that the set on Units does not overwrite it.
    set(hfreqspecs, 'Units', get(h,'freqUnits'));
    set(hfreqspecs, 'Fs', get(h, 'Fs'));
    
    [strs, lbls] = setstrs(h);
    
    set(hfreqspecs, 'Values', get(h, strs));
    set(hfreqspecs, 'Labels', lbls);
    
end

% [EOF]
