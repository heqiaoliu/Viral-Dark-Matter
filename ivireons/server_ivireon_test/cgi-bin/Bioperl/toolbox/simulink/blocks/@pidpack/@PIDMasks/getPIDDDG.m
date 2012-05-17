function dlgStruct = getPIDDDG(source,h)

%   Author(s): Murad Abu-Khalaf , December 17, 2008
%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2009/12/28 04:38:26 $

% Get entries of comboboxes/radioButtons
AntiWindupModeEntries = h.getPropAllowedValues('AntiWindupMode');
ControllerEntries = h.getPropAllowedValues('Controller');
TimeEntries = h.getPropAllowedValues('TimeDomain');
formEntries = h.getPropAllowedValues('Form');
IntegratorMethodEntries = h.getPropAllowedValues('IntegratorMethod');
FilterMethodEntries = h.getPropAllowedValues('FilterMethod');
InitialConditionSourceEntries = h.getPropAllowedValues('InitialConditionSource');
ExternalResetEntries = h.getPropAllowedValues('ExternalReset');
RndMethEntries = h.getPropAllowedValues('RndMeth');
IntegratorRTWStateStorageClassEntries = h.getPropAllowedValues('IntegratorRTWStateStorageClass');
FilterRTWStateStorageClassEntries = h.getPropAllowedValues('FilterRTWStateStorageClass');

% Get all DataTypeStr
params = source.getDialogParams;
tmp = strfind(params,'DataTypeStr');
index = true(numel(tmp),1);
for i = 1:numel(tmp)
    if isempty(tmp{i})
        index(i) = false;
    end
end
allDataTypeStrParam = params(index);

paramNames = allDataTypeStrParam;

NameStr = 'PID Controller';
DialogTitleStr = 'Block Parameters: PID 1dof';
DialogTagStr   = 'PID1dof';
if strcmp(h.MaskType,'PID 2dof')
    NameStr = [NameStr ' (2DOF)'];
    DialogTitleStr = 'Block Parameters: PID 2dof';
    DialogTagStr   = 'PID2dof';
end

isI = (source.Controller == 0 || source.Controller == 1 ||source.Controller == 4);
isD = (source.Controller == 0 || source.Controller == 2);
isDT = (source.TimeDomain == 1);

%% Description group box
txtDescription = struct('Type','text','Name',h.MaskDescription,...
    'WordWrap',true);

grpDescription = struct('Name',NameStr,...
    'Type','group',...
    'Tag','grpDescription',...
    'Items',{{txtDescription}},...
    'RowSpan',[1 1],...
    'ColSpan',[1 3]);

%% Controller settings
cmbController = createWidget(h,'combobox','Controller',...
    true,[2 2],[1 3],ControllerEntries,false,[]);
cmbController.DialogRefresh = true;

%% Time-domain settings
radioTime = createWidget(h,'radiobutton','TimeDomain',...
    true,[3 3],[1 1],TimeEntries,false,[]);
radioTime.DialogRefresh = true;

%% Discrete-time settings group box
cmbIntegrator = createWidget(h,'combobox','IntegratorMethod',...
    true,[1 1],[2 2],IntegratorMethodEntries,false,[]);
cmbIntegrator.Name ='';
cmbIntegrator.ToolTip = DAStudio.message('Simulink:blocks:discretePIDToolTip');
cmbIntegratorBuddy.Name = getPromptString(h,'IntegratorMethod');
cmbIntegratorBuddy.Buddy = 'IntegratorMethod';  cmbIntegratorBuddy.Tag = 'IntegratorMethod|Label';
cmbIntegratorBuddy.Type = 'text';
cmbIntegratorBuddy.RowSpan = [1 1]; cmbIntegratorBuddy.ColSpan = [1 1];

cmbFilter = createWidget(h,'combobox','FilterMethod',...
    true,[2 2],[2 2],FilterMethodEntries,false,[]);
cmbFilter.Name ='';
cmbFilter.ToolTip = DAStudio.message('Simulink:blocks:discretePIDToolTip');
cmbFilterBuddy.Name = getPromptString(h,'FilterMethod');
cmbFilterBuddy.Buddy = 'FilterMethod';  cmbFilterBuddy.Tag = 'FilterMethod|Label';
cmbFilterBuddy.Type = 'text';
cmbFilterBuddy.RowSpan = [2 2]; cmbFilterBuddy.ColSpan = [1 1];

txtSampleTime = createWidget(h,'edit','SampleTime',true,[3 3],[2 2],{},'',[]);
txtSampleTime.Name ='';
txtSampleTimeBuddy.Name = getPromptString(h,'SampleTime');
txtSampleTimeBuddy.Buddy = 'SampleTime';  txtSampleTimeBuddy.Tag = 'SampleTime|Label';
txtSampleTimeBuddy.Type = 'text';
txtSampleTimeBuddy.RowSpan = [3 3]; txtSampleTimeBuddy.ColSpan = [1 1];

cmbIntegrator.Visible = isI;
cmbIntegratorBuddy.Visible = isI;
cmbFilter.Visible = isD;
cmbFilterBuddy.Visible = isD;

