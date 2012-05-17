function dlgstruct = getDialogSchema(this,arg) %#ok
%GetDialogSchema Construct extension dialog.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2010/03/31 18:41:00 $

% Add the type tabs/tables
typePanel = getTypePanel(this);
typePanel.RowSpan = [1 1];
typePanel.ColSpan = [1 1];

% Add the buttons, options, ok, cancel, apply.
buttonGroup = getButtonGroup(this);
buttonGroup.RowSpan = [2 2];
buttonGroup.ColSpan = [1 1];

% Return DDG dialog structure
dlgstruct                     = this.StdDlgProps;
dlgstruct.Items               = {typePanel, buttonGroup};
dlgstruct.StandaloneButtonSet = {''};
dlgstruct.PreApplyMethod      = 'preApply';
dlgstruct.PostApplyMethod     = 'postApply';
dlgstruct.HelpMethod          = 'help';
dlgstruct.HelpArgs            = {this};
dlgstruct.HelpArgsDT          = {'handle'};
dlgstruct.DialogTag           = 'ExtmgrConfigDialog';

% -------------------------------------------------------------------------
function typePanel = getTypePanel(this)

hRegisterDb = this.Driver.RegisterDb;

types  = hRegisterDb.SortedTypeNames;  % cell-array of strings
nTypes = numel(types);  % # of extension types (= # of tabs in dialog)

if nTypes > 1

    typeTabs = cell(1,nTypes);

    % Create a tab panel for each extension type.
    for indx = 1:nTypes
        typeTabs{indx} = createTabForType(this, types{indx}, indx);
        if any(strcmp(types{indx}, this.HiddenTypes))

            typeTabs{indx}.Visible = false;
        end
    end

    % Create main prefs panel
    typePanel.Type               = 'tab';
    typePanel.Tag                = 'TypeTabGroup';
    typePanel.Tabs               = typeTabs;
    typePanel.ActiveTab          = getActiveTab(this);
    typePanel.TabChangedCallback = 'extmgr.ConfigDialog.changeDlgTab';
else

    % Create a panel for the only type instead of tabs.
    typePanel = createTabForType(this, types{1}, 1);
    typePanel.Type  = 'panel';
end

% -------------------------------------------------------------------------
function tabPanel = createTabForType(this,type,typeIdx)
%createTabForType Return tab panel for one extension Type
%   These tabs include the extension table.  When there is only 1 type, we
%   do not have any tabs, and this tab panel is converted to a panel.

hConfigDb   = this.Driver.ConfigDb;

% If the enable constraint for this type is "EnableAll", we do not allow
% the user to interact with the enable checkboxes at all. That is, the
% enables should be left on (enabled) at all times.
enable = ~isEnableAll(this, type);

% Get the configurations that match the current type.
hRegisters = findVisibleRegisters(this, type);

% When the type is constrained to "EnableAll" do not show the checkboxes.
colHeaders   = {'Name', 'Description'};
colWidth     = [8 42];
readOnlyCols = [0 1];
if enable
    cols         = 3;
    colHeaders   = [{'Enabled'} colHeaders];
    colWidth     = [6 colWidth - [0 7]];
    readOnlyCols = readOnlyCols+1;
else
    if isAllEnableAll(this)
        colWidth = [6 35];
    end
    cols = 2;
end

% Preallocate the rows/columns for the table
nType = length(hRegisters);
data  = repmat({struct('Type', '', ...
    'Source', [], ...
    'ObjectProperty', '', ...
    'Enabled', false)}, nType, cols);

if length(this.SelectedExtensions) < typeIdx
    this.SelectedExtensions = [this.SelectedExtensions ...
        zeros(1, typeIdx-length(this.SelectedExtensions))];
end

