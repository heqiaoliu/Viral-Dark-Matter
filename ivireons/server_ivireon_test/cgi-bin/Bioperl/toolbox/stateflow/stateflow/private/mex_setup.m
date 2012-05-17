function errorCode = mex_setup(method, varargin)

% Copyright 2003-2008 The MathWorks, Inc.

mlock;
persistent mexOptsPathStr;

switch method
    case 'create'
        compilerStr    = varargin{1};
        mexOptsPathStr = local_create_temp_dir;
        mexOptsFileStr = fullfile(mexOptsPathStr, 'mexopts.bat');
        mexSetupCmd    = ['mex -setup:' compilerStr ' -f ' mexOptsFileStr];
        errorCode      = dos(mexSetupCmd);
        if errorCode == 0
            addpath(mexOptsPathStr);
            sf('Private','compilerman', 'set_compiler_info', mexOptsFileStr);
        else
            rmdir(mexOptsPathStr, 's');
            mexOptsPathStr = '';
        end
    case 'destroy'
        if(~isempty(mexOptsPathStr))
            rmpath(mexOptsPathStr);
            rmdir(mexOptsPathStr, 's');
            mexOptsPathStr = '';
        end
        sf('Private','compilerman', 'reset_compiler_info');
    otherwise
        error('Stateflow:UnexpectedError','unknown method');
end

function tempDirName = local_create_temp_dir
currDir = pwd;
cd(tempdir);
% no "To" directory was passed in.
% Find a unique ( new ) directory in tempdir to use
tempDirName = tempname;
seps = find(tempDirName==filesep);
tempDirName = [tempDirName(1:seps(end)) 'sf_' tempDirName(seps(end)+1:end)];
while exist( tempDirName,'file' )
    tempDirName = tempname;
    seps = find(tempDirName==filesep);
    tempDirName = [tempDirName(1:seps(end)) 'sf_' tempDirName(seps(end)+1:end)];
end

FileSepLoc = find(tempDirName==filesep);
if ~isempty(FileSepLoc),
    DirName = tempDirName(1:FileSepLoc(end));
    NewDirName = tempDirName(FileSepLoc(end)+1:end);
    mkdir(DirName,NewDirName);
else
    mkdir(tempDirName);
end
cd(currDir);
