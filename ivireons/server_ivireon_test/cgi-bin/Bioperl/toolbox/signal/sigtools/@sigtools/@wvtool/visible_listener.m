function visible_listener(hV, eventData)
%VISIBLE_LISTENER Overload the base class method.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/12/26 22:23:36 $

hFig = get(hV, 'FigureHandle');
visState = get(hV, 'Visible');
set(hFig, 'Visible', visState);

hView = getcomponent(hV, '-class', 'siggui.winviewer');
set(hView, 'Visible', visState)

% [EOF]
