function auxInfo = auxInfoUnique(auxInfo)

%   Copyright 1995-2008 The MathWorks, Inc.

if ~isempty(auxInfo.sourceFiles)
    auxInfo.sourceFiles = unique(auxInfo.sourceFiles);
end
if ~isempty(auxInfo.linkObjects)
    auxInfo.linkObjects = unique(auxInfo.linkObjects);
end
if ~isempty(auxInfo.includeFiles)
    auxInfo.includeFiles = unique(auxInfo.includeFiles);
end
if ~isempty(auxInfo.includePaths)
    auxInfo.includePaths = unique(auxInfo.includePaths);
end
if ~isempty(auxInfo.linkFlags)
    auxInfo.linkFlags = unique(auxInfo.linkFlags);
end

% Strip empty include paths
npaths = numel(auxInfo.includePaths);
if npaths > 0 && isempty(auxInfo.includePaths{1})
    if npaths > 1
        auxInfo.includePaths = {auxInfo.includePaths{2:end}};
    else
        auxInfo.includePaths = [];
    end
end


