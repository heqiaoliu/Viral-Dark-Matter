function targetProps = rtw_target_props(relevantMachineName)

%   Copyright 1995-2010 The MathWorks, Inc.

    targetProps.codingStateBitsets = 0;
    targetProps.codingDataBitsets = 0;
    targetProps.codingEmitObjectDescriptions = 0;
    targetProps.codingComments = 0;
    targetProps.codingAutoComments = 0;
    targetProps.codingRedundantElim = 0;
    targetProps.codingEmitObjectRequirements = 0;
    targetProps.algorithmWordsizes =[];
    targetProps.targetWordsizes=[];
    targetProps.algorithmHwInfo=[];
    targetProps.targetHwInfo=[];
    targetProps.codingIntegerCodeOnly = 0;
    targetProps.codingRealCodeOnly = 0;
    targetProps.codingExtMode = 0;
    targetProps.xpcExtModeAnimation = 0;
    targetProps.codingBlockComments = 0;
    targetProps.codingMATLABSourceComments = 0;
    targetProps.codingMATLABFcnDesc = 0;
    targetProps.ignoreTestpoints = 0;

    targetProps.customSymbolStr = '';
    targetProps.customSymbolStrFcn = '';
    targetProps.customSymbolStrBlkIO = '';
    targetProps.customSymbolStrType = '';
    targetProps.customSymbolStrTmpVar = '';
    targetProps.mangleLength = 1;
    targetProps.maximumIdentifierLength = 32;
    targetProps.enableShiftOperators = true;
    targetProps.parenthesesLevel = 1;
    targetProps.systemTargetFile = '';
    targetProps.codingConvertIfToSwitch = 0;
    targetProps.codingUseSpecifiedMinMax = false;

    if ~strcmp(lower(get_param(relevantMachineName,'BlockDiagramType')),'library')
        cs = getActiveConfigSet(relevantMachineName);

        targetProps.codingStateBitsets = get_bool_prop(cs,'StateBitsets');
        targetProps.codingDataBitsets = get_bool_prop(cs,'DataBitsets');
        targetProps.codingEmitObjectDescriptions = get_bool_prop(cs,'SFDataObjDesc');
        targetProps.codingComments = get_bool_prop(cs,'GenerateComments');
        targetProps.codingAutoComments = targetProps.codingComments &&...
            get_bool_prop(cs,'IncAutoGenComments');
        targetProps.codingRedundantElim = get_bool_prop(cs,'UseTempVars');
        [targetProps.algorithmWordsizes,...
        targetProps.targetWordsizes,...
        targetProps.algorithmHwInfo,...
        targetProps.targetHwInfo, ...
        targetProps.rtwSettingsInfo] = ...
            get_word_sizes(relevantMachineName,'rtw');
        
        targetProps.sharedUtilsEnabled = rtw_gen_shared_utils(relevantMachineName);
        targetProps.usedTargetFunctionLib = get_param(cs,'TargetFunctionLibrary');
        targetProps.codingMemcpy = get_bool_prop(cs,'EnableMemcpy');
        targetProps.codingMemcpyThreshold = get_param(cs,'MemcpyThreshold');
        targetProps.codingMemsetDouble = get_bool_prop(cs,'InitFltsAndDblsToZero');
        
        targetProps.codingEmitObjectRequirements = get_bool_prop(cs,'ReqsInCode');
        targetProps.codingIntegerCodeOnly = get_bool_prop(cs,'PurelyIntegerCode');
        targetProps.codingRealCodeOnly = ~get_bool_prop(cs,'SupportComplex');
        [targetProps.codingExtMode, targetProps.xpcExtModeAnimation] = get_machine_extmode_setting(relevantMachineName);
        targetProps.codingBlockComments = get_bool_prop(cs, 'SimulinkBlockComments');
        targetProps.codingMATLABSourceComments = get_bool_prop(cs, 'MATLABSourceComments');
        targetProps.codingMATLABFcnDesc = get_bool_prop(cs, 'MATLABFcnDesc');
        targetProps.enableShiftOperators = get_bool_prop(cs,'EnableShiftOperators');
        targetProps.systemTargetFile = get_param(cs,'SystemTargetFile');

        % tag 'ConvertIfToSwitch' must match checkbox in UI
        % also make sure we're using the ERT target, otherwise the
        % if2switch param may not exist.
        if strcmp(get_param(cs, 'IsERTTarget'), 'on')
            targetProps.codingConvertIfToSwitch = get_bool_prop(cs, 'ConvertIfToSwitch');
            targetProps.codingSupportVariableSizeSignals = get_bool_prop(cs, 'SupportVariableSizeSignals');
            targetProps.codingUseSpecifiedMinMax = get_bool_prop(cs, 'UseSpecifiedMinMax');
        else
            targetProps.codingConvertIfToSwitch = 0;
            targetProps.codingSupportVariableSizeSignals = true;
        end

        targetProps.ignoreTestpoints = get_bool_prop(cs, 'IgnoreTestpoints');

        parenLvl = get_param(cs, 'ParenthesesLevel');

        if strcmpi(parenLvl, 'Minimum')
            targetProps.parenthesesLevel = 0;
        elseif strcmpi(parenLvl, 'Nominal')
            targetProps.parenthesesLevel = 1;
        elseif strcmpi(parenLvl, 'Maximum')
            targetProps.parenthesesLevel = 2;
        end
        
        % Customized symbols, only the length is used the rest is only for
        % checksum purposes
        targetProps.customSymbolStrGlobalVar= get_param(cs,'CustomSymbolStrGlobalVar');
        targetProps.customSymbolStrMacro    = get_param(cs,'CustomSymbolStrMacro');
        targetProps.customSymbolStrFcn      = get_param(cs,'CustomSymbolStrFcn');
        targetProps.customSymbolStrBlkIO    = get_param(cs,'CustomSymbolStrBlkIO');
        targetProps.customSymbolStrType     = get_param(cs,'CustomSymbolStrType');
        targetProps.customSymbolStrTmpVar    = get_param(cs,'CustomSymbolStrTmpVar');
        targetProps.mangleLength            = get_param(cs,'MangleLength');

        % Identifier length is currently used by the SF/EML naming pass
        targetProps.maximumIdentifierLength = get_param(cs,'MaxIdLength');
    end

function boolVal = get_bool_prop(cs,propName)
    boolVal = strcmp(get_param(cs,propName),'on');

    
