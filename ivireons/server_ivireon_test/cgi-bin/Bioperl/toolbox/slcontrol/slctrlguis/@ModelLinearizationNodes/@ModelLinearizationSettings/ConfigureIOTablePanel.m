function ConfigureIOTablePanel(this,DialogPanel)
% CONFIGUREIOTABLEPANEL  Configure the IOTable Panel.
%
 
% Author(s): John W. Glass 05-Mar-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:31:21 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IO Table Model
% Set the action callback for the analysis IO table model and store its
% handle
AnalysisIOTableModel = DialogPanel.IOPanel.IOTableModel;
this.Handles.AnalysisIOTableModel = AnalysisIOTableModel;
h = handle(this.Handles.AnalysisIOTableModel, 'callbackproperties' );
h.TableChangedCallback = {@LocalUpdateSetIOTableData, this};

% Set the table data for the linearization ios
this.updateIOTables;

% Set up listener for IO Data changes
this.IOListener = handle.listener(LinAnalysisTask.IODispatch,'ModelIOChanged',...
                                    {@LocalUpdateIOData this});

% Configure the highlight signal button
this.Handles.HighlightButton = DialogPanel.IOPanel.getHighlightButton;
h = handle(this.Handles.HighlightButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHighlightSignal, this};

% Configure the delete point button
this.Handles.DeletePointButton = DialogPanel.IOPanel.getDeletePointButton;
h = handle(this.Handles.DeletePointButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalDeletePoint, this};

% Configure the refresh signal button
this.Handles.RefreshSignalButton = DialogPanel.IOPanel.getRefreshSignalButton;
h = handle(this.Handles.RefreshSignalButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalRefreshSignalNames, this};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Local Functions 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateIOData - Callback for when the IO data changes
function LocalUpdateIOData(es,ed,this)

% Update the IO data
updateIOData(this,ed)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateSetIOTableData - Callback for the updating the IO table data
function LocalUpdateSetIOTableData(es,ed,this)

% Make sure the model is loaded
if ~isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',this.model))
    %% Set the IO Table data
    this.setIOTableData(this.Handles.AnalysisIOTableModel.data);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalHighlightSignal - Callback to highlight a signal
function LocalHighlightSignal(es,ed,this)

% Get the selected row
row = this.Dialog.IOPanel.IOTable.getSelectedRow+1;
 
if row > 0
    %% Get the block and port handle
    block = this.IOData(row).Block;
    port_number = this.IOData(row).PortNumber;
    try
        ph = get_param(block,'PortHandles');
        port = ph.Outport(port_number);
        hilite_system(port,'find');pause(1);hilite_system(port,'none')
    catch Ex
        str = sprintf('The block %s is no longer in the model',block);
        errordlg(str,'Simulink Control Design')
    end
else
    str = sprintf('Please select a linearization point.');
    warndlg(str,'Simulink Control Design')
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalDeletePoint - Callback to delete a linearization point
function LocalDeletePoint(es,ed,this)

% Get the selected row
row = this.Dialog.IOPanel.IOTable.getSelectedRow+1;
 
if row > 0
    this.IOData(row) = [];
    
    % Write the new settings to the Simulink model
    [oldio,newioset] = setlinio(this.model,this.IOData,'silent');

    if numel(newioset) ~= numel(this.IOData)
        % Throw a warning that other IO points were removed from the table
        % since they are no longer valid.
        str = sprintf('When modifying the linearization I/O using the Analysis I/O table there were linearization I/O points found that are no longer valid in the model %s or any of its child model references. These invalid I/O points have been removed from the Analysis I/O table.',this.model);
        warndlg(str,'Simulink Control Design')
        %% Update the tables
        this.IOData = newioset;
    end

    this.updateIOTables;

    %% Set the project dirty flag
    this.up.Dirty = 1;
else
    str = sprintf('Please select a linearization point.');
    warndlg(str,'Simulink Control Design')
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalRefreshSignalNames - Callback to refresh the signal names
function LocalRefreshSignalNames(es,ed,this)

% Sync the signal names
table_data = this.getIOTableData;
AnalysisIOTableModel = this.Handles.AnalysisIOTableModel;

if ~isempty(table_data)
    AnalysisIOTableModel.setData(table_data);
else
    AnalysisIOTableModel.clearRows;
end

% Set the project dirty flag
this.up.Dirty = 1;
