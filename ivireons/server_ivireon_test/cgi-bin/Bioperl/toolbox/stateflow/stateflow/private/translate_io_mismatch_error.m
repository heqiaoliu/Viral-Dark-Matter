function newMsg = translate_io_mismatch_error(oldId, oldMsg, chartId, blkHandles)

% Copyright 2004-2010 The MathWorks, Inc.

try
   % This function is buggy as hell!  When it fails we should display some
   % message.  Some message is better than no message. G377216
    newMsg = doit(oldId,oldMsg,chartId,blkHandles);
catch ME %#ok<NASGU>
    newMsg = [...
        '(Internal Error) Message translation failed.'...
        '  Port numbers and block names may be misleading.'...
        '  Untranslated message follows:'...
        10 ...
        oldMsg];
end


function newMsg = doit(oldId, oldMsg, chartId, blkHandles)
    oldMsg = slprivate('removeHyperLinksFromMessage',oldMsg);
    newMsg = oldMsg;
    chartName =  sf('get', chartId, 'chart.name');
    
    if strncmpi(get(0,'language'),'ja',2)
        isJapanese = true;
        sizePattern = 'Error in port widths or dimensions.*?/(?<dataName>[\w ]+)''.*?(?<io>Input|Output)\s*(?<actualSize>.+)';
    else
        isJapanese = false;
        sizePattern = 'Error in port widths or dimensions\.\s*(?<io>Input|Output).*?/(?<dataName>[\w ]+)''\s*(?<actualSize>.+)';
    end
    
    sizeError = regexp(oldMsg,sizePattern,'once','names');
    
    if ~isempty(sizeError)
        if strcmp(sizeError.io, 'Output')
            if isJapanese
                actualSize = '';
                tailMsg = sizeError.actualSize;
            else            
                actualSize = regexp(sizeError.actualSize,'\d+(?:x\d+)*','match','once');
                actualSize = regexprep(actualSize,'x',' ');
                actualSize = dim2str(str2num(actualSize));  %#ok<ST2NM>
                tailMsg = sprintf('is a %s', actualSize);
            end
            
            chartInputEvents = sf('find', sf('EventsOf', chartId), 'event.scope', 'INPUT_EVENT');
            eventId = sf('find', chartInputEvents, 'event.name', sizeError.dataName);
            
            chartInputData = sf('find', sf('DataOf', chartId), 'data.scope', 'INPUT_DATA');
            dataId = sf('find', chartInputData, 'data.name', sizeError.dataName);
            
            if strcmp(sizeError.dataName, ' input events ') || ... % In case of multiple input events
               ~isempty(eventId)
                % Size mismatch error on input event(s)
                expectedSize = dim2str(length(chartInputEvents));
                newMsg = sprintf('Port width mismatch. Chart is expecting input events signal of %s. The actual input events signal %s',expectedSize,tailMsg);
            elseif ~isempty(dataId)
                dataParsedInfo = sf('DataParsedInfo', dataId);
                parsedDataSize = dataParsedInfo.size;
                parsedDataSize = dim2str(parsedDataSize);
                if isequal(actualSize, parsedDataSize)
                    % this is a false error, get out!
                    newMsg = '';
                else
                    propsDataSize = sf('get',dataId,'data.props.array.size');
                    if ~isempty(regexp(propsDataSize, '^\s*-\s*1\s*$','once'))
                        newMsg = dynamic_library_error('Input', sizeError.dataName, dataId, 'size', chartName, chartId);
                    else                    
                        newMsg = sprintf('Port width mismatch. Input "%s"(#%d) expects a %s. The signal %s.',sizeError.dataName,dataId,parsedDataSize,tailMsg);
                    end
                end
            end
        else
            % report on Output, not Input
            newMsg = '';
        end
        return;
    end
    
    atomicSubchartSizeError = regexp(oldMsg, 'Error in port widths or dimensions\.\s*Invalid.* Merge\d* ''', 'once');
    if ~isempty(atomicSubchartSizeError)
        newMsg = '';
        return;
    end
    
    typeError = regexp(oldMsg,'Data type mismatch.\s*(?<io>\w+).*?/(?<dataName>[\w ]+)''.*?''(?<signalType>\w+)''.*?''(?<portType>\w+)''','once','names');
    
    if ~isempty(typeError)
        hiddenSfunBlkName = ' SFunction '; % Stateflow subsystem hidden sfun block name
        if strcmp(typeError.dataName, hiddenSfunBlkName)
            % Do not report any error whose source is the hidden SFunction block
            newMsg = '';
        elseif ~isempty(regexp(typeError.dataName, ' Merge\d* ', 'once'))
            % Do not report any error whose source is the hidden Merge
            % block for atomic subcharts (g587192)
            newMsg = '';
        else
            newMsg = translate_type_error_msg(oldMsg, typeError, chartId);
        end
        
        return;
    end
    
    complexError = regexp(oldMsg,'Complex signal mismatch.\s*(?<io>\w+).*?/(?<dataName>[\w ]+)''.*?(?<signalType>\w+)\..*?(?<portType>\w+)\W*$','once','names');
    
    if ~isempty(complexError)
        if strcmp(complexError.io, 'Output')
            chartInputData = sf('find',sf('DataOf',chartId),'data.scope','INPUT_DATA');
            dataId = sf('find',chartInputData,'data.name',complexError.dataName);
            if ~isempty(dataId)
                dataParsedInfo = sf('DataParsedInfo', dataId);
                dataComplexity = dataParsedInfo.complexity;

                if dataComplexity == 2 && is_eml_based_chart(chartId)
                    newMsg = dynamic_library_error('Input', complexError.dataName, dataId, 'complexity', chartName, chartId);
                else
                    newMsg = sprintf('Complex signal mismatch. Input "%s"(#%d) expects a signal of numeric type %s. However, it is driven by a signal of numeric type %s.',complexError.dataName,dataId,complexError.portType,complexError.signalType);
                end
                return;
            end
        else
            % report on Output, not Input
            newMsg = '';
            return;
        end       
    end

    dynamicLibraryError = regexp(oldMsg,':\s*(?<iop>\w+) ''(?<dataName>[\w ]+)'' \(#(?<dataId>\d+)\) must have the same (?<stc>\w+) in all instances of library #(?<chartId>\d+)','once','names');
    
    if ~isempty(dynamicLibraryError)
        newMsg = dynamic_library_error(dynamicLibraryError.iop, dynamicLibraryError.dataName, dynamicLibraryError.dataId, dynamicLibraryError.stc, chartName, dynamicLibraryError.chartId);
        return;
    end
        
    genericStateflowError = regexp(oldMsg, [xlate('Error reported by S-function ''sf_sfun'' in ''.*?'':') '\n(?<realError>.*)'],'once','names');
    if ~isempty(genericStateflowError)
        newMsg = genericStateflowError.realError;
        return;
    end
    
    errorPrefix = 'An error occurred while propagating';
    if strncmp(oldMsg,errorPrefix,length(errorPrefix))
        % Simulink is reporting that we threw an error 
        % so we can suppress this and let the SF error do the talking
        newMsg = '';
        return;
    end
    
    [unhandledIOError s e] = regexpi(oldMsg, '(?<from>from\s*)?(?<out>output)\s*port\s*1\s*of\s*''.*?/(?<dataName>[\w ]+)''(?(from)\s*to.*?/\s*SFunction\s*'')', 'names', 'once');
    if isempty(unhandledIOError)
        % Do nothing.
    elseif strcmp(oldId,'Simulink:Engine:CannotUnifyDimsMode')
        % As of 10/9/2009 Simulink message is: 
        %
        % Simulink cannot propagate the dimension mode from the output port
        % 1 of 'emltestt1/Embedded MATLAB Function/u' to the input port 1
        % of 'emltestt1/Embedded MATLAB Function/ SFunction '. One of the
        % multiplexed signals at the output of the source has variable-size
        % mode. This multiplexed signal has to be demultiplexed before
        % Simulink can propagate it to the destination.
        newMsg = DAStudio.message('Stateflow:misc:SF_CannotUnifyDimsMode',unhandledIOError.dataName);
        return;
    else
        to = regexprep(unhandledIOError.from, 'from', 'to', 'preservecase');
        in = regexprep(unhandledIOError.out, 'out', 'in', 'preservecase');
        dataScope = [upper(in) '_DATA'];
        chartData = sf('find',sf('DataOf',chartId),'data.scope',dataScope);
        dataId = sf('find',chartData,'data.name',unhandledIOError.dataName);
        newMsg = sprintf('%s%s%s "%s"(#%d) of "%s"(#%d)%s',oldMsg(1:s-1),to,in,unhandledIOError.dataName,dataId,chartName,chartId,oldMsg(e+1:end));                

        unifyDimError = regexp(oldMsg, 'we are attempting to unify the dimensions of the multiplexed signal with dimensions','once');
        if ~isempty(unifyDimError) && ~isempty(sf('find', dataId, 'data.props.type.method', 'SF_INHERITED_TYPE'))
            clueMsg = sprintf('If data ''%s'' (#%d) with ''Inherited'' type is meant to take in a Simulink bus signal, you can disable the multiplexing behaviour by explicitly setting data ''%s''s type mode to be ''Bus Object'' .', ...
                              unhandledIOError.dataName, dataId, unhandledIOError.dataName);
            newMsg = sprintf('%s\n\n%s', newMsg, clueMsg);
        end
        
        variableSizingUnsupportedError = regexp(oldMsg, 'the block supports variable-size signals but needs to be configured for them', 'once');
        if ~isempty(variableSizingUnsupportedError)
            if ~sf('IsVariableSizingON',chartId)
                newMsg = sprintf([newMsg '. You can enable variable-sizing for (#%d) from the ports and data manager dialog.'], chartId);
            end
        end

        return;
    end    
    
   % Correct "... (input|output) port <portNum> of '<chartPath>/ SFunction ' ..." 
    genericChartIOError = regexp(oldMsg, '(?<prefix>^.*?)(?<io>[iI]nput|[oO]utput)\s+port\s+(?<port>\d+)\s+of\s+''(?<chartPath>[^'']*?)\/\ SFunction\ ''(?<suffix>.*$)', 'once', 'names');
    if ~isempty(genericChartIOError)
        % First see if this is a hidden port which corresponds to a SL
        % function inside the Stateflow mask.
        newMsg = simfcn_man('translateIOError', genericChartIOError);
        if ~isempty(newMsg)
            return
        end
        if strcmpi(genericChartIOError.io, 'output')
            genericChartIOError.port = num2str(str2double(genericChartIOError.port) - 1);
        end
        newMsg = [genericChartIOError.prefix genericChartIOError.io ' port ' genericChartIOError.port ' of ''' genericChartIOError.chartPath '''' genericChartIOError.suffix];
        return;
    end

   % Cannot modify parameter ... of S-function '.../ SFunction ' while simulation is running.
   modifyParamError = regexpi(oldMsg, '(?<leading>Cannot modify parameter) (?<paramNumber>\d+) of S-function ''(?<blk>.*)/ SFunction\s+''(?<trailing>.*)','once','names');
   if ~isempty(modifyParamError)
       newMsg = [modifyParamError.leading ' ' modifyParamError.paramNumber ' of ''' modifyParamError.blk '''' modifyParamError.trailing];
       return;
   end
   
   dsmInitialValueError = regexpi(oldMsg, 'Error evaluating parameter ''InitialValue'' in ''(?<blk>.*?)'': (?<trailing>.*)', 'once', 'names');
   if ~isempty(dsmInitialValueError)
       newMsg = dsmInitialValueError.trailing;
       return;
   end
   
   dsmResolveSignalError = regexpi(oldMsg, 'Can not resolve Simulink signal object ''(?<name>\w+)'' for state of ''(?<path>.*)''', 'once', 'names');
   if ~isempty(dsmResolveSignalError)
       dataId = sf('DataOf', chartId);
       dataId = sf('find', dataId, 'data.scope', 'DATA_STORE_MEMORY', 'data.name', dsmResolveSignalError.name);
       newMsg = sprintf('Failed to resolve data ''%s'' (#%d) to a valid Simulink.Signal object.', dsmResolveSignalError.name, dataId);
   end
   
   if strcmp(oldId, 'Simulink:Parameters:InvParamSetting')
       if length(blkHandles) == 1 && strcmp(get_param(blkHandles, 'BlockType'), 'DataStoreMemory')
           dsmName =  get_param(blkHandles(1), 'DataStoreName');
           dataId = sf('DataOf', chartId);
           dataId = sf('find', dataId, 'data.name', dsmName);
           newMsg = DAStudio.message('Stateflow:misc:InvParamSetting', dsmName, dataId(1));
       end
   end
   
   iteratorError = regexpi(oldMsg, 'Implicit iterator subsystem ''(?<iterBlock>.*)'' is set to maintaining separate state. Block ''(?<sfBlock>.*)'' is not compliant to Implicit Iterator subsystem with separate state.', 'once', 'names');
   if ~isempty(iteratorError)
       iteratorSubsys = iteratorError.iterBlock;
       sfSubsys = regexprep(iteratorError.sfBlock, '/ SFunction ', '');
       newMsg = sprintf('Stateflow chart ''%s'' cannot be placed inside the Implicit iterator subsystem ''%s''. This might be because the Stateflow chart has ''Export chart level functions'' set', sfSubsys, iteratorSubsys);
   end
   
   if strcmp(oldId, 'Simulink:Parameters:BlkParamUndefined')
       if length(blkHandles) == 1 && strcmp(get_param(blkHandles, 'BlockType'), 'DataStoreMemory')
           newMsg = 'Error in usage of mapped local data. Please see error messages above for more information.'; % These are caught in SimulinkMan.
       end
   end
   
   if strcmp(oldId, 'Simulink:blocks:BlockDoesNotSupportMultiExecInstances')
       sfSubsys = get_param(blkHandles(1), 'Parent');
       newMsg = DAStudio.message('Stateflow:misc:BlockDoesNotSupportMultiExecInstances', sfSubsys);
   end


   if strcmp(oldId, 'Simulink:SFunctions:SFcnDesignMaxIsOutOfDTRange') || ...
           strcmp(oldId, 'Simulink:SFunctions:SFcnDesignMinIsOutOfDTRange')
       rangePattern = 'Inconsistent numeric values for Output of index (?<outputNumber>\S+) in ''(?<path>\S+) SFunction '': Design (?<minmax>minimum|maximum) \((?<specifiedMinMax>\S+)\) is out of data type range \[(?<dataTypeMin>\S+), (?<dataTypeMax>\S+)\]';
       rangePatternData = regexp(oldMsg, rangePattern, 'once', 'names'); 
       if (~isempty(rangePatternData) && length(blkHandles)==1)
           chartProps = get(blkHandles);
           outputSignalName = chartProps.OutputSignalNames{str2double(rangePatternData.outputNumber)};
           rangePatternData.minmax(1) = 'M'; % Capitalize first letter of minimum / maximum.
           newMsg = sprintf(['Inconsistent numeric values for output signal ''%s'' in Stateflow chart ''%s''. '...
               '%s value (%s) specified in ''Limit range'' is out of data type range [%s, %s].'], ...               
               outputSignalName,...
               rangePatternData.path(1:end-1),...
               rangePatternData.minmax,...
               rangePatternData.specifiedMinMax,...
               rangePatternData.dataTypeMin,...
               rangePatternData.dataTypeMax);
           return;
       end
   end


