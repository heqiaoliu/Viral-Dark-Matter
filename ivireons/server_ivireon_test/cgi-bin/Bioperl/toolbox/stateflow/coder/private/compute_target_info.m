function compute_target_info

%   Copyright 1995-2010 The MathWorks, Inc.

global gTargetInfo gMachineInfo

gTargetInfo.codingLibrary = sf('get',sf('get',gTargetInfo.target,'target.machine'),'machine.isLibrary');

targetName = sf('get',gMachineInfo.parentTarget,'target.name');
gTargetInfo.codingMakeDebug = coder_options('debugBuilds');
gTargetInfo.codingSFunction = strcmp(targetName,'sfun');
gTargetInfo.codingRTW = strcmp(targetName,'rtw');
gTargetInfo.codingHDL = strcmp(targetName,'slhdlc');
gTargetInfo.codingPLC = strcmp(targetName,'plc');
gTargetInfo.codingMEX = 0;
gTargetInfo.codingOpenMP = sf('Feature','EML Parallelize'); 
gTargetInfo.codingCustom = ~gTargetInfo.codingSFunction && ...
                           ~gTargetInfo.codingRTW && ...
                           ~gTargetInfo.codingHDL && ...
                           ~gTargetInfo.codingPLC && ...
                           ~gTargetInfo.codingMEX;

gTargetInfo.codingExportChartNames = 0;
gTargetInfo.codingPreserveNames = 0;
gTargetInfo.codingPreserveNamesWithParent=0;

relevantMachineName = sf('get',get_relevant_machine,'machine.name');

gTargetInfo.mdlrefInfo = get_model_reference_info(relevantMachineName);
gTargetInfo.isErtMultiInstanced = is_ert_multi_instance(relevantMachineName) || gTargetInfo.mdlrefInfo.isMultiInst;
gTargetInfo.ertMultiInstanceErrCode = get_ert_multi_instance_errcode(relevantMachineName);


try
    gTargetInfo.gencpp = rtwprivate('rtw_is_cpp_build', relevantMachineName);
catch ME
    gTargetInfo.gencpp = 0;
end

allFlags = all_flags(gMachineInfo.parentTarget);
gTargetInfo.codingDebug = flag_value(allFlags,'debug');
gTargetInfo.codingOverflow = flag_value(allFlags,'overflow');
gTargetInfo.codingNoEcho = ~flag_value(allFlags,'echo');
gTargetInfo.codingBLAS = flag_value(allFlags,'blas');
gTargetInfo.codingIntelIPP = false;
gTargetInfo.codingPreserveConstantNames = 0;

gTargetInfo.codingMultiInstance     = flag_value(allFlags,'multiinstanced');
gTargetInfo.codingNoInitializer = ~flag_value(allFlags,'initializer');

gTargetInfo.codingStateBitsets = flag_value(allFlags,'statebitsets');
gTargetInfo.codingDataBitsets = flag_value(allFlags,'databitsets');
gTargetInfo.codingComments = flag_value(allFlags,'comments');
gTargetInfo.codingAutoComments = flag_value(allFlags,'autocomments');
gTargetInfo.codingEmitObjectDescriptions = flag_value(allFlags,'emitdescriptions');
gTargetInfo.codingLogicalOps = flag_value(allFlags,'emitlogicalops');
gTargetInfo.codingElseIfDetection = flag_value(allFlags,'elseifdetection');
gTargetInfo.codingConstantFolding = flag_value(allFlags,'constantfolding');
gTargetInfo.codingRedundantElim = flag_value(allFlags,'redundantloadelimination');
gTargetInfo.codingEmitObjectRequirements = 0;
gTargetInfo.codingIntegerCodeOnly = 0;
gTargetInfo.codingRealCodeOnly = 0;
gTargetInfo.codingExtMode = 0;
gTargetInfo.xpcExtModeAnimation = 0;
gTargetInfo.maximumIdentifierLength = 64;
gTargetInfo.enableShiftOperators = true;
gTargetInfo.parenthesesLevel = 1;
gTargetInfo.codingBlockComments = 0;
gTargetInfo.codingMATLABSourceComments = 0;
gTargetInfo.codingMATLABFcnDesc = 0;
gTargetInfo.ignoreTestpoints = 0;

gTargetInfo.leavingIntegrityChecks = flag_value(allFlags,'integrity');
gTargetInfo.leavingExtrinsicCalls = flag_value(allFlags,'extrinsic');
gTargetInfo.leavingCtrlCChecks = flag_value(allFlags,'ctrlc');

gTargetInfo.codingSupportVariableSizeSignals = true;

ioformat = flag_value(allFlags,'ioformat');
switch(ioformat)
    case 0
        gTargetInfo.codingGlobalIO = 1;
        gTargetInfo.codingPackedIO = 0;
    case 1
        gTargetInfo.codingGlobalIO = 0;
        gTargetInfo.codingPackedIO = 1;
    case 2
        gTargetInfo.codingGlobalIO = 0;
        gTargetInfo.codingPackedIO = 0;
    otherwise
        gTargetInfo.codingGlobalIO = 1;
        gTargetInfo.codingPackedIO = 0;
