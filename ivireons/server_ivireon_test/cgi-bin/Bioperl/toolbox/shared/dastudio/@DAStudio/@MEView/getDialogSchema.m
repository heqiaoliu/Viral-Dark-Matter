function schema = getDialogSchema(h)

%   Copyright 2009-2010 The MathWorks, Inc.

%% Property Selector
search_edit.Type            = 'edit';
search_edit.Tag             = 'view_search_edit';
search_edit.ToolTip         = DAStudio.message('Shared:DAS:FindPropertiesSearch');
search_edit.Graphical       = true;
search_edit.RespondsToTextChanged = true;
search_edit.PlaceholderText = DAStudio.message('Shared:DAS:FindProperties');
search_edit.Clearable       = true;
search_edit.MatlabMethod    = 'MEView_cb';
search_edit.MatlabArgs      = {'%dialog', 'doFilterProperties'};
search_edit.RowSpan         = [1 1];
search_edit.ColSpan         = [1 1];
search_edit.MinimumSize     = [128 -1];

search_from_text.Type       = 'text';
search_from_text.Name       = DAStudio.message('Shared:DAS:PropertiesFrom');
search_from_text.RowSpan    = [1 1];
search_from_text.ColSpan    = [2 2];

search_from_combo.Type      = 'combobox';
search_from_combo.Tag       = 'view_search_from_combo';
search_from_combo.Entries   = {DAStudio.message('Shared:DAS:ObjectsInListView'), ...
                               DAStudio.message('Shared:DAS:ObjectsSelected')};
search_from_combo.Graphical    = true;
search_from_combo.Editable     = false;
search_from_combo.DialogRefresh = true;
search_from_combo.RowSpan      = [1 1];
search_from_combo.ColSpan      = [3 3];

% determine all properties in scope
entries   = {};
filterStr = getValueFromDialog(h, search_edit.Tag);
if ~h.ViewManager.IsCollapsed
    entries = calculatePossibleProperties(h, filterStr);
end

properties_list.Type        = 'listbox';
properties_list.Tag         = 'view_properties_list';
properties_list.Graphical   = true;
properties_list.Entries     = entries;
properties_list.RowSpan     = [2 2];
properties_list.ColSpan     = [1 3];
properties_list.AutoTranslateStrings = 0;
properties_list.ListDoubleClickCallback = @listDoubleClicked;

selector.Type               = 'panel';
selector.LayoutGrid         = [2 3];
selector.RowSpan            = [1 1];
selector.ColSpan            = [1 1];
selector.Items              = {search_edit, search_from_text, search_from_combo, properties_list};

%% Add to columns and delete columns
spacer_top.Type             = 'panel';
spacer_top.RowSpan          = [1 1];
spacer_top.ColSpan          = [1 1];

add_button.Type             = 'pushbutton';
add_button.Tag              = 'view_add_button';
add_button.ToolTip          = DAStudio.message('Shared:DAS:DisplayProperty');
add_button.FilePath         = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'add_row.gif');
add_button.MatlabMethod     = 'MEView_cb';
add_button.MatlabArgs       = {'%dialog', 'doAdd', h};
add_button.RowSpan          = [2 2];
add_button.ColSpan          = [1 1];

delete_button.Type          = 'pushbutton';
delete_button.Tag           = 'view_delete_button';
delete_button.ToolTip       = DAStudio.message('Shared:DAS:ColumnDelete');
delete_button.FilePath      = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'TTE_delete.gif');
delete_button.MatlabMethod  = 'MEView_cb';
delete_button.MatlabArgs    = {'%dialog', 'doRemove', h};
delete_button.RowSpan       = [3 3];
delete_button.ColSpan       = [1 1];

spacer_bottom.Type          = 'panel';
spacer_bottom.RowSpan       = [4 4];
spacer_bottom.ColSpan       = [1 1];

add.Type                    = 'panel';
add.Items                   = {spacer_top, add_button, delete_button, spacer_bottom};
add.LayoutGrid              = [4 1];
add.RowStretch              = [1 0 0 1];
add.RowSpan                 = [1 1];
add.ColSpan                 = [2 2];

%% Display columns
columns_text.Type           = 'text';
columns_text.Name           = DAStudio.message('Shared:DAS:DisplayColumns');
columns_text.RowSpan        = [1 1];
columns_text.ColSpan        = [1 2];

% determine all visible properties
data = {};
if ~isempty(h.Properties) && ~h.ViewManager.IsCollapsed
    props = find(h.Properties, 'isVisible', true, 'isTransient', false);
    propertyFilter = slfeature('ModelExplorerPropertyFilter');
    for i = 1:length(props)
        % This is a temporary solution for g589744.
        name = props(i).Name;
        dotLocation = strfind(name, '.');
        if ~isempty(dotLocation)
            nameToAppend = name(dotLocation(end)+1:end);
            name = [name ' (' nameToAppend ')'];
        end
        data{i, 1} = name;
        
        if propertyFilter
            data{i, 2}.Type  = 'checkbox';
            data{i, 2}.Value = props(i).isMatching;
        end
    end
