function clearmenus(h,manager,varargin)

% Copyright 2004 The MathWorks, Inc.

%% Refreshes the context menus (called when the set of views has changed)
if nargin==3 % Exclude node being deleted
    h.PopupMenu = h.getPopupSchema(manager,varargin{1});
else
    h.PopupMenu = h.getPopupSchema(manager);
end
manager.Cmenulistener.rmenu = h.PopupMenu;