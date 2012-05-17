%
% Standalone dialog for view management. Supports high level operations
% on all the views.
%
function dlg = getStandaloneDialogSchema(h)

%   Copyright 2009-2010 The MathWorks, Inc.

newViewButton.Type               = 'pushbutton';
newViewButton.Tag                = 'new_view_button';
newViewButton.Name               = DAStudio.message('Shared:DAS:NewAction');
newViewButton.MatlabMethod       = 'MEViewManager_cb';
newViewButton.MatlabArgs         = {'%dialog', 'doNewView'};   
newViewButton.RowSpan            = [1 1];
newViewButton.ColSpan            = [1 1];

copyViewButton.Type             = 'pushbutton';
copyViewButton.Tag              = 'copy_view_button';
copyViewButton.Name             = DAStudio.message('Shared:DAS:CopyAction');
copyViewButton.MatlabMethod     = 'MEViewManager_cb';
copyViewButton.MatlabArgs       = {'%dialog', 'doCopyView'};
copyViewButton.RowSpan          = [1 1];
copyViewButton.ColSpan          = [2 2];

deleteViewButton.Type           = 'pushbutton';
deleteViewButton.Tag            = 'delete_view_button';
deleteViewButton.Name           = DAStudio.message('Shared:DAS:DeleteAction');
deleteViewButton.MatlabMethod   = 'MEViewManager_cb';
deleteViewButton.MatlabArgs     = {'%dialog', 'doDeleteView'};
deleteViewButton.RowSpan        = [1 1];
deleteViewButton.ColSpan        = [3 3];
% Do not allow to delete last view.
deleteViewButton.Enabled       = length(find(h.VMProxy, '-isa', 'DAStudio.MEView')) > 1;
    
exportViewButton.Type           = 'pushbutton';
exportViewButton.Tag            = 'export_view_button';
exportViewButton.Name           = DAStudio.message('Shared:DAS:ExportAction');
exportViewButton.MatlabMethod   = 'MEViewManager_cb';
exportViewButton.MatlabArgs     = {'%dialog', 'doExportView'};
exportViewButton.RowSpan        = [1 1];
exportViewButton.ColSpan        = [4 4];
    
importViewButton.Type           = 'pushbutton';
importViewButton.Tag            = 'import_view_button';
importViewButton.Name           = DAStudio.message('Shared:DAS:ImportAction');
importViewButton.MatlabMethod   = 'MEViewManager_cb';
importViewButton.MatlabArgs     = {'%dialog', 'doImportView'};
importViewButton.RowSpan        = [1 1];
importViewButton.ColSpan        = [5 5];

optionsViewButton.Type          = 'pushbutton';
optionsViewButton.Tag           = 'options_view_button';
optionsViewButton.Name          = DAStudio.message('Shared:DAS:OptionsButton');
optionsViewButton.Menu          = getManageOptionsMenu(h);    
optionsViewButton.RowSpan       = [1 1];
optionsViewButton.ColSpan       = [6 6];
    
spacerView.Type                 = 'panel';
spacerView.RowSpan              = [1 1];
spacerView.ColSpan              = [7 7];

viewManagerButtonBar.Type       = 'panel';
viewManagerButtonBar.Tag        = 'view_manager_button_bar';
viewManagerButtonBar.Visible    = true;
viewManagerButtonBar.Items      = {newViewButton, copyViewButton, ...
                                   deleteViewButton, exportViewButton, ...
                                   importViewButton, optionsViewButton, ...
                                   spacerView};

viewManagerButtonBar.LayoutGrid = [1 7];
viewManagerButtonBar.ColStretch = [0 0 0 0 0 0 1];
viewManagerButtonBar.RowSpan    = [1 1];
viewManagerButtonBar.ColSpan    = [1 1];

data = {};
allViews = h.VMProxy.getAllViews;
totalRows = length(allViews);
for i = 1:totalRows
    data{i, 1}.Type = 'edit';
    data{i, 2}.Type = 'edit';
    data{i, 1}.Value = '';
    data{i, 2}.Value = '';
    if i <= length(allViews)
        data{i, 1}.Value = allViews(i).Name;                
        data{i, 2}.Value = allViews(i).Description;
    end
