function status = construct_context_for_machine(auxiliaryInfo)

%   Copyright 1995-2010 The MathWorks, Inc.

global gMachineInfo gTargetInfo

status = 0;

if(nargin<1)
    if gTargetInfo.codingHDL
        % HDL uses this to get at the CG_Ctx of the scope thet has already
        % been populated onto the chart.  Otherwise, SF makes a new CG_Ctx,
        % and there would be two of them running around.
        auxiliaryInfo = gMachineInfo.charts;
    else
        auxiliaryInfo = [];
    end
end

if gTargetInfo.codingRTW
    timeVarName = '%<LibSFGetCurrentTaskTime(block)>';
else
    timeVarName = '_sfTime_';
end

% PLC Coder specific info
relevantMachineName = sf('get', get_relevant_machine, '.name');
codingPLC = ~isempty(auxiliaryInfo) && gTargetInfo.codingRTW && (get_param(relevantMachineName, 'RTWExternMdlXlate') == 2);
codingPLCTargetIDE = '';
try
    if exist('plcprivate', 'file')
        plcOptions = plcprivate('plc_options', relevantMachineName);
        codingPLCTargetIDE = plcOptions.TargetIDE;
    end
catch ME
end

ctxInfo.machine = gMachineInfo.machineId;
ctxInfo.relevantMachine = get_relevant_machine;
ctxInfo.eventVariableName = gMachineInfo.eventVariableName;
ctxInfo.eventVariableType = gMachineInfo.eventVariableType;
ctxInfo.eventVariableUsed = false;
ctxInfo.timeVariableName       = timeVarName;
ctxInfo.minimumComplexity = coder_options('inlineThreshold');
ctxInfo.maximumComplexity = coder_options('inlineThresholdMax');
ctxInfo.inlineStackLimit = coder_options('inlineStackLimit');
ctxInfo.maintainOneToOne = coder_options('maintainOneToOne');
ctxInfo.maxStackUsage = coder_options('maxStackUsage');
ctxInfo.codingNoEcho = gTargetInfo.codingNoEcho;
ctxInfo.codingBLAS = gTargetInfo.codingBLAS;
ctxInfo.codingOpenMP = gTargetInfo.codingOpenMP;
ctxInfo.codingIntelIPP = gTargetInfo.codingIntelIPP;
ctxInfo.codingComments = gTargetInfo.codingComments;
ctxInfo.codingAutoComments = gTargetInfo.codingAutoComments;
ctxInfo.codingEmitObjectDescriptions = gTargetInfo.codingEmitObjectDescriptions;
ctxInfo.codingEmitObjectRequirements = gTargetInfo.codingEmitObjectRequirements;
ctxInfo.codingSFunction = gTargetInfo.codingSFunction;
ctxInfo.codingRTW = gTargetInfo.codingRTW;
ctxInfo.codingHDL = gTargetInfo.codingHDL;
ctxInfo.codingPLC = codingPLC;
ctxInfo.codingPLCTargetIDE = codingPLCTargetIDE;
ctxInfo.leavingIntegrityChecks = gTargetInfo.leavingIntegrityChecks;
ctxInfo.leavingExtrinsicCalls = gTargetInfo.leavingExtrinsicCalls;
ctxInfo.leavingCtrlCChecks = gTargetInfo.leavingCtrlCChecks;
ctxInfo.modelReferenceSimTarget = gTargetInfo.modelReferenceSimTarget;
ctxInfo.modelReferenceRTWTarget = gTargetInfo.modelReferenceRTWTarget;
ctxInfo.rtwMultiInstancedERT = gTargetInfo.isErtMultiInstanced;
ctxInfo.codingDebugForMachine = gTargetInfo.codingDebug;
ctxInfo.codingForAutoVerifier = gTargetInfo.codingForAutoVerifier;
ctxInfo.codingOverflow = gTargetInfo.codingOverflow;
ctxInfo.codingTelemetry = 0;
ctxInfo.codingStateBitsets = gTargetInfo.codingStateBitsets;
ctxInfo.codingDataBitsets = gTargetInfo.codingDataBitsets;
ctxInfo.codingWatcomCompiler = gTargetInfo.codingWatcomMakefile;
ctxInfo.ignoreUnsafeTransitionActions = sfpref('ignoreUnsafeTransitionActions');
ctxInfo.dataflowAnalysisThreshold = coder_options('dataflowAnalysisThreshold');
ctxInfo.machineNumberVarName = gMachineInfo.machineNumberVariableName;
ctxInfo.codingLogicalOps = gTargetInfo.codingLogicalOps;
ctxInfo.codingElseIfDetection = gTargetInfo.codingElseIfDetection;
ctxInfo.codingConstantFolding = gTargetInfo.codingConstantFolding;
ctxInfo.codingRedundantElim = gTargetInfo.codingRedundantElim;
ctxInfo.codingGlobalIO = gTargetInfo.codingGlobalIO;
ctxInfo.codingPackedIO = gTargetInfo.codingPackedIO;
ctxInfo.codingPreserveConstantNames = gTargetInfo.codingPreserveConstantNames;
ctxInfo.codingIntegerCodeOnly = gTargetInfo.codingIntegerCodeOnly;
ctxInfo.codingRealCodeOnly = gTargetInfo.codingRealCodeOnly;
ctxInfo.maximumIdentifierLength = gTargetInfo.maximumIdentifierLength;
ctxInfo.enableShiftOperators = gTargetInfo.enableShiftOperators;
ctxInfo.parenthesesLevel = gTargetInfo.parenthesesLevel;
ctxInfo.codingExtMode = gTargetInfo.codingExtMode;
ctxInfo.xpcExtModeAnimation = gTargetInfo.xpcExtModeAnimation;
ctxInfo.ignoreTestpoints = gTargetInfo.ignoreTestpoints;
ctxInfo.codingBlockComments = gTargetInfo.codingBlockComments;
ctxInfo.codingMATLABSourceComments = gTargetInfo.codingMATLABSourceComments;
ctxInfo.codingMATLABFcnDesc = gTargetInfo.codingMATLABFcnDesc;
ctxInfo.codingMemcpy = gTargetInfo.codingMemcpy;
ctxInfo.codingMemsetDouble = gTargetInfo.codingMemsetDouble;
ctxInfo.codingMemcpyThreshold = gTargetInfo.codingMemcpyThreshold;
ctxInfo.codingConvertIfToSwitch = gTargetInfo.codingConvertIfToSwitch;
ctxInfo.codingUseSpecifiedMinMax = gTargetInfo.codingUseSpecifiedMinMax;

[algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo,rtwSettingsInfo] = get_word_sizes_local;

ctxInfo.algorithmWordsizes = algorithmWordsizes;
ctxInfo.targetWordsizes = targetWordsizes;

ctxInfo.algorithmHwDeviceType                 = algorithmHwInfo.hwDeviceType;
ctxInfo.algorithmDivByZeroProtectionNotWanted = algorithmHwInfo.divByZeroProtectionNotWanted;
ctxInfo.algorithmSignedDivRounding            = algorithmHwInfo.signedDivRounding;
ctxInfo.algorithmSignedShiftIsArithmetic      = algorithmHwInfo.signedShiftIsArithmetic;

ctxInfo.targetHwDeviceType                    = targetHwInfo.hwDeviceType;
ctxInfo.targetDivByZeroProtectionNotWanted    = targetHwInfo.divByZeroProtectionNotWanted;
ctxInfo.targetSignedDivRounding               = targetHwInfo.signedDivRounding;
ctxInfo.targetSignedShiftIsArithmetic         = targetHwInfo.signedShiftIsArithmetic;

ctxInfo.castFloat2IntPortableWrapping = rtwSettingsInfo.castFloat2IntPortableWrapping;
ctxInfo.mapNaN2IntZero                = rtwSettingsInfo.mapNaN2IntZero;
ctxInfo.genFunctionFixptDiv           = rtwSettingsInfo.genFunctionFixptDiv;
ctxInfo.genFunctionFixptMul           = rtwSettingsInfo.genFunctionFixptMul;
ctxInfo.genFunctionFixptMisc          = rtwSettingsInfo.genFunctionFixptMisc;
ctxInfo.supportNonFinites             = rtwSettingsInfo.supportNonFinites;
ctxInfo.correctNetSlopeViaDiv         = rtwSettingsInfo.correctNetSlopeViaDiv;

ctxInfo.codingSupportVariableSizeSignals = gTargetInfo.codingSupportVariableSizeSignals;
 
ctxInfo.exportedFcnInfo = gMachineInfo.exportedFcnInfo;
ctxInfo.auxiliaryInfo = auxiliaryInfo;

if(gTargetInfo.codingRTW)
    ctxInfo.usedTargetFunctionLibH = get_param(gMachineInfo.mainMachineName, 'TargetFcnLibHandle');
elseif gTargetInfo.codingSFunction
    ctxInfo.usedTargetFunctionLibH = get_param(gMachineInfo.mainMachineName, 'SimTargetFcnLibHandle');
else
    ctxInfo.usedTargetFunctionLibH = 0;
end

gMachineInfo.ctxInfo = ctxInfo;

try
    sf('Cg','construct_context',ctxInfo);
catch ME
    sf('Private','coder_error_count_man','add',1);
    status = 1;
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo,rtwSettingsInfo] = get_word_sizes_local

global gMachineInfo

relevantMachineName = sf('get',get_relevant_machine,'machine.name');

[algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo,rtwSettingsInfo] = get_word_sizes(relevantMachineName,gMachineInfo.targetName);

