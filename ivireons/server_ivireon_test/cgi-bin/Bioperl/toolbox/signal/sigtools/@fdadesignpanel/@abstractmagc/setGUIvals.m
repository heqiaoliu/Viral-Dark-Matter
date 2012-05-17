function setGUIvals(h,eventData) %#ok
%SETGUIVALS Set values from object in GUI.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/06/16 08:39:12 $

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
    set(g, 'ConstrainedBands', get(h, 'ConstrainedBands'));
end

% [EOF]
