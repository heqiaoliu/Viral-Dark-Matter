function deletelineswithtag(hObj)
%DELETELINESWITHTAG Deletes the lines based on their tag

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/31 23:28:34 $

h = get(hObj, 'Handles');
delete(findobj(h.axes, 'type', 'line', 'tag', getlinetag(hObj)));

% [EOF]
