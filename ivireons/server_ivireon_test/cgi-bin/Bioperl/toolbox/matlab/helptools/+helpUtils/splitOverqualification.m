function [overqualifiedPath, actualName] = splitOverqualification(correctName, inputName, whichName)
    inputParts = splitPath(inputName);
    correctParts = splitPath(correctName);
    splitCount = length(correctParts);
    overqualifiedPath = joinPath(whichName, inputParts(1:end-splitCount));
    if ~isempty(overqualifiedPath) && overqualifiedPath(end) ~= '/'
        overqualifiedPath(end+1) = '/';
    end
    if nargout > 1
        actualName = joinPath(correctName, inputParts(end-splitCount+1:end));
    end
end

function parts = splitPath(name)
    parts = regexp(name, '([\\/.]|^)[@+]?', 'split');
    parts(cellfun(@isempty, parts)) = [];
end

function path = joinPath(fullPath, pathParts)
    path = sprintf('%s/', pathParts{:});
    path = helpUtils.extractCaseCorrectedName(fullPath, path);
end
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2009/07/06 20:37:29 $
