function [destModelH, errStr] = copyModel(destName, srcModelH)
%copyModel - Create a copy of a model in a new file

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/05 22:41:34 $


    destModelH = [];
    errStr = '';
    
    opts = sldvoptions;
    opts.OutputDir = '.';
    MakeOutputFilesUnique = 'off';
    
    destModelFullPath = Sldv.utils.settingsFilename(destName, MakeOutputFilesUnique, ...
        '.mdl', srcModelH, false, true, opts);                
    if isempty(destModelFullPath)
        errStr = sprintf('The model ''%s'' cannot be generated.',destName);
        return;
    end
        
    [~, destmodel] = fileparts(destModelFullPath); 
    destmodel  = sldvshareprivate('cmd_check_for_open_models', destmodel, MakeOutputFilesUnique, false);
    if isempty(destmodel)
        errStr = sprintf('The model ''%s'' cannot be generated.',destName);
        return;
    end
    
    modelToCopyloc = get_param(srcModelH,'location');
    modelToCopyfileName = get_param(srcModelH,'filename'); 
    copyfile(modelToCopyfileName,destModelFullPath);
    
    status = fileattrib(destModelFullPath,'+w');        
    if ~status
        delete(destModelFullPath);
        errStr = sprintf('The model ''%s'' cannot be generated.',destName);
        return;
    end
    
    try
        load_system(destModelFullPath);
    catch Mex
         delete(destModelFullPath);
         errStr = Mex.message;         
    end
    
    if ~isempty(errStr)
        return;
    end
    
    destModelH = get_param(destmodel,'Handle');
    
    set_param(destModelH, 'location', [modelToCopyloc(1),(modelToCopyloc(2)+modelToCopyloc(4))/2,...
        modelToCopyloc(3),modelToCopyloc(4)+(modelToCopyloc(4)-modelToCopyloc(2))/2]);   
end
