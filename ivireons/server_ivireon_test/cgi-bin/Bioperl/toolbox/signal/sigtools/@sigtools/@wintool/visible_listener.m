function visible_listener(hWT, eventData)
%VISIBLE_LISTENER Listener to the visible property of WinTool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/12/26 22:23:30 $

visState = get(hWT, 'Visible');

if strcmpi(visState, 'On'),
    sigcontainer_visible_listener(hWT, eventData);
end

set(hWT.FigureHandle, 'Visible', visState)

% [EOF]
