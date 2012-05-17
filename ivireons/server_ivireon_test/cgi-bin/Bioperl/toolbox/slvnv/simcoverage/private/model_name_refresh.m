function model_name_refresh
%MODEL_NAME_REFRESH - Update the coverage database to reflect model name changes.
%   Copyright 1990-2005 The MathWorks, Inc.

    cvModels = cv('get','all','modelcov.id');
    
    for modelId = cvModels(:)'
        [modelH, modelName] = cv('get',modelId,'.handle','.name');
        if (modelH ~= 0 && ishandle(modelH))
            try
                actName = get_param(modelH,'Name');
            catch Mex %#ok<NASGU>
                actName = '';
            end

            if (~isempty(actName) && ~strcmp(modelName,actName))
                cv('set',modelId,'.name',actName);
            end
        end
    end


    