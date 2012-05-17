function checkSldvData(obj, modelToCheck)         %#ok<INUSD>            

%   Copyright 2010 The MathWorks, Inc.

    [obj.SldvData, errStr] = ...
       Sldv.DataUtils.convertLoggedSldvDataToHarnessDataFormat(obj.SldvData, obj.Model);
    if ~isempty(errStr)
        msgId = 'InvalidDataFormat';
        msg = xlate('Invalid usage of %s. %s');
        obj.handleMsg('error', msgId, msg, obj.UtilityName, errStr);
    end
    
    checkSldvData@Sldv.RunTestCase(obj);   
    
    if strcmp(obj.CgvType,'topmodel') 
        msgId = 'InvalidVirtualBusOutput';
        msg = xlate(['Root outport ''%s'' is driven by a virtual bus signal. ',...
            'Code Generation Verification (CGV) API ',...
            'Top-model SIL or PIL simulation mode does not support virtual bus signals at root outports. ',...
            'To avoid this error, convert the signal driving the root outport to a nonvirtual bus.']);                       
        outputPortInfo = obj.SldvData.AnalysisInformation.OutputPortInfo; 
        for idx=1:length(outputPortInfo)            
            if iscell(outputPortInfo{idx})
                outputPortInfo_idx = outputPortInfo{idx}{1};
            else
                outputPortInfo_idx = outputPortInfo{idx};
            end
            if isfield(outputPortInfo_idx,'CompiledBusType') && ...
                    strcmp(outputPortInfo_idx.CompiledBusType,'VIRTUAL_BUS')
                obj.handleMsg('error', msgId, msg, getfullname(obj.OutportBlkHs(idx)));
            end
        end
    end
end

% LocalWords:  CGV PIL SIL nonvirtual topmodel
