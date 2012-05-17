function output = uset_param(object, varargin)
% Unified "set_param" utility for Simulink/Stateflow configuration.
%
% Examples:
%     uset_param('model_name', 'SolverMode', 'Auto')
%     uset_param('model_name', 'GenerateSampleERTMain', 'on')
%     uset_param('model_name', 'RootIOStructures', 'off')
%     uset_param('model_name', 'StateBitSets', 'on')
%
% To create a recovery (undo) point:
%     uset_param('model_name', 'BackupSettings')
% 
% To undo updates since last recovery point:
%     uset_param('model_name', 'RestoreSettings')
% 
% Or, specify multiple parameter/value pairs for a batch setting
%
%     uset_param('model_name', 'SolverMode', 'Auto', 'RTWInlineParameters', 'off')
%
% See also UGET_PARAM, GET_PARAM, SET_PARAM.

%   Copyright 2002-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $ $Date: 2009/11/13 05:08:07 $

persistent LAST_OBJECT;  % last working on object
persistent Update_Log;   % updating log
persistent dirty_state;  % dirty state of object

persistent warning_issued; % this prevents warning spamming

output = '';

if isempty(warning_issued)
    warning('Simulink:uset_param_obsolete',...
             [DAStudio.message('Simulink:dialog:ObsoleteFunctionUsetParam', 'uset_param', 'set_param'), ...
             'warning(''off'',''Simulink:uset_param_obsolete'')\n']);

    % assign any value to warning_issued to prevent spamming of the warning
    warning_issued = true;
end

if nargin <= 1
    % return table if invoked by uset/uget_param(model) or uset/get_param()
    output = MapParamNametoInternalName('', '');
    % extract Description, External name and valid value group columns
    output = [output(:,1), output(:,3), output(:,4)];
    return;
end

isConfigObj = false;

if isa(object, 'Simulink.ConfigSet')
  isConfigObj = true;
else
  object = get_param(object, 'handle');
  if isempty(find_system(object, 'type', 'block_diagram'))
    DAStudio.error('Simulink:dialog:FirstInputArgValidModelName');
  end
end

if isempty(LAST_OBJECT)
    % first start
    if isConfigObj
      dirty_state = 'off';
    else
      dirty_state = get_param(object, 'dirty');
    end
    LAST_OBJECT = object;
    Update_Log = {};
elseif ~strcmp(class(LAST_OBJECT), class(object)) || object ~= LAST_OBJECT
    % if user changed working object, clear log
    if isConfigObj
      dirty_state = 'off';
    else
      dirty_state = get_param(object, 'dirty');
    end
    LAST_OBJECT = object;
    Update_Log = {};
end

if strcmpi(varargin{1}, 'BackupSettings')
    if isConfigObj
      dirty_state = 'off';
    else
      dirty_state = get_param(object, 'dirty');
    end
    LAST_OBJECT = object;
    Update_Log = {};
    % disp('Recovery point created.');
    return;
elseif strcmpi(varargin{1}, 'RestoreSettings')
    if ~isempty(Update_Log)
        [Update_Log, errorLog] = undoUpdates(object, Update_Log);%#ok
        if ~isConfigObj
          set_param(object, 'dirty', dirty_state);
        end
        % disp('Recovery point restored.');
    else
        % disp('Log is empty.');
    end
    return;
elseif strcmpi(varargin{1}, 'uget_param')
    % support for "get" method
    if (nargin-2) == 0
        % return table if invoked by uset_param(model)
        output = MapParamNametoInternalName('', '');
        % extract Description, External name
        output = [output(:,1), output(:,3)];
        return;
    end
    internalName = MapParamNametoInternalName(varargin{2}, '');
    if iscell(internalName)
        internalName = internalName{:};
    end
    output = unifygetparam(object, internalName);
    return;
elseif mod((nargin-1), 2) > 0
    DAStudio.error('Simulink:dialog:InputArgsPropValPair');
end

for i=1:2:(nargin-1)
    [internalName, internalValue] = MapParamNametoInternalName(varargin{i}, varargin{i+1});
    if iscell(internalName)
        internalName = internalName{:};
    end
    if iscell(internalValue)
        internalValue = internalValue{:};
    end
    currentLog = unifysetparam(object, internalName, internalValue);
    Update_Log{end+1} = currentLog;%#ok
end

function paramValue = unifygetparam(object, paramName)
isConfigObj = isa(object, 'Simulink.ConfigSet');
[category, subParamName] = analyzeName(paramName);

