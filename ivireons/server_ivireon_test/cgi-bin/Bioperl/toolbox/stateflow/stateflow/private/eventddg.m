function dlgstruct = eventddg(h, name)
% Copyright 2002-2008 The MathWorks, Inc.

identityPane = identity_pane(h, 1); % Name and parent pane
propertyPane = property_pane(h, 2); % Scope, port, trigger pane
brkPointPane = brkpoint_pane(h, 3); % Breakpoint pane
descEditArea = desc_editarea(h, 4); % Description edit area
documentPane = document_pane(h, 5); % Document link and edit

items = {identityPane, propertyPane, brkPointPane, descEditArea, documentPane};
items = remove_empty_items(items);

%------------------------------------------------------------------
% Main dialog
%------------------------------------------------------------------
dlgstruct.DialogTitle = get_event_title(h);
dlgstruct.SmartApply = 0;
dlgstruct.DialogTag = create_unique_dialog_tag(h);
dlgstruct.CloseCallback = 'sf';
dlgstruct.CloseArgs = {'Private', 'eventddg_preclose_callback', '%dialog'};
dlgstruct.PreApplyCallback = 'sf';
dlgstruct.PreApplyArgs     = {'Private', 'eventddg_preapply_callback', '%dialog'};
dlgstruct.HelpMethod = 'sfhelp';
dlgstruct.HelpArgs = {h,'EVENT_DIALOG'};
dlgstruct.DisableDialog = ~is_object_editable(h);
dlgstruct.LayoutGrid = [5 1];
dlgstruct.RowStretch = [0 0 0 1 0];
dlgstruct.Items = items;

%------------------------------------------------------------------
% Determine the Entries and Values array of the scope combobox
%------------------------------------------------------------------
function scope = scope_of( eventId )
%
% Obtains the scope of an event
%
parent = sf('get',eventId,'.linkNode.parent');

if ~sf('ishandle',parent)
    scope.string = '';
    scope.values = [];
    warning('Stateflow:UnexpectedError','Event has an invalid parent.');
    return;
end

[MACHINE, CHART, STATE] = sf('get','default','machine.isa', 'chart.isa', 'state.isa');
switch sf('get',parent,'.isa')
    case MACHINE
        scope.string = {message('Local'),message('Exported'),message('Imported')};
        scope.values = [0,4,3];
    case CHART
        scope.string = {message('Local'),message('InputFromSimulink'),message('OutputToSimulink')};
        scope.values = [0,1,2];
    case STATE
        scope.string = {message('Local')};
        scope.values = 0;
    otherwise
        scope.string = '';
        scope.values = [];
        scope.value = 0;
        warning('Stateflow:UnexpectedError','Parent of event has an invalid class.');
        return;
end

return;

%------------------------------------------------------------------
% Construct scope combobox
%------------------------------------------------------------------
function cmbScope = scope_combobox(h, row, col)

cmbScope = [];

if isa(h, 'Stateflow.Event')
    cmbScope.Name           = [commonMessage('Scope') ':'];
    cmbScope.Type           = 'combobox';
    cmbScope.RowSpan        = [row row];
    cmbScope.ColSpan        = [col col];
    cmbScope.ObjectProperty = 'Scope';
    cmbScope.Mode           = 1;       %0 = batch, 1 = immediate refresh
    cmbScope.DialogRefresh  = 1;       %0 = no refresh, 1 = refresh

    % Show appropriate entries depending on the event's parent
    scp = scope_of(h.Id);
    cmbScope.Entries = scp.string;
    cmbScope.Values  = scp.values;
    cmbScope.Tag     = 'sfEventdlg_Scope:';
end

return;

%------------------------------------------------------------------
% Construct port combobox
%------------------------------------------------------------------
function cmbPort = port_combobox(h, row, col)

cmbPort = [];

if ~h.isValidProperty('Port')
    return;
end

cmbPort.Name           = [commonMessage('Port') ':'];
cmbPort.Type           = 'combobox';
cmbPort.RowSpan        = [row row];
cmbPort.ColSpan        = [col col];
cmbPort.ObjectProperty = 'Port';

allowedValStr = h.getPropAllowedValues('Port');
allowedValNum = NaN;
for i=1:length(allowedValStr)
    allowedValNum(i) = str2double(allowedValStr{i});
end

cmbPort.Entries = allowedValStr';
cmbPort.Values  = allowedValNum;
cmbPort.Tag     = 'sfEventdlg_Port:';

return;
  
%------------------------------------------------------------------
% Construct trigger combobox
%------------------------------------------------------------------
function cmbTrigger = trigger_combobox(h, row, col)
    
cmbTrigger = [];

if isa(h, 'Stateflow.FunctionCall')
    return;
end

switch h.scope
    case 'Input'
        cmbTrigger.Entries = {message('Either'), message('Rising'), message('Falling'), message('FunctionCall')};
    case 'Output'
        cmbTrigger.Entries = {message('EitherEdge'), message('FunctionCall')};
        cmbTrigger.Values  = [0, 3];
    otherwise
        return;
end

cmbTrigger.Name           = [commonMessage('Trigger') ':'];
cmbTrigger.Type           = 'combobox';
cmbTrigger.RowSpan        = [row row];
cmbTrigger.ColSpan        = [col col];
cmbTrigger.ObjectProperty = 'Trigger';
cmbTrigger.Tag            = 'sfEventdlg_Trigger:';

return;

%------------------------------------------------------------------
% Construct name, parent top pane
%------------------------------------------------------------------
function identityPane = identity_pane(h, row)
    
