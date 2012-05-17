function sldvData = generateDataFromMdl(model,usedSignalsOnly,forMdlRefHarness)

%   Copyright 2009-2010 The MathWorks, Inc.

    if nargin<3
        forMdlRefHarness = false;
    end

    if nargin<2
        usedSignalsOnly = false;
    end

    if ischar(model)
        try
            modelH = get_param(model,'Handle');
        catch myException  %#ok<NASGU>
            modelH = [];
        end
    else
        modelH = model;
    end
    
    sldvData = [];
    
    if usedSignalsOnly && ...
            license('test','Simulink_Design_Verifier') && ...
            exist('slavteng','file')==3 && ...
            exist('sldvprivate', 'file')==2 && ...
            logical(slavteng('feature','UnusedInputs'))  
        
        origDirtyFlag = get_param(modelH, 'Dirty');         
        origConfigSet = getActiveConfigSet(modelH);
        Sldv.utils.removeConfigSetRef(modelH);
        
        set_param(modelH, 'Dirty', 'off');
        modelName = get_param(modelH,'Name');
        
        optsModel = sldvdefaultoptions(modelH);
        opts = optsModel.deepCopy;                
                
        if forMdlRefHarness
            opts.ModelReferenceHarness = 'on';
        end
        logstr = sprintf('Detecting unused root level input signals of model ''%s''... ',modelName);
        disp(logstr);
        compatmsg = [];
        try                                 
            [~,status,compatmsg,sldvData] = ...
                evalc('sldvprivate(''sldvCompatibility'',modelName,[],opts,false,[])');
        catch Mex %#ok<NASGU>
            sldvData = [];
            status = false;
        end
        if ~status            
            msg = isRateTrasRelatedErrorMsg(compatmsg);
            if ~isempty(msg)
                error('SLDV:SldvDataUtils:NotCompatiblewithDV',...
                    'Unable to generate a harness model that includes %s in a Model block. %s',...
                    modelName, msg);  
            else                
                error('SLDV:SldvDataUtils:NotCompatiblewithDV',...
                    ['Unable to detect unused root level input signals ',...
                    'because model ''%s'' is not compatible with ',...
                    'Simulink Design Verifier. Please either resolve ',...
                    'incompatibilities or invoke harness generating by ',...
                    'setting ''usedSignalsOnly'' option to false.'], modelName);                                                            
            end
        else
            logstr = sprintf('Detected unused signals successfully.');
            disp(logstr);
        end
        
        Sldv.utils.restoreConfigSet(modelH, origConfigSet);  
        set_param(modelH, 'Dirty', origDirtyFlag); 
    end
    
    if isempty(sldvData)
        % Generate sldvData without translating the model
        %Create Model Information
        ModelInformation.Name = get_param(modelH, 'Name');
        ModelInformation.Version = get_param(modelH,'ModelVersion');
        ModelInformation.Author = get_param(modelH,'Creator'); 
        
        parameterSettings.('StrictBusMsg') = ...
            struct('newvalue','ErrorLevel1','originalvalue','');
        if forMdlRefHarness
            parameterSettings.('MultiTaskRateTransMsg') = ...
                struct('newvalue','error','originalvalue','');
        end

        [InputPortInfo, OutputPortInfo, flatInfo] = Sldv.DataUtils.generateIOportInfo(model, parameterSettings);    
        sldvOptions = feval('sldvdefaultoptions', get_param(model, 'Name'));

        AnalysisInformation.Status = [];
        AnalysisInformation.AnalysisTime = 0;
        AnalysisInformation.Options = sldvOptions;
        AnalysisInformation.InputPortInfo = InputPortInfo;
        AnalysisInformation.OutputPortInfo = OutputPortInfo; 

        AnalysisInformation.SampleTimes = flatInfo.SampleTimes;

        % Putting it all together    
        sldvData.ModelInformation = ModelInformation;
        sldvData.AnalysisInformation = AnalysisInformation;
        sldvData.Constraints = [];
        sldvData.ModelObjects = [];
        sldvData.Objectives = [];    

        % Put empty test case.
        defaultTestCase = Sldv.DataUtils.createDefaultTC(flatInfo.InportCompInfo);
        sldvData = Sldv.DataUtils.setSimData(sldvData,[],defaultTestCase);        
        sldvData = Sldv.DataUtils.compressSldvData(sldvData);        
        
        % Version is empty because DV might not be installed
        sldvData.Version = '';
    end
end

function msg = isRateTrasRelatedErrorMsg(compatmsg)
    msg = '';
    if ~isempty(compatmsg)
        index = strcmp({compatmsg.msgid},'Simulink:SampleTime:IllegalIPortRateTrans');        
        if ~isempty(index)
            compatmsg = compatmsg(index);
            msg = compatmsg(1).msg; 
        end
    end
end