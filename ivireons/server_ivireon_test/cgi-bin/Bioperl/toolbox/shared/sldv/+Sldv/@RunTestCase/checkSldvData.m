function checkSldvData(obj, modelToCheck)    

%   Copyright 2009-2010 The MathWorks, Inc.
    if nargin<2
        modelToCheck = obj.Model;
    end

    inputPortInfo = obj.SldvData.AnalysisInformation.InputPortInfo;    
    ssInBlkHs = Sldv.utils.getSubSystemPortBlks(modelToCheck);
    if length(ssInBlkHs)~=length(inputPortInfo)
        msgId = 'MissMatchInputs';                       
        msg = xlate(['Unable to invoke %s because the model ''%s'' has '...
            '%d Inport blocks and input data specifies test cases for %d inputs.']);                       
        obj.handleMsg('error', msgId, msg, ...
            obj.UtilityName, obj.Model, length(ssInBlkHs), length(inputPortInfo));
    end    
    
    if Sldv.DataUtils.has_structTypes_interface(obj.SldvData)
        msgId = 'StructTypes';                       
        msg = xlate(['Unable to invoke %s because the model ''%s'' has '...
            'Inport and Outports blocks having Simulink.StructType.']);                       
        obj.handleMsg('error', msgId, msg, obj.UtilityName, obj.Model);    
    end

    if Sldv.DataUtils.modelHasFixedPntInterface(obj.SldvData) && ...
            exist('fi','file')~=2
        msgId = 'FixedPointToolbox';                       
        msg = xlate(['Unable to invoke %s because the model ''%s'' has '...
            'Inport blocks having fixed-point type and Fixed-Point Toolbox is  ' ...
            'not installed. Fixed-Point Toolbox is required to invoke sldvruntest']);                       
        obj.handleMsg('error', msgId, msg, obj.UtilityName, obj.Model);
    end
    
    blockWithUspecBus = Sldv.DataUtils.has_unspecified_bus_objects(modelToCheck,obj.SldvData);
    if ~isempty(blockWithUspecBus);
        msgId = 'UnspecifiedBusObject';                       
        msg = xlate(['Unable to invoke %s because  '...
            'a bus is entering to the input port of block ''%s'' and its  ''Bus object'' '...
            'parameter is not specified. ''Bus object'' parameter must be specified '...
            'on the input port of Outport blocks to invoke sldvruntest']);                       
        obj.handleMsg('error', msgId, msg, obj.UtilityName, blockWithUspecBus);
    end
    
    if defaultOutputFormatRequired(obj.SldvData,obj.OutputFormat)
        obj.OutputFormat = 'TimeSeries';
        msgId = 'OutputFormatChange';                       
        msg = xlate(['Model ''%s'' has root level Outport blocks having bus signals at their input ports. '...
            'Changing ''outputFormat'' to ''TimeSeries'' to be able to generate outData.']);                       
        obj.handleMsg('warning', msgId, msg, obj.Model);
    end
end

function status = defaultOutputFormatRequired(sldvData,outputFormat)
    status = false;
    if strcmp(outputFormat,'StructureWithTime')
        outputPortInfo = sldvData.AnalysisInformation.OutputPortInfo;
        for i=1:length(outputPortInfo)
            if iscell(outputPortInfo{i})
                status = true;
                break;
            end
        end
    end
end