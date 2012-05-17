function dlg = getEmbeddedDialogSchema(h)

%   Copyright 2009-2010 The MathWorks, Inc.

[names index]           = calculateInstalledViews(h);

views.Type              = 'combobox';
views.Tag               = 'views_combo';
views.Name              = [DAStudio.message('Shared:DAS:SelectView') ' '];
views.Graphical         = true;
views.SaveState         = false;
views.Entries           = names;
views.Value             = index;
views.MatlabMethod      = 'MEViewManager_cb';
views.MatlabArgs        = {'%dialog', 'doViewChange', '%value'};
views.RowSpan           = [1 1];
views.ColSpan           = [1 1];

more.Type               = 'hyperlink';
more.Tag                = 'views_show_hide_details_link';
more.MatlabMethod       = 'MEViewManager_cb';
more.MatlabArgs         = {'%dialog', 'doExpandCollapse'};
more.RowSpan            = [1 1];
more.ColSpan            = [2 2];
more.Name               = '';
more.ToolTip            = '';

if h.isCollapsed
    more.Name = DAStudio.message('Shared:DAS:ShowDetails');
    more.ToolTip  = DAStudio.message('Shared:DAS:ExpandViewManager');
else
    more.Name = DAStudio.message('Shared:DAS:HideDetails');
    more.ToolTip  = DAStudio.message('Shared:DAS:CollapseViewManager');
end

[visible, possible] = countObjectsInView(h);
fPropsStr           = calculateFilterPropertiesString(h);

spacer.Type             = 'panel';
spacer.RowSpan          = [1 1];
spacer.ColSpan          = [3 3];

details.Type            = 'hyperlink';
details.Tag             = 'views_details_link';
details.MatlabMethod    = 'MEViewManager_cb';
details.MatlabArgs      = {'%dialog', 'doDetails', visible, possible, fPropsStr};
details.RowSpan         = [1 1];
details.ColSpan         = [4 4];

if visible == possible
    details.Name    = DAStudio.message('Shared:DAS:NumberInScope', visible);
    details.ToolTip = DAStudio.message('Shared:DAS:NumberInScopeFilteredTT');
else
    details.Name    = DAStudio.message('Shared:DAS:NumberInScopeFiltered', visible, possible);
    details.ToolTip = DAStudio.message('Shared:DAS:NumberInScopeFilteredTT');
end

% Hide it in search mode
if ishandle(h.Explorer)
    details.Visible = strcmp(h.Explorer.ViewMode, 'Content');
end

views_bar.Type          = 'panel';
views_bar.Tag           = 'views_bar';
views_bar.Items         = {views, more, spacer, details};
views_bar.LayoutGrid    = [1 4];
views_bar.ColStretch    = [0 0 1 0];

%% dynamic content based on active view visible when view manager is expanded
content.Type            = 'panel';
content.Tag             = 'views_content';
content.Items           = {};
content.Visible         = ~h.IsCollapsed;

view_schema = [];
if ~isempty(h.getActiveView) && ~h.IsCollapsed
    view_schema = h.ActiveView.getDialogSchema();
end

if ~isempty(view_schema)
    content.Items = {view_schema};
end

%% Suggestion GUI
view_suggestion_panel.Type            = 'panel';
view_suggestion_panel.Tag             = 'views_suggestion_panel';
view_suggestion_panel.Items           = {};

% Decide whether to generate suggestion GUI or not.
showSuggestion = false;
suggestedView = [];
reason        = '';
if strcmp(h.SuggestionMode, 'show')
    % Get suggested view.
    [suggestedView reason] = h.getSuggestedView();
    if ~isempty(suggestedView)
        % Sometimes, may be during initial launch it appears empty?            
        if ~isempty(h.getActiveView)
            % If views are different, make suggestion.
            if ~strcmp(suggestedView.Name, h.ActiveView.Name)  
                showSuggestion = true;
            end
        end
    end
