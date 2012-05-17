function objspecific_render(hObj)
%OBJSPECIFIC_RENDER

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:42:52 $

wrl = get(hObj, 'WhenRenderedListeners');

wrl = union(wrl, handle.listener(hObj, hObj.findprop('DisabledProps'), ...
    'PropertyPostSet', @disabledprops_listener));

set(wrl, 'CallbackTarget', hObj);
set(hObj, 'WhenRenderedListeners', wrl);

disabledprops_listener(hObj);

% [EOF]
