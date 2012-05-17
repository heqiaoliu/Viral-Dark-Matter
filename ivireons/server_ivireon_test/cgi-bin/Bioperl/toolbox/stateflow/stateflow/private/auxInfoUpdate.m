function auxInfoSum = auxInfoUpdate(auxInfoSum, auxInfo)

%   Copyright 1995-2008 The MathWorks, Inc.

if ~isempty(auxInfo.sourceFiles)
    files = {auxInfo.sourceFiles(:).FileName};
    auxInfoSum.sourceFiles = [auxInfoSum.sourceFiles files];
    paths = {auxInfo.sourceFiles(:).FilePath};
    auxInfoSum.includePaths = [auxInfoSum.includePaths paths];
end
if ~isempty(auxInfo.linkObjects)
    lnkObjs = {};
    for lo = 1:numel(auxInfo.linkObjects)
        lnkObj = auxInfo.linkObjects(lo);
        lnkObjs{end+1} = fullfile(lnkObj.FilePath, lnkObj.FileName); %#ok<AGROW>
    end
    auxInfoSum.linkObjects = [auxInfoSum.linkObjects lnkObjs];
    paths = {auxInfo.linkObjects(:).FilePath};
    auxInfoSum.includePaths = [auxInfoSum.includePaths paths];
end
if ~isempty(auxInfo.includeFiles)
    files = {auxInfo.includeFiles(:).FileName};
    auxInfoSum.includeFiles = [auxInfoSum.includeFiles files];
    paths = {auxInfo.includeFiles(:).FilePath};
    auxInfoSum.includePaths = [auxInfoSum.includePaths paths];
end
if ~isempty(auxInfo.includePaths)
    paths = {auxInfo.includePaths(:).FilePath};
    auxInfoSum.includePaths = [auxInfoSum.includePaths paths];
end
if ~isempty(auxInfo.linkFlags)
    flags = {auxInfo.linkFlags(:).Flags};
    auxInfoSum.linkFlags = [auxInfoSum.linkFlags flags];
end

% Strip empty include paths
npaths = numel(auxInfoSum.includePaths);
if npaths > 0 && isempty(auxInfoSum.includePaths{1})
    if npaths > 1
        auxInfoSum.includePaths = {auxInfoSum.includePaths{2:end}};
    else
        auxInfoSum.includePaths = [];
    end
end
