function dlgStruct = dataStoreMemddg(source, h)
% DATASTOREMEMDDG Dynamic dialog for Data store memory block.
  
%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.24 $  $Date: 2010/05/20 03:14:25 $

% ---------------------- FIRST TAB --------------------------------------------


% Get Scaling, Inheritance rules and builtin types
% if Unified data type feature is enabled

% Unified DataType   
dsDataTypeItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');

dsDataTypeItems.signModes = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
dsDataTypeItems.inheritRules = Simulink.DataTypePrmWidget.getInheritList('Auto');
dsDataTypeItems.builtinTypes = Simulink.DataTypePrmWidget.getBuiltinList('NumBool');

dsDataTypeItems.supportsEnumType = true;
if (slfeature('DSMBuses') == 1)
    dsDataTypeItems.supportsBusType = true;
end

rowIdx = 1;

% Top group is the block description
descTxt.Name            = h.BlockDescription;
descTxt.Type            = 'text';
descTxt.WordWrap        = true;

descGrp.Name            = h.BlockType;
descGrp.Type            = 'group';
descGrp.Items           = {descTxt};
descGrp.RowSpan         = [rowIdx rowIdx];
descGrp.ColSpan         = [1 1];

% Bottom group is the block parameters
rowIdx = rowIdx+1;
dsName = create_widget(source, h, 'DataStoreName', ...
                       rowIdx, 0, 2);

rowIdx = rowIdx+1;
dsRWBlks.Type           = 'textbrowser';
dsRWBlks.Text           = dataStoreRWddg_cb(h.Handle, 'getRWBlksHTML');
dsRWBlks.RowSpan        = [rowIdx rowIdx];
dsRWBlks.ColSpan        = [1 2];
dsRWBlks.Tag            = 'dsRWBlks';
dsRWBlks.Enabled         = ~source.isHierarchySimulating;

rowIdx = rowIdx+1;
dsInitVal.Name          = 'Initial value:';
dsInitVal.Type          = 'edit';
dsInitVal.RowSpan       = [rowIdx rowIdx];
dsInitVal.ColSpan       = [1 2];
dsInitVal.ObjectProperty = 'InitialValue';
dsInitVal.Tag           = dsInitVal.ObjectProperty;
% *** NOT DISABLED DURING SIMULATION ***
% required for synchronization --------
dsInitVal.MatlabMethod  = 'slDDGUtil';
dsInitVal.MatlabArgs    = {source,'sync','%dialog','edit','%tag', '%value'};

rowIdx = rowIdx+1;
dsResolveId = create_widget(source, h, 'StateMustResolveToSignalObject', ...
                            rowIdx, 0, 2);
dsResolveId.Enabled = (isvarname(h.DataStoreName) && ...
                       strcmp(h.RTWStateStorageClass,'Auto') && ...
                       ~source.isHierarchySimulating);

rowIdx = rowIdx+1;
dsRTWStor = create_widget(source, h, 'RTWStateStorageClass', ...
                          rowIdx, 0, 2);
dsRTWStor.Enabled = (isvarname(h.DataStoreName) && ...
                     strcmp(h.StateMustResolveToSignalObject, 'off') && ...
                     ~source.isHierarchySimulating);

rowIdx = rowIdx+1;
dsRTWType = create_widget(source, h, 'RTWStateStorageTypeQualifier', ...
                          rowIdx, 0, 2);
dsRTWType.Enabled = (dsRTWStor.Enabled && ...
                     ~strcmp(h.RTWStateStorageClass,'Auto') && ...
                     ~source.isHierarchySimulating);

rowIdx = rowIdx+1;
ds1D.Name               = 'Interpret vector parameters as 1-D';
ds1D.Type               = 'checkbox';
ds1D.RowSpan            = [rowIdx rowIdx];
ds1D.ColSpan            = [1 2];
ds1D.ObjectProperty     = 'VectorParams1D';
ds1D.Tag                = ds1D.ObjectProperty;
ds1D.Enabled            = ~source.isHierarchySimulating;
% required for synchronization --------
ds1D.MatlabMethod       = 'slDDGUtil';
ds1D.MatlabArgs         = {source,'sync','%dialog','checkbox','%tag', '%value'};

mainTab.Name            = 'Main';
mainTab.Items           = {dsName,dsRWBlks,dsInitVal,...
                           dsResolveId,dsRTWStor,dsRTWType,ds1D};
mainTab.LayoutGrid      = [rowIdx 2];
mainTab.RowStretch      = [0 1 0 0 0 0 0];


