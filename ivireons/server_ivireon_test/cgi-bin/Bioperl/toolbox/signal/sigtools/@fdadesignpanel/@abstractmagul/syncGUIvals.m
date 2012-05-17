function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS Get the values from the GUI

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:39:23 $

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g),
    
    [upper, lower, strs] = setstrs(h);
    
    set(h, upper, get(g, 'UpperValues')');
    set(h, lower, get(g, 'LowerValues')');
end

% [EOF]
