function [testFile, warnmsg] = make_systemtest_harness(model, sldvDataFilePath, systemTestFilePath)

%   Copyright 2008-2010 The MathWorks, Inc.

    testFile = '';
    warnmsg = '';        
    
    if nargin<3
        systemTestFilePath = [];
    end

    if nargin<2
            error('SLDV:HarnessUtils:MakeSystemTestHarness:MissingParameters', ...
                'make_systemtest_harness needs at least two parameters');
    end
    
    modelH = get_param(model,'Handle');
    
    sldvData = load(sldvDataFilePath);
    dataFields = fields(sldvData);
    if length(dataFields)==1 
        sldvData = sldvData.(dataFields{1});
    end      
    
    if strcmp(sldvData.AnalysisInformation.Options.Mode,'PropertyProving')
        warnmsg =  [ char(10) ...
            'The capability of generating test harness as SystemTest TEST-file is disabled  '....
            'because Simulink Design Verifier is configured for Property proving. '...
            'You can use this capability for Test generation mode. ' char(10)];           
        return;
    end
    
    hasRootPorts = Sldv.HarnessUtils.has_root_level_input_ports(modelH);
    if ~hasRootPorts
        warnmsg =  [ char(10) ...
            'The capability of generating test harness as SystemTest TEST-file is disabled due to '....
            sprintf('non existing root level input ports on Model ''%s''. ', get_param(modelH,'Name'))...
            'You must have at least one root level input port on the model in order to '...
            'use this capability. ' char(10)];
        return;
    end     
    
    if Sldv.DataUtils.has_structTypes_interface(sldvData)
        warnmsg =  [ char(10) ...
            'The capability of generating test harness as SystemTest TEST-file is disabled because '....
            'model has Inport and Outports blocks having Simulink.StructType. ' char(10)];           
        return;        
    end
    
    if isempty(systemTestFilePath)
        opts = sldvData.AnalysisInformation.Options;
        systemTestFilePath = Sldv.HarnessUtils.genSystemTestHarnessFilePath(modelH,opts);
    end
    
    if exist('systemtest','file')
        status = true;
        try
            stgate('sldvCreateHarness',get_param(modelH,'Name'),...
                 sldvDataFilePath,systemTestFilePath);
        catch Mex
            status = false;
            warnmsg = Mex.message;
        end
        if status
            testFile = systemTestFilePath;
            systemtest(testFile); % launches SystemTest with testFile
        end
    end
end
% LocalWords:  SLDV Sytem sldv
