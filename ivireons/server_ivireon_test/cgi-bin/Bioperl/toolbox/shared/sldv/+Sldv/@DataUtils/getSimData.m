function [simData, title] = getSimData(sldvData,dataIdx)    
    if nargin<2
        dataIdx = [];
    end
    if isfield(sldvData,'TestCases')               
        allSimData = sldvData.TestCases;
        title = 'Test Case';
    elseif isfield(sldvData,'CounterExamples')
        allSimData = sldvData.CounterExamples;
        title = 'Counter Example';
    else
        allSimData = [];
        title = 'No Data';
    end
    
    if isempty(dataIdx) || isempty(allSimData)
        simData = allSimData;
    else
        simData = allSimData(dataIdx);
    end
end