grpDiscrete = struct('Name','Discrete-time settings',...
    'Type','group',...
    'Tag','grpDiscrete',...
    'LayoutGrid',[3 2],...
    'ColStretch',[0 1],...
    'RowStretch',[1 1 1],...
    'RowSpan',[3 3],...
    'ColSpan',[2 3],...
    'Items',{{cmbIntegratorBuddy,cmbIntegrator,cmbFilterBuddy,cmbFilter,...
    txtSampleTimeBuddy,txtSampleTime}});

if strcmp(h.TimeDomain,radioTime.Entries{1})
    grpDiscrete.Visible = false;
    paramNames(strmatch('IntegratorOutDataTypeStr',paramNames)) = [];
    paramNames(strmatch('FilterOutDataTypeStr',paramNames)) = [];
elseif strcmp(h.TimeDomain,radioTime.Entries{2})
    grpDiscrete.Visible = true;
end

%% Main tab
layoutRow = 0; % Row counter

% Controller settings
cnt = 1;
cmbForm = createWidget(h,'combobox','Form',...
    true,[cnt cnt],[2 6],formEntries,false,5);
cmbForm.Name ='';
cmbFormBuddy.Name = getPromptString(h,'Form');
cmbFormBuddy.Type = 'text';
cmbFormBuddy.Buddy = 'Form';  cmbFormBuddy.Tag = 'Form|Label';
cmbFormBuddy.RowSpan = [cnt cnt]; cmbFormBuddy.ColSpan = [1 1];
cmbForm.Visible = ~(source.Controller==3 || source.Controller==4);
cmbFormBuddy.Visible = cmbForm.Visible;

cnt = cnt+1;
txtP = createWidget(h,'edit','P',true,[cnt cnt],[2 6],{},'',2);
txtP.Name ='';
txtPBuddy.Name = getPromptString(h,'P');
txtPBuddy.Type = 'text';
txtPBuddy.Buddy = 'P';  txtPBuddy.Tag = 'P|Label';
txtPBuddy.RowSpan = [cnt cnt]; txtPBuddy.ColSpan = [1 1];
txtP.Visible = ~(source.Controller == 4);
txtPBuddy.Visible = txtP.Visible;

cnt = cnt+1;
txtI = createWidget(h,'edit','I',true,[cnt cnt],[2 6],{},'',2);
txtI.Name ='';
txtIBuddy.Name = getPromptString(h,'I');
txtIBuddy.Buddy = 'I';  txtIBuddy.Tag = 'I|Label';
txtIBuddy.Type = 'text';
txtIBuddy.RowSpan = [cnt cnt]; txtIBuddy.ColSpan = [1 1];
txtI.Visible = isI;
txtIBuddy.Visible = txtI.Visible;

cnt = cnt+1;
txtD = createWidget(h,'edit','D',true,[cnt cnt],[2 3],{},'',2);
txtD.Name ='';
txtDBuddy.Name = getPromptString(h,'D');
txtDBuddy.Buddy = 'D';  txtDBuddy.Tag = 'D|Label';
txtDBuddy.Type = 'text';
txtDBuddy.RowSpan = [cnt cnt]; txtDBuddy.ColSpan = [1 1];
txtD.Visible = isD;
txtDBuddy.Visible = txtD.Visible;
txtN = createWidget(h,'edit','N',true,[cnt cnt],[5 6],{},'',2);
txtN.Name ='';
txtNBuddy.Name = getPromptString(h,'N');
txtNBuddy.Buddy = 'N';  txtNBuddy.Tag = 'N|Label';
txtNBuddy.Type = 'text';
txtNBuddy.RowSpan = [cnt cnt]; txtNBuddy.ColSpan = [4 4];
txtN.Visible = txtD.Visible;
txtNBuddy.Visible = txtN.Visible;

if strcmp(h.MaskType,'PID 2dof')
    cnt = cnt+1;
    txtb = createWidget(h,'edit','b',true,[cnt cnt],[2 6],{},'',2);
    txtb.Name ='';
    txtbBuddy.Name = getPromptString(h,'b');
    txtbBuddy.Buddy = 'b';  txtbBuddy.Tag = 'b|Label';
    txtbBuddy.Type = 'text';
    txtbBuddy.RowSpan = [cnt cnt]; txtbBuddy.ColSpan = [1 1];
    
    cnt = cnt+1;
    txtc = createWidget(h,'edit','c',true,[cnt cnt],[2 6],{},'',2);
    txtc.Name ='';
    txtcBuddy.Name = getPromptString(h,'c');
    txtcBuddy.Buddy = 'c';  txtcBuddy.Tag = 'c|Label';
    txtcBuddy.Type = 'text';
    txtcBuddy.RowSpan = [cnt cnt]; txtcBuddy.ColSpan = [1 1];
    txtc.Visible = isD;
    txtcBuddy.Visible = txtc.Visible;
end

cnt = cnt+1;
btnTune.Name    = 'Tune...';
btnTune.Type    = 'pushbutton';
btnTune.Tag     = 'TuneButton';
btnTune.ToolTip = DAStudio.message('Simulink:blocks:tunePIDButtonToolTip');
btnTune.ObjectMethod = 'callbackDialogDDG';
btnTune.MethodArgs = {'%tag','%dialog'};
btnTune.ArgDataTypes = {'string','handle'};
btnTune.RowSpan = [cnt cnt]; btnTune.ColSpan = [6 6];

