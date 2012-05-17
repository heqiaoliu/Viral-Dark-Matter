function deletelineswithtag(hObj)
%DELETELINESWITHTAG Deletes the lines based on their tag

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:28:21 $

h = get(hObj, 'Handles');
delete(findobj(h.axes, 'tag', getlinetag(hObj)));

% [EOF]
