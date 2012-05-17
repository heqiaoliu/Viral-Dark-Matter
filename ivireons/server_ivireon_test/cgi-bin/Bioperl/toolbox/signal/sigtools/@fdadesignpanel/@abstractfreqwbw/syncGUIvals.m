function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:39:10 $

hfreqspecs = findhandle(h, whichframes(h));

if ~isempty(hfreqspecs),
    
    nonbwlabel = getnonbwlabel(h);
    
    set(h, 'freqUnits', get(hfreqspecs, 'Units'), ...
        'Fs', get(hfreqspecs, 'Fs'), ...
        'Bandwidth', get(hfreqspecs, 'BandWidth'), ...
        nonbwlabel, get(hfreqspecs, 'nonBw'));
    
    p = setstrs(h);
    if ~isempty(p), set(h, p, get(hfreqspecs, 'Values')'); end
    
    if strcmpi(hfreqspecs.transitionmode, 'nonbw'),
        set(h, 'TransitionMode', nonbwlabel);
    else
        set(h, 'TransitionMode', 'Bandwidth');
    end
end

% [EOF]
