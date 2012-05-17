function makeInfo = rtwmakecfg()
%RTWMAKECFG adds include and source directories to RTW make files.
%   makeInfo=RTWMAKECFG returns a structured array containing build info.
%   Please refer to the rtwmakecfg API section in the Real-Time Workshop
%   Documentation for details on the format of this structure.
%
%   Simulink version    : 7.6 (R2010b) 28-Jun-2010
%   MATLAB file generated on : 30-Jun-2010 03:48:08

% Verify the Simulink version
verify_simulink_version();

% Get the current directory
currDir = pwd;

% Get the ML search paths and remove the toolbox subdirs except simfeatures
pSep = pathsep;
mlPaths = regexp([matlabpath pSep], ['.[^' pSep ']*' pSep], 'match');
if ~isempty(mlPaths)
    filteredPathIndices = strmatch(fullfile(matlabroot,'toolbox'), mlPaths);
    lctPath = fileparts(which('sldemo_lct_builddemos'));
    if ~isempty(lctPath)
        lctPathIndex = strmatch([lctPath pSep], mlPaths);
        filteredPathIndices(filteredPathIndices == lctPathIndex) = [];
    end
    mlPaths(filteredPathIndices) = [];
    mlPaths = strrep(mlPaths, pSep, '');
end

% Declare cell arrays for storing the paths found
allIncPaths = {};
allSrcPaths = {};


% Get the serialized paths information
info = get_serialized_info();

% Get all S-Function's name in the current model
sfunNames = {};
if ~isempty(bdroot)
    sfunBlks = find_system(bdroot,...
        'LookUnderMasks', 'all',...
        'FollowLinks', 'on',...
        'BlockType', 'S-Function'...
    );
    sfunNames = get_param(sfunBlks, 'FunctionName');
end

for ii = 1:length(info)
    % If the S-Function isn't part of the current build then skip its path info
    if isempty(strmatch(info(ii).SFunctionName, sfunNames, 'exact'))
        continue
    end

    % Path to the S-function source file
    if strcmp(info(ii).Language, 'C')
        fext = '.c';
    else
        fext = '.cpp';
    end
    pathToSFun = fileparts(which([info(ii).SFunctionName,fext]));
    if isempty(pathToSFun)
        pathToSFun = currDir;
    end

    % Default search paths for this S-function
    defaultPaths = [{pathToSFun} {currDir}];
    allPaths = [defaultPaths mlPaths];

    % Verify if IncPaths are absolute or relative and then complete
    % relative paths with the full S-function dir or current dir or ML path
    incPaths = info(ii).IncPaths;
    for jj = 1:length(incPaths)
        [fullPath, isFound] = resolve_path_info(correct_path_sep(incPaths{jj}), allPaths);
        if (isFound==0)
            DAStudio.error('Simulink:tools:LCTErrorCannotFindIncludePath',...
                incPaths{jj});
        else
            incPaths{jj} = fullPath;
        end
    end
    incPaths = [incPaths defaultPaths];

    % Verify if SrcPaths are Absolute or Relative and then complete
    % relative paths with the full S-function dir or current dir or ML path
    srcPaths = info(ii).SrcPaths;
    for jj = 1:length(srcPaths)
        [fullPath, isFound] = resolve_path_info(correct_path_sep(srcPaths{jj}), allPaths);
        if (isFound==0)
            DAStudio.error('Simulink:tools:LCTErrorCannotFindSourcePath',...
                srcPaths{jj});
        else
            srcPaths{jj} = fullPath;
        end
    end
    srcPaths = [srcPaths defaultPaths];

    % Common search paths for Source files specified with path
    srcSearchPaths = [srcPaths mlPaths];

    % Add path to source files if not specified and complete relative
    % paths with the full S-function dir or current dir or search
    % paths and then extract only the path part to add it to the srcPaths
    sourceFiles = info(ii).SourceFiles;
    pathFromSourceFiles = cell(1, length(sourceFiles));
    for jj = 1:length(sourceFiles)
        [fullName, isFound] = resolve_file_info(correct_path_sep(sourceFiles{jj}), srcSearchPaths);
        if isFound==0
            DAStudio.error('Simulink:tools:LCTErrorCannotFindSourceFile',...
                sourceFiles{jj});
        else
            % Extract the path part only
            [fpath, fname, fext] = fileparts(fullName);
            pathFromSourceFiles{jj} = fpath;
        end
    end
    srcPaths = [srcPaths pathFromSourceFiles];

    % Concatenate known include and source directories
    allIncPaths = RTW.uniquePath([allIncPaths incPaths]);
    allSrcPaths = RTW.uniquePath([allSrcPaths srcPaths]);

end

% Additional include directories
makeInfo.includePath = correct_path_name(allIncPaths);

% Additional source directories
makeInfo.sourcePath = correct_path_name(allSrcPaths);

