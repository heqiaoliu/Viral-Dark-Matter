
%   Copyright 2008 The MathWorks, Inc.

function checkUsupportedBlocks(modelH, settingStr)
try
    
    if any(settingStr == 'w')
        coveragePath = get_param(modelH,'CovPath');
        rootFullPath =  get_param(modelH,'name');
        if ~isempty(coveragePath)
            coveragePath = coveragePath(2:end); % Remove the initial '/'
            if ~isempty(coveragePath)
                rootFullPath = [rootFullPath '/' coveragePath];
            end
        end
        cvmissingblks(rootFullPath);
    end

catch MEx
    rethrow(MEx);
end