if strcmpi(category, 'stateflow')  % support for stateflow sub category
  paramValue = stateflowsettings('get', getfullname(object), subParamName);
elseif strcmpi(category, 'rtwoption')  % support for rtwoption sub category
  paramValue = getrtwoption(object, subParamName);    
else
  if ~isConfigObj
    cs = getActiveConfigSet(object);
  else
    cs = object;
  end
  
  fp = get_param(cs, 'ObjectParameters');
  if isfield(fp, paramName) 
    paramValue = get_param(cs, paramName);
  else
    % Parameter may only exist in bd world
    try
      paramValue = get_param(object, paramName);
    catch %#ok
      DAStudio.error('Simulink:dialog:UnsupportedParamSpecified', paramName);
    end
  end
end
    
function currentLog = unifysetparam(object, paramName, paramValue)
currentLog=[]; 
isConfigObj = isa(object, 'Simulink.ConfigSet');
[category, subParamName] = analyzeName(paramName);

if strcmpi(category, 'stateflow')  % support for stateflow sub category
  oldValue = stateflowsettings('get', getfullname(object), subParamName);
  if isempty(oldValue)
    % warning(['Unsupported parameter specified: ' paramName]);
    currentLog.NA = 1; % Not Applicable
  else
    setValue = l_translate(paramValue, 'decode');
    if iscell(setValue)
      setValue = setValue{:};
    end                            
    try
      stateflowsettings('set', getfullname(object), subParamName, setValue);
    catch err
      error(err.message);
    end
    newValue = stateflowsettings('get', getfullname(object), subParamName);
    % log current action
    currentLog.NA = 0; % Not Applicable
    currentLog.ParamName = paramName;
    currentLog.oldValue = oldValue;
    currentLog.setValue = setValue;
    currentLog.newValue = newValue;            
  end
elseif strcmpi(category, 'rtwoption')  % support for rtwoption sub category
    oldValue = getrtwoption(object, subParamName);
    if strcmpi(oldValue, 'We_Can_Not_Find_The_Value')
        if ~strcmpi(subParamName,'TargetOS') && ...
                ~strcmpi(subParamName,'MultiInstanceErrorCode')
            DAStudio.warning('Simulink:dialog:UnsupportedParamSpecified', subParamName);
        end
        currentLog.NA = 1; % Not Applicable
    else
        setValue = l_translate(paramValue, 'decode');
        if iscell(setValue)
            setValue = setValue{:};
        end
        if isnumeric(oldValue) && isstr(setValue)%#ok
            setValue = str2num(setValue);%#ok
        end
        try
            setrtwoption(object, subParamName, setValue);
        catch err
            error(err.message);
        end
        newValue = getrtwoption(object, subParamName);
        % log current action
        currentLog.NA = 0; % Not Applicable
        currentLog.ParamName = paramName;
        currentLog.oldValue = oldValue;
        currentLog.setValue = setValue;
        currentLog.newValue = newValue;
    end
else
   if ~isConfigObj
    cs = getActiveConfigSet(object);
  else
    cs = object;
  end
  fp = get_param(cs, 'ObjectParameters');
 
  if isfield(fp, paramName) || strcmpi(paramName, 'ConditionallyExecuteInputs')
    oldValue = get_param(cs, paramName);
    setValue = l_translate(paramValue, 'decode');
    if iscell(setValue)
        setValue = setValue{:};
    end
    if isnumeric(oldValue) && ischar(setValue)
        setValue = str2num(setValue);%#ok
    end
    
    try
      set_param(cs, paramName, setValue);
    catch err
      error(err.message);
    end
    newValue = get_param(cs, paramName);
    % log current action
    currentLog.NA = 0; % Not Applicable
    currentLog.ParamName = paramName;
    currentLog.oldValue = oldValue;
    currentLog.setValue = setValue;
    currentLog.newValue = newValue;
  else
    try
      oldValue = get_param(object, paramName);
      setValue = l_translate(paramValue, 'decode');
      if iscell(setValue)
        setValue = setValue{:};
      end
      if isnumeric(oldValue) && ischar(setValue)
        setValue = str2num(setValue);%#ok
      end
      
      set_param(object, paramName, setValue);

      newValue = get_param(object, paramName);
      % log current action
      currentLog.NA = 0; % Not Applicable
      currentLog.ParamName = paramName;
      currentLog.oldValue = oldValue;
      currentLog.setValue = setValue;
      currentLog.newValue = newValue;
    catch %#ok
      currentLog.NA = 1; % Not Applicable
      DAStudio.error('Simulink:dialog:UnsupportedParamOrValSpecified', paramName, paramValue);
    end
  end
