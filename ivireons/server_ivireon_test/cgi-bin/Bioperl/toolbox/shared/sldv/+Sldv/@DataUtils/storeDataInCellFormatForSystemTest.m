function sldvData = storeDataInCellFormatForSystemTest(sldvDatainTs)

    sldvData = sldvDatainTs;

    SimData = Sldv.DataUtils.getSimData(sldvData);
    if isempty(SimData)        
        return;
    end
    
    InputPortInfo = sldvData.AnalysisInformation.InputPortInfo;
    
    for i=1:length(SimData)   
        simData = SimData(i);                                
        if isempty(simData.dataValues)            
            warning('Sldv:DataUtils:storeDataInCellFormatForSystemTest','Detected Empty Case');
            continue;
        end                  
        for j=1:length(simData.dataValues)
            simData.dataValues{j} = Sldv.DataUtils.storeDataValuesInCellFormat(simData.dataValues{j},InputPortInfo{j});                                                                
        end        
        sldvData.TestCases(i) = simData;
    end    

end

