function minimalPath = minimizePath(qualifyingPath, isDir)
    minimalPath = '';
    pathParts = regexp(qualifyingPath, '^(?<qualifyingPath>[^@+]*)(?(qualifyingPath)[\\/])(?<pathItem>[^\\/]*)(?<pathTail>.*)', 'names', 'once');
    qualifyingPath = pathParts.qualifyingPath;
    pathItem = pathParts.pathItem;
    pathTail = pathParts.pathTail;
    if isDir
        firstPath = @(q,p)whatPath(q,p);
    else
        firstPath = @(q,p)which(fullfile(q,p,pathTail));
    end
    expectedPath = firstPath(qualifyingPath, pathItem);
    while ~strcmp(expectedPath, firstPath(minimalPath, pathItem))
        [qualifyingPath, pop] = fileparts(qualifyingPath);
        if isempty(pop)
            minimalPath = fullfile(qualifyingPath, minimalPath, pathItem, pathTail);
            return;
        end
        minimalPath = fullfile(pop, minimalPath);
    end
    minimalPath = fullfile(minimalPath, pathItem, pathTail);

%% ------------------------------------------------------------------------
function path = whatPath(qualifyingPath, pathItem)
    dirInfo = helpUtils.hashedDirInfo(fullfile(qualifyingPath, pathItem));
    if isempty(dirInfo)
        path = '';
    else
        path = dirInfo(1).path;
    end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2008/11/04 21:20:30 $
