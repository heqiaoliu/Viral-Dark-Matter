function [dataValues, dataNoEffect] = constructDataValuesForInport( ...                                                                                                                                
                                                                inportInfoData, ...
                                                                timeCompressed, ... 
                                                                inportTestData, ...
                                                                inportNoEffectData, ...
                                                                forNewFormat)
                                                            
    if ~iscell(inportTestData)
        numberTimeSteps = length(timeCompressed);    
        if forNewFormat
            Dimensions = inportInfoData.Dimensions;
        else
            Dimensions = inportInfoData.dimensions;
        end
        if forNewFormat
            dataValues = Sldv.DataUtils.reshapeData(numberTimeSteps, Dimensions, inportTestData);
            dataNoEffect = Sldv.DataUtils.reshapeData(numberTimeSteps, Dimensions, inportNoEffectData);
        else
            dataValues = Sldv.DataUtils.flattenData(numberTimeSteps, Dimensions, inportTestData);
            dataNoEffect = Sldv.DataUtils.flattenData(numberTimeSteps, Dimensions, inportNoEffectData);
        end        
    else
        numSignals = length(inportTestData);
        dataValues = cell(1,numSignals);
        dataNoEffect = cell(1,numSignals);        
        for i=1:numSignals
            [dataValues{i}, dataNoEffect{i}] = Sldv.DataUtils.constructDataValuesForInport( ...                                                                                                                                
                                                                inportInfoData{i+1}, ...
                                                                timeCompressed, ... 
                                                                inportTestData{i}, ...
                                                                inportNoEffectData{i}, ...
                                                                forNewFormat);
        end
    end   
                                                            
    
end