%--------------------------------------------------------------------------
function verify_simulink_version()

% Retrieve Simulink version
slVer = ver('simulink');
factor = 1.0;
thisVer = 0.0;
for ii = 1:length(slVer.Version)
    if slVer.Version(ii)=='.'
        factor = factor/10.0;
    else
        thisVer = thisVer + sscanf(slVer.Version(ii), '%d')*factor;
    end
end

% Verify that the actual plateform supports the function used
if thisVer < 6.4
    DAStudio.error('Simulink:tools:LCTErrorBadSimulinkVersion', sprintf('%g',thisVer))
end


%--------------------------------------------------------------------------
function [fullPath, isFound] = resolve_path_info(fullPath, searchPaths)

% Initialize output value
isFound = 0;

if is_absolute_path(fullPath)==1
    % Verify that the dir exists
    if exist(fullPath, 'dir')
        isFound = 1;
    end
else
    % Walk through the search path
    for ii = 1:length(searchPaths)
        thisFullPath = fullfile(searchPaths{ii}, fullPath);
        % If this candidate path exists then exit
        if exist(thisFullPath, 'dir')
            isFound = 1;
            fullPath = thisFullPath;
            break
        end
    end
end


%--------------------------------------------------------------------------
function [fullName, isFound] = resolve_file_info(fullName, searchPaths)

% Initialize output value
isFound = 0;

% Extract file parts
[fPath, fName, fExt] = fileparts(fullName);

if is_absolute_path(fPath)==1
    % If the file has no extension then try to add it
    if isempty(fExt)
        fExt = find_file_extension(fullfile(fPath, fName));
        fullName = fullfile(fPath, [fullName,fExt]);
    end
    % Verify that the file exists
    if exist(fullName, 'file')
        isFound = 1;
    end
else
    % Walk through the search path
    for ii = 1:length(searchPaths)
        thisFullName = fullfile(searchPaths{ii}, fullName);
        % If the file has no extension then try to add it
        if isempty(fExt)
            fExt = find_file_extension(thisFullName);
            thisFullName = [thisFullName,fExt];
        end
        % If this candidate path exists then exit
        if exist(thisFullName, 'file')
            fullName = thisFullName;
            isFound = 1;
            break
        end
    end
end


%--------------------------------------------------------------------------
function fext = find_file_extension(fullName)

% Initialize output value
fext = [];

% Use 'dir' because this command has the same behavior both
% on PC and Unix
theDir = dir([fullName,'.*']);
if ~isempty(theDir)
    for ii = 1:length(theDir)
        if theDir(ii).isdir
            continue
        end
        [fpath, fname, fext] = fileparts(theDir(ii).name);
        if ~isempty(fext)
            break % stop on first occurrence
        end
    end
end


%--------------------------------------------------------------------------
function bool = is_absolute_path(thisPath)

if isempty(thisPath)
    bool = 0;
    return
end

if(thisPath(1)=='.')
    % Relative path
    bool = 0;