% ---------------------- SECOND TAB --------------------------------------------
rowIdx = 1;

dsOutMin.Name          = 'Minimum:';
dsOutMin.Type          = 'edit';
dsOutMin.RowSpan       = [rowIdx rowIdx];
dsOutMin.ColSpan       = [1 1];
dsOutMin.ObjectProperty = 'OutMin';
dsOutMin.Tag           = dsOutMin.ObjectProperty;
dsOutMin.Enabled       = ~source.isHierarchySimulating;
% required for synchronization --------
dsOutMin.MatlabMethod  = 'slDDGUtil';
dsOutMin.MatlabArgs    = {source,'sync','%dialog','edit','%tag','%value'};

dsOutMax.Name          = 'Maximum:';
dsOutMax.Type          = 'edit';
dsOutMax.RowSpan       = [rowIdx rowIdx];
dsOutMax.ColSpan       = [2 2];
dsOutMax.ObjectProperty = 'OutMax';
dsOutMax.Tag           = dsOutMax.ObjectProperty;
dsOutMax.Enabled       = ~source.isHierarchySimulating;
% required for synchronization --------
dsOutMax.MatlabMethod  = 'slDDGUtil';
dsOutMax.MatlabArgs    = {source,'sync','%dialog','edit','%tag','%value'};

rowIdx = rowIdx+1;

% Start LockScale here because we need the tag in the unified data type
lockOutScale = start_lockScaleProperty(source, h, 'LockScale');

% Add Min/ Max tags to be used for on-dialog scaling
dsDataTypeItems.scalingMinTag = {dsOutMin.Tag};
dsDataTypeItems.scalingMaxTag = {dsOutMax.Tag};
dsDataTypeItems.scalingValueTags = {dsInitVal.Tag};

% Get Widget for Unified dataType
dsDataTypeGroup = Simulink.DataTypePrmWidget.getDataTypeWidget(source, ...
                                                  'OutDataTypeStr', ...
                                                  xlate('Data type:'),'OutDataTypeStr', ...
                                                  h.OutDataTypeStr, dsDataTypeItems, false);
dsDataTypeGroup.RowSpan = [rowIdx rowIdx];
dsDataTypeGroup.ColSpan = [1 2];
dsDataTypeGroup.Enabled = ~source.isHierarchySimulating;

rowIdx = rowIdx + 1;

lockOutScale.RowSpan        = [rowIdx rowIdx];
lockOutScale.ColSpan        = [1 2];

if ((slfeature('DSMBuses') == 1) && (slfeature('ArraysOfBuses') > 0))
    rowIdx = rowIdx+1;
    dsDims.Name          = 'Dimensions (-1 to infer from Initial value):';
    dsDims.Type          = 'edit';
    dsDims.Value         = '-1';
    dsDims.RowSpan       = [rowIdx rowIdx];
    dsDims.ColSpan       = [1 2];
    dsDims.ObjectProperty = 'Dimensions';
    dsDims.Tag           = dsDims.ObjectProperty;
    dsDims.Enabled       = ~source.isHierarchySimulating;    
    % required for synchronization --------
    dsDims.MatlabMethod  = 'slDDGUtil';
    dsDims.MatlabArgs    = {source,'sync','%dialog','combobox','%tag','%value'};
end

rowIdx = rowIdx+1;
dsSigType.Name          = 'Signal type:';
dsSigType.Type          = 'combobox';
dsSigType.Entries       = h.getPropAllowedValues('SignalType')';
dsSigType.RowSpan       = [rowIdx rowIdx];
dsSigType.ColSpan       = [1 2];
dsSigType.ObjectProperty = 'SignalType';
dsSigType.Tag           = dsSigType.ObjectProperty;
dsSigType.Enabled       = ~source.isHierarchySimulating;
% required for synchronization --------
dsSigType.MatlabMethod  = 'slDDGUtil';
dsSigType.MatlabArgs    = {source,'sync','%dialog','combobox','%tag','%value'};

rowIdx = rowIdx+1;
spacer.Name             = '';
spacer.Type             = 'text';
spacer.RowSpan          = [rowIdx rowIdx];
spacer.ColSpan          = [1 2];

dataTab.Name            = 'Signal Attributes';

if ((slfeature('DSMBuses') == 1) && (slfeature('ArraysOfBuses') > 0))
    dataTab.Items       = {dsOutMin,dsOutMax,dsDataTypeGroup,lockOutScale,dsDims,dsSigType,spacer};