layoutRow = layoutRow + 1;
grpPIDGains.Name = 'Controller settings';
grpPIDGains.Type = 'group';
grpPIDGains.Tag = 'grpPIDGains';
grpPIDGains.LayoutGrid = [cnt 6];
grpPIDGains.RowStretch = [0 0 0 0 0];
grpPIDGains.ColStretch = [1 1 1 1 1 1];
grpPIDGains.Items = {cmbFormBuddy,cmbForm, txtP,txtPBuddy, txtI,txtIBuddy, txtD,txtDBuddy, txtN,txtNBuddy,btnTune};
if strcmp(h.MaskType,'PID 2dof')
    grpPIDGains.Items = {cmbFormBuddy,cmbForm, txtP,txtPBuddy, txtI,txtIBuddy, txtD,txtDBuddy, txtN,txtNBuddy,txtb,txtbBuddy,txtc,txtcBuddy,btnTune};
end
grpPIDGains.RowSpan = [layoutRow layoutRow];
grpPIDGains.ColSpan = [1 3];
grpPIDGains.Flat = false;

switch source.Controller
    case 0 % PID
    case 1 % PI
        paramNames(strmatch('D',paramNames)) = [];
        paramNames(strmatch('N',paramNames)) = [];
        paramNames(strmatch('SumD',paramNames)) = [];
        paramNames(strmatch('FilterOut',paramNames)) = [];
        paramNames(strmatch('Sum2',paramNames)) = [];   % 2DOF case
        paramNames(strmatch('c',paramNames)) = [];      % 2DOF case
    case 2 % PD
        paramNames(strmatch('I',paramNames)) = [];
        paramNames(strmatch('Kb',paramNames)) = [];
        paramNames(strmatch('Kt',paramNames)) = [];
        paramNames(strmatch('SumI',paramNames)) = [];
        paramNames(strmatch('Sum3',paramNames)) = [];    % 2DOF case
        paramNames(strmatch('IntegratorOut',paramNames)) = [];
    case 3 % P   1DOF case
        paramNames(strmatch('I',paramNames)) = [];
        paramNames(strmatch('D',paramNames)) = [];
        paramNames(strmatch('N',paramNames)) = [];
        paramNames(strmatch('Kb',paramNames)) = [];
        paramNames(strmatch('Kt',paramNames)) = [];
        paramNames(strmatch('Sum',paramNames)) = [];
        paramNames(strmatch('IntegratorOut',paramNames)) = [];
        paramNames(strmatch('FilterOut',paramNames)) = [];
    case 4 % I   1DOF case
        paramNames(strmatch('P',paramNames)) = [];
        paramNames(strmatch('D',paramNames)) = [];
        paramNames(strmatch('N',paramNames)) = [];
        paramNames(strmatch('SumOut',paramNames)) = [];
        paramNames(strmatch('SumAccum',paramNames)) = [];
        paramNames(strmatch('SumD',paramNames)) = [];
        paramNames(strmatch('FilterOut',paramNames)) = [];
end

% Initial conditions
cmbInit = createWidget(h,'combobox','InitialConditionSource',...
    true,[1 1],[2 2],InitialConditionSourceEntries,false,[]);
cmbInit.Name ='';
cmbInit.DialogRefresh = true;
cmbInitBuddy.Name = getPromptString(h,'InitialConditionSource');
cmbInitBuddy.Type = 'text';
cmbInitBuddy.Buddy = 'InitialConditionSource';  cmbInitBuddy.Tag = 'InitialConditionSource|Label';
cmbInitBuddy.RowSpan = [1 1]; cmbInitBuddy.ColSpan = [1 1];


txtInitStates_I = createWidget(h,'edit','InitialConditionForIntegrator',true,[2 2],[2 2],{},'',5);
txtInitStates_I.Name ='';
txtInitStates_IBuddy.Name = getPromptString(h,'InitialConditionForIntegrator');
txtInitStates_IBuddy.Type = 'text';
txtInitStates_IBuddy.Buddy = 'InitialConditionForIntegrator';  txtInitStates_IBuddy.Tag = 'InitialConditionForIntegrator|Label';
txtInitStates_IBuddy.RowSpan = [2 2]; txtInitStates_IBuddy.ColSpan = [1 1];


txtInitStates_D = createWidget(h,'edit','InitialConditionForFilter',true,[3 3],[2 2],{},'',5);
txtInitStates_D.Name ='';
txtInitStates_DBuddy.Name = getPromptString(h,'InitialConditionForFilter');
txtInitStates_DBuddy.Type = 'text';
txtInitStates_DBuddy.Buddy = 'InitialConditionForFilter';  txtInitStates_DBuddy.Tag = 'InitialConditionForFilter|Label';
txtInitStates_DBuddy.RowSpan = [3 3]; txtInitStates_DBuddy.ColSpan = [1 1];

flag1 = (source.InitialConditionSource == 0);
flag2 = isI;
flag3 = (source.Controller == 0 || source.Controller == 2);
txtInitStates_I.Visible = flag1 && flag2;
txtInitStates_IBuddy.Visible = txtInitStates_I.Visible;
txtInitStates_D.Visible = flag1 && flag3;
txtInitStates_DBuddy.Visible = txtInitStates_D.Visible;

