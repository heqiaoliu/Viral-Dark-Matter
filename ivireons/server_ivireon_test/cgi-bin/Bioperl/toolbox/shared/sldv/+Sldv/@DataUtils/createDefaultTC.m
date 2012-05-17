function tc = createDefaultTC(inportCompInfos, forLogging)

%   Copyright 2009-2010 The MathWorks, Inc.

    if nargin<2
        forLogging = false;
    end           
    
    numInputsToTestUnit = length(inportCompInfos);
   
    if forLogging
        tc = struct(...
            'timeValues', 0,...
            'dataValues', '',...
            'paramValues',[]);
        dataValues = cell(numInputsToTestUnit,1);
        tc.dataValues = dataValues(:);
    else
        dataValues = [];
        dataNoEffect = [];
        for idx = 1:numInputsToTestUnit
            [dataValues{end+1},dataNoEffect{end+1}] = createInportTCData(inportCompInfos(idx)); %#ok<AGROW>
        end
        
        tc = struct(...
            'timeValues', 0,...
            'dataValues', '',...
            'paramValues',[],...
            'stepValues',[],...
            'objectives',[],...
            'dataNoEffect', ''...
            );
        
        tc.dataValues = dataValues(:);
        tc.dataNoEffect = dataNoEffect(:);
    end    
end

function [Data, DataNoEffect] = createInportTCData(inport)

    compInfo = inport.compiledInfo;
    sizedData = cell(length(compInfo),1);
    sizedNoEffect = cell(length(compInfo),1);
    for i=1:length(compInfo)
        [d d_noeff]= prepare_default_testdata_forinport(compInfo(i));
        sizedData{i} = d;
        sizedNoEffect{i} = d_noeff; 
    end
    
    if inport.IsStructBus
        busPath = compInfo(1).BusObjPath;
        buses = sldvshareprivate('util_get_signal_parts',busPath);
        bus = sl('slbus_get_object_from_name', buses{1}, true);
        Data = createBusCell(bus, sizedData, 1); 
        DataNoEffect = createBusCell(bus, sizedNoEffect, 1);
    else
        Data = sizedData{1}; % data should be a cell with 1 element
        DataNoEffect = sizedNoEffect{1};
    end
end

function [Data DataNoEffect] = prepare_default_testdata_forinport(inportInfo)

    signalDimension = inportInfo.Dimensions;
    signalDataTypeStr = inportInfo.DataType;
    data = zeros(prod(signalDimension),1);
    data_noeff = zeros(prod(signalDimension),1); %Assume the data always has an effect
    
    [~, testDataNumberTimeSteps] = size(data);
    
    untypedData = Sldv.DataUtils.reshapeData(testDataNumberTimeSteps,signalDimension,data);
    DataNoEffect = Sldv.DataUtils.reshapeData(testDataNumberTimeSteps,signalDimension,data_noeff);
       
    if sl('sldtype_is_builtin', signalDataTypeStr)
        if strcmp(signalDataTypeStr,'boolean') || strcmp(signalDataTypeStr,'bool')
            Data = cast(untypedData, 'logical');
    else
            Data = cast(untypedData, signalDataTypeStr);
        end
    else
        %Get the default value for enum, not necessarily 0
        [isEnum, className] = sldvshareprivate('util_is_enum_type', signalDataTypeStr);
        if(isEnum) 
            Data = sldvshareprivate('util_get_enum_defaultvalue', className);
        else
            [isfxptype, fxpTypeInfo] = sldvshareprivate('util_is_fxp_type',signalDataTypeStr);
            if isfxptype && ~isempty(fxpTypeInfo)            
                Data = fi(untypedData, fxpTypeInfo);
                for k=1:prod(size(Data)) %#ok<PSIZE>
                    a = Data(k);
                    a.int = untypedData(k);                    
                    Data(k) = a;
                end
            else
                 error('SLDV:MdlPrepareTestdataForInport:UnrecognizedType',...
                    'The data type ''%s'' is not recognized as a builtin or fixed point type',signalDataTypeStr);  
            end
        end
    end
end 

function [ isbus, bus ] = isabus(typename)
    bus = sl('slbus_get_object_from_name', typename, false);
    if ~isempty(bus) && isa(bus, 'Simulink.Bus')
        isbus = true;
    else
        bus = [];
        isbus = false;
    end    
end
    

function [out,id] = createBusCell(bus, data, dataId)
    out = cell(size(bus.Elements));
    id = dataId;
    for i=1:length(bus.Elements)
        [elem, id]  = createBusElement(bus.Elements(i), data, id);
        out{i} = elem;
    end
end

function [elem, id] = createBusElement(busElem, data, dataId)
    [isbus, bus] = isabus(busElem.DataType);
    if isbus
        [elem, id] = createBusCell(bus, data, dataId);
    else
        elem = data{dataId};
        id = dataId+1;
    end
end

% LocalWords:  SLDV Testdata fxp sldtype
