function deletelineswithtag(hObj)
%DELETELINESWITHTAG Deletes the lines based on their tag

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2009/01/05 18:00:06 $

% when we can call super methods replace this with
% super::deletelineswithtag(hObj)
h = get(hObj, 'Handles');
if isfield(h, 'line')
    delete(h.line(ishghandle(h.line)));
end
% delete(findobj(h.axes, 'type', 'line', 'tag', getlinetag(hObj)));
% delete(findobj(h.axes, 'type', 'line', 'tag', 'timeresp_stemline'));

% [EOF]
