function DialogPanel = getDialogInterface(this, manager)
%  GETDIALOGINTERFACE  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/12/04 23:26:52 $

% Get the panel
DialogPanel = javaMethodEDT('getInstance','com.mathworks.toolbox.slcontrol.ControlDesignDialogPanels.ValidSignalSelectTablePanel');

% Get the table model
TableModel = DialogPanel.getTableModel;

% Get the current data
if isempty(this.ListData)
    TableModel.clearRows;
else
    TableModel.data = this.ListData;
end

% Set the highlight selected signal callback
h = handle(DialogPanel.getHighlightSignalButton, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalHighlightSignal, this};

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHighlightSignal(es,ed,this)

% Get the selected row
DialogPanel = javaMethodEDT('getInstance','com.mathworks.toolbox.slcontrol.ControlDesignDialogPanels.ValidSignalSelectTablePanel');
row = DialogPanel.getTable.getSelectedRow+1;

if row > 0
    % Get the block and port handle
    block_signal = this.Signals{row};
    % Find the signal delimiter
    ind = strfind(block_signal,':');
    port_number = str2double(block_signal(ind(end)+1:end));
    block = block_signal(1:ind(end)-1);
    try
        ph = get_param(block,'PortHandles');
        port = ph.Outport(port_number);
        hilite_system(port,'find');pause(1);hilite_system(port,'none')
    catch Ex
        str = sprintf('The block %s is no longer in the model.',block);
        errordlg(str,'Simulink Control Design')
    end
else
    str = sprintf('Please select signal.');
    warndlg(str,'Simulink Control Design')
end
