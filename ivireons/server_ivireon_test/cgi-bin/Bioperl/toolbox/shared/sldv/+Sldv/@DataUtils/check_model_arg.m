function errStr = check_model_arg(model, utility)

    errStr = '';
    
    if isempty(model)
        model = gcs;
        if isempty(model)
            errStr = 'Invalid BLOCK or MODEL specified.';
        else
            model = bdroot(model);
        end
    end
    
    if ~isempty(errStr)
        return;
    end
    
    if ischar(model)
        try
            modelH = get_param(model,'Handle');
        catch Mex
            errStr = Mex.message;
        end
    else
        if ishandle(model)
            modelH = model;
        else
            errStr = 'Invalid object';
        end
    end
    
    if ~isempty(errStr)
        return;
    end
    
    modelObj = get_param(modelH,'Object');
    if ~modelObj.isa('Simulink.BlockDiagram') || strcmp(modelObj.BlockDiagramType, 'library'),
        errStr = sprintf('%s can only be invoked on Block Diagrams',utility);            
        return;
    end    
    
end