%----------------------------------------------------------------------
function newMsg = dynamic_library_error(iop, dataName, dataId, stc, chartName, chartId)
    if ischar(dataId)
        dataId = str2double(dataId);
    end
    if ischar(chartId)
        chartId = str2double(chartId);
    end
    if sf('get',sf('get', chartId, '.machine'),'machine.isLibrary')
        formatStr = '%s ''%s'' (#%d) must have the same %s in all instances of library ''%s'' (#%d).';
    else
        formatStr = '%s ''%s'' (#%d) has unexpectedly received a second %s in ''%s'' (#%d).';    
    end
    newMsg = sprintf(formatStr, iop, dataName, dataId, stc, chartName,chartId);

%----------------------------------------------------------------------
function dimensionStr = dim2str(dimensionNum)
    numDims = length(dimensionNum);
    if prod(dimensionNum) == 1;
        numDims = 0;
    end
    switch numDims
    case 0
        dimensionStr = 'scalar';
    case 1
        dimensionStr = sprintf('one dimensional vector with %d elements', dimensionNum);
    otherwise
        dimensionStr = sprintf('[%d',dimensionNum(1));
        for i = 2:numDims
            dimensionStr = sprintf('%sx%d', dimensionStr, dimensionNum(i));
        end
        dimensionStr = sprintf('%s] matrix', dimensionStr);
    end

