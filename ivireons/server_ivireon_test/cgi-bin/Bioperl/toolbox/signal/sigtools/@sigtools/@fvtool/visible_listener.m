function visible_listener(hFVT, eventData)
%VISIBLE_LISTENER Listener to the visible property of FVTool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:44:35 $

visState = get(hFVT, 'Visible');

if strcmpi(visState, 'on'),
    fvtool_visible_listener(hFVT, eventData);
end

hFig = get(hFVT,'FigureHandle');
set(hFig,'Visible', hFVT.Visible);

if strcmpi(visState, 'off'),
    fvtool_visible_listener(hFVT, eventData);
end

% [EOF]
