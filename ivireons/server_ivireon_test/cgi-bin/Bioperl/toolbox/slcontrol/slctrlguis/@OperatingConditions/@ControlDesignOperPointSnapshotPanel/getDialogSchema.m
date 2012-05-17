function DialogPanel = getDialogSchema(this, manager) %#ok<INUSD>
%  GETDIALOGSCHEMA  Construct the dialog panel

%   Author(s): John Glass
%   Revised:
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.5 $  $Date: 2009/05/23 08:21:40 $

% Add the settings pane to the frame
DialogPanel = javaObjectEDT('com.mathworks.toolbox.slcontrol.operating_points.operating_point_data.OperatingPointSnapshotPanel');

% Configure the operating point tables
configureTablePanels(this,DialogPanel);

% Turn off the editability of the columns
statetm=DialogPanel.getStateCondTableModel;
statetm.setEditablecolumns({false,false})
inputtm=DialogPanel.getInputCondTableModel;
inputtm.setEditablecolumns({false,false})

% Add the import operating point button
ImportButton = javaObjectEDT('com.mathworks.mwswing.MJButton',xlate('Import a New Operating Point...'));
ImportButton.setName('ImportButton');
ButtonPanel = DialogPanel.getButtonPanel;
ButtonPanel.add(ImportButton);

% Configure the import initial value for operating point button
h = handle(ImportButton, 'callbackproperties'); 
h.ActionPerformedCallback = {@LocalImportOpPoint, this};

% Configure the summary
updateSummary(this,DialogPanel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL FUNCTIONS

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LocalImportOpCond - Callback to import an operating point
function LocalImportOpPoint(es,ed,this)

% Throw up a question dialog explaining the implication of importing a new
% operating point.
msg = sprintf(['By selecting a new operating point your model will be analyzed to ',...
       'compute the open and closed-loop responses that have been configured. ',...
       'Continue?']);
%
ButtonName = questdlg(msg,sprintf('Import New Operating Point'),'Yes');

% If the user has selected yes, else return.
if strcmp(ButtonName,'Yes')
    % Get the SISO Task node
    task = this.up;
    
    % Create the dialog
    jDialogs.SnapShotSelectDialog(task,this);
end
