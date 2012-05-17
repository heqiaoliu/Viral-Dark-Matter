function [modelH, errstr] = loadIfNeeded(model)    
%Sldv.loadIfNeeded - Load a model and return its handle

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:06:17 $

    errstr = '';
    if ischar(model)
        [~, baseModel] = fileparts(model);
        modelH = model_handle(baseModel);
        if isempty(modelH)
            load_system(model)
            modelH = model_handle(baseModel);
            if isempty(modelH)
                errstr = ['Could not resolve model ' model];
            end
        end
    elseif isa(model,'Simulink.BlockDiagram')
        modelH = model.Handle;
    else
        errstr = 'Unexpected model reference';
    end    
end


function modelH = model_handle(modelName)
    try
        modelH = get_param(modelName,'Handle');
    catch Mex %#ok<NASGU>
        modelH = [];
    end
end