end

columns_table.Type                  = 'table';
columns_table.Tag                   = 'view_columns_table';
columns_table.Source                = h;
columns_table.Graphical             = true;
columns_table.Grid                  = false;
columns_table.ColHeader             = {DAStudio.message('Shared:DAS:HeaderName'),...
                                       DAStudio.message('Shared:DAS:HeaderFilter')};
columns_table.HeaderVisibility      = [0 1];
columns_table.ReadOnlyColumns       = [0];
columns_table.MultiSelect           = false;
columns_table.Editable              = true;
columns_table.Data                  = data;
columns_table.Size                  = size(data);
columns_table.ValueChangedCallback  = @onTableValueChanged;
columns_table.CurrentItemChangedCallback = @onTableCurrentChanged;
columns_table.RowSpan               = [2 2];
columns_table.ColSpan               = [1 1];
columns_table.SelectionBehavior     = 'Row';
columns_table.AutoTranslateStrings = 0;
columns_table.TableKeyPressCallback    = @onTableKeyPress;

% table buttons to reorder
columns_spacer_top.Type                 = 'panel';
columns_spacer_top.RowSpan              = [1 1];
columns_spacer_top.ColSpan              = [1 1];

up_button.Type              = 'pushbutton';
up_button.Tag               = 'view_up_button';
up_button.ToolTip           = DAStudio.message('Shared:DAS:ColumnLeft');
up_button.FilePath          = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'move_up.gif');
up_button.MatlabMethod      = 'MEView_cb';
up_button.MatlabArgs        = {'%dialog', 'doUp', h};
up_button.RowSpan           = [2 2];
up_button.ColSpan           = [1 1];

down_button.Type            = 'pushbutton';
down_button.Tag             = 'view_down_button';
down_button.ToolTip         = DAStudio.message('Shared:DAS:ColumnRight');
down_button.FilePath        = fullfile(matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'move_down.gif');
down_button.MatlabMethod    = 'MEView_cb';
down_button.MatlabArgs      = {'%dialog', 'doDown', h};
down_button.RowSpan         = [3 3];
down_button.ColSpan         = [1 1];

columns_spacer_bottom.Type                 = 'panel';
columns_spacer_bottom.RowSpan              = [4 4];
columns_spacer_bottom.ColSpan              = [1 1];

columns_buttons.Type        = 'panel';
columns_buttons.Items       = {columns_spacer_top, up_button, down_button, columns_spacer_bottom};
columns_buttons.LayoutGrid  = [4 1];
columns_buttons.RowStretch  = [1 0 0 1];
columns_buttons.RowSpan     = [2 2];
columns_buttons.ColSpan     = [2 2];

columns.Type                = 'panel';
columns.Items               = {columns_text, columns_table, columns_buttons};
columns.LayoutGrid          = [2 2];
columns.RowSpan             = [1 1];
columns.ColSpan             = [3 3];

%% Button bar
spacer.Type             = 'panel';
spacer.RowSpan          = [1 1];
spacer.ColSpan          = [1 1];
    
optionsButton.Type        = 'pushbutton';
optionsButton.Tag         = 'views_options_button';
optionsButton.Menu        = getViewOptionsMenu(h);
optionsButton.Name        = DAStudio.message('Shared:DAS:OptionsButton');
optionsButton.RowSpan     = [1 1];
optionsButton.ColSpan     = [2 2];

button_bar.Type         = 'panel';
button_bar.Tag          = 'views_button_bar';
button_bar.Items        = {spacer, optionsButton};
button_bar.LayoutGrid   = [1 2];
button_bar.ColStretch   = [1 0];
button_bar.RowSpan      = [2 2];
button_bar.ColSpan      = [1 3];

%% Top level schema
schema.Type                 = 'panel';
schema.Items                = {selector, add, columns, button_bar};
schema.LayoutGrid           = [2 3];
schema.ColStretch           = [1 0 1];


%
% Get properties for listbox using scope options selected.
%
function props = calculatePossibleProperties(h, filterStr)
me    = h.ViewManager.Explorer;
props = {};
if ishandle(me)
    scopeValue = getValueFromDialog(h, 'view_search_from_combo');    
    if ~isempty(scopeValue)
        switch scopeValue
            case 0                
                props = me.getProperties('ListView');
            case 1
                props = me.getProperties('Selection');        
        end
    else
        % Get default
        props = me.getProperties('ListView');
    end
    
    % filter the property list if a filter string is supplied
    if ~isempty(filterStr)
        % make sure that the filter string doesn't contain useless whitespace
        filterStr = strtrim(filterStr);
        if ~isempty(filterStr)
            % use a case sensitive match if the filter string is mixed case
            % otherwise use a case insensitive match
            if strcmp(lower(filterStr), filterStr)
                matchingProperties = strfind(lower(props), filterStr);
            else
                matchingProperties = strfind(props, filterStr);
            end

            % filter!
            props = props(~cellfun('isempty', matchingProperties));
        end
    end
    
    % remove 'Name' from the list
    index = strmatch('Name', props, 'Exact');
    if ~isempty(index)
        props(index) = [];
    end