layoutRow = layoutRow + 1;
grpInit.Name  = 'Initial conditions';
grpInit.Tag  = 'ICGroup';
grpInit.Type = 'group';
grpInit.Items = {cmbInitBuddy,cmbInit,txtInitStates_IBuddy,txtInitStates_I,txtInitStates_DBuddy,txtInitStates_D};
grpInit.LayoutGrid = [3 2];
grpInit.Alignment = 0;
grpInit.RowStretch = [0 0 0];
grpInit.ColStretch = [0 1];
grpInit.RowSpan = [layoutRow layoutRow];
grpInit.ColSpan = [1 3];
grpInit.Visible = isI || isD;

layoutRow = layoutRow + 1;
cmbinitTrigger = createWidget(h,'combobox','ExternalReset',...
    true,[layoutRow layoutRow],[1 3],ExternalResetEntries,false,[]);

layoutRow = layoutRow + 1;
ignoreResetLinearization = createWidget(h,'checkbox','IgnoreLimit',...
    true,[layoutRow layoutRow],[1 3],{},'',[]);

cmbinitTrigger.Visible = isI || isD;
ignoreResetLinearization.Visible = isI || isD;

layoutRow = layoutRow + 1;
zerocrossing = createWidget(h,'checkbox','ZeroCross',...
    true,[layoutRow layoutRow],[1 3],{},'',[]);

layoutRow = layoutRow + 1;
spacer.Name = '';
spacer.Type = 'text';
spacer.RowSpan = [layoutRow layoutRow];
spacer.ColSpan = [1 3];

tabMain.Name  = 'Main';
tabMain.Items = {grpPIDGains,grpInit,cmbinitTrigger,...
    ignoreResetLinearization,zerocrossing,spacer};
tabMain.LayoutGrid = [layoutRow 3];
tabMain.RowStretch = [zeros(1,layoutRow-1) 1];  % Stretch only the last row
tabMain.ColStretch = [1 1 0];                   % Stretch all columns, but the last.

%% PID Advanced tab
layoutRow = 0; % Row counter

% Anti-windup and Output Saturation
saturation = createWidget(h,'checkbox','LimitOutput',...
    true,[1 1],[1 6],{},'',[]);
saturation.DialogRefresh = true;
upperlim = createWidget(h,'edit','UpperSaturationLimit',...
    true,[2 2],[1 2],{},'',2);
lowerlim = createWidget(h,'edit','LowerSaturationLimit',...
    true,[3 3],[1 2],{},'',2);
cmbAntiWindup = createWidget(h,'combobox','AntiWindupMode',...
    true,[2 2],[4 6],AntiWindupModeEntries,false,2);
cmbAntiWindup.DialogRefresh = true;
timeconstant = createWidget(h,'edit','Kb',true,[3 3],[4 6],{},'',2);
treatGain = createWidget(h,'checkbox','LinearizeAsGain',...
    true,[4 4],[1 2],{},'',[]);

if ~(source.AntiWindupMode == 1) % not back-calculation
    paramNames(strmatch('Kb',paramNames)) = [];
    paramNames(strmatch('SumI2',paramNames)) = [];
end

cmbAntiWindup.Visible = isI;
timeconstant.Visible = (source.AntiWindupMode == 1) && isI;

upperlim.Enabled = upperlim.Enabled && source.LimitOutput;
lowerlim.Enabled = lowerlim.Enabled && source.LimitOutput;
treatGain.Enabled = treatGain.Enabled && source.LimitOutput;
cmbAntiWindup.Enabled = cmbAntiWindup.Enabled && source.LimitOutput;
timeconstant.Enabled = source.LimitOutput;
if ~source.LimitOutput
    paramNames(strmatch('Saturation',paramNames)) = [];
    paramNames(strmatch('Kb',paramNames)) = [];
    paramNames(strmatch('SumI2',paramNames)) = [];
end

layoutRow = layoutRow + 1;
grpSat.Name = 'Output saturation';
grpSat.Type = 'group';
grpSat.Tag = 'grpSat';
grpSat.LayoutGrid = [4 6];
grpSat.Alignment = 0;
grpSat.Items = {saturation,upperlim,lowerlim,treatGain,cmbAntiWindup,timeconstant};
grpSat.RowStretch = [0 0 0 0 ];
grpSat.ColStretch = [1 1 1 1 1 1];
grpSat.RowSpan = [layoutRow layoutRow];
grpSat.ColSpan = [1 1];

% Tracking mode
tracking = createWidget(h,'checkbox','TrackingMode',...
    true,[1 1],[1 1],{},'',[]);
tracking.DialogRefresh = true;
trackingtimeconstant = createWidget(h,'edit','Kt',...
    true,[2 2],[1 1],{},'',2);

trackingtimeconstant.Enabled = (source.TrackingMode == 1);
if ~source.TrackingMode
    paramNames(strmatch('Kt',paramNames)) = [];
    paramNames(strmatch('SumI3',paramNames)) = [];
end

layoutRow = layoutRow + 1;
grpTracking.Name = 'Tracking mode';
grpTracking.Type = 'group';
grpTracking.Tag = 'grpTracking';
grpTracking.LayoutGrid = [2 1];
grpTracking.Alignment = 0;
grpTracking.Items = {tracking, trackingtimeconstant};
grpTracking.RowStretch = [0 0];
grpTracking.ColStretch = 1;
grpTracking.RowSpan = [layoutRow layoutRow];
grpTracking.ColSpan = [1 1];
grpTracking.Visible = isI;

