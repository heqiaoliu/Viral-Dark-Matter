function [sldvData, inportUsage, anyUnused] = updateInportUsage(sldvData)    

%   Copyright 2010 The MathWorks, Inc.

    sldvData = Sldv.DataUtils.addInportUsage(sldvData);
    [inportUsage, allUnused, anyUnused] = Sldv.DataUtils.getInportUsage(sldvData);    
    if allUnused         
        if exist('sldvprivate', 'file')==2
            try
                testcomp = Sldv.Token.get.getTestComponent;
            catch myException %#ok<NASGU>
                testcomp = [];
            end
        else
            testcomp = [];
        end

        sldvAnalysisActive =  ~isempty(testcomp) && ...
            ishandle(testcomp) && ...
            ~isempty(testcomp.analysisInfo);    

        paramValueExist = isfield(sldvData,'TestCases') && ...
            ~isempty(sldvData.TestCases) && ...
            ~isempty(sldvData.TestCases(1).paramValues);
                
        if sldvAnalysisActive || paramValueExist
            % There is at least one input
            inportInfo = sldvData.AnalysisInformation.InputPortInfo{1};            
            sldvData.AnalysisInformation.InputPortInfo{1} = updateinportInfo(inportInfo);
            inportUsage{1}(1) = true;
        end
    end
end

function [inportInfo, updated] = updateinportInfo(inportInfo)
    updated = false;    
    if isstruct(inportInfo)
        inportInfo.Used = true;
        updated = true;
    else
        for idx=2:length(inportInfo)
            [subinportInfo, updated] = updateinportInfo(inportInfo{idx});
            if updated
                inportInfo{idx} = subinportInfo;
                break;
            end
        end
    end
end

