function activeView = getActiveView(h)
% Return active view of the view manager.

%   Copyright 2009 The MathWorks, Inc.
activeView = [];
if ishandle(h.activeView)
    % It could be empty. Called needs to check that.
    activeView = h.ActiveView;
end
