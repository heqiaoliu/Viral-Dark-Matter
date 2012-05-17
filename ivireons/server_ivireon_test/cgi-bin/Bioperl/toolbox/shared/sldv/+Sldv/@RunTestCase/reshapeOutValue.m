function outValue = reshapeOutValue(obj, outStruct, loggedData)

%   Copyright 2009 The MathWorks, Inc.

    numOutports = length(obj.OutportBlkHs);
    outValue = cell(1,numOutports);
    if strcmp(obj.OutputFormat,'StructureWithTime')
        for idx=1:numOutports
            outData.time = outStruct.time;
            outData.signals = outStruct.signals(idx);
            outValue{idx} = outData;
        end
    else
        numPortsAlreadyLogged = length(obj.PortHsToLog);
        if ~isempty(loggedData)
            for idx=1:numPortsAlreadyLogged              
                logger = loggedData.(get_param(obj.PortHsToLog(idx),'DataLoggingName'));
                portH = derivePortOfLogger(logger, obj.PortHsToLog(idx), obj.OutportBlkHs);
                outportH = portH.Outport(logger.PortIndex);
                lineH = get_param(outportH,'Line');
                destBlockH = get_param(lineH,'DstBlockHandle');
                for jdx=1:length(destBlockH)
                    if strcmp(get_param(destBlockH(jdx),'BlockType'),'Outport') && ...
                        strcmp(get_param(destBlockH(jdx),'Parent'),obj.Model)                    
                        refineLogger(logger, destBlockH(jdx));
                        portIndex = str2double(get_param(destBlockH(jdx),'Port'));
                        outValue{portIndex} = logger;
                    end
                end
            end
        end        
        outputPortInfo = obj.SldvData.AnalysisInformation.OutputPortInfo;
        flatPortIdx = 1;
        loogerIdx = numPortsAlreadyLogged;
        for idx=1:numOutports
            if ~iscell(outputPortInfo{idx})
                % Create a timeseries object. The isTimeFirst property should 
                % be assigned to true for 2-d data and false otherwise unless
                % there is a single sample, in which case isTimeFirst is true 
                % if and only if signal is scalar.
                assert(get_param(outStruct.signals(flatPortIdx).blockName,'Handle') == ...
                    get_param(obj.OutportBlkHs(idx),'Handle'))
                
                tsData = deriveOutPortValue(outStruct.signals(flatPortIdx).values,outputPortInfo{idx});
                if length(outStruct.time)==1
                    isTimeFirst = ndims(tsData)<=2 && size(tsData,1)==1 && ...
                        length(outputPortInfo{idx}.Dimensions)<=1;
                        tempMLtimeseriesobj = timeseries(tsData,outStruct.time,'isTimeFirst',...
                            isTimeFirst,'InterpretSingleRowDataAs3D',~isTimeFirst);
                else
                    isTimeFirst = ndims(tsData)<=2;
                    tempMLtimeseriesobj = timeseries(tsData,outStruct.time,'isTimeFirst',...
                        isTimeFirst);
                end
                outportValuesObj = Simulink.Timeseries(tempMLtimeseriesobj);       
            
                outportPortHandles = get_param(obj.OutportBlkHs(idx),'PortHandles');

                outportValuesObj.Name = sprintf('dvTestLogger_%d',idx);
                outportValuesObj.BlockPath = outStruct.signals(flatPortIdx).blockName;
                outportValuesObj.PortIndex = 1;
                outportValuesObj.SignalName = get_param(get_param(outportPortHandles.Inport,'Line'),'Name');
                outportValuesObj.ParentName = sprintf('%s%d',obj.SignalLoggerPrefix, loogerIdx);
                
                outValue{idx} = outportValuesObj;
                
                flatPortIdx = flatPortIdx+1;
                loogerIdx = loogerIdx+1;
            else
                assert(isa(outValue{idx},'Simulink.TsArray'));
            end
        end
    end
end

function portH = derivePortOfLogger(logger, portHLogged, rootLevelOutports)
    try 
        portH = get_param(logger.BlockPath,'PortHandles');
    catch Mex %#ok<NASGU>
        portH = [];
    end
    if isempty(portH)
        %The 'BlockPath' of the logger is not correct. Derive the block
        %the logger is connected to by iterating over the outport blocks
        %of the model. 
        for idx = 1:length(rootLevelOutports)
            outportPortHandles = get_param(rootLevelOutports(idx),'PortHandles');
            lineH = get_param(outportPortHandles.Inport,'Line');   
            srcportH = get_param(lineH,'SrcPortHandle');                         
            if srcportH==portHLogged
                portH = get_param(get_param(srcportH,'Parent'),'PortHandles');
                break;
            end
        end
    end
    assert(~isempty(portH),'Port handle of the logger must be found');
end

function refineLogger(logger, outPortH)
    if isa(logger,'Simulink.Timeseries')     
        outportPortHandles = get_param(outPortH,'PortHandles');
        logger.BlockPath = getfullname(outPortH);
        logger.PortIndex = 1;
        logger.SignalName = get_param(get_param(outportPortHandles.Inport,'Line'),'Name');        
    else
        members = logger.Members;        
        for idx = 1:length(members)
            memName = members(idx).name;
            refineLogger(logger.(memName), outPortH);
        end
    end
end

function value = deriveOutPortValue(value, outPortInfo)
    if ~sl('sldtype_is_builtin', outPortInfo.DataType)
        [isfxptype, fxpTypeInfo] = sldvshareprivate('util_is_fxp_type',outPortInfo.DataType);
        if isfxptype && ~isempty(fxpTypeInfo)  
            value = fi(value,fxpTypeInfo);
        end
    end
end

% LocalWords:  dv fxp sldtype