else
    dataTab.Items       = {dsOutMin,dsOutMax,dsDataTypeGroup,lockOutScale,dsSigType,spacer};
end

dataTab.LayoutGrid      = [rowIdx 2];
dataTab.RowStretch      = [zeros(1, (rowIdx-1)) 1];

% ---------------------- THIRD TAB --------------------------------------------
rowIdx = 1;

rbwMsg.Name             = 'Detect read before write:';
rbwMsg.Type             = 'combobox';
rbwMsg.Entries          = h.getPropAllowedValues('ReadBeforeWriteMsg')';
rbwMsg.RowSpan          = [rowIdx rowIdx];
rbwMsg.ColSpan          = [1 1];
rbwMsg.ObjectProperty   = 'ReadBeforeWriteMsg';
rbwMsg.Tag              = rbwMsg.ObjectProperty;
rbwMsg.Enabled          = ~source.isHierarchySimulating;
% required for synchronization --------
rbwMsg.MatlabMethod     = 'slDDGUtil';
rbwMsg.MatlabArgs       = {source,'sync','%dialog','combobox','%tag', '%value'};

rowIdx = rowIdx+1;
warMsg.Name             = 'Detect write after read:';
warMsg.Type             = 'combobox';
warMsg.Entries          = h.getPropAllowedValues('WriteAfterReadMsg')';
warMsg.RowSpan          = [rowIdx rowIdx];
warMsg.ColSpan          = [1 1];
warMsg.ObjectProperty   = 'WriteAfterReadMsg';
warMsg.Tag              = warMsg.ObjectProperty;
warMsg.Enabled          = ~source.isHierarchySimulating;
% required for synchronization --------
warMsg.MatlabMethod     = 'slDDGUtil';
warMsg.MatlabArgs       = {source,'sync','%dialog','combobox','%tag', '%value'};

rowIdx = rowIdx+1;
wawMsg.Name             = 'Detect write after write:';
wawMsg.Type             = 'combobox';
wawMsg.Entries          = h.getPropAllowedValues('WriteAfterWriteMsg')';
wawMsg.RowSpan          = [rowIdx rowIdx];
wawMsg.ColSpan          = [1 1];
wawMsg.ObjectProperty   = 'WriteAfterWriteMsg';
wawMsg.Tag              = wawMsg.ObjectProperty;
wawMsg.Enabled          = ~source.isHierarchySimulating;
% required for synchronization --------
wawMsg.MatlabMethod     = 'slDDGUtil';
wawMsg.MatlabArgs       = {source,'sync','%dialog','combobox','%tag', '%value'};

rowIdx = rowIdx+1;
spacer2.Name             = '';
spacer2.Type             = 'text';
spacer2.RowSpan          = [rowIdx rowIdx];
spacer2.ColSpan          = [1 1];

diagnosticTab.Name      = 'Diagnostics';
diagnosticTab.Items     = {rbwMsg,warMsg,wawMsg,spacer2};
diagnosticTab.LayoutGrid= [rowIdx 1];
diagnosticTab.RowStretch= [0 0 0 1];

