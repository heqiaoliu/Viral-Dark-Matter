function dlgStruct = getLinearizationDialogSchema(this,hBlk)
%
 
% Author(s): A. Stothert 08-Oct-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/05/10 17:58:09 $

% GETLINEARIZATIONDIALOGSCHEMA construct dialog widgets for linearization
% properties

%Blank row at top of dialog
txtTopSpace.Type    = 'text';
txtTopSpace.Tag     = 'txtTopSpace';
txtTopSpace.Name    = ' ';
txtTopSpace.RowSpan = [1 1];
txtTopSpace.ColSpan = [2 2];

%Construct IO portion of dialog based on whether the LinearizationIO
%property evaluates to a vector of IOpoint objects or not
iofromvar = isa(this.LinearizationIOs,'linearize.IOPoint');
if iofromvar
   %Text for variable name
   txtIOVarName.Type    = 'text';
   txtIOVarName.Tag     = 'txtIOVarName';
   txtIOVarName.Buddy   = 'edtIOVarName';
   txtIOVarName.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtIOVarName');
   txtIOVarName.RowSpan = [1 1];
   txtIOVarName.ColSpan = [1 1];
   %Edit field for variable name
   edtIOVarName.Type           = 'edit';
   edtIOVarName.Tag            = 'edtIOVarName';
   edtIOVarName.Name           = '';
   edtIOVarName.Value          = hBlk.LinearizationIOs;
   edtIOVarName.RowSpan        = [1 1];
   edtIOVarName.ColSpan        = [2 2];
   edtIOVarName.Enabled        = false;
   
   grpIOs.Type       = 'panel';
   grpIOs.Tag        = 'grpIOs';
   grpIOs.LayoutGrid = [1 2];
   grpIOs.RowStretch = 0;
   grpIOs.ColStretch = [0 1];
   grpIOs.RowSpan    = [2 2];
   grpIOs.ColSpan    = [2 2];
   grpIOs.Items      = {txtIOVarName, edtIOVarName};
