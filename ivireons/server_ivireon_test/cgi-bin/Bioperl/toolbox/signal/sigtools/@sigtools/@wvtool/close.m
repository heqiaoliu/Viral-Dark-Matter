function close(hV)
%CLOSE Close WVTool.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/12/26 22:23:33 $

% Send an event
send(hV, 'WVToolClosing', []);

hFig = get(hV, 'FigureHandle');
hView = getcomponent(hV, '-class', 'siggui.winviewer');
destroy(hView);
destroy(hV);
delete(hFig);


% [EOF]
