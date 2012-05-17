function [fileName, qualifyingPath, fullPath, hasMFileForHelp, alternateHelpFunction] = fixFileNameCase(fname, helpPath, whichTopic)
    fileName = fname;
    qualifyingPath = '';
    hasMFileForHelp = false;
    alternateHelpFunction = '';
    if nargin > 2 && ischar(whichTopic)
        fullPath = whichTopic;
        fname = regexprep(fname, '\.p$', '');
    else
        fullPath = helpUtils.safeWhich(fname);
    end
    if isempty(fullPath)
        return;
    end
    if ~isempty(helpPath)
        helpPath = [filesep helpPath filesep];
        if isempty(strfind(fullPath, helpPath))
            [~, name] = fileparts(fname);
            allPaths = which('-all',fname);
            for entry=1:length(allPaths)
                pathEntry = allPaths{entry};
                [~, entryName] = fileparts(pathEntry);
                if strcmpi(name, entryName)
                    startPos = strfind(pathEntry, helpPath);
                    if ~isempty(startPos)
                        qualifyingPath = fileparts(helpUtils.minimizePath(pathEntry(startPos(1)+1:end), false));
                        fullPath = pathEntry;
                        break;
                    end
                end
            end
        end
    end
    fileName = helpUtils.extractCaseCorrectedName(fullPath, fname);
    [~, ~, targetExtension] = fileparts(fullPath);
    hasMFileForHelp = ~isempty(regexpi(targetExtension, '^\.[mp]$', 'once'));
    if nargout > 4 && ~hasMFileForHelp
        alternateHelpFunction = helpUtils.getHelpFunction(targetExtension);
        if isempty(alternateHelpFunction)
            fullPath = '';
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/03/30 23:40:22 $
