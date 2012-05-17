function enable_listener(hObj, eventData)
%ENABLE_LISTENER Listener to the enable property

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:21:07 $

h = get(hObj, 'Handles');

if strcmpi(hObj.Enable, 'Off'),
    
    props = getdisabledprops(hObj);
    
    % When the root is disabled, set its color to gray and disable its
    % buttondownfcn and uicontextmenu.
    set(h.line, 'ButtonDownFcn', [], 'UIContextMenu', [], props{:});
else
    
    % Reenable the callbacks and make sure the object looks right.
    if strcmpi(hObj.Current, 'Off'),
        props = getdefaultprops(hObj);
    else
        props = getcurrentprops(hObj);
    end
    set(h.line, 'HitTest', 'On', 'ButtonDownFcn', hObj.ButtonDownFcn, ...
        'UIContextMenu', hObj.UIContextMenu, props{:});
end

% [EOF]
