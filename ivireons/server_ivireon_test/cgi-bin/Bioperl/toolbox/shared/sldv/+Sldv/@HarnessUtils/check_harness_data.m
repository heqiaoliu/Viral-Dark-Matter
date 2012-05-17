function [errStr, sldvData, sldvDataFilePath, isLoggedSldvData] = check_harness_data(modelH, sldvData, harnessopts)
%   Copyright 2008-2010 The MathWorks, Inc.
    errStr = '';
    sldvDataFilePath = '';
    isLoggedSldvData = false;
    
    if ischar(sldvData)
        if (exist(sldvData, 'file') == 2)
            sldvDataFilePath = sldvData;
            sldvData = load(sldvData);
        else
            errStr = sprintf('Data file not found: %s', sldvData);
        end
    end
    
    if harnessopts.systemTestHarness  && isempty(sldvDataFilePath)
        errStr = sprintf('SystemTest harness requires path of the Data file.');
    end
    
    if ~isempty(errStr)
        return;
    end
    
    dataFields = fields(sldvData);
    if length(dataFields)==1 
        sldvData = sldvData.(dataFields{1});
    end        
    
    isLoggedSldvData = isfield(sldvData,'LoggedTestUnitInfo'); 
    
    if harnessopts.systemTestHarness && isLoggedSldvData
        errStr = sprintf(['SystemTest harness cannot be geneated with ' ...
            'data generated from sldvlogsignals or slvnvlogsignals.']);
    end
    
    if ~isempty(errStr)
        return;
    end
    
    sldvData = Sldv.DataUtils.convertToCurrentFormat(modelH, sldvData);        
    
    [sldvData, errStr] = ...
        Sldv.DataUtils.convertLoggedSldvDataToHarnessDataFormat(sldvData);
    if ~isempty(errStr)
        return;
    end
            
    simData = Sldv.DataUtils.getSimData(sldvData);
    if(isempty(simData))
        errStr = 'Data does not contain any test cases nor counterexamples';
    end        
end
% LocalWords:  sldv