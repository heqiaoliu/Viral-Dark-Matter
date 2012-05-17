function this = SnapShotSelectDialog(task,opnode)
% Defines properties for @SnapShotSelectDialog class

%   Authors: John Glass
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $ $Date: 2009/05/23 08:21:49 $

% Construct the object
this = jDialogs.SnapShotSelectDialog;
this.task = task;
this.opnode = opnode;

% Create the hash table with the dialog strings
keystrcell = {'DialogTitle',xlate('Operating Point Snapshot Import');...
              'Step1Label' xlate('Step 1: Enter snapshot times and the run simulation.');...
              'ComputeSnapshotButton', xlate('Run Simulation');...
              'AvailableDataColName', xlate('Available Data');...
              'Step2Label', xlate('Step 2: Select a simulation snapshot from the list below and click import.');...
              'Import', xlate('Import');...
              'Help', xlate('Help');...
              'Cancel', xlate('Cancel')};
          
strhash = cell2hashtable(slcontrol.Utilities,keystrcell);

% Build the dialog
this.Handles.Dialog = javaObjectEDT('com.mathworks.toolbox.slcontrol.Dialogs.SnapShotSelectDialog',slctrlexplorer,strhash);

% Set the callbacks
h = handle( this.Handles.Dialog.getImportButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalImportCallback,this};

h = handle( this.Handles.Dialog.getCancelButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalCancelCallback,this};

h = handle( this.Handles.Dialog.getComputeSnapshotButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalComputeSnapshotCallback,this};

h = handle( this.Handles.Dialog.getHelpButton, 'callbackproperties');
h.ActionPerformedCallback = {@LocalHelpCallback,this};

h = handle( this.Handles.Dialog,'callbackproperties');
h.WindowClosingCallback = {@LocalCancelCallback,this};

% Block the explorer
explorer = slctrlexplorer;
explorer.setBlocked(true,[]);

% Show the dialog
this.Handles.Dialog.show;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHelpCallback(es,ed,this)

scdguihelp('operating_point_snapshot_import',this.Handles.Dialog);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalImportCallback(es,ed,this)

% Return the selected index
index = this.Handles.Dialog.getSnapshotList.getSelectedIndex + 1;
SnapshotData = this.Snapshots(index);

newdesign = SnapshotData.loopdata.exportdesign;

% Get a design snapshot
task = this.task;
opnode = this.opnode;
olddesign = task.sisodb.LoopData.exportdesign;

% Copy the current compensator data to the design
for ct = 1:numel(olddesign.Loops)
    olddesign.(olddesign.Loops{ct}) = newdesign.(olddesign.Loops{ct});
end

% Copy the plant data
olddesign.P = newdesign.P;

% Import the data
task.sisodb.LoopData.importdesign(olddesign)

% Store the new operating point and update the tables
opnode.OpPoint = SnapshotData.OperatingPoint;

% Refresh the tables
% Get the state and input table data
[opnode.StateTableData,opnode.StateIndices] = opnode.getStateTableData;
[opnode.InputTableData,opnode.InputIndices] = opnode.getInputTableData;
refreshTables(opnode);
opnode.updateSummary(opnode.Dialog);

javaMethodEDT('dispose',this.Handles.Dialog);
explorer = slctrlexplorer;
explorer.setBlocked(false,[]);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCancelCallback(es,ed,this)

% Return the selected index
this.SelectedSnapshot = [];
javaMethodEDT('dispose',this.Handles.Dialog);
explorer = slctrlexplorer;
explorer.setBlocked(false,[]);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalComputeSnapshotCallback(es,ed,this)

javaMethodEDT('setEnabled',this.Handles.Dialog.getComputeSnapshotButton,false);
ComputeSnapshotCallback(es,ed,this)
javaMethodEDT('setEnabled',this.Handles.Dialog.getComputeSnapshotButton,true);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ComputeSnapshotCallback(es,ed,this)

% Get the snapshot times
SnapShotTimes_Str = this.Handles.Dialog.getSnapshotTextField.getText;
if ~isempty(SnapShotTimes_Str)
    SnapShotTimes = str2num(SnapShotTimes_Str); %#ok<ST2NM>
    if isempty(SnapShotTimes)
        try
            SnapShotTimes = evalin('base',SnapShotTimes_Str);
        catch Ex %#ok<NASGU>
            errordlg(ctrlMsgUtils.message('Slcontrol:linutil:InvalidSnapshotTimes'));
            return
        end
    end
    
    % Ensure that the snapshot times are a vector
    SnapShotTimes = SnapShotTimes(:);
    if any(~(isreal(SnapShotTimes))) || any(isnan(SnapShotTimes)) || ...
            any(~isa(SnapShotTimes,'double')) || any(~isfinite(SnapShotTimes)) || ...
            any(SnapShotTimes < 0)
        errordlg(ctrlMsgUtils.message('Slcontrol:linutil:InvalidSnapshotTimes'));
        return
    else
        SnapShotObject = this.task.createSnapshotObject;
        SnapShotObject.SnapShotTimes = SnapShotTimes;

        % Run the snapshot
        this.Snapshots = SnapShotObject.runsnapshot;

        % Now update the listbox
        SnapshotString = cell(numel(this.Snapshots),1);
        for ct = numel(this.Snapshots):-1:1
            SnapshotString{ct} = ctrlMsgUtils.message('Slcontrol:linutil:OperatingPointTimeNote',num2str(this.Snapshots(ct).OperatingPoint.Time));
        end

        this.Handles.Dialog.updateList(SnapshotString);
    end
else
    errordlg(ctrlMsgUtils.message('Slcontrol:linutil:InvalidSnapshotTimes'));
end




