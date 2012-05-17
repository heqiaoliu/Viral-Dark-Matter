function deletelineswithtag(hObj)
%DELETELINESWITHTAG Deletes the lines based on their tag

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/23 18:58:18 $

h = get(hObj, 'Handles');
delete(findobj(h.axes, 'type', 'line', 'tag', getlinetag(hObj)));
delete(findobj(h.axes, 'tag', 'zplane_unitcircle'));

% [EOF]