%----------------------------------------------------------------------
function errMsg = translate_type_error_msg(oldMsg, typeError, chartId)

    if strcmp(typeError.io, 'Output')
        % Really the Stateflow block input side error
        ioData = sf('find',sf('DataOf',chartId),'data.scope','INPUT_DATA');
        ioStr = {'Input', 'expects', 'driven by'};
    else
        % Really the Stateflow block output side error
        ioData = sf('find',sf('DataOf',chartId),'data.scope','OUTPUT_DATA');
        ioStr = {'Output', 'is', 'driving'};
    end
    
    dataId = sf('find', ioData, 'data.name', typeError.dataName);
    if isempty(dataId)
        % In case of unexpected error, we failed to get valid
        % dataId, do not translate this message
        errMsg = oldMsg;
        return;
    end

    chartName =  sf('get', chartId, 'chart.name');
    
    if compare_property(dataId, 'data.props.type.method', 'SF_INHERITED_TYPE')
        errMsg = dynamic_library_error(ioStr{1}, typeError.dataName, dataId, 'type', chartName, chartId);
    else
        strongDataTyping = sf('get', chartId, 'chart.disableImplicitCasting');

        errMsg = sprintf('Data type mismatch. %s "%s"(#%d) %s a signal of data type ''%s''. However, it is %s a signal of data type ''%s''.', ...
                         ioStr{1}, typeError.dataName, dataId, ...
                         ioStr{2}, typeError.portType, ...
                         ioStr{3}, typeError.signalType);

        if ~strongDataTyping
            errMsg = sprintf('%s\n\nThis problem may be resolved by setting the Strong Data Typing option in the Stateflow chart "%s"(#%d), or by using a Simulink Data Type Conversion block',errMsg,chartName,chartId);
        else
            errMsg = sprintf('%s\n\nThis problem may be resolved by using a Simulink Data Type Conversion block',errMsg);
        end
    end
    
    return;
