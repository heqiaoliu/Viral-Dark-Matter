function setGUIvals(h, eventData) %#ok
%SETGUIVALS

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:39:09 $

hfreqspecs = findhandle(h, whichframes(h));

if ~isempty(hfreqspecs),

    [strs, lbls] = setstrs(h);
    nonbwlbl = getnonbwlabel(h);

    % Cache the fs so that the set on Units does not overwrite it.
    set(hfreqspecs, ...
        'Units', get(h,'freqUnits'), ...
        'Fs', get(h, 'Fs'), ...
        'Values', get(h, strs), ...
        'Labels', lbls, ...
        'nonbwlabel', nonbwlbl, ...
        'nonBW', get(h, nonbwlbl), ...
        'BandWidth', get(h, 'BandWidth'));
    
    switch lower(h.transitionmode)
        case {'bandwidth', 'none'}
            set(hfreqspecs, 'TransitionMode', h.transitionmode);
        otherwise
            set(hfreqspecs, 'TransitionMode', 'nonbw');
    end
end

% [EOF]
