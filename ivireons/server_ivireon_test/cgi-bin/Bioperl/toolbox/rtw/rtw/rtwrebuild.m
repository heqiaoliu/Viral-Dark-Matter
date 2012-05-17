function rtwrebuild(varargin) 
%RTWREBUILD  Calls the make command stored inside the information mat file to
%            rebuild the generated code as needed. Supports the following
%            usage:
% 1. rtwrebuild()
%    This usage requires user to CD into RTW build directory, i.e.,
%    ecdemo_ert_rtw. 
% 2. rtwrebuild(modelName)
%    This usage requires current directory to be one level above the model's
%    build directory, i.e. the Matlab pwd when RTW build was done.
% 3. rtwrebuild(path)
%    Same effect as option 1, except user can specify build directory.
% 
% rtwrebuild supports Model Reference. If the model contains submodels, before 
% rebuilding the top model, the submodels are built recursively.

%   Copyright 2003-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2008/12/01 07:24:04 $
savedpwd = pwd;
if nargin > 0
    if isdir(varargin{1})
        buildDir = varargin{1};
    else
        bDir = RTW.getBuildDir(varargin{1});
        buildDir = bDir.BuildDirectory;
        if exist(buildDir,'dir') ~= 7
            DAStudio.error('RTW:buildProcess:buildDirNotFound',...
                           buildDir, varargin{1});
        end
    end
    cd(buildDir);
else
    buildDir = savedpwd;
end

try
    if ~exist('rtw_proj.tmw','file') 
        DAStudio.error('RTW:buildProcess:buildDirInvalid',pwd);
    end
    rtwProjFile = fullfile(pwd, 'rtw_proj.tmw');
    fid = fopen(rtwProjFile,'rt');
    if fid == -1
        DAStudio.error('RTW:utility:fileIOError',rtwProjFile,'open');
    end
    % skip the first 3 lines, and process the 4th
    % line1 - rtwbuild information, modelname, tmf etc.
    % lines 2-3 info about the rtw_proj file itself
    % line 4 - the location of the rtwinfomatman file
    for i=1:4
        rtwProjLine = fgetl(fid);
    end
    fclose(fid);    
    if ischar(rtwProjLine)
        rtwinfomatfile = deblank(strrep(rtwProjLine,'The rtwinfomat located at: ',''));
    else
        DAStudio.error('RTW:buildProcess:buildDirInvalid',pwd);
    end
    if exist(rtwinfomatfile,'file') ~= 2
        DAStudio.error('RTW:buildProcess:buildDirInvalid',pwd);
    end
    load(rtwinfomatfile);
    % recursive build submodels.
    subrebuildCommandPath = infoStruct.directlinkLibrariesFullPaths;
    for  idxrebuildCommandFile = 1:length(subrebuildCommandPath)
        cd(fullfile(infoStruct.relativePathToAnchor, fileparts(subrebuildCommandPath{idxrebuildCommandFile})));
        rtwrebuild;
        cd(buildDir);
    end

    % check to see if the model is using the mdlref paths or not.  If it is not
    % using the paths, then the libs need to be copied over.
    makeCmd = getProp(infoStructConfigSet,'MakeCommand');
    useRelativePaths = parsestrforvar(makeCmd,'USE_MDLREF_LIBPATHS');
    % if the arg was not passed in, then default it to '0'.
    if isempty(useRelativePaths)
        useRelativePaths = '0';
    end
    % MAC platform automatically overrides the command line setting,
    % because it always needs the mdlref paths.
    useRelativePaths = (strcmp(useRelativePaths,'1') || ismac);

    if ~useRelativePaths
        % if submodel lib updated, we'll copy them to builddir.
        for idxLinkLibraries = 1:length(infoStruct.linkLibrariesFullPaths)
            srcLib = fullfile(infoStruct.relativePathToAnchor,...
                              infoStruct.linkLibrariesFullPaths{idxLinkLibraries});
            [srcLibpath, srcLibname, srcLibext] = fileparts(srcLib);
            dstLib = fullfile(buildDir, [srcLibname srcLibext]);
            if (cmpTimeFlag(dstLib, srcLib) > 0)  
                % 1 means dstLib earlier than srcLib, 2 means dstLib doesn't exist.
                rtw_copy_file(srcLib,buildDir);
            end
        end
    end
    cd(buildDir);
    makeCmd = infoStruct.makeCmd;
    if isunix
        % on UNIX platforms, make command is in the format of
        % /MATLAB/rtw/bin/<ARCH>/gmake -f model.mk, so we need do
        % string replacement to make it portable between different
        % MATLAB roots.
        makeCmd = strrep(makeCmd, '$(MATLAB_ROOT)', matlabroot);
        % support rebuild code generated on different MATLABROOT
        % installation.
        makeCmd = [makeCmd, ' MATLAB_ROOT=', matlabroot];
    end
    status = system(makeCmd);
    if (status ~= 0)
        DAStudio.error('RTW:buildProcess:rebuildError',buildDir);
    end
    cd(savedpwd);
catch exc
    cd(savedpwd);
    rethrow(exc);    
end

