function auxInfoCopyToBuildDir(auxBuildInfo, targetDirName)

%   Copyright 1995-2008 The MathWorks, Inc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy auxiliary buildinfo files to the build directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(auxBuildInfo) || ~isstruct(auxBuildInfo)
    return;
end
copyfilestobuild(auxBuildInfo.sourceFiles, targetDirName);
copyfilestobuild(auxBuildInfo.includeFiles, targetDirName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copy a set of auxiliary files to the build directory
function copyfilestobuild(auxBuildFiles, targetDirName)
for i = 1:numel(auxBuildFiles)
    auxBuildFile = auxBuildFiles(i);
    if ~isempty(auxBuildFile.FilePath)
        source = fullfile(auxBuildFile.FilePath, auxBuildFile.FileName);
        [status,msg,msgid] = copyfile(source,targetDirName,'f'); %#ok<NASGU>
    end
end

