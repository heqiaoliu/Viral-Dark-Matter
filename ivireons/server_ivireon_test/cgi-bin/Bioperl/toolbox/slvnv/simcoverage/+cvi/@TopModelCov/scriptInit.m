
%   Copyright 2008 The MathWorks, Inc.

function cvScriptId = scriptInit(scriptId, scriptNum, chartId)


try
    cvScriptId  = 0;
    
    modelH = get_param(bdroot(sf('Private', 'chart2block',chartId)), 'handle');
    coveng = cvi.TopModelCov.getInstance(modelH);
    %model handle migth be a library model, try to find the actual topModelCov 
    if isempty(coveng)
        topModelcovId = cv('find','all','~modelcov.topModelcovId',0);
        coveng = cv('get', topModelcovId(1), '.topModelCov');
        modelH = cv('get', topModelcovId(1), '.handle');
    end
    allModelcovIds  = coveng.getAllModelcovIds;
    aCallingModelcovId = allModelcovIds(1);
    actTestId = cv('get',aCallingModelcovId,'.activeTest');    
    %compileForCoverage can give zero testId !
    compileForCoverage = (actTestId == 0);
    if ~compileForCoverage && ~cv('get', actTestId, '.covExternalEMLEnable')
        return;
    end

    scriptName = sf('get',scriptId,'.name');
    scriptName =  scriptName(1:end-2); % cut .m
    machineIdStr =  ['m' num2str(sf('get',chartId,'.machine'))];

    if isfield(coveng.scriptDataMap, scriptName)
        cvScriptId = coveng.scriptDataMap.(scriptName).cvScriptId;
        coveng.scriptNumToCvIdMap.(machineIdStr)(scriptNum+1) = cvScriptId;
        coveng.scriptDataMap.(scriptName).machineIdStrs{end+1} = machineIdStr;
        return;
    end
    
    modelcovId  = cv('find','all','modelcov.name',scriptName );
    assert(numel(modelcovId) < 2);
    coveng.scriptDataMap.(scriptName).oldRootId = 0; 
    if isempty(modelcovId)
        modelcovId   = cv('new', 'modelcov' ...
                        ,'.name',		scriptName  ...
                        ,'.handle',		0 ...
                        ,'.isScript', 1 ...
                    );
    elseif ~compileForCoverage 
        ct = cv('get',modelcovId,'.currentTest');
        if ct ~= 0
            coveng.scriptDataMap.(scriptName).oldRootId = cv('get',ct,'.linkNode.parent');
        end
    end

    coveng.addScriptModelcovId(modelH, modelcovId);

    if ~compileForCoverage  
        % Create the testdata object

        % Create the testdata object
        newTestId = cv('new', 	'testdata'  					    ...
                ,'.type',				    'DLGENABLED_TST' 	...
                ,'.modelcov',				modelcovId 		    ...
                );

        newTest = clone(cvtest(actTestId), cvtest(newTestId));
        activate(newTest, modelcovId);            
    end
    
    newRootId = cv('new','root', '.modelcov', modelcovId);

    cv('set',modelcovId, '.activeRoot', newRootId);

    cvScriptId = cv('new','slsfobj',1, ...
                    '.origin',          'SCRIPT_OBJ', ...
                    '.modelcov',        modelcovId, ...
                    '.handle',          scriptId,...
                    '.refClass',        scriptNum); %abuse it

    codeBlockId = cv('new','codeblock',	1,'.slsfobj', cvScriptId, ...
                            'codeblock.code',sf('get',scriptId,'.script'));

    
    cv('CodeBloc','refresh',codeBlockId);
    cv('set',cvScriptId,'.code',codeBlockId);
    cv('set',cvScriptId,'.name',scriptName );
    
    scriptsSubSysObj  = cv('new','slsfobj',     1, ...
                '.origin',          'SCRIPT_OBJ', ...
                '.name', scriptName , ... 
                '.modelcov',        modelcovId, ...
                '.handle', scriptId,...
                '.refClass',        0);
    cv('set', newRootId, '.topSlsf', scriptsSubSysObj);               
    cv('BlockAdoptChildren', scriptsSubSysObj, cvScriptId);           
    coveng.scriptDataMap.(scriptName).cvScriptId = cvScriptId;
    coveng.scriptDataMap.(scriptName).machineIdStrs{1} = machineIdStr; 
    coveng.scriptNumToCvIdMap.(machineIdStr)(scriptNum+1) = cvScriptId;
catch MEx
    rethrow(MEx);
end
