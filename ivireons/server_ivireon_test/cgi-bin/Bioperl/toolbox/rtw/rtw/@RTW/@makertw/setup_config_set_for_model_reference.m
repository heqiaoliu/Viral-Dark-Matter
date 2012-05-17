function setup_config_set_for_model_reference(h, onlySetupSimTargetConfigSet)
% SETUP_CONFIG_SET_FOR_MODEL_REFERENCE
% This function is invoked two times:
% (1) At the start of make_rtw to setup the configSet for model reference
%     SIM target. This is required, because we use modelrefsim.tlc
%     for systemTargetFile.In addition, we would like to skip any rtw hook 
%     files. In this case, we create a temporary configset for model reference
%     SIM target, and attach it to the model.
% 
% (2) prior to invoking TLC to generate code for a model.
%   In this function we do the following things
%    0. Set up a temporary configuration set based on the config set of the
%       model. Note that, for Model reference sim target, this configset
%       is created and attached by an earlier call to this function
%       (onlySetupSimTargetConfigSet=true).
%       If we are generating code for model reference target, then this
%       temporary config set is used as the model's active config set, other
%       wise the temporary config set is used for checking the parent/child
%       config set compatibility.
%
%    1. If we are generating a model reference target (either SIM or RTW) then
%       report config set properties that are incompatible with model reference.
%       The process of checking and reporting incompatibilities also massages
%       some of the config set property values, so that the config set is
%       compatible with model reference. The latter massaging step is done if
%       we are building a standalone RTW target so that the massaged config
%       set is used in step 2 below.
%
%    2. Verify that the configuration sets of any models referenced from
%       this model are compatible with this model's configuration set.

