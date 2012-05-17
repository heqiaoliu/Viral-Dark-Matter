function setGUIvals(h,eventData) %#ok
%SETGUIVALS Set values from object in GUI.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2005/06/16 08:39:18 $

% Get handle to magspecs frame
fname = whichframes(h);
g     = findhandle(h, fname{:});

if ~isempty(g),
    
    [strs, lbls] = setstrs(h);
    
    set(g, 'Labels', lbls);
    set(g, 'Values', get(h, strs));

    % Set these last.  They will fire a syncGUIvals that will disrupt the values
    % if they are set first.
    set(g, 'IRType', get(h, 'IRType'));
    set(g, [get(h, 'IRType') 'units'], get(h, 'MagUnits'));
end

% [EOF]
