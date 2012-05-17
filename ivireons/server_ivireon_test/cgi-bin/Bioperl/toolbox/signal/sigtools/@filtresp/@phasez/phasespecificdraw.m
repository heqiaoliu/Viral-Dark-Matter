function phasespecificdraw(hObj)
%PHASESPECIFICDRAW

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/12 21:59:03 $

h = get(hObj, 'Handles');

hylbl = get(h.axes, 'YLabel');

if ~ishandlefield(hObj, 'phasecsmenu')
    h.phasecsmenu = contextmenu(getparameter(hObj, 'phase'), hylbl);
end

set(hObj, 'Handles', h);

% [EOF]
