function enableLiveliness(h)
% ensure changes on this view hierarchy propagate

%   Copyright 2009-2010 The MathWorks, Inc.

% enable liveliness for all managed views
views = find(h, '-isa', 'DAStudio.MEView');
for i = 1:length(views)
    views(i).enableLiveliness;
end

% add listeners to keep MEViewManager in sync with view ME selection
h.MEListSelectionChangedListener = handle.listener(h.Explorer, 'MEListSelectionChanged', {@syncMEViewManagerFromME, h});
h.MEViewModeChangedListener = handle.listener(h.Explorer, 'MEViewModeChanged', {@syncMEViewManagerFromME, h});
h.MESearchPropertiesAddedListener = handle.listener(h.Explorer, 'MESearchPropertiesAdded', {@syncMEViewManagerFromME, h});
h.MESortChangedListener = handle.listener(h.Explorer, 'MESortChanged', {@syncMEViewManagerFromME, h});

% add listeners to enable persistence on ME close/delete
h.MEClosedListener = handle.listener(h.Explorer, 'MEPostClosed', {@modelExplorerClosed, h});
h.MEDeleteListener = handle.listener(h.Explorer, 'ObjectBeingDestroyed', {@modelExplorerClosed, h});

% add listener to keep ME & MEViewManager in sync with active view changes
p = findprop(h, 'ActiveView');
h.ActiveViewListener = handle.listener(h, p, 'PropertyPostSet', {@syncUI, h});

% add listeners to keep MEViewManager in sync with view addition/removal
h.MEViewAddedListener   = handle.listener(h, 'ObjectChildAdded',   @syncMEViewManager);
h.MEViewRemovedListener = handle.listener(h, 'ObjectChildRemoved', @syncMEViewManager);

% add listener to keep MEViewManager in sync with property changes
p = findprop(h, 'IsCollapsed');
h.IsCollapsedListener = handle.listener(h, p, 'PropertyPostSet', @syncMEViewManager);


function syncUI(~, ~, manager)
% Keep domain in sync
% Set domain active view here. Get domain first.
domain = find(manager.Domains, 'Name', manager.ActiveDomainName);
% Get active domain view first.
domainView = domain.getActiveView();
% If it is not already selected, Make it active view for that domain.
if isempty(domainView) || ~strcmp(domainView.Name, manager.ActiveView.Name)
	domainView = manager.ActiveView;
end
domain.setActiveView(domainView);        
% Clear transient properties if any.
clearTransientProperties(domainView);
% Set group property if any
manager.Explorer.GroupColumn = domainView.GroupName;
manager.Explorer.SortColumn = domainView.SortName;
if ~isempty(domainView.SortOrder)
    manager.Explorer.SortOrder = domainView.SortOrder;
else
    manager.Explorer.SortOrder = 'Asc';
end
% refresh the ME
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('ListChangedEvent');


function syncMEViewManager(~, eventData)

switch eventData.Type
    case {'ObjectChildAdded', 'ObjectChildRemoved'}
        manager = eventData.Source;
        
    case 'PropertyPostSet'
        manager = eventData.AffectedObject;
        
    otherwise
        error('unknown event type');
end

refreshMEViewManager(manager);


%
% Handle ME UI events.
%
function syncMEViewManagerFromME(~, eventData, manager)

switch eventData.Type
  case 'MEListSelectionChanged'
    doListSelectionChanged(eventData, manager);        
  case 'MEViewModeChanged'   
    doViewModeChanged(eventData, manager);    
  case 'MESearchPropertiesAdded'
    doSearchPropertiesAdded(eventData, manager);        
  case 'MESortChanged'
    doSortChanged(eventData, manager);       
  otherwise
    error('unknown event type');
end


function refreshMEViewManager(manager)

managerUI = DAStudio.ToolRoot.getOpenDialogs(manager);

for i = 1:length(managerUI)
    managerUI(i).refresh;
end

%
% Model explorer is closed or deleted. Write views
% and close any open dialogs or do other cleanup.
%
function modelExplorerClosed(~, ~, manager)
% Save manager data
manager.save(manager);
% Delete the standalone dialog.
dlg = DAStudio.ToolRoot.getOpenDialogs(manager);
for i = 1:length(dlg)
    if ~strcmp(dlg(i).dialogTag, 'me_view_manager_ui')
        dlg(i).delete;       
    end