if ~(source.Trackingmode) && (~(source.LimitOutput) || source.AntiWindupMode ~= 1)
    paramNames(strmatch('SumI1',paramNames)) = [];
end

layoutRow = layoutRow + 1;
spacer.Name = '';
spacer.Type = 'text';
spacer.RowSpan = [layoutRow layoutRow];
spacer.ColSpan = [1 1];

tabPIDAdvanced.Name = 'PID Advanced';
tabPIDAdvanced.Items = {grpSat,grpTracking,spacer};
tabPIDAdvanced.LayoutGrid = [layoutRow 1];
tabPIDAdvanced.RowStretch = [zeros(1,layoutRow-1) 1];  % Stretch only the last row
tabPIDAdvanced.ColStretch = 1;                         % Stretch all columns, but the last.

%% Data Types tab

visibleDataTypes = paramNames;
paramNames       = allDataTypeStrParam;

% Layout management.
layoutRow = 0;
layoutCols = 5; % The grid width.
colIdxCell=num2cell(1:layoutCols); %[1 2 4 5 6]);
% Column indexes:
%   Prompt     Combobox     DTA Button   Design Min   Design Max
[dtaPrmColIdx dtaUDTColIdx dtaBtnColIdx desMinColIdx desMaxColIdx] = deal(colIdxCell{:});

% Data type widget column labels
layoutRow = layoutRow + 1;
dtColText.Type = 'text';
dtColText.Tag  = 'dtColText';
dtColText.Name = DAStudio.message('Simulink:dialog:DataTypeColumnLabel');
dtColText.Mode = false;
dtColText.RowSpan = [layoutRow    layoutRow];
dtColText.ColSpan = [dtaUDTColIdx dtaUDTColIdx];

dtaColText.Type = 'text';
dtaColText.Tag  = 'dtaColText';
dtaColText.Name = DAStudio.message('Simulink:dialog:AssistantColumnLabel');
dtaColText.Mode = false;
dtaColText.RowSpan = [layoutRow    layoutRow];
dtaColText.ColSpan = [dtaBtnColIdx dtaBtnColIdx];

minColText.Type = 'text';
minColText.Tag  = 'minColText';
minColText.Name = DAStudio.message('Simulink:dialog:MinimumColumnLabel');
minColText.Mode = false;
minColText.RowSpan = [layoutRow    layoutRow];
minColText.ColSpan = [desMinColIdx desMinColIdx];

maxColText.Type = 'text';
maxColText.Tag  = 'maxColText';
maxColText.Name = DAStudio.message('Simulink:dialog:MaximumColumnLabel');
maxColText.Mode = false;
maxColText.RowSpan = [layoutRow    layoutRow];
maxColText.ColSpan = [desMaxColIdx desMaxColIdx];

% Common Unified data type items
%commonItems.scalingModes       = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
commonItems.signModes          = Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
commonItems.builtinTypes       = Simulink.DataTypePrmWidget.getBuiltinList('Num');
commonItems.scalingValueTags   = {};
commonItems.scalingMinTag      = {};
commonItems.scalingMaxTag      = {};
dtaItems                       = commonItems;

% Preallocate (empty)
udtSpecs = cell(1,numel(paramNames));

for i=1:numel(udtSpecs)
    if ~isempty(strfind(paramNames{i},'Param'))
        dtaItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
    else
        dtaItems.scalingModes = Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    end
    udtSpecs{i} = getUDT(source,h,paramNames{i},dtaItems);
end

% Call getSPCDataTypeWidgets
[promptWidgets, comboxWidgets, shwBtnWidgets, hdeBtnWidgets, dtaGUIWidgets] = ...
    Simulink.DataTypePrmWidget.getSPCDataTypeWidgets(source, udtSpecs, -1, []);

uDTypeRowIdx = layoutRow + 1;
dtaGUIRowIdx = uDTypeRowIdx + 1;
desMinWidgets = cell(1, numel(udtSpecs)); % preallocate (empty)
desMaxWidgets = cell(1, numel(udtSpecs)); % preallocate (empty)