end

%undo updates
function [updateLog, errorLog] = undoUpdates(object, lastupdateLog)
updateLog=[];
errorLog='';
for j=1:length(lastupdateLog)
    newLog=[];
    if lastupdateLog{j}.NA
        newLog.NA = 1; % Not Applicable
    else
        newLog.ParamName = lastupdateLog{j}.ParamName;
        newLog.NA = 0;
        newLog.oldValue = lastupdateLog{j}.setValue;
        newLog.setValue = lastupdateLog{j}.oldValue;
        try
            [category, subParamName] = analyzeName(lastupdateLog{j}.ParamName);
            if strcmpi(category, 'stateflow')  % support for stateflow sub category
              stateflowsettings('set', getfullname(object), subParamName, lastupdateLog{j}.oldValue);
            else
              if isa(object, 'Simulink.ConfigSet')
                cs = object;
              else
                cs = getActiveConfigSet(object);
              end
              set_param(cs, lastupdateLog{j}.ParamName, lastupdateLog{j}.oldValue);
            end
        catch err
          errorLog = [errorLog, sprintf('\n'), err.message];%#ok
        end
        if strcmpi(category, 'stateflow')  % support for stateflow sub category
          newLog.newValue = stateflowsettings('get', getfullname(object), subParamName);
        else
          if isa(object, 'Simulink.ConfigSet')
            cs = object;
          else
            cs = getActiveConfigSet(object);
          end          
          newLog.newValue = get_param(cs, lastupdateLog{j}.ParamName);
        end
    end
    updateLog{length(updateLog)+1} = newLog;%#ok
end

% this function will translate between HTML page display and internal
% representation. i.e., "Yes"<->1 "No <->0
function output = l_translate(input, choice)
Table = ...
    { 'Yes' '1';...
      'No' '0';...
  };
input = num2str(input);
output = input;
switch choice
    case 'encode'
        for i=1:length(Table)
            if strcmpi(Table(i,2), input)
                output = Table(i,1);
                return
            end
        end
    case 'decode'
        for i=1:length(Table)
            if strcmpi(Table(i,1), input)
                output = Table(i,2);
                output = str2num(output{:});%#ok
                return
            end
        end
    otherwise
end

% analyze HTML form element:  "Name=Value"
% we expect "Name" follow category_serialNum pattern
function [category, serialNum] = analyzeName(name)
[category, serialNum] = strtok(name, '_');
serialNum = serialNum(2:end);
  
function result = stateflowsettings(methodName,modelName,codeFlag,codeFlagValue)
% call it with
% settings('get'/'set',modelName,'databitsets/statebitsets',1/0)
%
  result = [];
  switch(methodName)
   case 'get',
    result = get_code_flag(modelName,codeFlag);
   case 'set'
    result = set_code_flag(modelName,codeFlag,codeFlagValue);
  end
  
function result = get_code_flag(modelName,codeFlag)
  result = [];
  machineId = sf('find','all','machine.name',modelName);
  if(isempty(machineId))
    return;
  end
  targetId = sf('Private','acquire_target',machineId,'rtw');
  result = sf('Private','target_code_flags','get',targetId,codeFlag);
  
function result = set_code_flag(modelName,codeFlag,flagValue)
  
  machineId = sf('find','all','machine.name',modelName);
  if(isempty(machineId))
    return;
  end
  targetId = sf('Private','acquire_target',machineId,'rtw');
  sf('Private','target_code_flags','set',targetId,codeFlag,flagValue);
  result = flagValue;

  
