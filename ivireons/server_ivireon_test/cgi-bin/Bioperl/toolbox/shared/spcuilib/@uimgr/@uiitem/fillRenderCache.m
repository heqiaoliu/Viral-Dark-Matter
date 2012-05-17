function fillRenderCache(h)
%fillRenderCache Cache widget properties to be restored after rendering.
%   Render cache is only used for "state" property caching.
%   All other custom properties should be specified via the
%   custom property cache list, and/or the custom render cache.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2009/04/27 19:55:08 $

% Default implementation:
%  - cache the StateName property and value
%    (if it's a non-empty string)
%
% Must check if property is present
% Ex: It won't be present for a uibutton object that
% contains a uipushtool for a widget, since the 'state'
% property doesn't exist for that widget.
%
% Also, property could be empty for uigroup's, so
% take care for that as well.

theWidget = h.hWidget;
stateName = h.StateName;
if isempty(stateName) || ~isprop(theWidget,stateName)
	h.RenderCache = {};
else
	h.RenderCache = {stateName, get(theWidget, stateName)};
end

% [EOF]