% Create rows in table, based on registered extensions
for indx = 1:nType

    % Get Register.
    hConfig = findConfig(hConfigDb, hRegisters(indx));
    if isempty(hConfig)
        error(generatemsgid('MissingConfig'), 'ASSERT: Config should not be empty');
    end

    fName = getFullName(hRegisters(indx));

    col = 1;
    if enable

        % Enable checkbox - dynamic/can be changed
        data{indx,col}.Type           = 'checkbox';
        data{indx,col}.Source         = hConfig;
        data{indx,col}.ObjectProperty = 'Enable';
        data{indx,col}.Enabled        = enable;
        data{indx,col}.Tag            = sprintf('%s_checkbox', fName);
        data{indx,col}.Mode           = true;
        col = col+1;
    end

    % Name of extension: static info
    data{indx,col}.Type           = 'edit';
    data{indx,col}.Source         = hConfig;
    data{indx,col}.ObjectProperty = 'Name';
    data{indx,col}.Enabled        = true;
    data{indx,col}.Tag            = sprintf('%s_name', fName);

    col = col+1;

    % Description: static info
    data{indx,col}.Type           = 'edit';
    data{indx,col}.Source         = hRegisters(indx);
    data{indx,col}.ObjectProperty = 'Description';
    data{indx,col}.Enabled        = true;
    data{indx,col}.Tag            = sprintf('%s_description', fName);
end

% Define extension-enable table for the current type.
table.Type                 = 'table';
table.Tag                  = [type '_table'];
table.Size                 = [nType cols];
table.Data                 = data;
table.RowSpan              = [1 1];
table.ColSpan              = [1 1];
table.Editable             = true;
table.ColHeader            = colHeaders;
table.MinimumSize          = [100 nType*21+21];
table.SelectedRow          = this.SelectedExtensions(typeIdx);
table.ReadOnlyColumns      = readOnlyCols;  % 0-based column indices
table.ColumnCharacterWidth = colWidth;

% We cannot use this code to produce a "simple" dialog when there is only
% one type because of g365313.  This is preventing us from placing a table
% on a non-tab container when the HeaderVisibility is non-default.  Use
% RowHeaderWidth set to 0 to get around this.
% table.HeaderVisibility           = [0 1];
table.RowHeaderWidth             = 0;
table.ValueChangedCallback       = ...
    @(hDlg, row, col, newValue) valueChanged(hDlg, row, col, newValue, enable, type);
table.CurrentItemChangedCallback = ...
    @(hDlg, row, col) currentItemChanged(hDlg, row, type, typeIdx);

% Create a nice tab name, capitalize first letter
% Ex: if type is 'tools', tab name is "Tools"
tabPanel.Name       = [upper(type(1)) lower(type(2:end))];
tabPanel.Tag        = [type '_tab'];
tabPanel.Items      = {table};

% -------------------------------------------------------------------------
function btn_group = getButtonGroup(this)
% Define the Options buttons and the OK/Cancel/Apply buttons.  These are
% defined here instead of letting DDG use the defaults so that the 4
% buttons can be in the same row.

ok.Type         = 'pushbutton';
ok.Name         = ' OK ';
ok.RowSpan      = [1 1];
ok.ColSpan      = [3 3];
ok.ObjectMethod = 'callbacks';
ok.MethodArgs   = {'ok', '%dialog'};
ok.ArgDataTypes = {'string', 'handle'};
ok.Tag          = 'OK';

items = {ok};

% If any of the dialog's extensions have options, show the button.
if hasOptions(this)
    options.Type         = 'pushbutton';
    options.Name         = ' Options ... ';
    options.RowSpan      = [1 1];
    options.ColSpan      = [1 1];
    options.ObjectMethod = 'callbacks';
    options.MethodArgs   = {'editOptions', '%dialog'};
    options.ArgDataTypes = {'string', 'handle'};
    options.Tag          = 'Options';
    options.Enabled      = isOptionsEnabled(this);
    items = [{options} items];
end

% If all of the types are "EnableAll", i.e. there are no checkboxes, then
% there is nothing to Apply (or Cancel) so we do not need to show those
% buttons.
if ~isAllEnableAll(this)

    cancel.Type         = 'pushbutton';
    cancel.Name         = ' Cancel ';
    cancel.RowSpan      = [1 1];
    cancel.ColSpan      = [4 4];
    cancel.ObjectMethod = 'callbacks';
    cancel.MethodArgs   = {'cancel', '%dialog'};
    cancel.ArgDataTypes = {'string', 'handle'};
    cancel.Tag          = 'Cancel';

    apply.Type         = 'pushbutton';
    apply.Name         = ' Apply ';
    apply.RowSpan      = [1 1];
    apply.ColSpan      = [5 5];
    apply.ObjectMethod = 'callbacks';
    apply.MethodArgs   = {'apply', '%dialog'};
    apply.ArgDataTypes = {'string', 'handle'};
    apply.Tag          = 'Apply';
    apply.Enabled      = false;

    items = [items {apply, cancel}];