% translate parameter name/value pairs (such as Solver, GenSampleERTMain...) into internal
% representation name such as rtwoption_GenSampleERTMain.
function [internalName, internalValue] = MapParamNametoInternalName(paramName, paramValue)
persistent TranslationTable;
if isempty(TranslationTable)
    TranslationTable = ...
    { %Description name, Internal name, External paramName, valid values
    % Solver Page
        'Start simulation time', 'StartTime', 'StartTime', {};...
        'Stop simulation time', 'StopTime', 'StopTime', {};...
        'Absolute tolerance', 'AbsTol', 'AbsTol', {};...
        'Fixed step size', 'FixedStep', 'FixedStep', {};...
        'Initial step size', 'InitialStep', 'InitialStep', {};...
             %If MinStepSize parameter is a 2 element vector, then the second element is MaxNumMinSteps
        'Maximum number of minimum steps violation', 'MaxNumMinSteps', 'MaxnumMinSteps', {};...
        'Maximum Order (variable step solver ode15s)', 'MaxOrder', 'MaxOrder', {};...
        'Maximum step size', 'MaxStep', 'MaxStep', {};...
        'Minimum step size', 'MinStep', 'MinStep', {};...
        'Relative tolerance', 'RelTol', 'RelTol', {};...
        'Tasking mode', 'SolverMode', 'SolverMode', {'Auto', 'SingleTasking', 'MultiTasking'};...
        'Solver', 'Solver', 'Solver', getSolversByParameter();...
        % 'SolverType', derivative parameter from Solver, not writtable
        'Global zero cross control', 'ZeroCrossControl', 'ZeroCrossControl', {'UseLocalSettings', 'EnableAll', 'DisableAll'};... %R14 only
        % 'Zero cross algorithm', only accessible via ConfigSet object. 
    % Data Import/Export
        'Decimation', 'Decimation', 'Decimation', {};...
        'External input', 'ExternalInput', 'ExternalInput', {};...    
        'Final state name', 'FinalStateName', 'FinalStateName', {};...
        'Initial state name', 'InitialState', 'InitialState', {};...
        'Limit save data points', 'LimitDataPoints', 'LimitDataPoints', {'on', 'off'};...
        'Maximum save data points', 'MaxDataPoints', 'MaxDataPoints', {};...
        'Load external input', 'LoadExternalInput', 'LoadExternalInput', {'on', 'off'};...
        'Load initial state', 'LoadInitialState', 'LoadInitialState', {'on', 'off'};...
        'Save final state', 'SaveFinalState', 'SaveFinalState', {'on', 'off'};...
        'Save format', 'SaveFormat', 'SaveFormat', {'Array', 'StructureWithTime', 'Structure'};...
        'Save output', 'SaveOutput', 'SaveOutput', {'on', 'off'};...
        'Save state', 'SaveState', 'SaveState', {'on', 'off'};...
        'Save time', 'SaveTime', 'SaveTime', {'on', 'off'};...
        'State save name on workspace', 'StateSaveName', 'StateSaveName', {};...
        'Time save name on workspace', 'TimeSaveName', 'TimeSaveName', {};...
        'Output save name on workspace', 'OutputSaveName', 'OutputSaveName', {};...
        'Signal logging name', 'SignalLoggingName', 'SignalLoggingName', {};...
        'Output option', 'OutputOption', 'OutputOption', {'RefineOutputTimes', 'AdditionalOutputTimes', 'SpecifiedOutputTimes'};...
        'Output times', 'OutputTimes', 'OutputTimes', {};...
        'Output refine factor', 'Refine', 'Refine', {};...
        
    % Optimization
        'Eliminate redundant blocks (block reduction)', 'BlockReduction', 'BlockReduction', {'on', 'off'};...
        'Implement logic signals as boolean data', 'BooleanDataType', 'BooleanDataType', {'on', 'off'};...
        %'Conditionally execute blocks without state that feed switch operations', 'ConditionallyExecuteInputs', 'ConditionalExecOptimization', {'on', 'off'};...  % R13 version, it will disappear from ObjectParameters list in R14.
        %'Conditionally execute blocks without state that feed switch operations', 'ConditionalExecOptimization', 'ConditionalExecOptimization', {'on', 'off'};...  % R14 version
%         'Inline parameter values', 'InlineParams', 'InlineParams', {'on', 'off'};...  % R13 & R14
%         'Inline parameter values', 'InlineParameters', 'InlineParams', {'on', 'off'};... % R14 only 
        'Inline parameter values', 'InlineParams', 'InlineParams', {'on', 'off'};
        'Inline invariant signals with macros', 'InlineInvariantSignals', 'InlineInvariantSignals',  {'on', 'off'};...
        'Implement every signal in persistent global memory (1 of 2)', 'OptimizeBlockIOStorage', 'OptimizeBlockIOStorage', {'on', 'off'};...
        'Reuse local (stack) variables', 'BufferReuse', 'BufferReuse', {'on', 'off'};...
        'Preserve integer downcasts in folded expressions', 'EnforceIntegerDowncast', 'EnforceIntegerDowncast', {'on', 'off'};...
        'Eliminate superfluous temporary variables (expression folding)', 'ExpressionFolding', 'ExpressionFolding', {'on', 'off'};...
        'Expression fold unrolled vector signals', 'FoldNonRolledExpr', 'FoldNonRolledExpr', {'on', 'off'};...       
        'Implement every signal in persistent global memory (2 of 2)', 'LocalBlockOutputs', 'LocalBlockOutputs', {'on', 'off'};...
        'Generate reusable code for the entire model', 'MultiInstanceERTCode', 'MultiInstanced',  {'on', 'off'};...
        'Optimize storage of non-scalar parameter values', 'ParameterPooling', 'ParameterPooling', {'on', 'off'};...
        'For storing state information in Stateflow charts', 'StateBitsets', 'StateBitSets', {'on','off'};
        'For storing boolean data in Stateflow charts', 'DataBitsets', 'DataBitsets', {'on','off'};...
        'RTW System code inline auto', 'SystemCodeInlineAuto', 'SystemCodeInlineAuto', {'on', 'off'};...
        % IOFormat : stateflow option, skip for now
        
    % Debugging
        'Consistency checking', 'ConsistencyChecking', 'ConsistencyChecking', {'none', 'warning', 'error'} ;...
        'Array bounds checking', 'ArrayBoundsChecking', 'ArrayBoundsChecking', {'none', 'warning', 'error'} ;...
        'Algebraic loop', 'AlgebraicLoopMsg', 'AlgebraicLoopMsg', {'none', 'warning', 'error'} ;...
        'Block priority violation', 'BlockPriorityViolationMsg', 'BlockPriorityViolationMsg', {'warning', 'error'} ;...
        'Minimal step size violation', 'MinStepSizeMsg', 'MinStepSizeMsg', {'warning', 'error'} ;...
        '-1 sample time in source', 'InheritedTsInSrcMsg', 'InheritedTsInSrcMsg', {'none', 'warning', 'error'} ;...
        'Discrete used as continuous', 'DiscreteInheritContinuousMsg', 'DiscreteInheritContinuousMsg', {'none', 'warning', 'error'} ;...
        'MultiTask rate transition', 'MultiTaskRateTransMsg', 'MultiTaskRateTransMsg', {'warning', 'error'} ;...
        'SingleTask rate transition', 'SingleTaskRateTransMsg', 'SingleTaskRateTransMsg', {'none', 'warning', 'error'} ;...
        'Check for singular matrix', 'CheckMatrixSingularityMsg', 'CheckForMatrixSingularity', {'none', 'warning', 'error'} ;...
        'Data overflow', 'IntegerOverflowMsg', 'IntegerOverflowMsg', {'none', 'warning', 'error'} ;...
        'Int32 to float conversion', 'Int32ToFloatConvMsg', 'Int32ToFloatConvMsg', {'none', 'warning'} ;...
        'Parameter downcast', 'ParameterDowncastMsg', 'ParameterDowncastMsg', {'none', 'warning', 'error'} ;...
        'Parameter overflow', 'ParameterOverflowMsg', 'ParameterOverflowMsg', {'none', 'warning', 'error'} ;...
        'Parameter precision loss', 'ParameterPrecisionLossMsg', 'ParameterPrecisionLossMsg', {'none', 'warning', 'error'} ;...
        'Under specified data types', 'UnderSpecifiedDataTypeMsg', 'UnderSpecifiedDataTypeMsg', {'none', 'warning', 'error'} ;...
        'Unneeded type conversions', 'UnnecessaryDatatypeConvMsg', 'UnnecessaryDatatypeConvMsg', {'none', 'warning'} ;...
        'Vector/Matrix conversion', 'VectorMatrixConversionMsg', 'VectorMatrixConversionMsg', {'none', 'warning', 'error'} ;...
        'Model reference I/O', 'ModelReferenceIOMsg', 'ModelrefIOMsg', {'none', 'warning', 'error'} ;...
        'Invalid FunCall connection', 'InvalidFcnCallConnMsg', 'InvalidFcnCallConnMsg', {'none', 'warning', 'error'} ;...
        'Signal label mismatch', 'SignalLabelMismatchMsg', 'SignalLabelMismatchMsg', {'none', 'warning', 'error'} ;...
        'Unconnected block input', 'UnconnectedInputMsg', 'UnconnectedInputMsg', {'none', 'warning', 'error'} ;...
        'Unconnected block output', 'UnconnectedOutputMsg', 'UnconnectedOutputMsg', {'none', 'warning', 'error'} ;...
        'Unconnected line', 'UnconnectedLineMsg', 'UnconnectedLineMsg', {'none', 'warning', 'error'} ;...
        'S-function upgrades needed', 'SFcnCompatibilityMsg', 'SfunCompatibilityCheckMsg', {'none', 'warning', 'error'} ;...
        'Show build log inside MATLAB Command Window', 'RTWVerbose', 'RTWVerbose',    {'on', 'off'};...
        'Retain RTW file', 'RetainRTWFile', 'RetainRTWFile', {'on', 'off'};...
        'Profile TLC file', 'ProfileTLC', 'ProfileTLC', {'on', 'off'};...
        'Start TLC debugger when generating code', 'TLCDebug', 'TLCDebug', {'on', 'off'};...
        'Start TLC coverage when generating code', 'TLCCoverage', 'TLCCoverage', {'on', 'off'};...
        'Enable TLC assertions', 'TLCAssert', 'TLCAssertion', {'on', 'off'};...
        'Model verification block control', 'AssertControl', 'AssertControl', {'UseLocalSettings', 'EnableAll', 'DisableAll'};...
        % 'Stateflow echo', skip for now
        % 'Stateflow enable overflow detection', skip for now
        
        
    % Custom Code: Stateflow options, skip for now        
        % 'CustomCode'
        % 'CustomInitializer'
        % 'CustomTerminator'
        % 'UserIncludeDirs'
        % 'UserLibs'
        % 'UserSrcs'
    
    % Hardware Implementation
        'Production hardware characteristics', 'ProdHWDeviceType', 'ProdHWDeviceType', {'Specified','32-bit Generic','Infineon TriCore',...
                                                                                        'Motorola PowerPC','Motorola 68332','NEC 85x',...
                                                                                        'Hitachi SH-2','TI C6000','16-bit Generic',...
                                                                                        'ARM7','Infineon C16x','Motorola HC12','ASIC/FPGA'};...
        'Number of bits per char', 'ProdBitPerChar', 'ProdBitPerChar', {};... 
        'Number of bits per int', 'ProdBitPerInt', 'ProdBitPerInt', {};... 
        'Number of bits per long', 'ProdBitPerLong', 'ProdBitPerLong', {};... 
        'Number of bits per short', 'ProdBitPerShort', 'ProdBitPerShort', {};...
        
    % Document
        % 'DocumentLink', Stateflow options, skip for now        
        'Document generated code inside an HTML report', 'GenerateReport', 'GenerateReport',   {'on', 'off'};...
        
    % Code Appearance
        % 'Comment', stateflow option
        'Unconditionally comment parameter data structure', 'ForceParamTrailComments', 'ForceParamTrailComments', {'on', 'off'};...
        'Include comments', 'GenerateComments', 'GenerateComments', {'on', 'off'};...
        'Ignore custom storage classes', 'IgnoreCustomStorageClasses', 'IgnoreCustomStorageClasses',  {'on', 'off'};...
        'Include system hierarchy number in identifiers', 'IncHierarchyInIds', 'IncHierarchyInIds',  {'on', 'off'};...
        'Maximum identifier length (does not apply to Stateflow identifiers)', 'MaxIdLength', 'MaxIdLength', {};...
        % 'PreserveName' stateflow option
        % 'PreserveNameWithParent' stateflow option
        'Show eliminated code statements', 'ShowEliminatedStatement', 'ShowEliminatedStatement',    {'on', 'off'};...

    % RTW Target
        'RTW system target file', 'SystemTargetFile', 'SystemTargetFile', {};...
        % 'Code generation directory', only accessible via ConfigSet, R14 only
        'Generate code only', 'GenCodeOnly', 'GenCodeOnly', {'on', 'off'};...
        'RTW make command', 'MakeCommand', 'MakeCommand', {};...
        'Template make file', 'TemplateMakefile', 'TemplateMakefile', {};...
        'Include data type acronym in identifier', 'IncDataTypeInIds', 'IncDataTypeInIds', {'on', 'off'};...
        'Prefix model name to global identifiers', 'PrefixModelToSubsysFcnNames', 'PrefixModelToSubsysFcnNames', {'on', 'off'};...
        'Generate scalar inlined parameters as', 'InlinedPrmAccess', 'InlinedPrmAccess', {'Literals', 'Macros'};...
        'Generate full header including time stamp', 'GenerateFullHeader', 'GenerateFullHeader', {'on', 'off'};...
        'Processor in the loop Target', 'IsPILTarget', 'IsPILTarget', {'on', 'off'};...
        'MAT-file variable name modifier', 'LogVarNameModifier', 'LogVarNameModifier', {'rt_', 'none', '_rt'};... % R14 GRT only
        'Instrument code for Simulink External Mode', 'ExtMode', 'ExtMode', {'on', 'off'};...
%       'External mode transport layer', 'ExtModeTransport', 'ExtModeTransport', {'tcpip', 'serial_win32'};...
        'External mode transport layer', 'ExtModeTransport', 'ExtModeTransport', {};...
        
   % Additional options 
        'Initialize root level I/O data to zero', 'ZeroExternalMemoryAtStartup', 'ZeroExternalMemoryAtStartup', {'on', 'off'};...
        'Initialize internal state data to zero', 'ZeroInternalMemoryAtStartup', 'ZeroInternalMemoryAtStartup', {'on', 'off'};...
        'Explicitly initialize floats and doubles to 0.0', 'InitFltsAndDblsToZero', 'InitFltsAndDblsToZero', {'on', 'off'};...
        'Parameter structure implementation', 'InlinedParameterPlacement', 'InlinedParameterPlacement', {'Hierarchical', 'NonHierarchical'};...
        'Generate a concise example main program for this model', 'GenerateSampleERTMain', 'GenerateSampleERTMain', {'on', 'off'};...
        'Target operating system', 'TargetOS', 'TargetOS', {'BareBoardExample', 'VxWorksExample'};...
        'Generate integer code only', 'PurelyIntegerCode', 'PurelyIntegerCode', {'on', 'off'};...
        'Target floating point math environment', 'TargetFunctionLibrary', 'TargetFunctionLibrary', {'ANSI_C', 'ISO_C'};...
        'Unroll for loops when signal width does not exceed threshold', 'RollThreshold', 'RollThreshold', {};...
        'Insert Simulink block descriptions', 'InsertBlockDesc', 'InsertBlockDesc', {'on', 'off'};...
        'Create SIL block for software-in-the-loop testing', 'GenerateErtSFunction', 'GenerateErtSFunction', {'on', 'off'};...
        'Instrument the generated code to log results into a MAT-file', 'MatFileLogging', 'MatFileLogging',   {'on', 'off'};...
        'Reusable code error diagnostic', 'MultiInstanceErrorCode', 'MultiInstanceErrorCode',  {'Error', 'Warning', 'None'};...
        'Pass root level I/O data as', 'RootIOFormat', 'RootIOStructures',  {'Individual Arguments', 'Structure Reference'};...
        'Suppress error status in real-time model data structure', 'SuppressErrorStatus', 'SuppressErrorStatus',  {'on', 'off'};...
        'Combine the model step function into a single output/update function', 'CombineOutputUpdateFcns', 'CombineOutputUpdateFcns', {'on', 'off'};...
        'Generate a model termination function', 'IncludeMdlTerminateFcn', 'IncludeMdlTerminateFcn',  {'on', 'off'};...
        'Generate an ASAP2 data exchange file', 'GenerateASAP2', 'GenerateASAP2', {'on', 'off'};...
        'Generate a C-interface API for runtime Signal monitoring', 'RTWCAPISignals', 'BlockIOSignals',       {'on', 'off'};...
        'Generate a C-interface API for runtime Parameter tuning', 'RTWCAPIParams', 'ParameterTuning',     {'on', 'off'};...
        
    };
    verinfo = ver('simulink');
    vernum = str2num(verinfo.Version(1:3));%#ok
    R13str = {'Conditionally execute blocks without state that feed switch operations', 'ConditionallyExecuteInputs', 'ConditionalExecOptimization', {'on', 'off'};}; % R13 version, it will disappear from ObjectParameters list in R14.
    R14str = {'Conditionally execute blocks without state that feed switch operations', 'ConditionalExecOptimization', 'ConditionalExecOptimization', {'on', 'off'};};%#ok  % R14 version 
    if abs(vernum - 5.0) > 1e-4
        % TranslationTable = [TranslationTable; R14str]; % Vertical concatenation
        % always using R13 style for increase compatibility.
        TranslationTable = [TranslationTable; R13str]; % Vertical concatenation
    else
        TranslationTable = [TranslationTable; R13str]; % Vertical concatenation
    end
