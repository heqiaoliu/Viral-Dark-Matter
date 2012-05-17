function [buildDir codeGenName] = targets_get_build_dir(fullSystemPath)
%TARGETS_GET_BUILD_DIR Get RTW build directory for a Simulink system path.
%
%   TARGETS_GET_BUILD_DIR(fullSystemPath) returns the RTW build directory for a
%   Simulink system path, if it exists.   Additionally, the base name used 
%   by RTW for generated source files can be returned.
%
%   Input arguments:
%
%   Name:       Description:
%
%   fullSystemPath  String containing the name of the Simulink system path to
%                   find a build directory for. This is either the name of a
%                   model or the full path to a subsystem.
%
%   Output arguments:
%
%   Name:       Description:
%
%   buildDir    String containing the full path to the RTW build directory
%               or empty if a build directory was not found.
% 
%   codeGenName String containing the base name used by RTW for generated 
%               source files.
%
%   Examples:
%
%      1.
%
%      [buildDir codeGenName] = targets_get_build_dir('rtwdemo_mrmtbb')
%
%      2.
%
%      [buildDir codeGenName] = targets_get_build_dir(['rtwdemo_fuelsys/fuel rate' ...
%                                                      sprintf('\n') ...
%                                                     'controller'])
%
%      3.
%
%      [buildDir codeGenName] = targets_get_build_dir('rtwdemo_fuelsys')
%

% Copyright 2007-2010 The MathWorks, Inc.

error(nargchk(1, 1, nargin, 'struct'));
if ~ischar(fullSystemPath)
  TargetCommon.ProductInfo.error('common', 'InputArgNInvalid', '"fullSystemPath"', 'string');
end

% split fullSystemPath into model and system path
[rootModel systemPath] = strtok(fullSystemPath, '/');

% use RTW.getBuildDir
buildDirInfo = RTW.getBuildDir(rootModel);

if isempty(systemPath)
    % rootModel    
    buildDir = buildDirInfo.BuildDirectory;
    [~, relCodeGenDir] = fileparts(buildDir);
    % remove build dir suffix
    codeGenName = strrep(relCodeGenDir, ...
        buildDirInfo.BuildDirSuffix, ...
        '');
else  
    % subsystem
    %
    % linear search relevant binfo.mat files for matching 
    % SourceSubsystemName!
    %
   
    buildDir = '';
    codeGenName = '';
    
    % get the list of all files in the appropriate slprj sub-dir
    rootBuildDir = buildDirInfo.CodeGenFolder;
    slprjSubDir = fullfile(rootBuildDir, ...
                         fileparts(buildDirInfo.ModelRefRelativeBuildDir));
    files = dir(slprjSubDir);
    
    % process directories and find the ones with binfo files
    dirIndices = find([files.isdir]);        
    binfoFiles = {};
    possibleCodeGenNames = {};
    for i=1:length(dirIndices)
        dirName = files(dirIndices(i));
        binfoFile = fullfile(slprjSubDir, dirName.name, 'tmwinternal', 'binfo.mat');
        if exist(binfoFile, 'file')
            % found file
            binfoFiles{end+1} = binfoFile; %#ok<AGROW>
            possibleCodeGenNames{end+1} = dirName.name; %#ok<AGROW>
        end
    end
    % rogue value for timestamp
    latestTimeStamp = -1;
    % linear search through all matching binfo files
    %
    % loadPostBuild
    action = 'loadPostBuild';
    % load binfo
    minfo_or_binfo = 'binfo';        
    mdlRefTgtType = 'NONE';
    % don't load the whole config set
    loadConfigSet = 0;                
    for i=1:length(binfoFiles)
        % load the binfo
        binfoFile = binfoFiles{i};  
        possibleCodeGenName = possibleCodeGenNames{i};                       
        %
        infoStruct = rtwprivate('rtwinfomatman', ...
                        action, ...
                        minfo_or_binfo, ...
                        possibleCodeGenName, ...
                        mdlRefTgtType, ...
                        binfoFile, ...
                        loadConfigSet);
                       
        % get subsystem from binfo infoStruct
        originalSystem = infoStruct.SourceSubsystemName;
        if strcmp(originalSystem, fullSystemPath)
            % get timestamp for this file
            d = dir(binfoFile);
            currentTimeStamp = d.datenum;
            if currentTimeStamp > latestTimeStamp
                % found new match
                latestTimeStamp = currentTimeStamp;
                codeGenName = possibleCodeGenName;
                buildDir = fullfile(rootBuildDir, ...
                                    [codeGenName buildDirInfo.BuildDirSuffix]);                
            end
        end
    end
end
