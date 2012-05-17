function DialogPanel = getDialogSchema(this, manager)
%  GETDIALOGSCHEMA  Construct the dialog panel

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2008/12/04 23:27:24 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.GenericSimulinkSettingsObjects.OperatingConditionsValuePanel');

% Turn off the editability of the columns
statetm=DialogPanel.getStateCondTableModel;
statetm.setEditablecolumns({false,false})
inputtm=DialogPanel.getInputCondTableModel;
inputtm.setEditablecolumns({false,false})

% Configure the operating point tables
configureTablePanels(this,DialogPanel);