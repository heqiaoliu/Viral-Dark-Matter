function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS Sync values from frame.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2005/06/16 08:39:20 $

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g),
    
    set(h, 'MagUnits', get(g, [get(h, 'IRType') 'units']));
    
    set(h, setstrs(h), get(g, 'Value')');
end

% [EOF]
