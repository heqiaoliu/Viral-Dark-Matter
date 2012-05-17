function  sldvDataComp = compressSldvData(sldvData)   
    sldvDataComp = sldvData;
    simData = Sldv.DataUtils.getSimData(sldvData);
    if ~isempty(simData)        
        for i=1:length(simData)           
           newSimData =  Sldv.DataUtils.compressTestCaseData(simData(i));
           sldvDataComp = Sldv.DataUtils.setSimData(sldvDataComp,i,newSimData);
        end 
    end
end