else
    if(ispc && length(thisPath)>=2)
        % Absolute path on PC start with drive letter or \(for UNC paths)
        bool = (thisPath(2)==':') | (thisPath(1)=='\');
    else
        % Absolute paths on unix start with '/'
        bool = thisPath(1)=='/';
    end
end


%--------------------------------------------------------------------------
function thePath = correct_path_sep(thePath)

if isunix
    wrongFilesepChar = '\';
    filesepChar = '/';
else
    wrongFilesepChar = '/';
    filesepChar = '\';
end

seps = find(thePath==wrongFilesepChar);
if(~isempty(seps))
    thePath(seps) = filesepChar;
end


%--------------------------------------------------------------------------
function thePaths = correct_path_name(thePaths)

for ii = 1:length(thePaths)
    thePaths{ii} = rtw_alt_pathname(thePaths{ii});
end
thePaths = RTW.uniquePath(thePaths);


%--------------------------------------------------------------------------
function info = get_serialized_info()

% Allocate the output structure array
info(1:18) = struct(...
    'SFunctionName', '',...
    'IncPaths', {{}},...
    'SrcPaths', {{}},...
    'LibPaths', {{}},...
    'SourceFiles', {{}},...
    'HostLibFiles', {{}},...
    'TargetLibFiles', {{}},...
    'Language', ''...
    );

% Dependency info for S-function 'rtwdemo_sfun_counterbus'
info(1).SFunctionName = 'rtwdemo_sfun_counterbus';
info(1).IncPaths = {'sldemo_lct_src'};
info(1).SrcPaths = {'sldemo_lct_src'};
info(1).SourceFiles = {'counterbus.c'};
info(1).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_adder_cpp'
info(2).SFunctionName = 'rtwdemo_sfun_adder_cpp';
info(2).IncPaths = {'sldemo_lct_src'};
info(2).SrcPaths = {'sldemo_lct_src'};
info(2).SourceFiles = {'adder_cpp.cpp'};
info(2).Language = 'C++';
% Dependency info for S-function 'rtwdemo_sfun_gain_fixpt'
info(3).SFunctionName = 'rtwdemo_sfun_gain_fixpt';
info(3).IncPaths = {'sldemo_lct_src'};
info(3).SrcPaths = {'sldemo_lct_src'};
info(3).SourceFiles = {'timesS16.c'};
info(3).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_times_s16'
info(4).SFunctionName = 'rtwdemo_sfun_times_s16';
info(4).IncPaths = {'sldemo_lct_src'};
info(4).SrcPaths = {'sldemo_lct_src'};
info(4).SourceFiles = {'timesS16.c'};
info(4).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_gain_scalar'
info(5).SFunctionName = 'rtwdemo_sfun_gain_scalar';
info(5).IncPaths = {'sldemo_lct_src'};
info(5).SrcPaths = {'sldemo_lct_src'};
info(5).SourceFiles = {'gainScalar.c'};
info(5).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_fault'
info(6).SFunctionName = 'rtwdemo_sfun_fault';
info(6).IncPaths = {'sldemo_lct_src'};
info(6).SrcPaths = {'sldemo_lct_src'};
info(6).SourceFiles = {'fault.c'};
info(6).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_filterV1'
info(7).SFunctionName = 'rtwdemo_sfun_filterV1';
info(7).IncPaths = {'sldemo_lct_src'};
info(7).SrcPaths = {'sldemo_lct_src'};
info(7).SourceFiles = {'filterV1.c'};
info(7).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_filterV2'
info(8).SFunctionName = 'rtwdemo_sfun_filterV2';
info(8).IncPaths = {'sldemo_lct_src'};
info(8).SrcPaths = {'sldemo_lct_src'};
info(8).SourceFiles = {'filterV2.c'};
info(8).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_mat_add'
info(9).SFunctionName = 'rtwdemo_sfun_mat_add';
info(9).IncPaths = {'sldemo_lct_src'};
info(9).SrcPaths = {'sldemo_lct_src'};
info(9).SourceFiles = {'mat_ops.c'};
info(9).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_mat_mult'
info(10).SFunctionName = 'rtwdemo_sfun_mat_mult';
info(10).IncPaths = {'sldemo_lct_src'};
info(10).SrcPaths = {'sldemo_lct_src'};
info(10).SourceFiles = {'mat_ops.c'};
info(10).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_dlut3D'
info(11).SFunctionName = 'rtwdemo_sfun_dlut3D';
info(11).IncPaths = {'sldemo_lct_src'};
info(11).SrcPaths = {'sldemo_lct_src'};
info(11).SourceFiles = {'directLookupTableND.c'};
info(11).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_dlut4D'
info(12).SFunctionName = 'rtwdemo_sfun_dlut4D';
info(12).IncPaths = {'sldemo_lct_src'};
info(12).SrcPaths = {'sldemo_lct_src'};
info(12).SourceFiles = {'directLookupTableND.c'};
info(12).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_work'
info(13).SFunctionName = 'rtwdemo_sfun_work';
info(13).IncPaths = {'sldemo_lct_src'};
info(13).SrcPaths = {'sldemo_lct_src'};
info(13).SourceFiles = {'memory_bus.c'};
info(13).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_ndarray_add'
info(14).SFunctionName = 'rtwdemo_sfun_ndarray_add';
info(14).IncPaths = {'sldemo_lct_src'};
info(14).SrcPaths = {'sldemo_lct_src'};
info(14).SourceFiles = {'ndarray_ops.c'};
info(14).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_cplx_gain'
info(15).SFunctionName = 'rtwdemo_sfun_cplx_gain';
info(15).IncPaths = {'sldemo_lct_src'};
info(15).SrcPaths = {'sldemo_lct_src'};
info(15).SourceFiles = {'cplxgain.c'};
info(15).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_st_inherited'
info(16).SFunctionName = 'rtwdemo_sfun_st_inherited';
info(16).IncPaths = {'sldemo_lct_src'};
info(16).SrcPaths = {'sldemo_lct_src'};
info(16).SourceFiles = {'gainScalar.c'};
info(16).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_st_fixed'
info(17).SFunctionName = 'rtwdemo_sfun_st_fixed';
info(17).IncPaths = {'sldemo_lct_src'};
info(17).SrcPaths = {'sldemo_lct_src'};
info(17).SourceFiles = {'gainScalar.c'};
info(17).Language = 'C';
% Dependency info for S-function 'rtwdemo_sfun_st_parameterized'
info(18).SFunctionName = 'rtwdemo_sfun_st_parameterized';
info(18).IncPaths = {'sldemo_lct_src'};
info(18).SrcPaths = {'sldemo_lct_src'};
info(18).SourceFiles = {'gainScalar.c'};
info(18).Language = 'C';