for cnt = 1:numel(udtSpecs)
    
    isVisible = ~isempty(strmatch(udtSpecs{cnt}.dtName,visibleDataTypes,'exact'));
    
    isEnabled = ~source.isHierarchySimulating;
    promptWidgets{cnt}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    promptWidgets{cnt}.ColSpan = [dtaPrmColIdx dtaPrmColIdx];
    promptWidgets{cnt}.Visible = isVisible;
    
    comboxWidgets{cnt}.RowSpan = [uDTypeRowIdx uDTypeRowIdx];
    comboxWidgets{cnt}.ColSpan = [dtaUDTColIdx dtaUDTColIdx];
    comboxWidgets{cnt}.Visible = isVisible;
    comboxWidgets{cnt}.Enabled = isEnabled;
    
    shwBtnWidgets{cnt}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
    shwBtnWidgets{cnt}.ColSpan     = [dtaBtnColIdx dtaBtnColIdx];
    shwBtnWidgets{cnt}.Visible     = isVisible;
    shwBtnWidgets{cnt}.MaximumSize = get_size('BtnMax');
    shwBtnWidgets{cnt}.Enabled     = isEnabled;
    
    hdeBtnWidgets{cnt}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
    hdeBtnWidgets{cnt}.ColSpan     = [dtaBtnColIdx dtaBtnColIdx];
    hdeBtnWidgets{cnt}.MaximumSize = get_size('BtnMax');
    hdeBtnWidgets{cnt}.Enabled     = isEnabled;
    
    % Possible Design Min/Max edit box widgets
    hasDesMinMax = ~isempty(udtSpecs{cnt}.dtaItems.scalingMinTag);
    
    if hasDesMinMax
        
        desMinWidgets{cnt}.Type = 'edit';
        desMinWidgets{cnt}.Name = '';
        desMinWidgets{cnt}.Tag = udtSpecs{cnt}.dtaItems.scalingMinTag{1};
        desMinWidgets{cnt}.ObjectProperty = desMinWidgets{cnt}.Tag;
        desMinWidgets{cnt}.Mode = true;
        desMinWidgets{cnt}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
        desMinWidgets{cnt}.ColSpan     = [desMinColIdx desMinColIdx];
        desMinWidgets{cnt}.Visible     = isVisible;
        desMinWidgets{cnt}.MaximumSize = get_size('DesMMMax');
        desMinWidgets{cnt}.Enabled     = isEnabled;
        desMinWidgets{cnt}.UserData.detailPrompt = getPromptString(h,desMinWidgets{cnt}.ObjectProperty);
        
        desMaxWidgets{cnt}.Type = 'edit';
        desMaxWidgets{cnt}.Name = '';
        desMaxWidgets{cnt}.Tag = udtSpecs{cnt}.dtaItems.scalingMaxTag{1};
        desMaxWidgets{cnt}.ObjectProperty = desMaxWidgets{cnt}.Tag;
        desMaxWidgets{cnt}.Mode = true;
        desMaxWidgets{cnt}.RowSpan     = [uDTypeRowIdx uDTypeRowIdx];
        desMaxWidgets{cnt}.ColSpan     = [desMaxColIdx desMaxColIdx];
        desMaxWidgets{cnt}.Visible     = isVisible;
        desMaxWidgets{cnt}.MaximumSize = get_size('DesMMMax');
        desMaxWidgets{cnt}.Enabled     = isEnabled;
        desMaxWidgets{cnt}.UserData.detailPrompt = getPromptString(h,desMaxWidgets{cnt}.ObjectProperty);
        
    end
    
    % Data Type Assistant GUI widget
    dtaGUIWidgets{cnt}.RowSpan = [dtaGUIRowIdx dtaGUIRowIdx];
    dtaGUIWidgets{cnt}.ColSpan = [dtaUDTColIdx layoutCols];
    dtaGUIWidgets{cnt}.Enabled = isEnabled;
    
    uDTypeRowIdx = uDTypeRowIdx + 2;
    dtaGUIRowIdx = uDTypeRowIdx + 1;
    
end

layoutRow = uDTypeRowIdx;

% Scale Lock
chklockOutScale = createWidget(h,'checkbox','LockScale',...
    true,[layoutRow  layoutRow],[1 2],{},'',[]);

layoutRow = layoutRow + 1;
% Rounding values
cmbRounding = createWidget(h,'combobox','RndMeth',...
    true,[layoutRow  layoutRow],[2 2],RndMethEntries,false,[]);
cmbRounding.Name = '';
cmbRoundingBuddy.Name = getPromptString(h,'RndMeth');
cmbRoundingBuddy.Type = 'text';
cmbRoundingBuddy.Buddy = 'RndMeth';  cmbRoundingBuddy.Tag = 'RndMeth|Label';
cmbRoundingBuddy.RowSpan = [layoutRow  layoutRow]; cmbRoundingBuddy.ColSpan = [1 1];

layoutRow = layoutRow + 1;
% Saturation
chkSaturateOverflow = createWidget(h,'checkbox','SaturateOnIntegerOverflow',...
    true,[layoutRow  layoutRow],[1 2],{},'',[]);

layoutRow = layoutRow + 1;
spacer.Name = '';
spacer.Type = 'text';
spacer.RowSpan = [layoutRow layoutRow];
spacer.ColSpan =  [1 layoutCols];

tabDataTypes.Name = DAStudio.message('Simulink:dialog:DataTypesTab');
tabDataTypes.Items = {dtColText,dtaColText,minColText,maxColText};
for cnt = 1:numel(udtSpecs)
    tabDataTypes.Items = [tabDataTypes.Items promptWidgets{cnt} comboxWidgets{cnt} ...
        shwBtnWidgets{cnt} hdeBtnWidgets{cnt} dtaGUIWidgets{cnt}];
    hasDesMinMax = ~isempty(udtSpecs{cnt}.dtaItems.scalingMinTag);
    if hasDesMinMax
        tabDataTypes.Items = [tabDataTypes.Items desMinWidgets{cnt} ...
            desMaxWidgets{cnt}];
    end
end

tabDataTypes.Items = [tabDataTypes.Items chklockOutScale cmbRoundingBuddy ...
    cmbRounding chkSaturateOverflow spacer];