else
   %IO selector text
   txtIOSelector.Type    = 'text';
   txtIOSelector.Tag     = 'txtIOSelector';
   txtIOSelector.Buddy   = 'edtIOTbl';
   txtIOSelector.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtIOSelector');
   txtIOSelector.RowSpan = [1 1];
   txtIOSelector.ColSpan = [1 1];
   %IO selector show/hide buttons
   btnIOSelector_Show.Type           = 'pushbutton';
   btnIOSelector_Show.Tag            = 'btnIOSelector_Show';
   btnIOSelector_Show.ObjectMethod   = 'callbackLinearize';
   btnIOSelector_Show.MethodArgs     = {'%tag','%dialog'};
   btnIOSelector_Show.ArgDataTypes   = {'string','handle'};
   btnIOSelector_Show.RowSpan        = [3 3];
   btnIOSelector_Show.ColSpan        = [2 2];
   btnIOSelector_Show.FilePath       = fullfile(matlabroot,'toolbox','slcontrol','slctrlutil','resources','SigSelectorOpen');
   btnIOSelector_Show.ToolTip        = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:ttipBtnIOSelector_Show');
   btnIOSelector_Hide.Type           = 'pushbutton';
   btnIOSelector_Hide.Tag            = 'btnIOSelector_Hide';
   btnIOSelector_Hide.ObjectMethod   = 'callbackLinearize';
   btnIOSelector_Hide.MethodArgs     = {'%tag','%dialog'};
   btnIOSelector_Hide.ArgDataTypes   = {'string','handle'};
   btnIOSelector_Hide.RowSpan        = [3 3];
   btnIOSelector_Hide.ColSpan        = [2 2];
   btnIOSelector_Hide.FilePath       = fullfile(matlabroot,'toolbox','slcontrol','slctrlutil','resources','SigSelectorClose');
   btnIOSelector_Hide.ToolTip        = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:ttipBtnIOSelector_Hide');
   %IO selector add btn
   btnIOAdd.Type         = 'pushbutton';
   btnIOAdd.Tag          = 'btnIOSelectorAdd';
   btnIOAdd.FilePath     = fullfile(matlabroot,'toolbox','slcontrol','slctrlutil','resources','SigSelectorAdd');
   btnIOAdd.ToolTip      = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:ttipBtnIOSelectorAdd');
   btnIOAdd.ObjectMethod = 'callbackLinearize';
   btnIOAdd.MethodArgs   = {'%tag','%dialog'};
   btnIOAdd.ArgDataTypes = {'string','handle'};
   btnIOAdd.RowSpan      = [5 5];
   btnIOAdd.ColSpan      = [2 2];
   %IO selector remove btn
   btnIORemove.Type         = 'pushbutton';
   btnIORemove.Tag          = 'btnIOSelectorRemove';
   btnIORemove.FilePath     = fullfile(matlabroot,'toolbox','slcontrol','slctrlutil','resources','SigSelectorRemove');
   btnIORemove.ToolTip      = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:ttipBtnIOSelectorRemove');
   btnIORemove.RowSpan      = [7 7];
   btnIORemove.ColSpan      = [2 2];
   btnIORemove.ObjectMethod = 'callbackLinearize';
   btnIORemove.MethodArgs   = {'%tag','%dialog'};
   btnIORemove.ArgDataTypes = {'string','handle'};
   %IO table
   tblIOs.Type                 = 'table';
   tblIOs.Tag                  = 'tblIOs';
   tblIOs.Grid                 = true;
   tblIOs.HeaderVisibility     = [0 1];
   tblIOs.RowHeader            = {''};
   tblIOs.RowSpan              = [2 8];
   tblIOs.ColSpan              = [1 1];
   tblIOs.ColHeader            = {...
      ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:tblIOsBlockName'), ...
      ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:tblIOsConfiguration'), ...
      ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:tblIOsOpenLoop')};
   tblIOs.ColumnHeaderHeight   = 2;    %Prevents vertical character clipping
   tblIOs.ReadOnlyColumns      = 0;    %1st column (block path) is read only
   tblIOs.Editable             = true;
   tblIOs                      = localSetIOData(this, tblIOs);
   tblIOs.SelectionBehavior    = 'Row';
   tblWidth  = 8*numel([tblIOs.ColHeader{:}]);
   tblHeight = 16*(size(tblIOs.Data,1)+5);
   tblIOs.MinimumSize          = [tblWidth, tblHeight];
   tblIOs.MaximumSize          = [2^24-1, tblHeight];
   %Signal Selector text
   txtSigSelector.Type    = 'text';
   txtSigSelector.Tag     = 'txtSigSelector';
   txtSigSelector.Buddy   = 'edtIOSel';
   txtSigSelector.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSigSelector');
   txtSigSelector.RowSpan = [1 1];
   txtSigSelector.ColSpan = [3 3];
   %Signal selector tree widget
   wgtIOSelector         = getDialogSchema(this.hSigSelector,'');
   wgtIOSelector.Tag     = 'wgtIOSelector';
   wgtIOSelector.Source  = this.hSigSelector;
   wgtIOSelector.RowSpan = [2 8];
   wgtIOSelector.ColSpan = [3 3];
   wgtIOSelector.Items{1}.MinimumSize = [200 tblHeight];
   wgtIOSelector.Items{1}.MaximumSize = [2^24-1 tblHeight];
   
   %Dummy edt fields to enable CSH for table "labels"
   edtIOTbl.Type    = 'edit';
   edtIOTbl.Tag     = 'edtIOTbl';
   edtIOTbl.Name    = '';
   edtIOTbl.Enabled = false;
   edtIOTbl.Visible = false;
   edtIOTbl.RowSpan = [9 9];
   edtIOTbl.ColSpan = [1 1];
   edtIOSel.Type    = 'edit';
   edtIOSel.Tag     = 'edtIOSel';
   edtIOSel.Name    = '';
   edtIOSel.Enabled = false;
   edtIOSel.Visible = false;
   edtIOSel.RowSpan = [9 9];
   edtIOSel.ColSpan = [2 2];
   
   %Collect all widgets into linearization IOs group
   grpIOs.Type       = 'panel';
   grpIOs.Tag        = 'grpIOs';
   grpIOs.LayoutGrid = [9 3];
   grpIOs.RowStretch = [0 1 0 1 0 1 0 1 0];
   grpIOs.ColStretch = [1 0 0];
   grpIOs.RowSpan    = [2 2];
   grpIOs.ColSpan    = [2 2];
   %Set widget visibility/enabled state based on whether we are showing the signal
   %selector or not
   wgtIOSelector.Visible      = this.showSigSelector;
   txtSigSelector.Visible     = this.showSigSelector;
   btnIOSelector_Hide.Visible = this.showSigSelector;
   btnIOAdd.Visible           = this.showSigSelector;
   btnIOSelector_Show.Visible = ~this.showSigSelector;
   if size(tblIOs.Data,1) == 1 && isempty(tblIOs.Data{1})
      %No data in the table
      btnIORemove.Enabled = false;
   else
      btnIORemove.Enabled = true;
   end
   btnIOAdd.Enabled      = this.hSigSelector.TCPeer.isAnyTreeSelection;
   %Add all the widgets to the group
   grpIOs.Items = {txtSigSelector, wgtIOSelector, btnIOSelector_Show, btnIOSelector_Hide, ...
      btnIOAdd, btnIORemove, txtIOSelector, tblIOs, edtIOTbl, edtIOSel};
end

%Blank row between table and options
txtMidSpace.Type    = 'text';
txtMidSpace.Tag     = 'txtMidSpace';
txtMidSpace.Name    = ' ';
txtMidSpace.RowSpan = [3 3];
txtMidSpace.ColSpan = [2 2];

%Linearize at text
txtLinearizeAt.Type    = 'text';
txtLinearizeAt.Tag     = 'txtLinearizeAt';
txtLinearizeAt.Buddy   = 'LinearizeAt';
txtLinearizeAt.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtLinearizeAt');
txtLinearizeAt.RowSpan = [1 1];
txtLinearizeAt.ColSpan = [1 1];
%Linearize at combo-box
cmbLinearizeAt.Type           = 'combobox';
cmbLinearizeAt.Tag            = 'LinearizeAt';
cmbLinearizeAt.ObjectProperty = 'LinearizeAt';
cmbLinearizeAt.Entries        = {...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementSnapshotTimes'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementExternalTrigger')};
cmbLinearizeAt.ObjectMethod   = 'callbackLinearize';
cmbLinearizeAt.MethodArgs     = {'%tag','%dialog'};
cmbLinearizeAt.ArgDataTypes   = {'string','handle'};
cmbLinearizeAt.RowSpan        = [1 1];
cmbLinearizeAt.ColSpan        = [2 2];
%Snapshot times text
txtSnapshotTimes.Type    = 'text';
txtSnapshotTimes.Tag     = 'txtSnapshotTimes';
txtSnapshotTimes.Buddy   = 'SnapshotTimes';
txtSnapshotTimes.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSnapshotTimes');
txtSnapshotTimes.RowSpan = [2 2];
txtSnapshotTimes.ColSpan = [1 1];
%Snapshot times edit field
edtSnapshotTimes.Type           = 'edit';
edtSnapshotTimes.Tag            = 'SnapshotTimes';
edtSnapshotTimes.Name           = '';
edtSnapshotTimes.ObjectProperty = 'SnapshotTimes';
edtSnapshotTimes.RowSpan        = [2 2];
edtSnapshotTimes.ColSpan        = [2 2];
edtSnapshotTimes.Enabled        = strcmp(this.LinearizeAt,'SnapshotTimes');
%Trigger type text
txtTriggerType.Type     = 'text';
txtTriggerType.Tag      = 'txtTriggerType';
txtTriggerType.Buddy    = 'TriggerType';
txtTriggerType.Name     = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtTriggerType');
txtTriggerType.RowSpan  = [3 3];
txtTriggerType.ColSpan  = [1 1];
%Trigger type combo
cmbTriggerType.Type           = 'combobox';
cmbTriggerType.Tag            = 'TriggerType';
cmbTriggerType.ObjectProperty = 'TriggerType';
cmbTriggerType.Entries        = {...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementRisingEdge'); ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementFallingEdge')};
cmbTriggerType.RowSpan        = [3 3];
cmbTriggerType.ColSpan        = [2 2];
cmbTriggerType.Enabled        = strcmp(this.LinearizeAt,'ExternalTrigger');
%Linearize settings panel
grpSettings.Type  = 'panel';
grpSettings.Tag   = 'grpSettings';
grpSettings.Items = {...
   txtLinearizeAt, cmbLinearizeAt, ...
   txtSnapshotTimes, edtSnapshotTimes, ...
   txtTriggerType, cmbTriggerType};
