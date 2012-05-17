function s = siggui_getstate(hObj)
%SIGGUI_GETSTATE Get the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:32:41 $

s = get(hObj);

if isrendered(hObj),
    s = rmfield(s, get(find(hObj.RenderedPropHandles, 'Visible', 'On'), 'Name'));
end

% [EOF]