% Copyright 2003-2010 The MathWorks, Inc.
% $Revision: 1.1.6.40 $

    mdlRefTgtType     = h.MdlRefBuildArgs.ModelReferenceTargetType;
    mdl               = h.ModelName;

    if onlySetupSimTargetConfigSet
        if ~isequal(mdlRefTgtType,'SIM')
            DAStudio.error('RTW:makertw:invalidMdlRefTgtType');
        end
        % Only setup sim target configset
        configSet = loc_create_tmp_configset(mdl, mdlRefTgtType);
        h.cleanChange('configset', configSet);
        loc_setup_config_set_for_mdl_ref_sim_target(configSet);

        % Set the TFL Control to the SIM TFL. This is needed here to set the
        % TFL up properly for the referenced models (the top model is handled
        % earlier (in update_model_reference_target), and as a by-product of
        % this logic, here as well).
        hTflControl = get_param(mdl, 'SimTargetFcnLibHandle');
        set_param(mdl, 'TargetFcnLibHandle', hTflControl);
    else

        rtwTargetType  = strtok(get_param(mdl, 'RTWSystemTargetFile'),'.');

        reportConfigSetMdlRefIncompat      = true; % assume
        reportParentChildConfigSetIncompat = true; % assume

        % If are here generating code for accelerator, then we have nothing
        % to do: no massaging of the config set of this model and no checking
        % the config set of this model with config sets of models referenced
        % in this model.
        if isequal(rtwTargetType, 'accel')
            if(~ isequal(mdlRefTgtType, 'NONE'))
                DAStudio.error('Simulink:slbuild:AccelTargetFileNotAllowedForModelRefTarget', mdl);
            end
            
            return;
        end

        if isequal(mdlRefTgtType, 'NONE')

            % We are doing RTW build for mdl in any of the various targets
            % (ERT, GRT, RSIM, etc).

            % We have nothing to do if there are no model references in mdl
            minfo = rtwprivate('rtwinfomatman','load','minfo',mdl,mdlRefTgtType);
            if isempty(minfo.modelRefs)
                return; 
            end

            % Since we are here doing an RTW build for mdl (and we have an early
            % return above for accelerator) we know that model reference target
            % type for models referenced in this model is RTW
            mdlRefTgtType = 'RTW';

            % We check the compatibility of this model's config set only
            % if we are building a model reference target for this model.
            reportConfigSetMdlRefIncompat = false;

        end

        % STEP 0: Create a temporary Config Set
        if isequal(mdlRefTgtType,'SIM')
            % When this function is called with onlySetupSimTargetConfigSet=true,
            % we attached a temporary sim target configSet.
            configSet = getActiveConfigSet(mdl);
        else
            configSet = loc_create_tmp_configset(mdl, mdlRefTgtType);
        end

        % If we are here to build the model reference target for mdl, then
        % attach configSet (that we have setup and checked to be compatible
        % with mdlRefTgtType) to mdl and set it to be the active config set.
        % Note that we cannot use the modified value in mdlRefTgtType here.
        if isequal(h.MdlRefBuildArgs.ModelReferenceTargetType,'RTW')
            h.cleanChange('configset', configSet);
        end

        % STEP 1: Setup config set for model reference sim target
        if isequal(mdlRefTgtType, 'SIM')
            % Any incompat between parent/child config set props are reported by
            % the child in its mdlStart function ... we do not handle this here.
            reportParentChildConfigSetIncompat = false;

            loc_setup_config_set_for_mdl_ref_sim_target(configSet);
        end

        if (isequal(h.MdlRefBuildArgs.ModelReferenceTargetType, 'SIM') || ...
            isequal(h.MdlRefBuildArgs.ModelReferenceTargetType, 'RTW'))
            set_param(configSet, 'RTWVerbose', h.MdlRefBuildArgs.Verbose);
        end

        % STEP 2: If we are building a model reference target, check and report
        % (and massage) config set prop values that are incompatible with model
        % reference. If we are build a standalone RTW target, then only do the
        % massaging (do not report errors) so that the massaged config set can be
        % used for parent/child comparison

        messageType = get_param(mdl, 'ModelReferenceCSMismatchMessage');
        if ~reportConfigSetMdlRefIncompat
            messageType = 'none'; 
        end

        loc_check_and_massage_configset(mdl, ...
                                        mdlRefTgtType, ...
                                        messageType, ...
                                        reportConfigSetMdlRefIncompat, ...
                                        configSet);


        % STEP 3:
        if reportParentChildConfigSetIncompat
            info = rtwprivate('rtwinfomatman','load','minfo',mdl,h.MdlRefBuildArgs.ModelReferenceTargetType);
            mdlRefs  = info.modelRefs;
            nMdlRefs = length(mdlRefs);

            for i = 1:nMdlRefs
                mdlRef = mdlRefs{i};
                bi=rtwprivate('rtwinfomatman','load','binfo',mdlRef,mdlRefTgtType);
                mdlRefConfigSet = bi.configSet;
                
                childStatesLogging = 'off';
                if (bi.areStatesLogged)
                    childStatesLogging = 'on';
                end
            
                parentStatesLogging = 'off';
                if ((strcmp(get_param(mdl, 'SaveState'),'on') || ...
                    strcmp(get_param(mdl,'SaveFinalState'),'on')) &&  ...
                    strcmp(get_param(mdl,'ModelReferenceMatFileLogging'),'on'))
                    parentStatesLogging = 'on';
                end
                % Error out if the State Logging options are inconsistent
                if ~isequal(parentStatesLogging, childStatesLogging)
                    % Combine all the error messages into one
                    tab = sprintf('    ');
                    oErrMsg.identifier = 'Simulink:slbuild:topChildMdlParamMismatch';
                    oErrMsg.message = [DAStudio.message(oErrMsg.identifier,...
                        get_param(mdl,'Name'), mdlRef), sprintf('\n')];                 
                    
                    oErrMsg.identifier = 'Simulink:slbuild:reportStateLoggingErr';
                    errmsg = DAStudio.message(oErrMsg.identifier, parentStatesLogging, childStatesLogging);
                    oErrMsg.message = [oErrMsg.message, tab, errmsg, sprintf('\n')];
                    
                    UIInfo = slprivate('slCSProp2UI',configSet, [], 'SaveState');
                    oErrMsg.message = [oErrMsg.message, tab,tab,'- ',...
                        DAStudio.message('Simulink:slbuild:saveStateMapping',...
                        UIInfo.Prompt, UIInfo.Path(2:end)), sprintf('\n')];
                    
                    UIInfo = slprivate('slCSProp2UI',configSet, [], 'SaveFinalState');
                    oErrMsg.message = [oErrMsg.message, tab,tab,'- ',...
                        DAStudio.message('Simulink:slbuild:saveFinalStateMapping',...
                        UIInfo.Prompt, UIInfo.Path(2:end)), sprintf('\n')];
                    
                    UIInfo = slprivate('slCSProp2UI',configSet, [], 'MatFileLogging');
                    if ~isempty(UIInfo) && ~isempty(UIInfo.Prompt)
                        oErrMsg.message = [oErrMsg.message, tab,tab,'- ',...
                            DAStudio.message('Simulink:slbuild:matFileLoggingMapping',...
                            UIInfo.Prompt, UIInfo.Path(2:end)), sprintf('\n')];
                    end
                    
                    error(oErrMsg);
                    
                end                
                
                [hadErr, errMsg] = slprivate('compare_configuration_sets', ...
                                             mdl, configSet, ...
                                             mdlRef, mdlRefConfigSet, ...
                                             mdlRefTgtType);
                if hadErr
                    error(errMsg);
                end
            end
        end
    end
