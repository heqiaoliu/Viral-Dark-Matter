function usesaxes_visible_listener(hObj, eventData)
%USESAXES_VISIBLE_LISTENER Make sure that the title is visible off.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:48 $

siggui_visible_listener(hObj, eventData);

if strcmpi(get(hObj, 'Visible'), 'on'),

    ht = get(getbottomaxes(hObj), 'Title');
    
    set(ht, 'Visible', get(hObj, 'Title'));
end

% [EOF]
