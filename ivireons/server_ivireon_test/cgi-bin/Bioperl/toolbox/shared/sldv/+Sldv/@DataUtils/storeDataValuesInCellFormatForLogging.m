function dataValuesInCell = storeDataValuesInCellFormatForLogging(...
    dataValuesInTs, PortInfo, ...
    funTsRefModel, funTsLoggeData, ...
    timeExpanded, minLogTime, maxLogTime)

%   Copyright 2009 The MathWorks, Inc.


    if isa(dataValuesInTs,'Simulink.Timeseries')        
        Data = dataValuesInTs.Data;        
        tsTimeInfo = dataValuesInTs.Time;     
        signalDimension = PortInfo.Dimensions;
        signalDataTypeStr = PortInfo.DataType;
        
        sizeData = size(Data);
        if isscalar(signalDimension) || ...
                (all(signalDimension==1) && sizeData(end)~=length(tsTimeInfo))
            % Transpose the data if time is first because in sldvData we
            % always put numTimeSteps last
            Data = Data';
            isScalarData = true;
        else
            isScalarData = false;
        end
        
        if ~isScalarData && dataValuesInTs.IsTimeFirst
            Data = Data';
            %Reshape the data to the format expected by sldvData
            numberTimeSteps = length(tsTimeInfo);
            dt = Sldv.DataUtils.flattenData(numberTimeSteps,signalDimension,Data);        
            Data = Sldv.DataUtils.reshapeData(numberTimeSteps,signalDimension,dt);
        end                
                        
        if tsTimeInfo(end)~=maxLogTime
            % Logged data is missing the log for the last step. Repeat the
            % last value to extrapolate
            numberTimeSteps = length(tsTimeInfo);
            dt = Sldv.DataUtils.flattenData(numberTimeSteps,signalDimension,Data);        
            dt = [dt dt(:,end)];         
            Data = Sldv.DataUtils.reshapeData(numberTimeSteps+1,signalDimension,dt);
            tsTimeInfo(end+1) = maxLogTime;
        end
        
        if tsTimeInfo(1)~=minLogTime
            % Logged data is missing the log for the first step. Assume it
            % is zero. 
            numberTimeSteps = length(tsTimeInfo);
            dt = Sldv.DataUtils.flattenData(numberTimeSteps,signalDimension,Data);        
            dt = [dt dt(:,end)];  
            dt(:,1) = creatZeroData(signalDimension, signalDataTypeStr);
            Data = Sldv.DataUtils.reshapeData(numberTimeSteps+1,signalDimension,dt);
            tsTimeInfo = [minLogTime tsTimeInfo];
        end
        
        % Align the first element to zero because logged data may not start
        % from zero
        tsTimeInfo = tsTimeInfo-tsTimeInfo(1); 
        
        if length(timeExpanded)~=length(tsTimeInfo)
            tsTimeInfo = floor(tsTimeInfo/funTsLoggeData)*funTsRefModel;
            Data = Sldv.DataUtils.interpBelow(tsTimeInfo, Data, timeExpanded, signalDimension);            
            if isScalarData
                % interpBelow makes data column wise, make it rowwise
                Data = Data';
            end
        end
        
        dataValuesInCell = Data;                
    else    
        numComponents = length(dataValuesInTs.Members);
        dataValuesInCell = cell(numComponents,1);        
        for idx=1:numComponents
            component = dataValuesInTs.Members(idx);            
            dataValuesInCell{idx} = ...
                Sldv.DataUtils.storeDataValuesInCellFormatForLogging(...
                    dataValuesInTs.(component.('name')), PortInfo{idx+1}, ...
                    funTsRefModel, funTsLoggeData, ...
                    timeExpanded, minLogTime, maxLogTime);
        end   
    end
end

function zeroData = creatZeroData(signalDimension, signalDataTypeStr)
    data = zeros(prod(signalDimension),1);
    untypedData = Sldv.DataUtils.reshapeData(1,signalDimension,data);    
    if sl('sldtype_is_builtin', signalDataTypeStr)
        if strcmp(signalDataTypeStr,'boolean') || strcmp(signalDataTypeStr,'bool')
            zeroData = cast(untypedData, 'logical');
        else
            zeroData = cast(untypedData, signalDataTypeStr);
        end
    else
        [isEnum, enumCls] = sldvprivate('util_is_enum_type', signalDataTypeStr);
        if(isEnum)
            zeroData = feval(enumCls, untypedData);
        else
            [isfxptype, fxpTypeInfo] = sldvshareprivate('util_is_fxp_type',signalDataTypeStr);
            if isfxptype && ~isempty(fxpTypeInfo)
                zeroData = fi(untypedData, fxpTypeInfo);
            else
                zeroData = untypedData;
            end                        
        end
    end
end