end % setup_config_set_for_model_reference


%%------------------------------------------------------------------------
function loc_setup_config_set_for_mdl_ref_sim_target(ioConfigSet)
    % before modifying the configset, get the existing setting
    TLCDebug =  get_param(ioConfigSet, 'TLCDebug');
    RetainRTWFile = get_param(ioConfigSet,'RetainRTWFile');
    TLCAssert = get_param(ioConfigSet, 'TLCAssert');
    TLCCov = get_param(ioConfigSet, 'TLCCoverage');

    % Set IgnoreCustomStorageClasses for simulating model reference
    ignoreCSC = 'on';

    % Setup properties in the RTW->Target Component
    if isValidParam(ioConfigSet, 'CombineOutputUpdateFcns')
        % If the model RTW target has CombineOutputUpdateFcns, then use the
        % combineOutputUpdate setting as specified on the target to make sure
        % Simulation and code generation results matches.
        % For all other targets set combineOutputUpdate to off.
        combineOutputUpdate = get_param(ioConfigSet,'CombineOutputUpdateFcns');
    else
        combineOutputUpdate = 'off';
    end

    % Create a default 'Real-Time Workshop'

    rtw = Simulink.RTWCC('ert.tlc');

    rtw.SystemTargetFile = 'modelrefsim.tlc';
    rtw.TemplateMakefile = 'modelrefsim_default_tmf';
    rtw.MakeCommand      = 'make_rtw';
    rtw.RetainRTWFile = RetainRTWFile;
    rtw.TLCDebug = TLCDebug;
    rtw.TLCAssert = TLCAssert;
    rtw.TLCCoverage = TLCCov;
    
    if strcmp(get_param(ioConfigSet, 'SupportModelReferenceSimTargetCustomCode'),'on')
      rtw.RTWUseSimCustomCode = 'on';
    end
    
    % Turn on the flag that generates bus hierarchy in the Block
    % Hierarchy Map.  This is leveraged in the C-API which is used by
    % signal logging
    rtw.IncludeBusHierarchyInRTWFileBlockHierarchyMap = 'on';

    % create default ERT component
    ert = Simulink.ERTTargetCC;

    ert.CombineOutputUpdateFcns = combineOutputUpdate;
    ert.GenerateSampleERTMain   = 'off';
    ert.RTWCAPISignals          = 'on';
    ert.RTWCAPIStates           = 'on';
    ert.SupportNonInlinedSFcns  = 'on';
    ert.SupportContinuousTime   = 'on';

    % For model reference sim target, we do not need to use
    % ert template files
    ert.ERTSrcFileBannerTemplate = '';
    ert.ERTHdrFileBannerTemplate = '';
    ert.ERTDataSrcFileTemplate   = '';
    ert.ERTDataHdrFileTemplate   = '';
    ert.ERTCustomFileTemplate    = '';

    rtw.attachComponent(ert);

    % get the default code appearance component from default RTWCC component
    cap = rtw.getComponent('Code Appearance');

    % To generate faster code and unreadable code
    cap.GenerateComments        = 'off';
    cap.IgnoreCustomStorageClasses = ignoreCSC;
    cap.MaxIdLength = 128;

    % Now attach rtw component
    ioConfigSet.attachComponent(rtw);

    % modify hardware device
    hw = ioConfigSet.getComponent('Hardware Implementation');
    slprivate('setHardwareDevice',hw, 'Target', 'MATLAB Host');

    % Update some of the optimization options
    opt = ioConfigSet.getComponent('Optimization');
    set_param(opt,'ZeroInternalMemoryAtStartup', 'on');
    set_param(opt,'ZeroExternalMemoryAtStartup', 'on');
    set_param(opt,'InitFltsAndDblsToZero', 'on');
    set_param(opt,'NoFixptDivByZeroProtection', 'off');
    set_param(opt,'EfficientFloat2IntCast', 'off');
    set_param(opt,'EfficientMapNaN2IntZero', 'off');
