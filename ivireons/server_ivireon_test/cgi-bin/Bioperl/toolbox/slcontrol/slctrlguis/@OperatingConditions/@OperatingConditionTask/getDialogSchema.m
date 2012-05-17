function DialogPanel = getDialogSchema(this, ~)
%  GETDIALOGSCHEMA  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.6.24 $ $Date: 2010/05/10 17:57:49 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.OperatingConditionSpecificationPanels.OperatingConditionsSettingsPanel');

% Get and store the two tabbed panels
OpCondSpecPanel = javaObjectEDT(DialogPanel.getOpCondSpecPanel);
this.Handles.OpCondSpecPanel = OpCondSpecPanel;

% Configure the operation condition selection panel
this.Handles.OpCondSelectionPanel = OperatingConditions.OperatingConditionSelectionPanel(...
                                    DialogPanel.getOpCondSelectPanel,this); 

% Configure the delete and import operating conditions buttons
h = handle(DialogPanel.getDeleteConditionButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalDeleteOpCondCallback, this};

h = handle(DialogPanel.getImportConditionButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalImportOpCond, this};

h = handle(DialogPanel.getNewConditionButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalNewOpCond, this};

% Configure the input constraint table
this.configureInputConstraintTable;
% Configure the output constraint table
this.configureOutputConstraintTable;
% Configure the state constraint table
this.configureStateConstraintTable;
% Configure the compute operating conditions button
this.configureComputeOpCondButton;

% Configure the import initial value for operating spec button
h = handle(OpCondSpecPanel.getImportButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalImportOpSpec, this};

% Configure the import initial value for operating spec button
h = handle(OpCondSpecPanel.getSyncButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalSyncOpSpec, this};

% Configure the callback for the hyperlinks in the display
StatusArea = OpCondSpecPanel.getStatus;
editor = StatusArea.getEditor;
h = handle(editor, 'callbackproperties');
h.HyperlinkUpdateCallback = {@LocalEvaluateHyperlinkUpdate, this};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDuplicateOpPoint
function LocalNewOpCond(~,~,this)

% Create the new operating point
str = ctrlMsgUtils.message('Slcontrol:operpointtask:DefaultOperatingPointNodeLabel');
Label = this.createDefaultName(str, this);
newpoint = OperatingConditions.OperConditionValuePanel(this.down.OpPoint,Label);

% Connect it to the explorer
addNode(this,newpoint);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalEvaluateHyperlinkUpdate
function LocalEvaluateHyperlinkUpdate(~,hData,this)
if strcmp(hData.getEventType.toString, 'ACTIVATED')
    Description = char(hData.getDescription);
    typeind = findstr(Description,':');
    switch Description(1:typeind(1)-1)
        case 'block'
            block = char(Description(typeind(1)+1:end));
            try
                dynamicHiliteSystem(slcontrol.Utilities,block)
            catch Ex
                try
                    % Remove the Primitive Label for the block highlighting
                    PrimitiveInd = findstr(block,':');
                    block = block(1:PrimitiveInd(end)-1);
                    dynamicHiliteSystem(slcontrol.Utilities,block)
                catch Ex2
                    str = ctrlMsgUtils.message('Slcontrol:operpointtask:BlockNotAvailableHighlighting',block);
                    errordlg(str,'Simulink Control Design');
                end
            end
        case 'childnode'
            node = char(Description(typeind(1)+1:end));
            % Get the children of the operating task
            children = this.getChildren;
            % Find the matching node
            ind = find(strcmp(node,get(children,'Label')));
            if isempty(ind)
                errordlg(sprintf('The node %s does not exist in the current project.',node),...
                            'Simulink Control Design')
            else
                Frame = slctrlexplorer;
                Frame.setSelected(children(ind).getTreeNodeInterface);
            end            
    end
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalSyncOpSpec
function LocalSyncOpSpec(~,~,this)

% Update the operating specification data    
try
    this.OpSpecData = EvalOperSpecForms(this);
    this.OpSpecData.update;
catch Ex
    lastmsg = Ex.message;
    % Look for a hyperlink in an error message since we are reusing a
    % message with potential hyperlinks.
    lastmsg = regexprep(regexprep(lastmsg,'<(\w+).*?>',''),'</a>','');
    % Show error message
    str = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointSyncError',this.Model,lastmsg);
    titlestr = ctrlMsgUtils.message('Slcontrol:operpointtask:OperatingPointSyncErrorTitle');
    errordlg(str,titlestr)
end

