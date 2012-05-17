function setGUIvals(h, eventData) %#ok
%SETGUIVALS Set the values in the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:39:22 $

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g),

    [upper, lower, strs] = setstrs(h);
    
    set(g, 'Labels', strs);
    set(g, 'UpperValues', get(h, upper));
    set(g, 'LowerValues', get(h, lower));

end

% [EOF]