end % loc_setup_config_set_for_mdl_ref_sim_target



%%------------------------------------------------------------------------
function loc_check_and_massage_configset(iMdl, ...
                                         iMdlRefTgtType, ...
                                         iMessageType, ...
                                         iReportIncompat, ...
                                         configSet)

 
    % Note: it would be nice to do this in c in the checkMdlRefCompliance
    % function, but since the value of these properties depends on the original 
    % values of other properties (which may be modified) we cannot do that 
    % (we'd need to be sure of the order that the checks happened in and that 
    % just seems error prone)
    %
    % Before we do the compliance checking, look up some values to decide
    % how to set some properties "behind the scenes"
    % if logging states & MATFileLogging, then turn on RTWCAPIStates
    %
    origConfigSet = getActiveConfigSet(iMdl);
    dataComponent = origConfigSet.getComponent('Data Import/Export');
    RTWComponent = origConfigSet.getComponent('Real-Time Workshop');
    targetComponent = RTWComponent.getComponent('Target');
    turnOnRTWCAPIStates = false;
    
    if ( (strcmp(dataComponent.SaveState,'on') || ...
            strcmp(dataComponent.SaveFinalState,'on')) &&  ...
            strcmp(targetComponent.MatFileLogging,'on') )
        turnOnRTWCAPIStates = true;
    end

    % We need to turn the parameter MatFileLogging to off for model
    % reference targets, because we cannot generate RTW otherwise.  But, we
    % need to know what the original value of the parameter is to be able
    % to generate correct code for ToFile blocks.  Cache the original value
    % into the hidden parameter ModelReferenceMatFileLogging so it will be 
    % be available later.
    set_param(iMdl, 'ModelReferenceMatFileLogging', targetComponent.MatFileLogging);
    
    % checkMdlRefCompliance will throw an exception if an error occurs
    configSet.checkMdlRefCompliance(iMdlRefTgtType, ...
                                    iMessageType, ...
                                    iReportIncompat, ...
                                    get_param(iMdl, 'Name'));

    % If the target supports RTWCAPIStates set the RTWCAPIStates appropriately
    % If it doesn't and the user is asking us to log states, warn them that 
    % we cannot
    newRTW = configSet.getComponent('Real-Time Workshop');
    newTarget = newRTW.getComponent('Target');
    if newTarget.hasProp('RTWCAPIStates')
        if turnOnRTWCAPIStates
            newTarget.setProp('RTWCAPIStates','on');
        end
    else
        if turnOnRTWCAPIStates
            DAStudio.warning('RTW:buildProcess:stateLoggingNotSupported');
        end
    end
end % loc_check_and_massage_configset



%%------------------------------------------------------------------------
function oConfigSet = loc_create_tmp_configset(iMdl, mdlRefTgtType)
% cache away the name of the current active config set
    oldConfigSet = getActiveConfigSet(iMdl);

    % Now create a new config set by cloning the current
    % configuration set and giving it a unique name.
    oConfigSet = oldConfigSet.copy;
    if isequal(mdlRefTgtType,'SIM')
        oConfigSet.reenableAllProps;
    end
    
    base_name = ['ModelReference_' oConfigSet.Name];
    oConfigSet.Name = base_name;
    % Make new config set name unique by appending a digit if needed.
    idx = 1;
    csName = getConfigSet(iMdl, oConfigSet.Name);
    while ~isempty(csName)
        oConfigSet.Name = [base_name num2str(idx)];
        csName = getConfigSet(iMdl, oConfigSet.Name);
        idx = idx + 1;
    end
end % loc_create_tmp_configset

