function [fname, shouldLink, qualifyingPath, fullPath, hasLocalFunction] = fixLocalFunctionCase(fname, helpPath, justChecking)
    hasLocalFunction = false;
    shouldLink = false;
    qualifyingPath = '';
    fullPath = '';
    if ~isempty(regexp(fname, '\w>\w', 'once'))
        hasLocalFunction = true;
        split = regexp(fname, filemarker, 'split', 'once');
        [fileName, qualifyingPath, fullPath, hasMFileForHelp] = helpUtils.fixFileNameCase(split{1}, helpPath);
        if hasMFileForHelp
            if helpUtils.isClassMFile(fullPath)
                fname = [fileName, filesep, split{2}];
                hasLocalFunction = false;
            else
                try
                    % Note: -subfun is an undocumented and unsupported feature
                    localFunctions = which('-subfun', fileName);
                    localFunctionIndex = strcmpi(localFunctions, split{2});
                    if any(localFunctionIndex)
                        shouldLink = true;
                        if justChecking
                            fname = [fileName, filemarker, localFunctions{localFunctionIndex}];
                        else
                            fname = regexprep(fullPath, '\.[mp]$', [filemarker, localFunctions{localFunctionIndex}]);
                        end
                    end
                catch e %#ok<NASGU>
                    % error parsing fileName
                end
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/18 20:48:50 $
