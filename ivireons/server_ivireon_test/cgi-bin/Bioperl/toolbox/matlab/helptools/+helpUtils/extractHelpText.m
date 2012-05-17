function extractHelpText(inputFullPath, outputDir)
    [~, fileName] = fileparts(inputFullPath);

    if ~exist(inputFullPath, 'file')
        error('MATLAB:extractHelpText:FileNotFound','Input file does not exist');
    end

    outputFile = fullfile(outputDir, [fileName '.m']);
    if isequal(outputFile, inputFullPath)
        error('MATLAB:helpUtils:extractHelpText:SameFile', 'Output file and input file can not be the same');
    end

    if exist(outputFile, 'file')
        s = warning('off', 'MATLAB:DELETE:Permission');
        cleanup = onCleanup(@()warning(s));
        delete(outputFile);
        if exist(outputFile, 'file')
            error('MATLAB:helpUtils:extractHelpText:CannotDeleteFile', 'Previous version of output file exists and can not be overwritten');            
        end
    end

    helpContainer = helpUtils.containers.HelpContainerFactory.create(inputFullPath, 'onlyLocalHelp', true);
    helpContainer.exportToMFile(outputDir);
end

