function ConfigureIOTablePanel(this,DialogPanel) 
% CONFIGUREIOTABLEPANEL  Configure the IOTable Panel.
%
 
% Author(s): John W. Glass 06-Sep-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/11/09 16:35:47 $

% Get the handle to the IOPanel
IOPanel = DialogPanel.getClosedLoopIOPanel;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input IO Table Model
InputIOTableModel = IOPanel.getInputIOTableModel;
this.Handles.InputIOTableModel = InputIOTableModel;
MATLABInputIOTableModel = handle(this.Handles.InputIOTableModel, 'callbackproperties' );
listener = handle.listener(MATLABInputIOTableModel,'tableChanged',...
             {@LocalUpdateSetInputIOTableData, this});
this.Handles.MATLABInputIOTableModel = [MATLABInputIOTableModel;listener];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output IO Table Model
OutputIOTableModel = IOPanel.getOutputIOTableModel;
this.Handles.OutputIOTableModel = OutputIOTableModel;
MATLABOutputIOTableModel = handle(this.Handles.OutputIOTableModel, 'callbackproperties' );
listener = handle.listener(MATLABOutputIOTableModel,'tableChanged',...
             {@LocalUpdateSetOutputIOTableData, this});
this.Handles.MATLABOutputIOTableModel = [MATLABOutputIOTableModel;listener];

% Set up listener for IO Data changes
this.IOListener = handle.listener(LinAnalysisTask.IODispatch,'ModelIOChanged',...
                                    {@LocalUpdateIOData this});
                                
% Update the tables
this.updateIOTables;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the mouse clicked callbacks for the tables
InputIOTable = IOPanel.getInputIOTable;
this.Handles.InputIOTable = InputIOTable;
h = handle(this.Handles.InputIOTable, 'callbackproperties' );
h.MouseClickedCallback = {@LocalInputTableMouseClick,this};