end


%
% Table value changed callback.
%
function onTableValueChanged(dlg, r, ~, value)
manager = dlg.getSource();
view    = manager.ActiveView;
name    = dlg.getTableItemValue('view_columns_table', r, 0);
prop = find(view.Properties, 'Name', name);
prop.isMatching = value;

%
% Table selection changed callback handler
%
function onTableCurrentChanged(dlg, ~, ~)
% Enable disable buttons
MEView_cb(dlg, 'doEnableDisableButtons');

%
% Key press event on table
%
function onTableKeyPress(dlg, tag, key)
% Process only del key
if strcmp(tag, 'view_columns_table') && strcmp(key, 'Del')
    manager = dlg.getSource();
    MEView_cb(dlg, 'doRemove', manager.ActiveView);
end

% helper functions --------------------------------------------------------
function value = getValueFromDialog(h, tag)
value  = [];
dialog = DAStudio.ToolRoot.getOpenDialogs(h.ViewManager);
if ~isempty(dialog) && dialog(1).isWidgetValid(tag)
    value = dialog(1).getWidgetValue(tag);
end

%
% Add property on double click
%
function listDoubleClicked(h, ~, ~)
manager = h.getSource;
MEView_cb(h, 'doAdd',manager.ActiveView);

%
% Create Options menu for options button
%
function menu = getViewOptionsMenu(h)
manager = h.ViewManager;
% Hold on to the allocated menu per MEViewManager instance
if isempty(findprop(manager, 'OptionsMenu'))
    p = schema.prop(manager, 'OptionsMenu', 'handle');
    p.Visible = 'off';
end

% Clean up any previously allocated menu along with its actions
if ishandle(manager.OptionsMenu)
    delete(manager.OptionsMenu.getChildren);
    delete(manager.OptionsMenu);
    manager.OptionsMenu = [];
end
am   = DAStudio.ActionManager;
menu = am.createPopupMenu(manager.Explorer);

action = am.createAction(manager.Explorer);
action.Tag      = 'views_options_manageViews';
action.text     = DAStudio.message('Shared:DAS:ManageViews');
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
action = addCallbackData(action, {'manageView', manager} );
menu.addMenuItem(action);
menu.addSeparator();

action = am.createAction(manager.Explorer);
action.Tag      = 'views_options_export';
action.text     = DAStudio.message('Shared:DAS:ExportDotDotDot');
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
action = addCallbackData(action, {'exportView', manager} );
menu.addMenuItem(action);
menu.addSeparator();

% Enable or show only if changed factory view /or a factory view
if ~isempty(manager.getActiveView)        
    % Check if this is really a factory view.
    if ~isempty(manager.ActiveView.InternalName)        
        % Get factory view settings.
        factoryView = manager.getFactoryViews(manager.ActiveView.Name);
        if ~isempty(factoryView)
            % This is a factory view.
            action = am.createAction(manager.Explorer);
            action.Tag      = 'views_options_resettofactory';
            action.text     = DAStudio.message('Shared:DAS:ResetToFactoryDotDotDot');
            % Enable if changed
            if AreSameViews(manager.ActiveView, factoryView)
                action.enabled = 'off';
            else
                action.enabled = 'on';
            end
            action = addCallbackData(action, {'resetToFactory', manager} );
            action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
            menu.addMenuItem(action);
            menu.addSeparator();
            factoryView.delete;
        end
    end    
end
manager.OptionsMenu = menu;

%
% Compare views: Name, Properties
% We will need to compare other attributes too.
%
function same = AreSameViews(v1, v2)
same = strcmp(v1.Name, v2.Name) ...
        && strcmp(v1.Description, v2.Description) ...
        && strcmp(v1.GroupName, v2.GroupName) && strcmp(v1.SortName, v2.SortName) ...
        && strcmp(v1.SortOrder, v2.SortOrder);
if same       
    % Both empty.
    if isempty(v1.Properties) && isempty(v2.Properties)
        same = true;
        return;
    end
    % One does not have any properties.
    if isempty(v1.Properties) && ~isempty(v2.Properties)
        same = false;
        return;
    end
    if ~isempty(v1.Properties) && isempty(v2.Properties)
        same = false;
        return;
    end
    % Quickly check length to decide.
    same = length(v1.Properties) == length(v2.Properties);
    % Compare properties.
    if same
        p1 = get(v1.Properties, 'Name');
        p2 = get(v2.Properties, 'Name');
        same = isequal(p1, p2);
        % Visibility/Hidden
        if same
            p1Visible = get(find(v1.Properties, 'isVisible', true), 'Name');
            p2Visible = get(find(v2.Properties, 'isVisible', true), 'Name');
            same = isequal(p1Visible, p2Visible);
        end
    end
end

%
% TODO: Why addCallbackData in pvt folder not being called?
%
function action = addCallbackData(action, data)

schema.prop(action, 'callbackData', 'mxArray');
action.callbackData = data;

