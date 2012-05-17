function menu = getHeaderContextMenu(h, header)

%   Copyright 2009-2010 The MathWorks, Inc.

% Hold on to the allocated options menu per MEViewManager instance
if isempty(findprop(h.ViewManager, 'HeaderContextMenu'))
    p = schema.prop(h.ViewManager, 'HeaderContextMenu', 'handle');
    p.Visible = 'off';
end

% Clean up any previously allocated menu along with its actions & submenus
if ishandle(h.ViewManager.HeaderContextMenu)
    % submenu
    sub = find(h.ViewManager.Explorer, '-isa', 'DAStudio.PopupMenu',...
                                       'label', DAStudio.message('Shared:DAS:InsertHidden'));
    delete(sub.getChildren);
    delete(sub);
    
    % top level menu
    delete(h.ViewManager.HeaderContextMenu.getChildren);
    delete(h.ViewManager.HeaderContextMenu);
    manager.HeaderContextMenu = [];
end

menu   = [];
%header = strtrim(header);

am   = DAStudio.ActionManager;
menu = am.createPopupMenu(h.ViewManager.Explorer);
prop = [];

if ~isempty(h.Properties)
    prop = find(h.Properties, 'Name', header);

    if ~isempty(prop) && ~strcmp(prop.Name, 'Name')
        % Hide
        action = getHideAction(am, h);
        % add some useful information for processing this action
        action = addCallbackData(action, {'hide', prop, '', h});
        if slfeature('ModelExplorerPropertyFilter');
            % disable hide option if filter property
            if prop.isMatching
                action.enabled = 'off';
            end
        end
        menu.addMenuItem(action);
        
        if slfeature('ModelExplorerPropertyFilter');
            % Filter
            action = getFilterAction(am, h);
            % disable if matching property.
            if prop.isMatching
                isOn = 'on';
            else
                isOn = 'off';
            end
            action.on = isOn;
            % add some useful information for processing this action
            action = addCallbackData(action, {'isMatching', prop, '', h}); 
            menu.addMenuItem(action);
        end
        menu.addSeparator();
        
        % Insert Path
        action = getPathAction(am, h, header);
        menu.addMenuItem(action);
        
        % Insert Hidden if necessary
        sub = getInsertHidden(am, h, header);     
        menu.addSubMenu(sub, DAStudio.message('Shared:DAS:InsertHidden'));
        menu.addSeparator();
        
        if ~isempty(strtrim(header))
            menu.addSeparator();
            action = getGroupByAction(am, h, header);
            menu.addMenuItem(action);
        end
        if ~isempty(h.GroupName)
            action = getRemoveGroupAction(am, h, header);
            menu.addMenuItem(action);
        end
        
        menu.addSeparator();
        % Show details of this view
        action = getDetailsAction(am, h);
        menu.addMenuItem(action);
    else
        % Insert Path
        action = getPathAction(am, h, header);
        menu.addMenuItem(action);
        
        % Insert Hidden if necessary
        sub = getInsertHidden(am, h, header);     
        menu.addSubMenu(sub, DAStudio.message('Shared:DAS:InsertHidden'));
        menu.addSeparator();
        
        if ~isempty(strtrim(header))
            menu.addSeparator();
            action = getGroupByAction(am, h, header);
            menu.addMenuItem(action);
        end
        if ~isempty(h.GroupName)            
            action = getRemoveGroupAction(am, h, header);
            menu.addMenuItem(action);
        end
        
        menu.addSeparator();
        % Show details of this view
        action = getDetailsAction(am, h);
        menu.addMenuItem(action);
    end
else
    % Insert Path
    action = getPathAction(am, h, header);
    menu.addMenuItem(action);

    menu.addSeparator();
    % Show details of this view
    action = getDetailsAction(am, h);
    menu.addMenuItem(action);
end

h.ViewManager.HeaderContextMenu = menu;

end

%
% Hide action item on listview columns
%
function action = getHideAction(am, h)
    action = am.createAction(h.ViewManager.Explorer);
    action.Tag      = 'views_cm_hide';
    action.text     = DAStudio.message('Shared:DAS:HideID');
    action.callback = ['MEView_action_cb(' num2str(action.id) ')'];
