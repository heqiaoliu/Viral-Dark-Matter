function harnessFilePath = genHarnessModelFilePath(modelH,opts,mode)

%   Copyright 2009-2010 The MathWorks, Inc.

    HarnessModelFileName = get(opts,'HarnessModelFileName');
    MakeOutputFilesUnique = get(opts,'MakeOutputFilesUnique');

    if(strcmp(mode, 'SLVNV'))
        dialogTitle = 'Simulink Verification and Validation';
        opts.outputDir = regexprep(opts.outputDir, 'sldv_output\/', 'slvnv_output\/');
    else
        dialogTitle = 'Simulink Design Verifier';
    end
    
    harnessFilePath = Sldv.utils.settingsFilename(HarnessModelFileName,MakeOutputFilesUnique,...
                    '.mdl', modelH, false, true, opts, dialogTitle);
    if isempty(harnessFilePath)
        error([mode ':HarnessUtils:GenHarnessModelFilePath:NoFilePath'], ...
                'Unable to generate the path for harness model');
    end

    [~, harnessmodel] = fileparts(harnessFilePath);
    harnessmodel  = sldvshareprivate('cmd_check_for_open_models', harnessmodel, MakeOutputFilesUnique, false);
    if isempty(harnessmodel)
        error([mode ':HarnessUtils:GenHarnessModelFilePath:ModeOpen'], ...
                'Unable to generate the harness model');
    end           
end
% LocalWords:  SLDV