end

gTargetInfo.modelReferenceSimTarget = 0;
gTargetInfo.modelReferenceRTWTarget = 0;

gTargetInfo.codingMemcpy = 0;
gTargetInfo.codingMemcpyThreshold = 0;
gTargetInfo.codingMemsetDouble = 0;
gTargetInfo.codingGenerateSFunction = 0;
gTargetInfo.codingConvertIfToSwitch = 0;
gTargetInfo.codingUseSpecifiedMinMax = false;

if gTargetInfo.codingRTW
    targetProps = rtw_target_props(relevantMachineName);
    gTargetInfo.codingDebug = 0;
    gTargetInfo.codingOverflow = 0;
    gTargetInfo.codingNoEcho = 1;
    gTargetInfo.codingBLAS = 0;
    gTargetInfo.codingOpenMP = 0;
    gTargetInfo.codingPreserveConstantNames = true;

    gTargetInfo.codingMultiInstance = 0;
    gTargetInfo.codingNoInitializer = 0;

    gTargetInfo.codingStateBitsets = targetProps.codingStateBitsets;
    gTargetInfo.codingDataBitsets = targetProps.codingDataBitsets;
    gTargetInfo.codingComments = targetProps.codingComments;
    gTargetInfo.codingAutoComments = targetProps.codingAutoComments;

    gTargetInfo.codingEmitObjectDescriptions = targetProps.codingEmitObjectDescriptions;
    gTargetInfo.codingRedundantElim = targetProps.codingRedundantElim;
    gTargetInfo.codingLogicalOps = 1;
    gTargetInfo.codingElseIfDetection = 1;
    gTargetInfo.codingConstantFolding = 1;
    
    gTargetInfo.codingEmitObjectRequirements = targetProps.codingEmitObjectRequirements;
    gTargetInfo.codingExtMode = targetProps.codingExtMode;
    gTargetInfo.xpcExtModeAnimation = targetProps.xpcExtModeAnimation;
    gTargetInfo.codingConvertIfToSwitch = targetProps.codingConvertIfToSwitch;

    % Bitsets have to be disabled for extmode, which requires all dwork data to be addressable
    if gTargetInfo.codingExtMode && (gTargetInfo.codingStateBitsets || gTargetInfo.codingDataBitsets)
        gTargetInfo.codingStateBitsets = 0;
        gTargetInfo.codingDataBitsets = 0;
        warning('Stateflow:CoderError',['Model has "External mode" configured, which requires all block state data to be addressable. ' ...
                 'The parameters "Use bitsets for storing state configuration" and "Use bitsets for storing boolean data" are turned on ' ...
                 'in the "Optimization|Code generation|Stateflow" pane of the Configuration Parameters dialog box. ' ...
                 'However, these settings have been ignored because these two parameters do not work with external mode.']);
    end
    
    gTargetInfo.rtwProps = targetProps;
    gTargetInfo.modelReferenceSimTarget = model_reference_sim_target(relevantMachineName);
    gTargetInfo.modelReferenceRTWTarget = model_reference_rtw_target(relevantMachineName);
    gTargetInfo.codingIntegerCodeOnly = targetProps.codingIntegerCodeOnly;
    gTargetInfo.codingRealCodeOnly = targetProps.codingRealCodeOnly;
    gTargetInfo.maximumIdentifierLength = targetProps.maximumIdentifierLength;
    gTargetInfo.enableShiftOperators = targetProps.enableShiftOperators;
    gTargetInfo.parenthesesLevel = targetProps.parenthesesLevel;
    gTargetInfo.codingBlockComments = targetProps.codingBlockComments;
    gTargetInfo.codingMATLABSourceComments = targetProps.codingMATLABSourceComments;
    gTargetInfo.codingMATLABFcnDesc = targetProps.codingMATLABFcnDesc;
    gTargetInfo.codingMemcpy = targetProps.codingMemcpy;
    gTargetInfo.codingMemcpyThreshold = targetProps.codingMemcpyThreshold;
    gTargetInfo.codingMemsetDouble = targetProps.codingMemsetDouble;
    gTargetInfo.ignoreTestpoints = targetProps.ignoreTestpoints && ...
                                   ~gTargetInfo.modelReferenceSimTarget && ...
                                   ~gTargetInfo.codingExtMode && ...
                                   strcmpi(get_param(relevantMachineName, 'RapidAcceleratorSimStatus'), 'inactive');

    gTargetInfo.codingUseSpecifiedMinMax = targetProps.codingUseSpecifiedMinMax;
    modelH = get_param(relevantMachineName, 'Handle');
    hMakeRTWSettingsObject = get_param(modelH, 'MakeRTWSettingsObject');
    if ~isempty(hMakeRTWSettingsObject) && ~isempty(hMakeRTWSettingsObject.BuildOpts)
        if(strcmp(hMakeRTWSettingsObject.BuildOpts.codeFormat,'S-Function'))
            gTargetInfo.codingGenerateSFunction = 1;
        end
    end
    
    if ~gTargetInfo.modelReferenceSimTarget
        gTargetInfo.codingSupportVariableSizeSignals = targetProps.codingSupportVariableSizeSignals;
    end

