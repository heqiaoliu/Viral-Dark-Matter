function [inportUsage, allUnused, anyUnused] = getInportUsage(sldvData)

%   Copyright 2010 The MathWorks, Inc.
   
    inportInfo = sldvData.AnalysisInformation.InputPortInfo;
    numInports = length(inportInfo);
    inportUsage = cell(1,numInports);
    allUnused = [];
    anyUnused = false;
    for idx=1:numInports
        inportUsage{idx} = portUsage(inportInfo{idx});
        if isempty(allUnused)
            allUnused = all(~inportUsage{idx});
        else
            allUnused = allUnused && all(~inportUsage{idx});
        end
        anyUnused = anyUnused || any(~inportUsage{idx});
    end
    if isempty(allUnused)
        allUnused = false;
    end
end

function inportUsage = portUsage(inportInfo, inportUsage)
    if nargin<2
        inportUsage = [];
    end
    if isstruct(inportInfo)
        inportUsage(end+1) = inportInfo.Used;
    else
        for idx=2:length(inportInfo)
            inportUsage = portUsage(inportInfo{idx},inportUsage);
        end
    end
end