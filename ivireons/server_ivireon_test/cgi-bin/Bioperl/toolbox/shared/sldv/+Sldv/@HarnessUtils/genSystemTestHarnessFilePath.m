function systemTestFilePath = genSystemTestHarnessFilePath(modelH,opts, mode)

%   Copyright 2009-2010 The MathWorks, Inc.

    SystemTestFileName = get(opts,'SystemTestFileName');
    MakeOutputFilesUnique = get(opts,'MakeOutputFilesUnique');

    if(strcmp(mode, 'SLVNV'))
        dialogTitle = 'Simulink Verification and Validation';
        opts.outputDir = regexprep(opts.outputDir, 'sldv_output\/', 'slvnv_output\/');
    else
        dialogTitle = 'Simulink Design Verifier';
    end
  
    systemTestFilePath = Sldv.utils.settingsFilename(SystemTestFileName,MakeOutputFilesUnique,...
                    '.test', modelH, false, true, opts, dialogTitle);
    if isempty(systemTestFilePath)
        error([mode 'HarnessUtils:GenSystemTestHarnessFilePath:NoFilePath'], ...
            'Unable to generate the file path for SystemTest test file');
    end  
end
% LocalWords:  SLDV
