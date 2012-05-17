function siggui_visible_listener(hObj, eventData)
%SIGGUI_VISIBLE_LISTENER The listener for the visible property
%   Does the actual work

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2009/01/05 18:01:20 $

visState = get(hObj, 'Visible');

if isempty(hObj.Container) || ~ishghandle(hObj.Container)

    h = handles2vector(hObj);

    if length(h) == 1 && strcmp('uicontextmenu', get(h, 'Type')),
        h = [];
    else
        h(strcmp('uicontextmenu', get(h, 'Type'))) = [];
    end

    set(h,'Visible',visState);
else
    set(hObj.Container, 'Visible', visState);
end

% [EOF]
