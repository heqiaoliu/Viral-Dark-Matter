
%   Copyright 2008-2010 The MathWorks, Inc.

classdef (Sealed=true) HarnessUtils     
   
    methods(Access = 'private')       
        function obj = HarnessUtils
        end                        
    end
    
    methods(Static, Access = 'private')
        [errStr, model, sldvData] = check_make_harness_args(model, sldvData)
        [errStr, sldvData, sldvDataFilePath, isLoggedSldvData] = check_harness_data(modelH, sldvData, harnessopts)
        [time, data] = harness_data(testCase, inportUsage)
        [harnessH,sigbH,testSubsysH] = create_model_harness(objH,harnessFilePath,time,data,...
                                                groups,sldvData,opts,fundts,...
                                                reconsParams,posShift,...
                                                fromMdlFlag,mode)
        build_bus_hierarchy(subsysH, nameTree, isRootInportNonVirtual)        
        harnessFilePath = genHarnessModelFilePath(modelH,opts,mode)
        systemTestFilePath = genSystemTestHarnessFilePath(modelH,opts,mode)
        status = has_unlicensed_stateflow(modelH)
        status = has_root_level_input_ports(modelH)
        [reconsParams, posShift, warnmsg] = getReconstructionParams(model, sldvData, maxConstHandle)        
        [sldvData, inportUsage, anyUnused] = updateInportUsage(sldvData)        
    end
    
    methods (Static)
        status = isMdlRefHarnessEnabled(testcomp)
        [harnessFilePath, warnmsg] = make_model_harness(model, sldvData, harnessOpts, utilityName, maxConstHandle)
        [testFileName, warnmsg] = make_systemtest_harness(model, sldvDataFilePath, systemTestFilePath)
        [sigbH, errStr] = sigbuild_handle(modelH)
        status = isSldvGenHarness(modelH)        
        pairs = getModelParamValuePairs(modelH)
        modelName = getGeneratedModel(modelH)
        status = merge(destModelH, modelHs, initCmds, isNew, caller)
    end    
    
    methods (Static, Access = 'public')
        function harnessOpts = getHarnessOpts
            harnessOpts.harnessFilePath = '';
            harnessOpts.modelRefHarness = true;
            harnessOpts.usedSignalsOnly = false;
            harnessOpts.systemTestHarness = false;
        end
        
        function msg = iscorrectHarnessOpts(harnessOpts)
            msg = '';
            defaultHarnessOpts = Sldv.HarnessUtils.getHarnessOpts;
            acceptableFields = fieldnames(defaultHarnessOpts);
            currentfields = fieldnames(harnessOpts);
            if ~isempty(setdiff(currentfields,acceptableFields))                
                strtmp = '';
                for idx=1:length(acceptableFields)-1
                    strtmp = [strtmp '%s, ']; %#ok<AGROW>
                end
                strtmp = [strtmp 'and %s.'];
                paramNames = sprintf(strtmp,acceptableFields{:});
                msg = xlate([...
                    'The harnessOpts parameter must specify a structure ',...
                    'with fields: %s']);     
                msg = sprintf(msg,paramNames);                            
            end
            if(isempty(msg))
                if(~isempty(harnessOpts.harnessFilePath) && ...
                        ~ischar(harnessOpts.harnessFilePath))
                    msg = 'HARNESSFILEPATH should be a string';
                end
                if ~((harnessOpts.modelRefHarness == true) || ...
                     (harnessOpts.modelRefHarness == false))
                    msg = [msg 'The MODELREFHARNESS argument should be of class logical.'];
                end
                if ~((harnessOpts.usedSignalsOnly == true) || ...
                     (harnessOpts.usedSignalsOnly == false))
                    msg = [msg 'The USEDSIGNALSONLY argument should be of class logical.'];
                end
                if ~((harnessOpts.systemTestHarness == true) || ...
                     (harnessOpts.systemTestHarness == false))
                    msg = [msg 'The SYSTEMTESTHARNESS argument should be of class logical.'];
                end
            end
        end
    end
end
% LocalWords:  HARNESSFILEPATH MODELREFHARNESS USEDSIGNALSONLY
% LocalWords:  SYSTEMTESTHARNESS
