function auxInfoAddToBuildInfo(h, modelName, ~)

%   Copyright 1995-2010 The MathWorks, Inc.

%-------------------------------------------------------------------------%
% Add auxiliary information into buildInfo
%-------------------------------------------------------------------------%

infoStruct = infomatman('load', 'binary', modelName, modelName, 'rtw');
if isfield(infoStruct, 'chartInfo') && isfield(infoStruct.chartInfo, 'auxBuildInfo')
    auxBuildInfos = [infoStruct.chartInfo(:).auxBuildInfo];
    for bi=1:numel(auxBuildInfos)
        auxBuildInfo = auxBuildInfos(bi);
        locAddAuxUsageInfoToBuildInfo(h, auxBuildInfo);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locAddAuxUsageInfoToBuildInfo(h, auxBuildInfo)

% Add aux source files to the BuildInfo.
if ~isempty(auxBuildInfo.sourceFiles)
    fileNames = {auxBuildInfo.sourceFiles(:).FileName};
    filePaths = {auxBuildInfo.sourceFiles(:).FilePath};
    fileGroups= {auxBuildInfo.sourceFiles(:).Group};
    h.BuildInfo.addSourceFiles(fileNames, filePaths, fileGroups);
    h.BuildInfo.addSourcePaths(filePaths, fileGroups);
end

% Add aux non-build files to the BuildInfo.
if ~isempty(auxBuildInfo.nonBuildFiles)
    fileNames = {auxBuildInfo.nonBuildFiles(:).FileName};
    filePaths = {auxBuildInfo.nonBuildFiles(:).FilePath};
    fileGroups= {auxBuildInfo.nonBuildFiles(:).Group};
    h.BuildInfo.addNonBuildFiles(fileNames, filePaths, fileGroups);
end

% Add aux link objects to the BuildInfo.
if ~isempty(auxBuildInfo.linkObjects)
    fileNames = {auxBuildInfo.linkObjects(:).FileName};
    filePaths = {auxBuildInfo.linkObjects(:).FilePath};
    fileGroups= {auxBuildInfo.linkObjects(:).Group};
    priority = repmat(1000,1,numel(fileNames));
    precompiled = true(1,numel(fileNames));
    linkonly = true(1,numel(fileNames));
    h.BuildInfo.addLinkObjects(fileNames, filePaths, priority, precompiled, ...
        linkonly, fileGroups);
    h.BuildInfo.addIncludePaths(filePaths, fileGroups);
end

% Add aux include files to the BuildInfo.
if ~isempty(auxBuildInfo.includeFiles)
    fileNames = {auxBuildInfo.includeFiles(:).FileName};
    filePaths = {auxBuildInfo.includeFiles(:).FilePath};
    fileGroups= {auxBuildInfo.includeFiles(:).Group};
    h.BuildInfo.addIncludeFiles(fileNames, filePaths, fileGroups);
    h.BuildInfo.addIncludePaths(filePaths, fileGroups);
end

% Add aux include paths to the BuildInfo.
if ~isempty(auxBuildInfo.includePaths)
    filePaths = {auxBuildInfo.includePaths(:).FilePath};
    fileGroups= {auxBuildInfo.includePaths(:).Group};
    h.BuildInfo.addIncludePaths(filePaths, fileGroups);
end

% Add aux link flags to the BuildInfo.
% The BuildInfo.addLinkFlags methods doesn't uniquify flags, so we
% do it ourselves.
if ~isempty(auxBuildInfo.linkFlags)
    for i=1:numel(auxBuildInfo.linkFlags)
        lf = auxBuildInfo.linkFlags(i);
        oldLinkFlags = h.BuildInfo.getLinkFlags(lf.Group);
        indices = strfind(oldLinkFlags,lf.Flags);
        if ~any([indices{:}])
            h.BuildInfo.addLinkFlags(lf.Flags, lf.Group);
        end
    end
end