end
% Delete any timer
if usejava('jvm')
   t = timerfind('Name', 'MEViewTimer');
   if ~isempty(t)
       stop(t);
       delete(t);
   end
end

%
% ModelExplorer list selection changed
%
function doListSelectionChanged(eventData, manager)

if slfeature('ModelExplorerHighlightRows')
    me = manager.Explorer;
    me.unhighlight;
    if strcmp(me.Scope, 'CurrentAndBelow')
        selection = eventData.EventData;
        if length(selection) == 1 && ~isempty(selection.getParent)
            highlightColor = [.9 1 1];
            me.highlight(selection.getParent, highlightColor);
        end
    end
end
if ~manager.isCollapsed
    % TODO: Refresh it only if option in Property-Scope combo is
    % 'Selected Objects in Spreadsheet/2'.
    refreshMEViewManager(manager);
end

%
% ModelExploer view mode changed
%
function doViewModeChanged(~, manager)

dlg = DAStudio.ToolRoot.getOpenDialogs(manager);
exp = manager.Explorer;
for i = 1:length(dlg)
    if strcmp(dlg(i).dialogTag, 'me_view_manager_ui')
        if strcmp(exp.ViewMode,'Content')
            dlg(i).setVisible('views_details_link', true);  
        else
            dlg(i).setVisible('views_details_link', false);  
        end
        break;
    end
end
% If view mode is search, add transient 'Path' property if not
% there already.    
actView = manager.ActiveView;
if strcmpi(exp.ViewMode, 'Search')
    % Add Path as first property.
    property = DAStudio.MEViewProperty('Path');
    property.isTransient = true;
    MEView_cb([], 'doAddProperty', actView, {property}, 'prepend');
else
    % Remove existing transient properties
    clearTransientProperties(actView);
end
exp.GroupColumn = actView.GroupName;

%
% ModelExplorer search properties added
%
function doSearchPropertiesAdded(eventData, manager)
% Add any properties as transient properties
propsToAdd = eventData.EventData;
if ~isempty(propsToAdd)
    exp = manager.Explorer;
    if strcmpi(exp.ViewMode, 'Search')
        % Remove this special property.
        index = strmatch('Name', propsToAdd, 'exact');
        if ~isempty(index)
            propsToAdd(index) = [];
        end
        actView = manager.ActiveView;
        % No need to do anything is everything is same. This does
        % not allow any change if search is execute again for any 
        % action.
        if ~isempty(actView.Properties)
            t = get(find(actView.Properties, 'isTransient', true), 'Name');
            p = propsToAdd;
            % Add path first
            p{end+1} = 'Path';
            if isequal(sort(t), sort(p))
                return;
            end
        end
        % Remove existing transient properties
        clearTransientProperties(actView);
        actView.disableLiveliness;
        % Add Path as first property.
        property = DAStudio.MEViewProperty('Path');
        property.isTransient = true;
        MEView_cb([], 'doAddProperty', actView, {property}, 'prepend');
        property = cell(1, length(propsToAdd));
        for i = 1:length(propsToAdd)
            propToAdd = char(propsToAdd{i});
            property{i} = DAStudio.MEViewProperty(propToAdd);
            property{i}.isTransient = true;
        end
        MEView_cb([], 'doAddProperty', actView, property, 'append');
        actView.enableLiveliness;                
    end
end


%
% ModelExplorer sort order changed
%
function doSortChanged(eventData, manager)
sortInfo = eventData.EventData;
% Update sort info for current view
actView = manager.ActiveView;
actView.SortName = char(sortInfo(1));
actView.SortOrder = char(sortInfo(2));
refreshMEViewManager(manager);       
        
%
% Utility function to clear transient properties
%
function clearTransientProperties(view)
% Clear transient properties
if ~isempty(view.Properties)
    transProps = find(view.Properties, 'isTransient', true);
    if ~isempty(transProps)
        view.disableLiveliness;
        allProps = get(view.Properties, 'Name');
        for i = 1:length(transProps)
            index = strmatch(lower(transProps(i).Name), ...
                             lower(allProps), 'exact');
            if ~isempty(index)
                % If it was a group property remove it. 
                if strcmp(view.Properties(index).Name, view.GroupName)
                    view.GroupName = '';
                end
                view.Properties(index) = [];
            end
            allProps = get(view.Properties, 'Name');
        end
        view.enableLiveliness;
    end
end

