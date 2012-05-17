function DialogPanel = getDialogInterface(this, manager)
%  GETDIALOGINTERFACE  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%  Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.10.7 $ $Date: 2008/12/04 23:26:46 $

% Get the panel
if isempty(this.Dialog)
    DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.ControlDesignDialogPanels.ValidBlockSelectTablePanel');

    % Get the table model
    TableModel = DialogPanel.getTableModel;
    
    % Set the table callback.  Since the table is a singleton a singleton
    % listener needs to be created.
    h = handle(TableModel, 'callbackproperties' );
    this.TableListener = handle.listener(h,'tableChanged',{@LocalTableChangedCallback,this});

    % Set the highlight selected block callback
    h = handle(DialogPanel.getHighlightButton, 'callbackproperties' );
    h.ActionPerformedCallback = {@LocalHighlightBlock, this};
    this.Dialog = DialogPanel;
else
    DialogPanel = this.Dialog;
    % Get the table model
    TableModel = DialogPanel.getTableModel;
end

% Set the current node data
this.TableListener.Enabled = 'off';
if size(this.ListData,1) > 0
    TableModel.setData(this.ListData);
else
    TableModel.clearRows;
end
drawnow
this.TableListener.Enabled = 'on';

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Local Functions
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalTableChangedCallback(es,ed,this)

% Get the selected row
row = ed.JavaEvent.getFirstRow;
% Set the data
this.ListData{row+1,1} = es.getValueAt(row,0);
% Determine if their is an unapplied change
this.UnappliedSelectedElements(row+1,1) = true;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHighlightBlock(es,ed,this)

% Get the selected row
DialogPanel = this.Dialog;
row = DialogPanel.getTable.getSelectedRow+1;

% Highlight the selected block
% Get the full block name
if row >= 1
    block = this.Blocks{row};
    try
        util = slcontrol.Utilities;
        dynamicHiliteSystem(util,block);
    catch
        str = sprintf('The block %s is no longer in the model.',block);
        errordlg(str,'Simulink Control Design')
    end
else
    errordlg('There are no blocks currently selected.','Simulink Control Design')
end