% Repopulate table data with the data from the operating point
% Get the table data for the constraint table data
[this.InputSpecTableData,this.InputIndices] = this.getInputConstrTableData;
refreshInputConstrTable(this);
[this.OutputSpecTableData,this.OutputIndices] = this.getOutputConstrTableData;
refreshOutputConstrTable(this);
[this.StateSpecTableData,this.StateIndices] = this.getStateConstrTableData;
refreshStateConstrTable(this);

% Unselect the known checkbox and select the steady state checkbox
if ~isempty(this.OpSpecData.Inputs)
    s = get(this.OpSpecData.Inputs,{'Known'});
    this.Handles.OpCondSpecPanel.setInputFixedColumnCheckBoxSelected(all(vertcat(s{:})))
end
if ~isempty(this.OpSpecData.Outputs)
    s = get(this.OpSpecData.Outputs,{'Known'});
    this.Handles.OpCondSpecPanel.setOutputFixedColumnCheckBoxSelected(all(vertcat(s{:})))
end
if ~isempty(this.OpSpecData.States)
    s = get(this.OpSpecData.States,{'Known'});
    this.Handles.OpCondSpecPanel.setStateFixedColumnCheckBoxSelected(all(vertcat(s{:})))
    s = get(this.OpSpecData.States,{'SteadyState'});
    this.Handles.OpCondSpecPanel.setStateSteadyStateColumnCheckBoxSelected(all(vertcat(s{:})))
end

% Set the dirty flag
this.setDirty

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalImportOpSpec
function LocalImportOpSpec(~,~,this)

% Get the valid projects to import from the session
[~,Workspace] = slctrlexplorer;
openprojects = Workspace.getChildren;

names = get(openprojects,'Model');
pvalid = openprojects(strcmp(names,this.Model));

% Create the dialog and show it
dlg = jDialogs.OpcondImport(this.OpSpecData,pvalid,'import_initial_values');
% Set import function
dlg.importfcn = {@ImportOperSpecData,this,dlg};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ImportOperSpecData - Callback to import an operating point to the GUI
function ImportOperSpecData(this,dlg)

% Get the operating point from the dialog
op = getSelectedOperatingPoints(dlg);

if ~isempty(op)
    this.OpSpecData = initopspec(this.OpSpecData,op);
    
    % Repopulate table data with the data from the operating point
    [this.InputSpecTableData,this.InputIndices] = this.getInputConstrTableData;
    refreshInputConstrTable(this);
    [this.StateSpecTableData,this.StateIndices] = this.getStateConstrTableData;
    refreshStateConstrTable(this);
    
    % Set the dirty flag
    this.setDirty
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalImportOpCond - Callback to import an operating point
function LocalImportOpCond(~,~,this)

% Get the valid projects to import from
openprojects = this.up.up.getChildren;
ind = openprojects == this.up;
openprojects(ind) = [];

names = get(openprojects,'Model');
indvalid = strcmp(names,this.Model);
pvalid = openprojects(indvalid);

% Create the dialog and show it
dlg = jDialogs.OpcondImport(this.OpSpecData,pvalid,'import','MultiSelect',true);
dlg.importfcn = {@ImportOperPointData,this,dlg};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ImportOperPointData - Callback to import an operating point to the GUI
function ImportOperPointData(this,dlg)

% Get the operating point from the dialog
[op,names] = getSelectedOperatingPoints(dlg);

if ~isempty(op)
    for ct = 1:length(op)
        % Create the new node
        node = OperatingConditions.OperConditionValuePanel(op(ct),names{ct});

        % Add the new node to the operating point task
        this.addNode(node);
    end
    
    % Set the dirty flag
    this.setDirty
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeleteOpCondCallback - Callback to delete an operating condition.
function LocalDeleteOpCondCallback(~,~,this)

% Get the children of the operating conditions
Children = this.getChildren;

% Get the selected indices
rows = this.Handles.OpCondSelectionPanel.Handles.JavaPanel.OpCondTable.getSelectedRows+1;

% Delete the appropriate nodes
if (rows == 0)
    str = ctrlMsgUtils.message('Slcontrol:operpointtask:SelectOperatingPointToDelete');
    errordlg(str,'Simulink Control Design')
elseif (any(find(rows == 1)))
    str = ctrlMsgUtils.message('Slcontrol:operpointtask:DefaultOperatingPointCannotBeDeleted');
    errordlg(str,'Simulink Control Design')
else
    for ct = length(rows):-1:1
        this.removeNode(Children(rows(ct)));   
    end
    % Set the dirty flag
    this.setDirty
end

