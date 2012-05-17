function buildClientContextMenu(dp)
% Create Client-specific context menus

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:28 $

% Invoke client handler, which is specific to a DPVerticalPanel
% Client function must accept hParent and hContextMenu handles as args
fcn = dp.BodyContextMenuHandler;
if ~isempty(fcn)
    fcn(dp.hParent,dp.hContextMenu);
end
