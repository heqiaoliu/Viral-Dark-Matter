function  createCopyCGVModel(obj)

%   Copyright 2010 The MathWorks, Inc.
    [~, mdlBlks] = find_mdlrefs(obj.Model, false);
    if ~isempty(mdlBlks) 
        msg = xlate(['Unable to copy model ''%s'' because it ',...
            'includes Model blocks referencing other models.']);  
        msgId = 'UnabletoCreateCopyModelBecauseModelRef';
        obj.handleMsg('error', msgId, msg, obj.Model);   
    end

    opts = sldvdefaultoptions;       
    opts.OutputDir = obj.OutputDir;
    
    msg = xlate(['In order to use Code Generation Verification (CGV) API ' ...
                'model ''%s'' must be copied. Unable to copy the model.']);  
    msgId = 'UnabletoCreateCopyModelForCGV';
    
    FilePathCGVConfiguredModel = '$ModelName$_cgv';
    MakeOutputFilesUnique = get(opts,'MakeOutputFilesUnique');
    
    if strcmp(obj.UtilityName,'sldvruncgvtest')
        dialogTitle = 'Simulink Design Verifier';
    else
        dialogTitle = 'Simulink Verification and Validation';
    end

    fullPath = Sldv.utils.settingsFilename(...
        FilePathCGVConfiguredModel,...
        MakeOutputFilesUnique,...
        '.mdl', obj.Model, false, true, opts, dialogTitle);
    
    if isempty(fullPath)                                                                   
        obj.handleMsg('error', msgId, msg, obj.Model);          
    end
    
    [copymodeldir, copymodel] = fileparts(fullPath); 
    copymodel  = sldvshareprivate('cmd_check_for_open_models', copymodel, MakeOutputFilesUnique, false);
    if isempty(copymodel)
        obj.handleMsg('error', msgId, msg, obj.Model);        
    end
    
    copymodelFullPath = fullPath;
    
    originalmdlfileName = which(obj.Model); 
    copyfile(originalmdlfileName,copymodelFullPath);
    
    status = fileattrib(copymodelFullPath,'+w');        
    if ~status                
        obj.handleMsg('error', msgId, msg, obj.Model);        
    end
    
    try
        load_system(copymodelFullPath);
    catch Mex
        msg = xlate([msg ' %s']);                
        obj.handleMsg('error', msgId, msg, obj.Model, Mex.message);         
    end       
    
    obj.CGVModelH = get_param(copymodel,'Handle'); 
    obj.CGVModel = get_param(copymodel,'Name'); 
    obj.CGVModelPath = copymodelFullPath;    
    obj.CGVFullOutputDir = copymodeldir;
    
    % Check whether the copy model compiles
    addpath(copymodeldir);
    try
        evalc('feval(copymodel,[],[],[],''compileForSizes'');');        
        evalc('feval(copymodel,[],[],[],''term'');'); 
    catch Mex
        rmpath(copymodeldir);
        msg = xlate([msg ' %s']);                
        obj.handleMsg('error', msgId, msg, obj.Model, Mex.message);  
    end        
    rmpath(copymodeldir);        
end

% LocalWords:  CGV Unableto cgv Beause copymodel
