function helpStr = callHelpFunction(helpFunction, fullPath)
    langDirs = {builtin('_lookInSubdirectory'), 'en', ''};
    if strcmp(langDirs{1}, 'en')
        langDirs(1) = [];
    end
    
    [filePath, fileName, fileExt] = fileparts(fullPath);
    fileName = [fileName, fileExt];
    
    helpStr = '';
    for i = 1:length(langDirs)
        langPath = fullfile(filePath, langDirs{i}, fileName);
        if exist(langPath, 'file')
            helpStr = getHelpTextFromFile(helpFunction, langPath);
            if ~isempty(helpStr)
                return;
            end
        end
    end
end

function helpStr = getHelpTextFromFile(helpFunction, helpFile)
    try
        helpStr = feval(helpFunction, helpFile);
        if ~ischar(helpStr)
            helpStr = '';
        end
    catch e  %#ok<NASGU>
		helpStr = '';
    end
end
    