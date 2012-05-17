function fillRenderCache(h)
%fillRenderCache Cache widget properties to be restored after rendering.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2009/04/27 19:55:17 $

% uistatusbar implementation:
%  - cache the text,tooltip,callback
%  - ignore the StateName property, since it's just 'text' once again
%
% Must check if property is present
% Ex: It won't be present for a uibutton object that
% contains a uipushtool for a widget, since the 'state'
% property doesn't exist for that widget.
%
% Also, property could be empty for uigroup's, so
% take care for that as well.

theWidget = h.hWidget;
h.RenderCache = {'text', theWidget.text, ...
	             'tooltip', theWidget.tooltip, ...
				 'callback', theWidget.callback};

% [EOF]