end

btn_group.Type       = 'panel';
btn_group.Tag        = 'ActionButtons';
btn_group.Items      = items;
btn_group.LayoutGrid = [1 5];
btn_group.ColStretch = [0 1 0 0 0];

% -------------------------------------------------------------------------
function valueChanged(hDlg, row, col, newValue, enabled, type)
% Needed so that Apply button enables properly and the checkboxes are
% updated depending on the Constraints.

hDlg.setEnabled('Apply', true);

% We only need to check when the enable changes.
if col ~= 0 || ~enabled
    return;
end

% Get this from the source of the dialog.
this = hDlg.getSource;

% Get the Constraint object from the registry.
constraint = getConstraint(this.Driver.RegisterDb.RegisterTypeDb, type);

% Allow the constraint to modify this.
constraint.tableValueChanged(this.Driver.ConfigDb, this.Driver.RegisterDb, ...
    hDlg, row, newValue);

% Make sure that the row that is changed becomes the current row.
hDlg.selectTableRow([type '_table'], row);

% Make sure that the enable state of the Options button reflects the newly
% selected extension.
hDlg.setEnabled('Options', isOptionsEnabled(this, type, row));

% -------------------------------------------------------------------------
function currentItemChanged(hDlg, row, type, index)
% Updates the selected row and the Options button

% Update the table's current row.
hDlg.selectTableRow([type '_table'], row);

this = getSource(hDlg);

oldSelect = get(this, 'SelectedExtensions');

% To avoid flicker, return early when we are not changing the row.
if oldSelect(index) == row
    return;
end

oldSelect(index) = row;

% Cache the newly selected row.
set(this, 'SelectedExtensions', oldSelect);

% Make sure that the enable state of the Options button reflects the newly
% selected extension.
hDlg.setEnabled('Options', isOptionsEnabled(this, type, row));

% Update the table's current row.
hDlg.selectTableRow([type '_table'], row);

% -------------------------------------------------------------------------
function y = hasOptions(this)
% Returns false if all the constraints are EnableAll and getPropsSchema is
% empty for all extensions.

if isAllEnableAll(this)
    hEDb = get(this.Driver, 'ExtensionDb');
    y = false;
    hExt = hEDb.down;
    while ~y && ~isempty(hExt)
        y = ~isempty(feval(hExt.Register, 'getPropsSchema', hExt.Config, []));
        hExt = hExt.right;
    end
else
    y = true;
end

% -------------------------------------------------------------------------
function y = isAllEnableAll(this)

allTypes = get(this.Driver.RegisterDb, 'SortedTypeNames');
y = true;
for indx = 1:length(allTypes)
    y = y && isEnableAll(this, allTypes{indx});
end

% -------------------------------------------------------------------------
function y = isEnableAll(this,type)
%local_isEnableAll True if type has constraint EnableAll or if it is
%   EnableOne and there is only 1 extension of that type.

hConstraint = getConstraint(this.Driver.RegisterDb.RegisterTypeDb, type);
y = hConstraint.isEnableAll(this.Driver.ConfigDb);

% -------------------------------------------------------------------------
function activeTab = getActiveTab(this)

hidTypes  = this.HiddenTypes;

% If the 'SelectedType' is pointing at a hidden type, pick the first
% visible one.
[visTypes, visTabs] = setdiff(this.Driver.RegisterDb.SortedTypeNames, hidTypes);
visTabs = sort(visTabs)-1; % Get 0 based indices
if isempty(visTabs)
    activeTab = 0;
else
    if ~any(this.SelectedType == visTabs)
        this.SelectedType = visTabs(1);
    end

    % Compensate for any hidden types that appear at or before the ActiveTab.
    activeTab = find(visTabs == this.SelectedType)-1;
end

% [EOF]
