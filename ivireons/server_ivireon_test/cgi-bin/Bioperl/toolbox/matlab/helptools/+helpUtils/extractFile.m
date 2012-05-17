function [fileName, foundTarget] = extractFile(dirInfo, targetName)
    [fileName, foundTarget] = extractField(dirInfo, 'm', targetName);
    if ~foundTarget
        [fileName, foundTarget] = extractField(dirInfo, 'p', targetName);
    end
end

function [fileName, foundTarget] = extractField(dirInfo, field, targetName)
    fileIndex = strcmpi(dirInfo.(field), [targetName '.' field]);
    foundTarget = any(fileIndex);
    if foundTarget
        fileName = dirInfo.(field){fileIndex}(1:end-2);
    else
        fileName = '';
    end
end

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:40:20 $
