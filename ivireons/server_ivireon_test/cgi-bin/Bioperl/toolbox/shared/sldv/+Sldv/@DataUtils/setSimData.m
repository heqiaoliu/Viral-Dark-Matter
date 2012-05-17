function sldvData = setSimData(sldvData,dataIdx,simData)
    opts = sldvData.AnalysisInformation.Options;
    if strcmp(opts.Mode,'TestGeneration')
        if ~isempty(dataIdx)
            sldvData.TestCases(dataIdx) = simData;
        else
            sldvData.TestCases = simData;
        end
    else
        if ~isempty(dataIdx)        
            sldvData.CounterExamples(dataIdx) = simData;
        else
            sldvData.CounterExamples = simData;
        end
    end
end