% Name field
txtName.Name           = [commonMessage('Name') ':'];
txtName.Type           = 'edit';
txtName.RowSpan        = [1 1];
txtName.ColSpan        = [1 2];
txtName.ObjectProperty = 'Name';
txtName.Tag            = 'sfEventdlg_Name:';

identityPane.Type = 'panel';
identityPane.RowSpan = [row row];
identityPane.LayoutGrid = [1 2];
identityPane.ColStretch = [0 1];
identityPane.Items = {txtName};

return;

%------------------------------------------------------------------
% Construct properties pane for scope, port and trigger type
%------------------------------------------------------------------
function propertyPane = property_pane(h, row)

propertyPane.Type = 'panel';
propertyPane.RowSpan = [row, row];
propertyPane.LayoutGrid = [1 3];
propertyPane.ColStretch = [0 0 1];
propertyPane.Items = {};
col = 1;

cmbScope = scope_combobox(h, 1, col);
if ~isempty(cmbScope)
    propertyPane.Items{end+1} = cmbScope;
    col = col + 1;
end

cmbPort = port_combobox(h, 1, col);
if ~isempty(cmbPort)
    propertyPane.Items{end+1} = cmbPort;
    col = col + 1;
end

cmbTrigger = trigger_combobox(h, 1, col);
if ~isempty(cmbTrigger)
    propertyPane.Items{end+1} = cmbTrigger;
end

return;

%------------------------------------------------------------------
% Construct breakpoints pane
%------------------------------------------------------------------
function pnlBreak = brkpoint_pane(h, row)

pnlBreak = [];

if ~isa(h, 'Stateflow.Event')
    return;
end

lblDBP.Name    = [message('DebuggerBreakpoints') ': '];
lblDBP.Type    = 'text';
lblDBP.RowSpan = [1 1];
lblDBP.ColSpan = [1 1];
lblDBP.Tag     = 'sfEventdlg_Debugger breakpoints: ';

chkSBC.Name    = message('StartBroadcast');
chkSBC.Type    = 'checkbox';
chkSBC.RowSpan = [1 1];
chkSBC.ColSpan = [2 2];
chkSBC.ObjectProperty = 'StartBroadcast';
chkSBC.Tag            = 'sfEventdlg_Start of Broadcast';

chkEBC.Name           = message('EndBroadcast');
chkEBC.Type           = 'checkbox';
chkEBC.RowSpan        = [1 1];
chkEBC.ColSpan        = [3 3];
chkEBC.ObjectProperty = 'EndBroadcast';
chkEBC.Tag            = 'sfEventdlg_End of Broadcast';

pnlBreak.Type         = 'panel';
pnlBreak.LayoutGrid   = [1 3];
pnlBreak.ColStretch   = [0 0 1];
pnlBreak.RowSpan      = [row row];
pnlBreak.Source       = h.Debug.Breakpoints;
pnlBreak.Items        = {lblDBP, chkSBC, chkEBC};
pnlBreak.Tag          = 'sfEventdlg_pnlBreak';

return;

%------------------------------------------------------------------
% Construct description editarea
%------------------------------------------------------------------
function desc = desc_editarea(h, row)

desc.Name           = [commonMessage('Description') ':'];
desc.Type           = 'editarea';
desc.WordWrap       = true;
desc.RowSpan        = [row row];
desc.ObjectProperty = 'Description';
desc.Tag            = 'sfEventdlg_Description';

return;

%------------------------------------------------------------------
% Construct document pane
%------------------------------------------------------------------
function pnlDoc = document_pane(h, row)

doclinkName.Name = [commonMessage('DocumentLink') ':'];
doclinkName.Tag = 'doclinkNameTag';
doclinkName.RowSpan = [1 1];
doclinkName.ColSpan = [1 1];
doclinkName.Type = 'hyperlink';
doclinkName.MatlabMethod = 'sf';
doclinkName.MatlabArgs = {'Private', 'dlg_goto_document', h.Id};

doclinkEdit.Name = '';
doclinkEdit.RowSpan = [1 1];
doclinkEdit.ColSpan = [2 2];
doclinkEdit.Type = 'edit';
doclinkEdit.ObjectProperty = 'Document';
doclinkEdit.Tag = 'sfEventdlg_doclinkEdit';

pnlDoc.Type = 'panel';
pnlDoc.LayoutGrid = [1 2];
pnlDoc.RowSpan = [row row];
pnlDoc.ColStretch = [0 1];
pnlDoc.Items = {doclinkName, doclinkEdit};

return;

%------------------------------------------------------------------
% Filter out empty items
%------------------------------------------------------------------
function items = remove_empty_items(items)

ei = zeros(1, length(items));
for i = 1:length(items)
    if isempty(items{i})
        ei(i) = 1;
    end
end

items(ei > 0) = [];
return;

%------------------------------------------------------------------
% Construct title
%------------------------------------------------------------------
function title = get_event_title(h)

switch h.class
    case 'Stateflow.Event'
        title = commonMessage('Event');
    case 'Stateflow.Trigger'
        title = commonMessage('Trigger');
    case 'Stateflow.FunctionCall'
        title = commonMessage('FunctionCall');
    otherwise
        error('Stateflow:UnexpectedError','Not an event object.');
end

title = [title ' ' h.Name];

% if the developer feature is on append the id to the title
if sf('Feature', 'Developer')
    title = [title ' #' sf_scalar2str(h.Id)];
end

return;

function s = commonMessage(id,varargin)

s = DAStudio.message(['Stateflow:dialog:Common' id],varargin{:});

function s = message(id,varargin)

s = DAStudio.message(['Stateflow:dialog:Event' id],varargin{:});
