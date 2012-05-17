function syncGUIvals(h, eventData) %#ok
%SYNCGUIVALS Sync values from frame.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:39:26 $

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g),
    
    set(h, setstrs(h), get(g, 'Values')');
end

% [EOF]
