function out = parameters(method, modelH, varargin)

%   Copyright 2006-2010 The MathWorks, Inc.

    switch (lower(method))
        case 'hasparameters'
            [~, params] = getParamsFromTestComponent(modelH); 
            if isempty(params)
                out = false;
            else
                out = true;
            end

        case 'isvalid'
            [out, params] = getParamsFromTestComponent(modelH); %#ok;

        case 'list'
            [status, params] = getParamsFromTestComponent(modelH);
            if status
                if isempty(params)
                    out = {};
                else
                    out = fieldnames(params);
                end
            else
                out = [];
            end

        case 'getall'
            [~, params] = getParamsFromTestComponent(modelH);
            out = params;

        case 'addparamstoharness'            
            status = addParamstoWorkspace(modelH,  varargin{1}, varargin{2});
            out = status;

        case 'init'
            modelName = gcs;
            modelH = get_param(modelName, 'Handle');
            out = instantiateParams(modelH,  varargin{1});                 

        otherwise
            error('SLDV:Parameters:UnknownMethod', 'Unknown method');
    end
end

function [status, params] = getParamsFromTestComponent(modelH)
    status = false;
    params = [];

    testComp = Sldv.Token.get.getTestComponent;

    if ~isempty(testComp)
        if ~isempty(testComp.parameterSettings)
            params = testComp.parameterSettings;
            status = true;
        else
            options = testComp.activeSettings;
            if isequal(options.Parameters,'on'),
                try
                    params = evalParams(options.ParametersConfigFileName, modelH);
                    testComp.parameterSettings = params;
                    status = true;
                catch Mex
                    errmsg = filterEvalParamsEror(Mex,options.ParametersConfigFileName);

                    % We should only reach this line if full sldv is installed and licensed
                    sldv_error_push(modelH, errmsg,  'SLDV:Compatibility:Parameters');
                end
            end
        end
    else
        % empty test component, return false.
    end
end

%--------------------------------------------------------------------------

function evaluated_params = evalParams(fileParams, modelH)

    sldv_params = evalFileParams(fileParams);

    if ~isstruct(sldv_params)
        evaluated_params = {};
        return;
    end

    evaluated_params = sldv_params;
    fields = fieldnames(sldv_params);
    hws = get_param(modelH, 'modelworkspace');
    
    for i=1:length(fields) % iterates over all parameters    
        isDeclInBaseWork = evalin('base', [ 'exist(''' fields{i} ''', ''var'');' ]);
        if ~isDeclInBaseWork
            error('SLDV:Parameters:CheckParamInBase',...
                  ['Parameter %s must be defined in the base workspace '...
                   'in order to be treated as input variable in its analysis'],fields{i});
        end
        isDeclInModelWork = evalin(hws, [ 'exist(''' fields{i} ''', ''var'');' ]);
        if isDeclInModelWork
            error('SLDV:Parameters:CheckParamInModelWorkSpace',...
                  ['Parameter %s must be only defined in the base workspace '...
                   'in order to be treated as input variable in its analysis. '...
                   'Parameter %s is currently defined in model and base workspace.'],fields{i},fields{i});
        end
        for j=1:length(sldv_params)
            % Let's first check that we can support this parameter
            currentVal = evalin('base', fields{i});
            if isa(currentVal, 'Simulink.Parameter')
                currentVal = currentVal.Value;
            end
            if ~(isnumeric(currentVal) || islogical(currentVal))
                error('SLDV:Parameters:Unsupported', ...
                      ['Parameter %s is not of a numeric or logical type. '...
                       'Only numeric and logical parameters can be treated as ' ...
                       'input during analysis.'], fields{i});
            end
            [spec, errMsg] = checkSldvSpecification(sldv_params(j).(fields{i}));
            if isempty(errMsg)
                evaluated_params(j).(fields{i}) = spec;
            else
                error('SLDV:Parameters:CheckSpecification',errMsg);
            end
        end
    end
end

%--------------------------------------------------------------------------

function sldv_params = evalFileParams(file)
% This should define a variable 'params', that is a struct
% containing the parameters specification
    
    currPath = path;
    
    [ dir, name ]  = fileparts(file);
    if ~isempty(dir)
        addpath(dir);
    end
    
    params = feval(name);
    
    path(currPath);

    if isempty(params)
        sldv_params = {};
    else
        sldv_params = params;
    end
end

%--------------------------------------------------------------------------

function status = addParamstoWorkspace(modelH, sldvData, mdlRefHarn)
    status = true;

    if isempty(sldvData)
        status = false;
        return;
    end

    SimData = Sldv.DataUtils.getSimData(sldvData);
    for i=1:length(SimData),
        testcase(i).parameters = getfield(SimData(i),'paramValues'); %#ok
    end     
    hws = get_param(modelH, 'modelworkspace');    
    hws.assignin('SldvTestCaseParameterValues',testcase);

    setInitFcn(modelH,mdlRefHarn);    
end

%--------------------------------------------------------------------------

function  setInitFcn(modelH,mdlRefHarn)

    startFcnStr = sprintf('sldvshareprivate(''parameters'',''init'',[],%s);',num2str(mdlRefHarn));
    set_param(modelH,'InitFcn',startFcnStr);
end

%--------------------------------------------------------------------------

function status = instantiateParams(modelH,mdlRefHarn)
    status = true;
    hws = get_param(modelH, 'modelworkspace');

    try
        testcase = hws.evalin('SldvTestCaseParameterValues');
    catch Mex  %#ok<NASGU>
        testcase = [];
    end     

    sigbH = sigbuild_handle(modelH);

    if ~isempty(testcase) && ishandle(sigbH),
        testCaseIndex = signalbuilder(sigbH,'ActiveGroup');
        SldvParameters = testcase(testCaseIndex).parameters;
        for i=1:length(SldvParameters)
            if mdlRefHarn
                assignin('base',SldvParameters(i).name, SldvParameters(i).value);
            else
                hws.assignin(SldvParameters(i).name, SldvParameters(i).value);
            end
        end
    else
        status = false;
    end
end

%--------------------------------------------------------------------------

function sigbH = sigbuild_handle(modelH)

    sigbH = find_system(modelH, ...
        'SearchDepth',        1, ...
        'LoadFullyIfNeeded', 'off', ...
        'FollowLinks',       'off', ...
        'LookUnderMasks',    'all', ...
        'BlockType',         'SubSystem', ...
        'PreSaveFcn',        'sigbuilder_block(''preSave'');');

end

%--------------------------------------------------------------------------

function errmsg = filterEvalParamsEror(errStruct, parametersConfigFileName)
    
    coreMsg = sprintf('Error detected in the parameters configuration file ''%s'' ',parametersConfigFileName);

    message = errStruct.message;    
    location = strfind(message,xlate('Error using ==>')); 
    if ~isempty(location)
        index_cr = strfind(message,10);
        if ~isempty(index_cr)
            message = message(index_cr(1)+1:length(message));
        end
    end          
    if ~isempty(strfind(message, 'Error: <a href="error:'))
        message = regexprep(message, 'Error: <a href="error:[^"]*">([^<]*)</a>', '$1');
    end
    
    stackNames = {errStruct.stack.name};
    relaventStack = errStruct.stack(strcmp(stackNames,strrep(parametersConfigFileName,'.m','')));
    if ~isempty(relaventStack)
        lineStr = [' (line ' num2str(relaventStack(1).line) ') : '];
    else
        lineStr = '';
    end
    
    % it must be the first one    
    errmsg = [coreMsg  lineStr char(10) message];        
end    