tabDataTypes.LayoutGrid = [layoutRow layoutCols];
tabDataTypes.RowStretch = [zeros(1,layoutRow-1) 1];    % Stretch only the last row
tabDataTypes.ColStretch = [ones(1, layoutCols -1), 0]; % Stretch all columns, but the last.

%% State Attributes tab

% State name
statename_I = createWidget(h,'edit','IntegratorContinuousStateAttributes',...
    true,[1 1],[1 1],{},'',2);

% State Identifier
stateidentifier_I = createWidget(h,'edit','IntegratorStateIdentifier',...
    true,[2 2],[1 1],{},'',2);
stateidentifier_I.DialogRefresh = true;

% State Must Resolve To Signal Object
stateresolve_I = createWidget(h,'checkbox','IntegratorStateMustResolveToSignalObject',...
    true,[3 3],[1 1],{},'',[]);
stateresolve_I.DialogRefresh = true;

% RTW State Storage Class
classRTW_I = createWidget(h,'combobox','IntegratorRTWStateStorageClass',...
    true,[4 4],[1 1],h.getPropAllowedValues('IntegratorRTWStateStorageClass'),false,[]);
classRTW_I.DialogRefresh = true;

% RTW State Storage Type Qualifier
qualifierRTW_I = createWidget(h,'edit','IntegratorRTWStateStorageTypeQualifier',...
    true,[5 5],[1 1],{},'',2);

isEnabled = ~source.isHierarchySimulating;
flag1 = ~isempty(source.IntegratorStateIdentifier);
flag2 = ~source.IntegratorStateMustResolveToSignalObject;
flag3 = ~strcmp(source.IntegratorRTWStateStorageClass,IntegratorRTWStateStorageClassEntries{1});

stateresolve_I.Enabled = isEnabled && flag1;   % Consider stateresolve_I.Enabled = stateresolve_I.Enabled && flag1   because of creatWidget
classRTW_I.Enabled     = isEnabled && flag1 && flag2;
qualifierRTW_I.Enabled = isEnabled && flag1 && flag2 && flag3;

statename_I.Visible = isI && ~isDT;
stateidentifier_I.Visible = isI && isDT;
stateresolve_I.Visible = isI && isDT;
classRTW_I.Visible = isI && isDT;
qualifierRTW_I.Visible = isI && isDT;

grpStateAttributes_I.Name = 'Integrator State';
grpStateAttributes_I.Type = 'group';
grpStateAttributes_I.Tag  = 'groupIntStateAttribute';
grpStateAttributes_I.LayoutGrid = [5 1];
grpStateAttributes_I.Items = {statename_I,stateidentifier_I,stateresolve_I,...
    classRTW_I,qualifierRTW_I};
grpStateAttributes_I.RowSpan = [1 1];
grpStateAttributes_I.ColSpan = [1 1];
grpStateAttributes_I.Flat = true;

% State name
statename_D = createWidget(h,'edit','FilterContinuousStateAttributes',...
    true,[1 1],[1 1],{},'',2);

% State Identifier
FilterStateIdentifier = createWidget(h,'edit','FilterStateIdentifier',...
    true,[2 2],[1 1],{},'',2);
FilterStateIdentifier.DialogRefresh = true;

% State Must Resolve To Signal Object
stateresolve_D = createWidget(h,'checkbox','FilterStateMustResolveToSignalObject',...
    true,[3 3],[1 1],{},'',[]);
stateresolve_D.DialogRefresh = true;

% RTW State Storage Class
classRTW_D = createWidget(h,'combobox','FilterRTWStateStorageClass',...
    true,[4 4],[1 1],h.getPropAllowedValues('IntegratorRTWStateStorageClass'),false,[]);
classRTW_D.DialogRefresh = true;

% RTW State Storage Type Qualifier
qualifierRTW_D = createWidget(h,'edit','FilterRTWStateStorageTypeQualifier',...
    true,[5 5],[1 1],{},'',2);

isEnabled = ~source.isHierarchySimulating;
flag1 = ~isempty(source.FilterStateIdentifier);
flag2 = ~source.FilterStateMustResolveToSignalObject;
flag3 = ~strcmp(source.FilterRTWStateStorageClass,FilterRTWStateStorageClassEntries{1});

stateresolve_D.Enabled = isEnabled && flag1;   % Consider stateresolve_I.Enabled = stateresolve_I.Enabled && flag1   because of creatWidget
classRTW_D.Enabled     = isEnabled && flag1 && flag2;
qualifierRTW_D.Enabled = isEnabled && flag1 && flag2 && flag3;

statename_D.Visible = isD && ~isDT;
FilterStateIdentifier.Visible = isD && isDT;
stateresolve_D.Visible = isD && isDT;
classRTW_D.Visible = isD && isDT;
qualifierRTW_D.Visible = isD && isDT;

grpStateAttributes_D.Name = 'Filter State';
grpStateAttributes_D.Type = 'group';
grpStateAttributes_D.Tag  = 'groupDerStateAttribute';
grpStateAttributes_D.LayoutGrid = [6 1];
grpStateAttributes_D.Items = {statename_D,FilterStateIdentifier,stateresolve_D,...
    classRTW_D,qualifierRTW_D};
grpStateAttributes_D.RowSpan = [2 2];
grpStateAttributes_D.ColSpan = [1 1];
grpStateAttributes_D.Flat = true;