OutputIOTable = IOPanel.getOutputIOTable;
this.Handles.OutputIOTable = OutputIOTable;
h = handle(this.Handles.OutputIOTable, 'callbackproperties' );
h.MouseClickedCallback = {@LocalOutputTableMouseClick,this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configure the buttons
% Configure the highlight signal button
this.Handles.HighlightButton = IOPanel.getHighlightButton;
h = handle(this.Handles.HighlightButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHighlightSignal, this};

% Configure the delete point button
this.Handles.DeletePointButton = IOPanel.getDeletePointButton;
h = handle(this.Handles.DeletePointButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalDeletePoint, this};

% Configure the refresh signal button
this.Handles.RefreshSignalButton = IOPanel.getRefreshSignalButton;
h = handle(this.Handles.RefreshSignalButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalRefreshSignalNames, this};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateIOData - Callback for when the IO data changes
function LocalUpdateIOData(es,ed,this)

% Update the IO data
updateIOData(this,ed)

% Set the project dirty flag
this.setDirty;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalInputTableMouseClick - Callback when a user clicks the input table
function LocalInputTableMouseClick(es,ed,this)

% Clear the selection of the output table
javaMethodEDT('clearSelection',this.Handles.OutputIOTable);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalOutputTableMouseClick - Callback when a user clicks the output table
function LocalOutputTableMouseClick(es,ed,this)

% Clear the selection of the output table
javaMethodEDT('clearSelection',this.Handles.InputIOTable);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetInputIOTableData - Callback for the updating the IO table data
function LocalUpdateSetInputIOTableData(es,ed,this)

% Get the selected row
row = this.Dialog.getClosedLoopIOPanel.getInputIOTable.getSelectedRow+1;

% Get the new data
data = cell(this.Handles.InputIOTableModel.data);

% Update the model
LocalUpdateModelIO(this,data,row)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetOutputIOTableData - Callback for the updating the output IO table data
function LocalUpdateSetOutputIOTableData(es,ed,this)

% Get the selected row
row = this.Dialog.getClosedLoopIOPanel.getOutputIOTable.getSelectedRow+1;

% Get the new data
data = cell(this.Handles.OutputIOTableModel.data);

% Update the model
LocalUpdateModelIO(this,data,row)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateModelIO - Callback for the updating model IO due to changes
% in the table active column
function LocalUpdateModelIO(this,data,row)

% Determine the active flag
active = data{row,1};
if active 
    active = 'on';
else
    active = 'off';
end

% Get the block and port handle
block = data{row,2};
port_number = data{row,3};

% Find the IODATA objects corresponding to the selected block
ios = this.IOData;
indios = find(strcmp(get(ios,{'Block'}),block));

% Find the IODATA object corresponding to the selected port
ioports = get(ios(indios),{'PortNumber'});
indio = indios(find([ioports{:}] == port_number));
io = ios(indio);
io.Active = active;

% Update the model
[oldio,newioset] = setlinio(this.model,ios,'silent');
iochanged = numel(newioset) ~= numel(this.IOData);

if iochanged
    % Throw a warning that other IO points were removed from the table
    % since they are no longer valid.
    str = sprintf('When setting the activating/deactivating the closed loop signal for the block %s, there were closed loop signals that were no longer valid in the model %s or any of its child model references.  These invalid closed loop signals have been removed from the closed loop signal tables.',block,this.model);
    warndlg(str,'Simulink Control Design')
    this.IOData = newioset;
    updateIOTables(this);
end

% Update the table if the io is in-out or out-in.  This will deactivate
% the matching channel.
type = io.Type;
if strcmp(type,'inout') || strcmp(type,'outin') || (numel(newioset) ~= numel(this.IOData))
    %% Update the tables
    updateIOTables(this);
end

% Set the project dirty flag
this.setDirty;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHighlightSignal - Callback to highlight a signal
function LocalHighlightSignal(es,ed,this)

% Get the selected row.  This could be either of the tables
row = this.Dialog.getClosedLoopIOPanel.getInputIOTable.getSelectedRow+1;
if row == 0
    row = this.Dialog.getClosedLoopIOPanel.getOutputIOTable.getSelectedRow+1;
    data = cell(this.Dialog.getClosedLoopIOPanel.getOutputIOTableModel.data);
else
    data = cell(this.Dialog.getClosedLoopIOPanel.getInputIOTableModel.data);
end

if row > 0
    %% Get the block and port handle
    block = data{row,2};
    port_number = data{row,3};
    try
        ph = get_param(block,'PortHandles');
        port = ph.Outport(port_number);
        hilite_system(port,'find');pause(1);hilite_system(port,'none')
    catch
        str = sprintf('The block %s is no longer in the model',block);
        errordlg(str,'Simulink Control Design')
    end
else
    str = sprintf('Please select a signal in the tables above to highlight.');
    warndlg(str,'Simulink Control Design')
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeletePoint - Callback to delete a linearization point
function LocalDeletePoint(es,ed,this)

% Make sure the model is loaded
ensureOpenModel(slcontrol.Utilities,this.model);

% Get the selected row.  This could be either of the tables
row = this.Dialog.getClosedLoopIOPanel.getInputIOTable.getSelectedRow+1;
if row == 0
    row = this.Dialog.getClosedLoopIOPanel.getOutputIOTable.getSelectedRow+1;
    data = cell(this.Dialog.getClosedLoopIOPanel.getOutputIOTableModel.data);
    type = 'out';
else
    data = cell(this.Dialog.getClosedLoopIOPanel.getInputIOTableModel.data);
    type = 'in';
end

if row > 0
    ios = this.IOData;
    
    %% Get the block and port handle
    block = data{row,2};
    port_number = data{row,3};
    
    %% Find the linearization objects corresponding to the selected block
    indios = find(strcmp(get(ios,{'Block'}),block));

    %% Find the IDDATA object corresponding to the selected port
    ioports = get(ios(indios),{'PortNumber'});
    indio = indios(find([ioports{:}] == port_number));
       
    if strcmp(ios(indio).Type,type)
        this.IOData(indio) = [];
    else
        if strcmp(type,'in')
            this.IOData(indio).Type = 'out';
        else
            this.IOData(indio).Type = 'in';
        end
    end
    [oldio,newioset] = setlinio(this.model,this.IOData,'silent');
    
    if numel(newioset) ~= numel(this.IOData)
        % Throw a warning that other IO points were removed from the table
        % since they are no longer valid.
        str = sprintf('When deleting the closed loop signal for the block %s, there were other closed loop signals that were no longer valid in the model %s or any of its child model references. These invalid closed loop signals have been removed from the closed loop signal tables.',block,this.model);
        warndlg(str,'Simulink Control Design')
    end
        
    %% Update the tables
    this.IOData = newioset;
    updateIOTables(this);
    
    %% Set the project dirty flag
    this.up.Dirty = 1;
else
    str = 'Please select a signal in the tables above to delete.';
    warndlg(str,'Simulink Control Design')
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalRefreshSignalNames - Callback to refresh the signal names
function LocalRefreshSignalNames(es,ed,this)

% Update the tables
updateIOTables(this);
