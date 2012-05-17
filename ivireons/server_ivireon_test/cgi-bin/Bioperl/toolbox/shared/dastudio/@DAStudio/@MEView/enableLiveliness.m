function enableLiveliness(h)
% ensure changes on this view propagate to the view manager

%   Copyright 2009-2010 The MathWorks, Inc.

% add listener to keep ME & MEViewManager in sync with Properties
p = findprop(h, 'Properties');
h.PropertiesListener = handle.listener(h, p, 'PropertyPostSet', @syncUIFromMEView);
p = findprop(h, 'GroupName');
h.GroupChangedListener = handle.listener(h, p, 'PropertyPostSet', {@syncUIFromMEViewProperty, h});

updateMEViewPropertyListeners(h);


function updateMEViewPropertyListeners(view)

% remove any existing listeners
view.MEViewPropertyListeners = [];

% add property listeners for the MEViewProperty properties
for i = 1:length(view.Properties)
    cls = classhandle(view.Properties(i));
    lnr = handle.listener(view.Properties(i), cls.Properties, 'PropertyPostSet', {@syncUIFromMEViewProperty, view});
    view.MEViewPropertyListeners = [view.MEViewPropertyListeners; lnr];
end


function syncUIFromMEView(~, eventData)

view = eventData.AffectedObject;

refreshUIs(view);
updateMEViewPropertyListeners(view);


function syncUIFromMEViewProperty(~, ~, view)

refreshUIs(view);

%
% Refresh ModelExplorer list.
%
function refreshUIs(view)
if ~isempty(view.ViewManager)
    exp = view.ViewManager.Explorer;
    % Set group property if any
    exp.GroupColumn = view.GroupName;
    if ~isempty(view.SortName)
        exp.SortColumn = view.SortName;
        exp.SortOrder = view.SortOrder;
    end
end
% Update the ME
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('ListChangedEvent');