grpSettings.LayoutGrid = [3 2];
grpSettings.RowStretch = zeros(1,3);
grpSettings.ColStretch = [0 1];
grpSettings.RowSpan    = [4 4];
grpSettings.ColSpan    = [2 2];

%Zero-crossing check box
chkZeroCross.Type           = 'checkbox';
chkZeroCross.Tag            = 'ZeroCross';
chkZeroCross.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtZeroCross');
chkZeroCross.ObjectProperty = 'ZeroCross';
chkZeroCross.RowSpan        = [1 1];
chkZeroCross.ColSpan        = [1 2];
%Use exact delay checkbox
chkExactDelay.Type           = 'checkbox';
chkExactDelay.Tag            = 'UseExactDelayModel';
chkExactDelay.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtExactDelayModel');
chkExactDelay.ObjectProperty = 'UseExactDelayModel';
chkExactDelay.RowSpan        = [2 2];
chkExactDelay.ColSpan        = [1 2];
%Sample time text label
txtSampleTime.Type    = 'text';
txtSampleTime.Tag     = 'txtSampleTime';
txtSampleTime.Buddy   = 'SampleTime';
txtSampleTime.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtSampleTime');
txtSampleTime.RowSpan = [3 3];
txtSampleTime.ColSpan = [1 1];
%Sample time edit field
edtSampleTime.Type           = 'edit';
edtSampleTime.Tag            = 'SampleTime';
edtSampleTime.Name           = '';
edtSampleTime.ObjectProperty = 'SampleTime';
edtSampleTime.RowSpan        = [3 3];
edtSampleTime.ColSpan        = [2 2];
%Rate conversion text
txtRateConversion.Type    = 'text';
txtRateConversion.Tag     = 'txtRateConversion';
txtRateConversion.Buddy   = 'RateConversionMethod';
txtRateConversion.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtRateConversion');
txtRateConversion.RowSpan = [4 4];
txtRateConversion.ColSpan = [1 1];
%Rate conversion combo-box
cmbRateConversion.Type           = 'combobox';
cmbRateConversion.Tag            = 'RateConversionMethod';
cmbRateConversion.ObjectProperty = 'RateConversionMethod';
cmbRateConversion.Entries        = {...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementZOH'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementTustin'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementPrewarp'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementUpsampleZOH'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementUpsampleTustin'), ...
   ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementUpsamplePrewarp')};
cmbRateConversion.RowSpan        = [4 4];
cmbRateConversion.ColSpan        = [2 2];
cmbRateConversion.ObjectMethod   = 'callbackLinearize';
cmbRateConversion.MethodArgs     = {'%tag','%dialog'};
cmbRateConversion.ArgDataTypes   = {'string','handle'};
%Prewarp frequency text label
txtPreWarpFreq.Type    = 'text';
txtPreWarpFreq.Tag     = 'txtPreWarpFreq';
txtPreWarpFreq.Buddy   = 'PreWarpFreq';
txtPreWarpFreq.Name    = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtPreWarpFreq');
txtPreWarpFreq.RowSpan = [5 5];
txtPreWarpFreq.ColSpan = [1 1];
%Prewarp frequency edit field
edtPreWarpFreq.Type           = 'edit';
edtPreWarpFreq.Tag            = 'PreWarpFreq';
edtPreWarpFreq.Name           = '';
edtPreWarpFreq.ObjectProperty = 'PreWarpFreq';
edtPreWarpFreq.RowSpan        = [5 5];
edtPreWarpFreq.ColSpan        = [2 2];
edtPreWarpFreq.Enabled        = any(strcmp(this.RateConversionMethod,{'prewarp', 'upsample_prewarp'}));
%Linearization options toggle group
grpOptions.Type  = 'togglepanel';
grpOptions.Tag   = 'pnlOptions';
grpOptions.Name  = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:grpOptions');
grpOptions.Items = {...
   chkZeroCross, ...
   chkExactDelay, ...
   txtSampleTime, edtSampleTime, ...
   txtRateConversion, cmbRateConversion, ...
   txtPreWarpFreq, edtPreWarpFreq};
grpOptions.LayoutGrid = [6 2];
grpOptions.RowStretch = zeros(1,6);
grpOptions.ColStretch = [0 1];
grpOptions.RowSpan    = [5 5];
grpOptions.ColSpan    = [2 2];

%Use fullnames checkbox
chkUseFullNames.Type           = 'checkbox';
chkUseFullNames.Tag            = 'UseFullBlockNameLabels';
chkUseFullNames.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtUseFullBlockNameLabels');
chkUseFullNames.ObjectProperty = 'UseFullBlockNameLabels';
chkUseFullNames.RowSpan        = [1 1];
chkUseFullNames.ColSpan        = [1 1];
%Use bus signal names checkbox
chkUseBusSignalNames.Type           = 'checkbox';
chkUseBusSignalNames.Tag            = 'UseBusSignalLabels';
chkUseBusSignalNames.Name           = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:txtUseBusSignalLabels');
chkUseBusSignalNames.ObjectProperty = 'UseBusSignalLabels';
chkUseBusSignalNames.RowSpan        = [2 2];
chkUseBusSignalNames.ColSpan        = [1 1];
pnlLabels.Type       = 'panel';
pnlLabels.Tag        = 'pnlLabels';
pnlLabels.Items      = {chkUseFullNames, chkUseBusSignalNames};
pnlLabels.LayoutGrid = [2 1];
pnlLabels.RowStretch = zeros(1,2);
pnlLabels.ColStretch = 1;
pnlLabels.RowSpan    = [1 1];
pnlLabels.ColSpan    = [1 1];
%Labels toggle panel
grpLabels.Type       = 'togglepanel';
grpLabels.Tag        = 'grpLabels';
grpLabels.Name       = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:grpLinOptionsLabels');
grpLabels.Items      = {pnlLabels};
grpLabels.LayoutGrid = [1 1];
grpLabels.RowStretch = 0;
grpLabels.ColStretch = 1;
grpLabels.RowSpan    = [6 6];
grpLabels.ColSpan    = [2 2];

%Create widgets to give left/right indents
txtLeftSpace.Type     = 'text';
txtLeftSpace.Tag      = 'txtLeftSpace';
txtLeftSpace.Name     = ' ';
txtLeftSpace.RowSpan  = [1 6];
txtLeftSpace.ColSpan  = [1 1];
txtRightSpace.Type    = 'text';
txtRightSpace.Tag     = 'txtRightSpace';
txtRightSpace.Name    = ' ';
txtRightSpace.RowSpan = [1 6];
txtRightSpace.ColSpan = [3 3];

%Create tab pane
dlgStruct.Name       = ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:tabLinearizations');
dlgStruct.Items      = {...
   txtLeftSpace, txtTopSpace, txtRightSpace, ...
   grpIOs, txtMidSpace, grpSettings, grpOptions, grpLabels};
dlgStruct.LayoutGrid = [7 3];
dlgStruct.RowStretch = [zeros(1,6) 1];
dlgStruct.ColStretch = [0 1 0];
end

function tbl = localSetIOData(this, tbl)
% Local helper function to populate the Linearization IO table

if ~this.isIOModifiedByDlg
   %Refresh called by something outside the dialog
   this.syncLinIOData;
   this.isIOModifiedByDlg = true; %Reset flag so expect all changes to be made by dialog
end
lData  = this.LinearizationIOs;
if isempty(lData)
   %Create table with empty row
   tbl.Size = [0 3];
   tbl.Data = {'', '', ''};
else
   mdl = bdroot(this.getBlock.getFullName);
   if isa(lData,'linearize.IOPoint')
      nPorts = numel(lData);
      %Table data defined by workspace variable, can not allow changes
      lBlks  = get(lData,{'Block'});
      lPorts = get(lData,{'PortNumber'});
      lTypes = get(lData,{'Type'});
      lOL    = get(lData,{'OpenLoop'});
      tbl.Editable = false;   
   else
      nPorts = size(lData,1);
      lBlks  = lData(:,1);
      lPorts = lData(:,2);
      lTypes = lData(:,3);
      lOL    = lData(:,4);
   end
   tbl.Size = [nPorts, 3];
   data     = cell(nPorts, 3);
   for ct = 1:nPorts
      %Create edit field for block name/path
      blkPath = lBlks{ct};
      if ~strncmp(blkPath,mdl,length(mdl))
         blkPath = strcat(mdl,blkPath);
      end
      data{ct,1}   = sprintf('%s : %d', blkPath, lPorts{ct});
      %Create combo-box for linearization type
      cmbType.Type    = 'combobox';
      cmbType.Tag     = 'cmbLinearizationType';
      cmbType.Entries = {...
         ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementInput'), ...
         ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementOutput'), ...
         ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementInputOutput'), ...
         ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementOutputInput'), ...
         ctrlMsgUtils.message('Slcontrol:slctrlblkdlgs:cmbElementNone')};
      switch lTypes{ct}
         case 'in'
            cmbType.Value = 0;
         case 'out'
            cmbType.Value = 1;
         case 'inout'
            cmbType.Value = 2;
         case 'outin'
            cmbType.Value = 3;
         case 'none'
            cmbType.Value = 4;
      end
      data{ct,2}      = cmbType;
      %Create checkbox for open loop setting
      chkOL.Type      = 'checkbox';
      chkOL.Tag       = 'chkLinearizationOpenLoop';
      chkOL.Name      = '';
      chkOL.Value     = strcmp(lOL{ct},'on');
      data{ct,3}      = chkOL;
   end
   tbl.Data = data;
end
end