end

viewManagerTable.Type             = 'table';
viewManagerTable.Tag              = 'view_manager_table';
viewManagerTable.Source           = h;
viewManagerTable.Graphical        = true;
viewManagerTable.Grid             = true;
viewManagerTable.ColHeader        = {DAStudio.message('Shared:DAS:ViewID'), ...
                                    DAStudio.message('Shared:DAS:DescriptionID')};
viewManagerTable.HeaderVisibility = [0 1];
viewManagerTable.ReadOnlyColumns  = [];
viewManagerTable.MultiSelect      = true;
viewManagerTable.Editable         = true;
viewManagerTable.Data             = data;
viewManagerTable.Size             = size(data);
viewManagerTable.ValueChangedCallback  = @onTableValueChanged;
viewManagerTable.CurrentItemChangedCallback = @onTableCurrentChanged;
viewManagerTable.RowSpan          = [1 4];
viewManagerTable.ColSpan          = [1 1];
viewManagerTable.SelectionBehavior= 'Row';
viewManagerTable.AutoTranslateStrings = 0;
viewManagerTable.TableKeyPressCallback = @onTableKeyPress;

spacerTop.Type                 = 'panel';
spacerTop.RowSpan              = [1 1];
spacerTop.ColSpan              = [2 2];

viewButtonUp.Type              = 'pushbutton';
viewButtonUp.Tag               = 'up_view_button';
viewButtonUp.ToolTip           = '';
viewButtonUp.FilePath          = fullfile(matlabroot, 'toolbox', ...
                                    'shared', 'dastudio', 'resources', ...
                                    'move_up.gif');
viewButtonUp.MatlabMethod      = 'MEViewManager_cb';
viewButtonUp.MatlabArgs        = {'%dialog', 'doViewUp'};
viewButtonUp.RowSpan           = [2 2];
viewButtonUp.ColSpan           = [2 2];
viewButtonUp.Enabled           = false;

viewButtonDown.Type            = 'pushbutton';
viewButtonDown.Tag             = 'down_view_button';
viewButtonDown.ToolTip         = '';
viewButtonDown.FilePath        = fullfile(matlabroot, 'toolbox', ...
                                    'shared', 'dastudio', 'resources', ...
                                    'move_down.gif');
viewButtonDown.MatlabMethod    = 'MEViewManager_cb';
viewButtonDown.MatlabArgs      = {'%dialog', 'doViewDown'};
viewButtonDown.RowSpan         = [3 3];
viewButtonDown.ColSpan         = [2 2];
    
spacerDown.Type                = 'panel';
spacerDown.RowSpan             = [4 4];
spacerDown.ColSpan             = [2 2];

viewManagerTabelPanel.Type     = 'panel';
viewManagerTabelPanel.Items    = {viewManagerTable, spacerTop, ...
                                  viewButtonUp, viewButtonDown, ...
                                  spacerDown};
viewManagerTabelPanel.LayoutGrid = [4 2];
viewManagerTablePanel.RowStretch = [1 0 0 1];
viewManagerTablePanel.RowStretch = [1 0];
viewManagerTablePanel.RowSpan    = [2 2];
viewManagerTablePanel.ColSpan    = [1 1];
    
            
dlg.DialogTitle         = DAStudio.message('Shared:DAS:ViewManagerDialogTitle');
dlg.DialogTag           = 'me_view_manager_dialog_ui';    
dlg.CloseCallback       = 'viewManagerDialogCallback';    
dlg.CloseArgs           = {h, '%closeaction'};
dlg.HelpMethod          = 'helpview';
dlg.HelpArgs            = {[docroot '/toolbox/simulink/helptargets.map'], 'ModelExplorer_ViewManager_HelpButton'};
dlg.StandaloneButtonSet = {'Ok', 'Cancel', 'Help'};
dlg.Items               = {viewManagerButtonBar, viewManagerTabelPanel};
dlg.LayoutGrid          = [2 1];
dlg.RowStretch          = [0 1];