if isI
    grpStateAttributes_I.Visible = true;
else
    grpStateAttributes_I.Visible = false;
end
if isD
    grpStateAttributes_D.Visible = true;
else
    grpStateAttributes_D.Visible = false;
end

panelSpacer.Type = 'panel';
panelSpacer.RowSpan = [5 5];
panelSpacer.ColSpan = 1;

tabStateAttributes.Name = 'State Attributes';
tabStateAttributes.Items = {grpStateAttributes_I,grpStateAttributes_D,panelSpacer};
tabStateAttributes.LayoutGrid = [3 1];
tabStateAttributes.RowStretch = [0 0 0 0 1];
tabStateAttributes.ColStretch = 1;

%% Tabs
tabList.Type = 'tab';
tabList.Tabs = {tabMain,tabPIDAdvanced,tabDataTypes,tabStateAttributes};
tabList.ColSpan = [1 3];
tabList.RowSpan = [4 4];

%% Dialog
dlgStruct.DialogTitle = DialogTitleStr;
dlgStruct.DialogTag   = DialogTagStr;
dlgStruct.HelpMethod  = 'slhelp';
dlgStruct.HelpArgs    = {h.Handle};
dlgStruct.Items       = {grpDescription, radioTime, cmbController, grpDiscrete, ...
    tabList};
dlgStruct.LayoutGrid  = [4 3];
dlgStruct.RowStretch  = [0 0 0 1];
dlgStruct.ColStretch  = [0 0 1] ;
%dlgStruct.Geometry    = [getPixels(2) getPixels(2) getPixels(7.8) getPixels(9)];
dlgStruct.ShowGrid = false;

% Required for simulink/block sync ----
dlgStruct.PreApplyMethod = 'callbackPreApplyPID';
dlgStruct.PreApplyArgs   = {'%dialog'};
dlgStruct.PreApplyArgsDT = {'handle'};

dlgStruct.PostApplyMethod   =  'callbackPostApplyPID';
dlgStruct.PostApplyArgs     = {'%dialog'};
dlgStruct.PostApplyArgsDT   = {'handle'};

% Required for deregistration ---------
dlgStruct.CloseMethod       = 'closeCallback';
dlgStruct.CloseMethodArgs   = {'%dialog'};
dlgStruct.CloseMethodArgsDT = {'handle'};

% Disable the dialog in a library.
[~, isLocked] = source.isLibraryBlock(h);
if isLocked
    dlgStruct.DisableDialog = 1;
else
    dlgStruct.DisableDialog = 0;
end

end



% ************************** Local functions *************************** %

function aStruct = createWidget(ahandle,aType,aObjectProperty,aMode,...
    aRowSpan,aColSpan,aEntries,aEditable,aNameLocation)
%% Create widgets local functions

aStruct.Name = getPromptString(ahandle,aObjectProperty);
aStruct.ObjectProperty = aObjectProperty;
aStruct.Type = aType;
aStruct.Tag = aObjectProperty;
aStruct.Mode = aMode;
aStruct.RowSpan = aRowSpan;
aStruct.ColSpan = aColSpan;

if ~isempty(aEntries)
    aStruct.Entries = aEntries;
end
if ~isempty(aEditable)
    aStruct.Editable = aEditable;
end
if ~isempty(aNameLocation)
    aStruct.NameLocation = aNameLocation;
end

source = ahandle.getDialogSource;
if ~isTunable(ahandle,aObjectProperty)
    aStruct.Enabled = ~source.isHierarchySimulating;
end

end

function aPromptString = getPromptString(h,paramName)
%% Get the prompt string stored in the block
aPromptString = h.DialogParameters.(paramName).Prompt;
% i= strcmp(h.MaskName,paramName);
% aPromptString = h.MaskPrompts{i};
end

function status = isTunable(h,paramName)
strarray = h.DialogParameters.(paramName).Attributes;
status = isempty(strmatch('read-only-if-compiled',strarray,'exact'));
end

function udtSpec = getUDT(source,h,paramName,dtaItems)
% Get inherit list form the mask
tmp = getPropAllowedValues(h,paramName);
InheritList = tmp(strmatch('Inherit:',tmp));
dtaItems.inheritRules = InheritList;
if isempty(strfind(paramName,'Accum'))
    dtaItems.scalingMinTag= {strrep(paramName,'DataTypeStr','Min')};
    dtaItems.scalingMaxTag= {strrep(paramName,'DataTypeStr','Max')};
else
    dtaItems.scalingMinTag= {};
    dtaItems.scalingMaxTag= {};
end
udtSpec.hDlgSource            = source;
udtSpec.dtName                = paramName;
udtSpec.dtPrompt              = getPromptString(h,paramName);
udtSpec.dtTag                 = paramName;
udtSpec.dtVal                 = h.(paramName);
udtSpec.dtaItems              = dtaItems;
udtSpec.customAsstName        = false;
end

%==========================================================================
function size = get_size(what)
switch what
    case 'BtnMax'
        size = [(get_inch*5/12) 2^24-1];
    case 'DesMMMax'
        size = [get_inch 2^24-1];
    otherwise
        size = [0 0];
end
end

%==========================================================================
function dpi = get_inch
dpi = get(0,'ScreenPixelsPerInch');
end