end
view_suggestion_panel.Visible         = showSuggestion;
if showSuggestion
    suggestion_info_icon.Type        = 'image';
    suggestion_info_icon.Tag         = 'suggestion_info_icon';
    suggestion_info_icon.ToolTip     = '';
    suggestion_info_icon.FilePath    = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'info_suggestion.png');    
    suggestion_info_icon.RowSpan     = [1 1];
    suggestion_info_icon.ColSpan     = [1 1];
    
    suggestion_try_view.Type   = 'text';
    suggestion_try_view.Name   = DAStudio.message('Shared:DAS:TryViewTip');
    suggestion_try_view.Tag    = 'suggestion_try_view';
    suggestion_try_view.RowSpan = [1 1];
    suggestion_try_view.ColSpan = [2 2];
    
    % Which view was suggested?
    suggestion_view.Type            = 'hyperlink';
    suggestion_view.Tag             = 'views_suggestion_link';
    suggestion_view.MatlabMethod    = 'MEViewManager_cb';
    suggestion_view.MatlabArgs      = {'%dialog', 'doSuggestion'};
    suggestion_view.RowSpan         = [1 1];
    suggestion_view.ColSpan         = [3 3];
    suggestion_view.Name            = suggestedView.Name;
    
    % Why the view was suggested?
    suggestion_view_reason.Type     = 'text';
    suggestion_view_reason.Tag      = 'views_suggestion_reason';
    suggestion_view_reason.RowSpan  = [1 1];
    suggestion_view_reason.ColSpan  = [4 4];
    suggestion_view_reason.Name = reason;
    
    suggestion_spacer.Type             = 'panel';
    suggestion_spacer.RowSpan          = [1 1];
    suggestion_spacer.ColSpan          = [5 5];
    
    suggestion_close_icon.Type          = 'pushbutton';
    suggestion_close_icon.Tag           = 'suggestion_close_button';
    suggestion_close_icon.MaximumSize   = [15 15];
    suggestion_close_icon.BackgroundColor = [255 255 225];
    suggestion_close_icon.Menu          = getViewSuggestionsMenu(h);
    suggestion_close_icon.Name          = '';
    suggestion_close_icon.ToolTip       = '';
    suggestion_close_icon.FilePath      = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'down_arrow.png');
    suggestion_close_icon.Flat          = true;
    suggestion_close_icon.RowSpan       = [1 1];
    suggestion_close_icon.ColSpan       = [6 6];    
    
    view_suggestion_panel.BackgroundColor = [255 255 225];
    view_suggestion_panel.LayoutGrid      = [1 6];
    view_suggestion_panel.ColStretch      = [0 0 0 0 1 0];
    view_suggestion_panel.Items           = {suggestion_info_icon, suggestion_try_view, ...
                        suggestion_view, suggestion_view_reason, ...
                        suggestion_spacer, suggestion_close_icon};
end

%% top level UI specification dialog
dlg.DialogTitle         = '';
dlg.DialogTag           = 'me_view_manager_ui';
dlg.EmbeddedButtonSet   = {''};
dlg.IsScrollable        = false;
dlg.Items               = {views_bar, content, view_suggestion_panel};

function [names index] = calculateInstalledViews(h)
views = h.getAllViews;
names = get(views, 'Name');
if ~iscell(names)
    names = {names};    
end

index = -1;

if ~isempty(h.getActiveView)
    index = find(views == h.ActiveView) - 1;
end


function fPropsStr = calculateFilterPropertiesString(h)

fPropsStr = '';

if ~isempty(h.getActiveView)
    fProps = [];
    if ~isempty(h.ActiveView.Properties)
        fProps = get(find(h.ActiveView.Properties, 'isMatching', true), 'Name');
    end
    
    if isempty(fProps)
        return;
    end
    
    if ischar(fProps)
        fPropsStr = fProps;
    else
        fPropsStr = fProps{1};
        for i = 2:length(fProps)
            fPropsStr = [fPropsStr ' OR ' fProps{i}];
        end
    end
end

%
% Count possible and visible number of objects in listview.
%
function [visible possible] = countObjectsInView(h)
visible  = 0;
possible = 0;
if ishandle(h.Explorer)
    imme = DAStudio.imExplorer(h.Explorer);
    [visible possible] = imme.countListViewNodes;
    imme.delete;
end

%
% Create menu on Suggestions panel.
%
function menu = getViewSuggestionsMenu(manager)

% Hold on to the allocated menu per MEViewManager instance
if isempty(findprop(manager, 'SuggestionsMenu'))
    p = schema.prop(manager, 'SuggestionsMenu', 'handle');
    p.Visible = 'off';
end

% Clean up any previously allocated menu along with its actions
if ishandle(manager.SuggestionsMenu)
    delete(manager.SuggestionsMenu.getChildren);
    delete(manager.SuggestionsMenu);
    manager.SuggestionsMenu = [];
end

am   = DAStudio.ActionManager;
menu = am.createPopupMenu(manager.Explorer);

action = am.createAction(manager.Explorer);
action.Tag      = 'suggestion_option_hide';
action.text     = DAStudio.message('Shared:DAS:HideSuggestion');
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
action = addCallbackData(action, {'hideSuggestion', manager});        
menu.addMenuItem(action);        
menu.addSeparator();

action = am.createAction(manager.Explorer);        
action.Tag      = 'suggestion_option_hide_and_apply';
action.text     = DAStudio.message('Shared:DAS:HideAndApplySuggestions');
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
action.toggleAction = 'on';
if strcmp(manager.SuggestionMode, 'auto')
    action.on = 'on';
else
    action.on = 'off';
end
action = addCallbackData(action, {'hideApplySuggestions', manager});
menu.addMenuItem(action);

menu.addSeparator();

action = am.createAction(manager.Explorer);
action.Tag      = 'suggestion_whatis_this';
action.text     = 'What''s This?';
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
action = addCallbackData(action, {'suggestionsWhatIsThis', manager});
menu.addMenuItem(action);

manager.SuggestionsMenu = menu;

%
% TODO: Why addCallbackData in pvt folder not being called?
%
function action = addCallbackData(action, data)

schema.prop(action, 'callbackData', 'mxArray');
action.callbackData = data;