elseif gTargetInfo.codingSFunction
    gTargetInfo.codingNoInitializer = 0;
    gTargetInfo.codingNoComments = 1;
    gTargetInfo.codingEmitObjectDescriptions = 0;
    gTargetInfo.codingRedundantElim = 1;
    gTargetInfo.codingLogicalOps = 1;
    gTargetInfo.codingElseIfDetection = 1;
    gTargetInfo.codingConstantFolding = 1;
    [gTargetInfo.codingExtMode, gTargetInfo.xpcExtModeAnimation] = get_machine_extmode_setting(relevantMachineName);

elseif gTargetInfo.codingHDL
    gTargetInfo.codingDebug = 0;
    gTargetInfo.codingNoInitializer = 0;
    gTargetInfo.hdl = get_hdl_target_info(allFlags, targetName);
elseif gTargetInfo.codingPLC
    gTargetInfo.codingDebug = 0;
    gTargetInfo.codingNoInitializer = 0;
    gTargetInfo.plc = get_plc_target_info(allFlags, targetName);
else
    gTargetInfo.codingDebug = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Option to indicate this is an AutoVerifier code generation
% (replaces old gTargetInfo.codingForTestGen)
if( ~strcmp(targetName,'sfun') && get_param(relevantMachineName,'RTWExternMdlXlate') == 1)
    gTargetInfo.codingForAutoVerifier = 1;
else
    gTargetInfo.codingForAutoVerifier = 0;
end


if(gTargetInfo.codingPreserveNamesWithParent)
    gTargetInfo.codingPreserveNames = 1;
end


if(gTargetInfo.codingLibrary && (gTargetInfo.codingSFunction || gTargetInfo.codingRTW))
    gTargetInfo.codingMultiInstance  = 1;
end

gTargetInfo.codingTMW = 0;

compute_compiler_info;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = all_flags(target)
result = sf('Private','target_methods','codeflags',target);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = flag_value(flags,str)
flagNames = {flags.name};
index = find(strcmp(flagNames,str));
if(~isempty(index))
    result = flags(index).value;
else
    result = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hdlLang = get_hdl_lang(allFlags)

if flag_value(allFlags, 'language')
    hdlLang = 'verilog';
else
    hdlLang = 'vhdl';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = hdlgetparameter_wrapper(paramName)
% Get Simulink hdl coder parameters

try
    val = hdlgetparameter(paramName);
catch ME
    val = [];
end

if isempty(val)
    construct_coder_error([], sprintf('Failed to get hdl parameter "%s".', paramName), 1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hdlFileExt = get_hdl_file_ext(hdlLang)
    
switch hdlLang
    case 'vhdl'
        hdlFileExt = hdlgetparameter_wrapper('vhdl_file_ext');
    otherwise
        hdlFileExt = hdlgetparameter_wrapper('verilog_file_ext');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plcFileExt = get_plc_file_ext()
    plcFileExt = '.pro';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hdlTargetInfo = get_hdl_target_info(allFlags, targetName)

hdlTargetInfo.language = lower(hdlgetparameter_wrapper('target_language'));

hdlTargetInfo.clockName = hdlgetparameter_wrapper('clockname');
hdlTargetInfo.clockEnableName = hdlgetparameter_wrapper('clockenablename');
hdlTargetInfo.resetName = hdlgetparameter_wrapper('resetname');
hdlTargetInfo.async_reset = hdlgetparameter_wrapper('async_reset');
hdlTargetInfo.reset_asserted_level = hdlgetparameter_wrapper('reset_asserted_level');
    
hdlTargetInfo.clock_rising_edge = '1';
hdlTargetInfo.inline_configurations = '1';
hdlTargetInfo.verilogTimescale = '1';
    
hdlTargetInfo.packageName = hdlgetparameter_wrapper('vhdl_package_name');
if strcmp(hdlTargetInfo.language, 'verilog') == 1
    hdlTargetInfo.verilogTimescale = hdlgetparameter_wrapper('use_verilog_timescale');
else
    hdlTargetInfo.clock_rising_edge = hdlgetparameter_wrapper('clock_rising_edge');
    hdlTargetInfo.inline_configurations= hdlgetparameter_wrapper('inline_configurations');
end

hdlTargetInfo.optimizeForHDL = 1;
hdlTargetInfo.codegenDir = hdlgetparameter_wrapper('codegendir');

hdlTargetInfo.genDebugInfo = hdlgetparameter_wrapper('debug');

hdlTargetInfo.fileExt = get_hdl_file_ext(hdlTargetInfo.language);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plcTargetInfo = get_plc_target_info(~, targetName)

if strcmp(targetName,'plc')
    plcTargetInfo.codingPLC = 1;

end

plcTargetInfo.fileExt = get_plc_file_ext;