end

% return full table if empty paramName pass in
if isempty(paramName)
    internalName = TranslationTable;
    return;
end

% do translation
for i=1:length(TranslationTable)
    if strcmp(TranslationTable(i, 3), paramName)
        internalName = TranslationTable(i,2);
        if ~isempty(paramValue)
            validValueGroup = TranslationTable(i,4);
            validValueGroup = validValueGroup{1};
        else
            % if only pass in paramName, we'll only translate paramName
            internalValue = '';
            return
        end
        if ~isempty(validValueGroup)
            % if validValueGroup is 'on/off' group, translate 'on/off' into
            % it.
            if (strcmpi(validValueGroup(1), 'Yes'))
                if strcmpi(paramValue, 'on')
                    paramValue = 'Yes';
                elseif strcmpi(paramValue, 'off')
                    paramValue = 'No';
                end
            end
            
            for j=1:length(validValueGroup)
                if strcmpi(validValueGroup(j), paramValue)
                    internalValue = validValueGroup(j);
                    return
                end
            end
            % if reach here, means value not found in validValueGroup
            DAStudio.error('Simulink:dialog:InvalidInputParamValForParam', paramValue, paramName);
        else
            % no rescrition on valid values 
            internalValue = paramValue;
        end
        return
    end
end
% if not found in the table, keep the original pair untouched
internalName = paramName;
internalValue = paramValue;