end

%
% Filter action item on listview columns
%
function action = getFilterAction(am, h)    
    action = am.createAction(h.ViewManager.Explorer);
    action.Tag          = 'views_cm_filter';
    action.text         = ['Filter (show objects with this property)'];
    action.toggleAction = 'on';
    action.callback     = ['MEView_action_cb(' num2str(action.id) ')'];               
end

%
% Path action item on listview columns
%
function action = getPathAction(am, h, header)
    pathProperty = [];
    
    if ~isempty(h.Properties)
        pathProperty = find(h.Properties, 'Name', 'Path');
    end
    % Create one if we do not have this property already.
    if isempty(pathProperty)
        pathProperty = DAStudio.MEViewProperty('Path');
        pathProperty.isVisible = false;     
    end

    action = am.createAction(h.ViewManager.Explorer);
    action.Tag          = 'views_cm_insert_path';
    action.text         = DAStudio.message('Shared:DAS:InsertPath');
    action.callback     = ['MEView_action_cb(' num2str(action.id) ')'];
    action = addCallbackData(action, {'insertPath', pathProperty, header, h});
    
    if pathProperty.isVisible
        action.enabled = 'off';
    end
end

%
%
function action = getGroupByAction(am, h, header)    
    action = am.createAction(h.ViewManager.Explorer);
    action.Tag          = 'views_cm_group_by';
    action.text         = DAStudio.message('Shared:DAS:GroupByColumn');
    action.callback     = ['MEView_action_cb(' num2str(action.id) ')'];    
    action = addCallbackData(action, {'groupBy', header, h});
end

%
%
%
function action = getRemoveGroupAction(am, h, ~)
    action = am.createAction(h.ViewManager.Explorer);
    action.Tag          = 'views_cm_ungroup_by';
    action.text         = DAStudio.message('Shared:DAS:RemoveGrouping');
    action.callback     = ['MEView_action_cb(' num2str(action.id) ')'];    
    action = addCallbackData(action, {'removeGrouping', h});
end        
        
%
% Insert Recently Hidden
%
function menu = getInsertHidden(am, h, header)
    menu = am.createPopupMenu(h.ViewManager.Explorer);
    % Find the hidden properties.
    count = 0;
    hiddenProperties = find(h.Properties, 'IsVisible', false, 'isTransient', false);
    if ~isempty(hiddenProperties)
        for i = 1:length(hiddenProperties)
            % Path is not added to this list, it is a separate item.
            if ~strcmp(hiddenProperties(i).Name, 'Path')
                action = am.createAction(h.ViewManager.Explorer);
                action.text         = hiddenProperties(i).Name;        
                action.callback     = ['MEView_action_cb(' num2str(action.id) ')'];
                action = addCallbackData(action, {'insertHidden',  hiddenProperties(i), header, h});
                menu.addMenuItem(action);
                count = count + 1;
                if count == 5
                    break;
                end
            end
        end
    end
    if count == 0
        action = am.createAction(h.ViewManager.Explorer);
        action.text         = DAStudio.message('Shared:DAS:NoHiddenProperties');
        action.enabled      = 'off';
        menu.addMenuItem(action);
    end
end

% Search
% TODO: Disabled for now.
% action = am.createAction(h.ViewManager.Explorer);
% action.Tag         = 'views_cm_search_by_property';
% action.text         = 'Search by This Property';
% action.callback     = ['MEView_action_cb(' num2str(action.id) ')'];
% menu.addMenuItem(action);
%

%
% Show details of this view action.
%
function action = getDetailsAction(am, h)
action = am.createAction(h.ViewManager.Explorer);
action.Tag      = 'views_cm_customize';
action.text     = DAStudio.message('Shared:DAS:ShowDetailsCurrentView');
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
action.toggleAction = 'on';

if h.ViewManager.IsCollapsed
    action.on = 'off';
else
    action.on = 'on';
end
% add some useful information for processing this action
action = addCallbackData(action, {'customizeView', h.ViewManager});
end

%
% TODO: Why addCallbackData in pvt folder not being called?
%
function action = addCallbackData(action, data)

schema.prop(action, 'callbackData', 'mxArray');
action.callbackData = data;
end