%-----------------------------------------------------------------------
% Forth Tab: Logging
%-----------------------------------------------------------------------
if slfeature('DSMLogging') 
    bIsLogging = strcmp(h.DataLogging, 'on');

    %---------------------------------------
    % Sub-Group: Log on-off
    %---------------------------------------
    chkLogSigData.Type             = 'checkbox';
    chkLogSigData.Name             = DAStudio.message('Simulink:dialog:SigpropChkLogSigDataName');
    chkLogSigData.ObjectProperty   = 'DataLogging';
    chkLogSigData.Tag              = chkLogSigData.ObjectProperty;
    chkLogSigData.ColSpan          = [1 1];
    chkLogSigData.Enabled          = ~source.isHierarchySimulating;
    % required for synchronization --------
    chkLogSigData.DialogRefresh    = 1;
    chkLogSigData.MatlabMethod     = 'slDDGUtil';
    chkLogSigData.MatlabArgs       = {source,'sync','%dialog','checkbox','%tag', '%value'};

    spacer1.Tag                    = 'spacer1';
    spacer1.Type                   = 'panel';
    spacer1.ColSpan                = [2 2];

    pnl1.Tag                       = 'pnl1';
    pnl1.Type                      = 'panel';
    pnl1.LayoutGrid                = [1 2];
    pnl1.Items                     = {chkLogSigData, spacer1};
    pnl1.ColStretch                = [0 1];
    pnl1.RowSpan                   = [1 1];

    %---------------------------------------
    % Sub-Group: Custom Name
    %---------------------------------------
    cmbLog.Type                    = 'combobox';
    cmbLog.ObjectProperty          = 'DataLoggingNameMode';
    cmbLog.Tag                     = cmbLog.ObjectProperty;
    cmbLog.Values                  = [0 1];
    cmbLog.Entries                 = {DAStudio.message('Simulink:dialog:SigpropCmbLogEntryUseSignalName'), ...
                                    DAStudio.message('Simulink:dialog:SigpropCmbLogEntryCustom')};
    cmbLog.ColSpan                 = [1 1];
    cmbLog.Enabled                 = bIsLogging && ~source.isHierarchySimulating;
    % required for synchronization --------
    cmbLog.DialogRefresh           = 1;
    cmbLog.MatlabMethod            = 'slDDGUtil';
    cmbLog.MatlabArgs              = {source,'sync','%dialog','combobox','%tag', '%value'};

    txtName.Type                   = 'edit';
    txtName.ObjectProperty         = 'DataLoggingName';
    txtName.Tag                    = txtName.ObjectProperty;
    txtName.ColSpan                = [2 2];
    txtName.Enabled                = bIsLogging && ...
                                     ~(isequal(h.DataLoggingNameMode, 'SignalName')) && ...
                                     ~source.isHierarchySimulating;
    % required for synchronization --------
    txtName.MatlabMethod     = 'slDDGUtil';
    txtName.MatlabArgs       = {source,'sync','%dialog','edit','%tag', '%value'};

    grpLog.Tag                     = 'grpLog';
    grpLog.Type                    = 'group';
    grpLog.Name                    = DAStudio.message('Simulink:dialog:SigpropGrpLogName');
    grpLog.LayoutGrid              = [1 2];
    grpLog.Items                   = {cmbLog, txtName};
    grpLog.RowSpan                 = [2 2];

    %---------------------------------------  
    % Sub-Group: Decimation & Max Pts
    %---------------------------------------
    chkDataPoints.Type             = 'checkbox';
    chkDataPoints.RowSpan          = [1 1];
    chkDataPoints.ColSpan          = [1 1];
    chkDataPoints.ObjectProperty   = 'DataLoggingLimitDataPoints';
    chkDataPoints.Tag              = chkDataPoints.ObjectProperty;
    chkDataPoints.Enabled          = bIsLogging && ~source.isHierarchySimulating;
    % required for synchronization -------- 
    chkDataPoints.DialogRefresh    = 1;
    chkDataPoints.MatlabMethod     = 'slDDGUtil';
    chkDataPoints.MatlabArgs       = {source,'sync','%dialog','checkbox','%tag', '%value'};
    
    bLimitPts = strcmp(h.DataLoggingLimitDataPoints, 'on');
    
    lblDataPoints.Tag              = 'lblDataPoints';
    lblDataPoints.Type             = 'text';
    lblDataPoints.Name             = [DAStudio.message('Simulink:dialog:SigpropLblDataPointsName'), ' '];
    lblDataPoints.RowSpan          = [1 1];
    lblDataPoints.ColSpan          = [2 2];
    lblDataPoints.Enabled          = bIsLogging && ~source.isHierarchySimulating;

    txtDataPoints.Type             = 'edit';
    txtDataPoints.ObjectProperty   = 'DataLoggingMaxPoints';
    txtDataPoints.Tag              = txtDataPoints.ObjectProperty;
    txtDataPoints.RowSpan          = [1 1];
    txtDataPoints.ColSpan          = [3 3];
    txtDataPoints.Enabled          = bIsLogging && bLimitPts && ~source.isHierarchySimulating;
    % required for synchronization --------
    txtDataPoints.MatlabMethod     = 'slDDGUtil';
    txtDataPoints.MatlabArgs       = {source,'sync','%dialog','edit','%tag', '%value'};

    chkDecimation.Type             = 'checkbox';
    chkDecimation.RowSpan          = [2 2];
    chkDecimation.ColSpan          = [1 1];
    chkDecimation.ObjectProperty   = 'DataLoggingDecimateData';
    chkDecimation.Tag              = chkDecimation.ObjectProperty;
    chkDecimation.Enabled          = bIsLogging && ~source.isHierarchySimulating;
    % required for synchronization -------- 
    chkDecimation.DialogRefresh    = 1;
    chkDecimation.MatlabMethod     = 'slDDGUtil';
    chkDecimation.MatlabArgs       = {source,'sync','%dialog','checkbox','%tag', '%value'};
    
    bDecData = strcmp(h.DataLoggingDecimateData, 'on');
    
    lblDecimation.Tag              = 'lblDecimation';
    lblDecimation.Type             = 'text';
    lblDecimation.Name             = [DAStudio.message('Simulink:dialog:SigpropLblDecimationName'), ' '];
    lblDecimation.RowSpan          = [2 2];
    lblDecimation.ColSpan          = [2 2];
    lblDecimation.Enabled          = bIsLogging && ~source.isHierarchySimulating;

    txtDecimation.Type             = 'edit';
    txtDecimation.ObjectProperty   = 'DataLoggingDecimation';
    txtDecimation.Tag              = txtDecimation.ObjectProperty;
    txtDecimation.RowSpan          = [2 2];
    txtDecimation.ColSpan          = [3 3];
    txtDecimation.Enabled          = bIsLogging && bDecData && ~source.isHierarchySimulating;
    % required for synchronization --------
    txtDecimation.MatlabMethod     = 'slDDGUtil';
    txtDecimation.MatlabArgs       = {source,'sync','%dialog','edit','%tag', '%value'};

    grpData.Tag                    = 'grpData';
    grpData.Type                   = 'group';
    grpData.Name                   = DAStudio.message('Simulink:dialog:SigpropGrpDataName');
    grpData.LayoutGrid             = [2 3];
    grpData.Items                  = {chkDataPoints, lblDataPoints, txtDataPoints, ...
                                      chkDecimation, lblDecimation, txtDecimation};
    grpData.RowSpan                = [3 3];

    groupspacer.Type               = 'panel';
    groupspacer.RowSpan            = [4 4];

    logTab.Tag                       = 'tab1';
    logTab.Name                      = DAStudio.message('Simulink:dialog:SigpropGrpLogging');
    logTab.Items                     = {pnl1, grpLog, grpData, groupspacer};
    logTab.LayoutGrid                = [4 1];
    logTab.RowStretch                = [0 0 0 1];