function setrtwoption(modelname,opt,val,create)
%SETRTWOPTION sets an RTW option for a Simulink model
%   OPT=SETRTWOPTION(MODELNAME, OPT, VALUE, CREATE) sets the RTW option OPT to VALUE for 
%   Simulink model MODELNAME. If CREATE = 1 the option is created if necessary, otherwise
%   an error is thrown if the option does note exist.
  if ~isa(modelname, 'Simulink.ConfigSet');
    cs = getActiveConfigSet(modelname);
  else
    cs = object;
  end
  if cs.isValidParam(opt)  % rtwoption strings will be feed into cs
      set_param(cs, opt, val);
      return;
  end

  % the remaining parts should be feed into tlcotpions 
  
  if nargin < 4
    create=0;
  end
  
  if isstr(val)%#ok
      val = ['"' val '"'];
  end
  
  opts = get_param(modelname,'TLCOptions');
  
  if isempty(findstr(opts,['-a' opt '=']))
    if create~=1
      DAStudio.error('Simulink:dialog:ErrorRTWOptSetting', modelname, opt);
    else
      if isstr(val)%#ok
        newopts = [ opts ' -a' opt '=' val ];
      else
        newopts = [ opts ' -a' opt '=' num2str(val)];
      end      
    end
  else
    if isstr(val)%#ok
      newopts = regexprep(opts,...
                          ['-a' opt '="[^"]*"'],...
                          ['-a' opt '=' val]);
    else
      newopts = regexprep(opts,...
                          ['-a' opt '=\d*'],...
                          ['-a' opt '=' num2str(val)]);
    end   
  end
  
  set_param(modelname,'TLCOptions',newopts);
  
