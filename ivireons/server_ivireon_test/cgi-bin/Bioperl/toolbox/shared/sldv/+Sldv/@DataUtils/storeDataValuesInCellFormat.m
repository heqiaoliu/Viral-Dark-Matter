function [dataValuesInCell, tsTimeInfo] = storeDataValuesInCellFormat(dataValuesInTs,PortInfo)

%   Copyright 2008-2009 The MathWorks, Inc.

    if isa(dataValuesInTs,'Simulink.Timeseries')        
        Data = dataValuesInTs.Data;        
        tsTimeInfo = dataValuesInTs.Time;
        signalDimension = PortInfo.Dimensions;
        sizeData = size(Data);
        if isscalar(signalDimension) || ...
                (all(signalDimension==1) && sizeData(end)~=length(tsTimeInfo))
            % Transpose the data if time is first because in sldvData we
            % always put numTimeSteps first
            dataValuesInCell = Data';
        else
            dataValuesInCell = Data;
        end        
    elseif isa(dataValuesInTs,'Simulink.TsArray')        
        numComponents = length(dataValuesInTs.Members);
        dataValuesInCell = cell(numComponents,1);        
        for i=1:numComponents
            component = dataValuesInTs.Members(i);            
            [dataValuesInCell{i}, tsTimeInfo] = Sldv.DataUtils.storeDataValuesInCellFormat(dataValuesInTs.(component.('name')),...
                PortInfo{i+1});
        end
    else
        error('Sldv:DatayUtils:storeDataValuesInCellFormat','Incorrect data type');
    end
end