end
  
%-----------------------------------------------------------------------
% Assemble Parameter tabs
%-----------------------------------------------------------------------
paramGrp.Name           = 'Parameters';
paramGrp.Type           = 'tab';
paramGrp.Tabs           = {mainTab, dataTab, diagnosticTab};
paramGrp.RowSpan        = [2 2];
paramGrp.ColSpan        = [1 1];
paramGrp.Source         = h;

if slfeature('DSMLogging')
    paramGrp.Tabs       = [paramGrp.Tabs logTab];
end

%-----------------------------------------------------------------------
% Assemble main dialog struct
%-----------------------------------------------------------------------
dlgStruct.DialogTitle   = ['Block Parameters: ' strrep(h.Name, sprintf('\n'), ' ')];
dlgStruct.DialogTag     = 'DataStoreMemory';
dlgStruct.Items         = {descGrp, paramGrp};
dlgStruct.LayoutGrid    = [2 1];
dlgStruct.RowStretch    = [0 1];
dlgStruct.CloseCallback = 'dataStoreRWddg_cb';
dlgStruct.CloseArgs     = {h.Handle, 'unhilite'};
dlgStruct.HelpMethod    = 'slhelp';
dlgStruct.HelpArgs      = {h.Handle};
% Required for simulink/block sync ----
dlgStruct.PreApplyMethod = 'preApplyCallback';
dlgStruct.PreApplyArgs   = {'%dialog'};
dlgStruct.PreApplyArgsDT = {'handle'};
% Required for deregistration ---------
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

[isLib, isLocked] = source.isLibraryBlock(h);
if isLocked
  dlgStruct.DisableDialog = 1;
else
  dlgStruct.DisableDialog = 0;
end

function property = start_lockScaleProperty(source, h, propName)
% Start the property definition for a parameter.

% The ObjectProperty and the Tag are mostly the same.
property.ObjectProperty = propName;
property.Tag            = property.ObjectProperty;
% Extract the prompt string from the block itself.
property.Name           = 'Lock output data type setting against changes by the fixed-point tools';%h.DialogParameters.(propName).Prompt;
% Choose the proper dialog parameter type.
property.Type         = 'checkbox';
property.Enabled      = ~source.isHierarchySimulating;
property.MatlabMethod = 'handleCheckEvent';

property.MatlabArgs = {source, '%value', find(strcmp(source.paramsMap, propName))-1, '%dialog'}; 
% end start_property

