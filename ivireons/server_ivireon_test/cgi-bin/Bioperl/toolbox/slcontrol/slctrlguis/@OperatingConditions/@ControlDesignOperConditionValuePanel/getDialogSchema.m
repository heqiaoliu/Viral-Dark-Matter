function DialogPanel = getDialogSchema(this, manager)
%  GETDIALOGSCHEMA  Construct the dialog panel

%   Author(s): John Glass
%   Revised:
%   Copyright 1986-2006 The MathWorks, Inc.
%	$Revision: 1.1.8.8 $  $Date: 2008/12/04 23:27:22 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.operating_points.operating_point_data.OperatingPointSummaryValuePanel');

% Configure the operating point tables
configureTablePanels(this,DialogPanel);

% Turn off the editability of the columns
statetm = DialogPanel.getStateCondTableModel;
statetm.setEditablecolumns({false,false})
inputtm = DialogPanel.getInputCondTableModel;
inputtm.setEditablecolumns({false,false})

% Add the import operating point button
ImportButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Import a New Operating Point...'));
ImportButton.setName('ImportButton');
ButtonPanel = DialogPanel.getButtonPanel;
ButtonPanel.add(ImportButton);

% Configure the import initial value for operating point button
h = handle(ImportButton, 'callbackproperties');
h.ActionPerformedCallback = {@localImportOpPoint, this};

% Update the summary table
this.updateSummary(DialogPanel);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localImportOpPoint(es,ed,this)

importOpPoint(this);