function val=getrtwoption(modelname,opt)
%GETRTWOPTION gets an RTW option for a Simulink model
%   VALUE = GETRTWOPTION(MODELNAME, OPT) returns the VALUE of the RTW 
%   option OPT for Simulink model MODELNAME.
  if ~isa(modelname, 'Simulink.ConfigSet');
    cs = getActiveConfigSet(modelname);
  else
    cs = object;
  end
  if cs.isValidParam(opt)  % rtwoption strings will be feed into cs
      val = get_param(cs, opt);
      return;
  end
  % the remaining parts should be feed into tlcotpions 

  opts = get_param(modelname,'TLCOptions');
  if isempty(opts)
      val = 'We_Can_Not_Find_The_Value';
      return
  end
  
  if isempty(findstr(opts,['-a' opt '=']))
    val = 'We_Can_Not_Find_The_Value';
    return
  end
  
  [s,~,t] = regexp(opts, ['-a' opt '=\"([^"]*)\"']);
  
  isNumeric=0;
  if isempty(s)
    % Numeric values are not double quoted
    [~,~,t] = regexp(opts, ['-a' opt '=(\d*)']);
    isNumeric=1;
  end
  
  t1 = t{1};
  
  if isempty(t1)
    val = '';
  else
    if isNumeric==0
      val = opts(t1(1):t1(2));
    else
      eval(['val = ' opts(t1(1):t1(2)) ';']);
    end
  end 