%
% Table selection changed callback handler
%
function onTableCurrentChanged(dlg, ~, ~)
% Enable disable buttons
MEViewManager_cb(dlg, 'doEnableDisableButtons');

%
% Handle changes in view management dialog
%
function onTableValueChanged(dlg, r, c, ~)
h = dlg.getSource();

viewName  = dlg.getTableItemValue('view_manager_table', r, 0);
viewDesc  = dlg.getTableItemValue('view_manager_table', r, 1);

% Validate rename if any change in view name, description is ok.
if c == 0
    ignoreChange = isempty(strtrim(viewName));
    if ignoreChange == false
        oldView = h.VMProxy.getView(viewName);
        if isempty(oldView)
            allViews = h.VMProxy.getAllViews;
            % TODO: Reordering of views might change this logic.
            view = allViews(r+1);
            if ~isempty(view)            
                % If this was active view, change it
                if ~isempty(h.VMProxy.getActiveView)
                    if strcmp(view.Name, h.VMProxy.ActiveView.Name)
                        h.VMProxy.ActiveView = view;
                    end
                end
                % This will no more be an internal factory view.
                if ~isempty(view.InternalName)
                    view.InternalName = '';
                end
                view.Name = viewName;
            end
        else
            ignoreChange = true;
        end
    end
    % Ignore any change
    if ignoreChange
        allViews = h.VMProxy.getAllViews;
        % TODO: Reordering of views might change this logic.
        view = allViews(r+1);
        dlg.setTableItemValue('view_manager_table', r, 0, view.Name);
    end
else
    allViews = h.VMProxy.getAllViews;
    view = allViews(r+1);
    if ~isempty(view)            
        view.Desc = viewDesc;    
    end
end

%
% Key press event on table
%
function onTableKeyPress(dlg, tag, key)
% Process only del key
if strcmp(tag, 'view_manager_table') && strcmp(key, 'Del')    
    MEViewManager_cb(dlg, 'doDeleteView');    
end

%
% Create menu on options button in view management dialog.
%
function menu = getManageOptionsMenu(manager)

% Hold on to the allocated menu per MEViewManager instance
if isempty(findprop(manager, 'StandaloneOptionsMenu'))
    p = schema.prop(manager, 'StandaloneOptionsMenu', 'handle');
    p.Visible = 'off';
end

% Clean up any previously allocated menu along with its actions
if ishandle(manager.StandaloneOptionsMenu)
    delete(manager.StandaloneOptionsMenu.getChildren);
    delete(manager.StandaloneOptionsMenu);
    manager.StandaloneOptionsMenu = [];
end

am   = DAStudio.ActionManager;
menu = am.createPopupMenu(manager.Explorer);

action = am.createAction(manager.Explorer);
action.Tag      = 'manage_options_hide_and_apply';
action.text     = DAStudio.message('Shared:DAS:HideAndApplySuggestions');
action.toggleAction = 'on';
if strcmp(manager.SuggestionMode, 'auto')
    action.on = 'on';
else
    action.on = 'off';
end
action = addCallbackData(action, {'hideApplySuggestions', manager.VMProxy});
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
menu.addMenuItem(action);

menu.addSeparator();

action = am.createAction(manager.Explorer);
action.Tag      = 'manage_options_resetAll';
action.text     = DAStudio.message('Shared:DAS:ResetAllToFactoryDotDotDot');
action.callback = ['MEViewManager_action_cb(' num2str(action.id) ')'];
action = addCallbackData(action, {'resetAllToFactory', manager});
menu.addMenuItem(action);

manager.StandaloneOptionsMenu = menu;

%
% TODO: Why addCallbackData in pvt folder not being called?
%
function action = addCallbackData(action, data)

schema.prop(action, 'callbackData', 'mxArray');
action.callbackData = data;
