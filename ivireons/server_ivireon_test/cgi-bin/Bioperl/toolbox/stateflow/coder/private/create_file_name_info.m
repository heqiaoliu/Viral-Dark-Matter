function fileNameInfo = create_file_name_info
% FILENAMEINFO = CREATE_FILE_NAME_INFO

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.29.2.40.4.1 $  $Date: 2010/06/23 17:29:02 $

global gMachineInfo gTargetInfo

% root directory determination: get the model of the parentTarget
% get the filename property of the model which will give you
% model directory. this dir will be used for constructing abs path
% from relative paths in user source files, user incl dirs etc.

parentTargetMachine = sf('get',gMachineInfo.parentTarget,'target.machine');
modelH = sf('get',parentTargetMachine,'machine.simulinkModel');
machineFullName = get_param(modelH,'filename');
currentDirPath = pwd;

if(isempty(machineFullName))
    rootDirectory = currentDirPath;
else
    % extract rootDirectory from machine's full name
    lastFileSep = find(machineFullName==filesep, 1, 'last' );
    if(~isempty(lastFileSep))
        rootDirectory = machineFullName(1:lastFileSep-1);
    else
        % machine full name does not have dir info, so it is a new machine
        rootDirectory = currentDirPath;
    end
end

[projectDirPath,projectDirArray, projectDirRelPath, projectDirReverseRelPath] = sfprivate('get_sf_proj',pwd,gMachineInfo.mainMachineName,gMachineInfo.machineName,gMachineInfo.targetName,'src');
fileNameInfo.targetDirName = projectDirPath;
fileNameInfo.targetDirRelPath = projectDirRelPath;
baseName = [gMachineInfo.machineName,'_',gMachineInfo.targetName];
if gTargetInfo.codingRTW || gTargetInfo.codingSFunction
    fileNameInfo.mexFunctionName = baseName;
    [dirName, success, errorCreateMsg] = sf('Private','create_directory_path',projectDirArray{:});
    if(~success)
        construct_dir_path_error(dirName,errorCreateMsg);
    end
    fileNameInfo.dllDirFromMakeDir = projectDirReverseRelPath;
elseif gTargetInfo.codingMEX || gTargetInfo.codingHDL
    fileNameInfo.targetDirName = pwd;
    fileNameInfo.dllDirFromMakeDir = '.\';
else
    codegenDir = sf('get',gMachineInfo.parentTarget,'target.codegenDirectory');

    if(isempty(codegenDir))
        fileNameInfo.targetDirName = projectDirPath;
        [dirName, success, errorCreateMsg] = sf('Private','create_directory_path',projectDirArray{:});
        if(~success)
            construct_dir_path_error(dirName,errorCreateMsg);
        end
        fileNameInfo.dllDirFromMakeDir = projectDirReverseRelPath;
    else
        codegenDirOrig = codegenDir;
        [codegenDir,errorStr] = sf('Private','tokenize',currentDirPath,codegenDir,'Code generation directory string');
        if(~isempty(errorStr))
            construct_coder_error(gMachineInfo.parentTarget,errorStr);
        end

        codegenDir = codegenDir{1};

        if(~exist(codegenDir,'dir'))
            [success, errorMessage] = sf('Private', 'sf_mk_dir', currentDirPath, codegenDirOrig);

            if(~success)
                construct_dir_path_error(codegenDir, errorMessage);
            end
        end

        fileNameInfo.targetDirName = codegenDir;
        fileNameInfo.dllDirFromMakeDir = '.\';
    end
end
if(sf('Private','testing_stateflow_in_bat'))
    % make sure we are generating code in
    % MATLAB directories
    if(~isempty(findstr(lower(fileNameInfo.targetDirName),lower(matlabroot))))
        construct_coder_error([],'Code generation in MATLAB directories during Stateflow testing is prohibited.',1);
    end
end

% Can't generate C++ s-function using lcc
if gTargetInfo.codingSFunction && gTargetInfo.gencpp && gTargetInfo.codingLccMakefile
    construct_coder_error([],['The current Real-Time Workshop target is configured to ',...
        'generate C++, but the C-only compiler, LCC, is the default compiler.  '...
        'To specify a C++ compiler, enter ''mex -setup'' '...
        'at the command prompt.  To generate C code, '...
        'open the Configuration Parameters dialog and set the target language to C.'...
        ],1);
end

if gTargetInfo.codingRTW
    fileNameInfo.headerExtension = '.tlh';
    fileNameInfo.sourceExtension = '.tlc';
elseif gTargetInfo.codingHDL
    fileNameInfo.headerExtension = '';
    fileNameInfo.sourceExtension = gTargetInfo.hdl.fileExt;
elseif gTargetInfo.codingPLC
    fileNameInfo.headerExtension = ''; % no header file
    fileNameInfo.sourceExtension = gTargetInfo.plc.fileExt;
else
    fileNameInfo.headerExtension = '.h';
    if gTargetInfo.gencpp
        fileNameInfo.sourceExtension = '.cpp';
    else
        fileNameInfo.sourceExtension = '.c';
    end
end
if(gTargetInfo.codingSFunction)
    fileNameInfo.machineRegistryFile = [baseName,'_registry',fileNameInfo.sourceExtension];
end

if(gTargetInfo.codingDebug)
    fileNameInfo.sfDebugMacrosFile = [baseName,'_debug_macros',fileNameInfo.headerExtension];
end

fileNameInfo.machineHeaderFile = [baseName,fileNameInfo.headerExtension];
fileNameInfo.machineSourceFile = [baseName,fileNameInfo.sourceExtension];

numCharts = length(gMachineInfo.charts);
fileNameInfo.chartHeaderFiles = cell(1,numCharts);
fileNameInfo.chartSourceFiles = cell(1,numCharts);
fileNameInfo.chartSpecUniqueNames = cell(1,numCharts);
fileNameInfo.chartTLCFiles = cell(1,numCharts);
fileNameInfo.chartOutputsFcns = cell(1,numCharts);
fileNameInfo.chartInitializeFcns = cell(1,numCharts);

if gTargetInfo.codingRTW
    machineSourceFile = fileNameInfo.machineSourceFile;
    sf('set',gMachineInfo.machineId,'machine.rtwInfo.machineTLCFile',machineSourceFile(1:end-length(fileNameInfo.sourceExtension)));
end

for chart = gMachineInfo.charts
    chartNumber = sf('get',chart,'chart.number');

    %TLTODO: Handle all targets
    numSpecs = length(gMachineInfo.specializations{chartNumber+1});
    for j = 1:numSpecs
        chartSpecUniqueName = sf('CodegenNameOf', chart, gMachineInfo.specializations{chartNumber+1}{j});
        fileNameInfo.chartSpecUniqueNames{chartNumber+1}{j} = chartSpecUniqueName;

        if gTargetInfo.codingSFunction || gTargetInfo.codingRTW
            fileNameInfo.chartHeaderFiles{chartNumber+1}{j} = [chartSpecUniqueName,fileNameInfo.headerExtension];
            fileNameInfo.chartSourceFiles{chartNumber+1}{j} = [chartSpecUniqueName,fileNameInfo.sourceExtension];
        else
            fileNameInfo.chartHeaderFiles{chartNumber+1} = [chartSpecUniqueName,fileNameInfo.headerExtension];
            fileNameInfo.chartSourceFiles{chartNumber+1} = [chartSpecUniqueName,fileNameInfo.sourceExtension];
        end

        % chartTLCFile, chartOutputsFcn, chartInitializeFcn are only used when coder unification is turned off
        if(gTargetInfo.codingRTW)
            fileNameInfo.chartTLCFiles{chartNumber+1}{j} = chartSpecUniqueName;
            fileNameInfo.chartOutputsFcns{chartNumber+1}{j} = ['sf_',chartSpecUniqueName];
        end

        if gTargetInfo.codingRTW || gTargetInfo.codingMEX
            fileNameInfo.chartInitializeFcns{chartNumber+1}{j} = ['initialize_',chartSpecUniqueName];
        end
    end
end

compilerInfo = sf('Private','compilerman','get_compiler_info');
gTargetInfo.codingIntelIPP = emlcoderprivate.compiler_supports_eml_ipp(compilerInfo.compilerName);

if gTargetInfo.codingBLAS && ...
    ~emlcoderprivate.compiler_supports_eml_blas(compilerInfo.compilerName)
    gTargetInfo.codingBLAS = false; 
    DAStudio.warning('EMLCoder:reportGen:noCompilerBlasSupport',compilerInfo.compilerName);
end

if gTargetInfo.codingOpenMP
    if ~emlcoderprivate.compiler_supports_eml_openmp(compilerInfo.compilerName)
        gTargetInfo.codingOpenMP = false; 
    else
        % xxx: disabling debugging, bound checks, ctrl-c checks and echo when  
        % parallelization is enabled. Parallelization is disabled by default.
        gTargetInfo.codingDebug = false;
        gTargetInfo.leavingIntegrityChecks = false;
        gTargetInfo.leavingCtrlCChecks = false;
        gTargetInfo.codingNoEcho = true;
    end    
end


fileNameInfo.mexOptsFile = compilerInfo.mexOptsFile;
fileNameInfo.mexOptsIgnored = compilerInfo.mexOptsIgnored;
fileNameInfo.mexOptsNotFound = compilerInfo.mexOptsNotFound;
fileNameInfo.matlabRoot = sf('Private','sf_get_component_root','matlab');
fileNameInfo.blasLibFile = [];
fileNameInfo.blasIncludeFile = [];
fileNameInfo.openMPIncludeFile = [];

if(gTargetInfo.codingSFunction)
    fileNameInfo.makeBatchFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.bat'];
    fileNameInfo.machineDefFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.def'];
    fileNameInfo.SFunctionName = [gMachineInfo.machineName,'_',gMachineInfo.targetName];
    fileNameInfo.unixMakeFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.mku'];
    fileNameInfo.msvcdspFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.dsp'];
    fileNameInfo.msvcdswFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.dsw'];
    fileNameInfo.msvcMakeFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.mak'];
    fileNameInfo.watcomMakeFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.wmk'];
    fileNameInfo.borlandMakeFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.bmk'];
    fileNameInfo.lccMakeFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.lmk'];
    fileNameInfo.intelMakeFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.imk'];
    fileNameInfo.machineObjListFile = [gMachineInfo.machineName,'_',gMachineInfo.targetName,'.mol'];
end
if (~gTargetInfo.codingRTW)
    fileNameInfo.sfcMexLibInclude = fullfile(fileNameInfo.matlabRoot,'stateflow','c','mex','include');
    fileNameInfo.sfcMexLibLib = fullfile(fileNameInfo.matlabRoot,'stateflow','c','mex','lib');
    fileNameInfo.sfcDebugLibInclude = fullfile(fileNameInfo.matlabRoot,'stateflow','c','debugger','include');
    fileNameInfo.sfcDebugLibLib = fullfile(fileNameInfo.matlabRoot,'stateflow','c','debugger','lib');
    fileNameInfo.archName = computer('arch');
    if(~isempty(fileNameInfo.archName))
        fileNameInfo.sfcMexLibLib = fullfile(fileNameInfo.sfcMexLibLib,fileNameInfo.archName);
        fileNameInfo.sfcDebugLibLib = fullfile(fileNameInfo.sfcDebugLibLib,fileNameInfo.archName);

        if gTargetInfo.codingBLAS
            fileNameInfo.blasIncludeFile = 'blascompat32.h';
            if strcmp(computer,'PCWIN') || strcmp(computer,'PCWIN64')
                compilerName = compilerInfo.compilerName;
                if strcmp(compilerName, 'msvc100') || ...
                   strcmp(compilerName, 'msvc90') || ...
                   strcmp(compilerName, 'msvc80') || ...
                   strcmp(compilerName, 'msvc60') 
                    compilerName = 'microsoft';
                end
                fileNameInfo.blasLibFile = fullfile(fileNameInfo.matlabRoot,'extern','lib',fileNameInfo.archName,compilerName,'libmwblascompat32.lib');
                if ~exist(fileNameInfo.blasLibFile,'file')	 
                    fileNameInfo.blasLibFile = [];	 
                end	             
            else
                fileNameInfo.blasLibFile = 'libmwblascompat32.so';
            end
        end
    end

    if gTargetInfo.codingOpenMP
        fileNameInfo.openMPIncludeFile = 'omp.h';
    end

    switch computer
        case 'PCWIN'
            switch compilerInfo.compilerName
                case 'lcc'
                    dbgLib = 'sfc_debuglcc.lib';
                    mexLib = 'sfc_mexlcc.lib';
                case { 'msvc80','msvc90','msvc100','intelc91msvs2005','intelc11msvs2008' }
                    dbgLib = 'sfc_debugmsvc80.lib';
                    mexLib = 'sfc_mexmsvc80.lib';
                case {'msvc60'}
                    dbgLib = 'sfc_debugmsvc.lib';
                    mexLib = 'sfc_mexmsvc.lib';
                case 'borland'
                    dbgLib = 'sfc_debugbor.lib';
                    mexLib = 'sfc_mexbor.lib';
                case 'watcom'
                    dbgLib = 'sfc_debugwat.lib';
                    mexLib = 'sfc_mexwat.lib';
                otherwise
                    error('Stateflow:UnexpectedError','unexpected compiler');
            end
        case 'PCWIN64'
            dbgLib = 'sfc_debug.lib';
            mexLib = 'sfc_mex.lib';
        otherwise
            dbgLib = 'sfc_debug.a';
            mexLib = 'sfc_mex.a';
    end

    fileNameInfo.sfcMexLibFile = fullfile(fileNameInfo.sfcMexLibLib,mexLib);
    fileNameInfo.sfcDebugLibFile = fullfile(fileNameInfo.sfcDebugLibLib,dbgLib);

    fileNameInfo.dspLibInclude ='';
    fileNameInfo.dspLibLib ='';
    fileNameInfo.dspLibFile ='';

else
    fileNameInfo.rtwDspLibInclude = fullfile(fileNameInfo.matlabRoot,'toolbox','eml','lib','dsp');
    fileNameInfo.rtwDspLibIncludeFileName = 'template_support_fcn_list.h';
end

customCodeSettings = get_custom_code_settings(gMachineInfo.target,gMachineInfo.parentTarget);

customCodeIsEmpty = isempty(customCodeSettings.customCode) &&...
                    isempty(customCodeSettings.customSourceCode) &&...
                    isempty(customCodeSettings.userIncludeDirs) &&...
                    isempty(customCodeSettings.userSources) &&...
                    isempty(customCodeSettings.customInitializer) &&...
                    isempty(customCodeSettings.customTerminator) &&...
                    isempty(customCodeSettings.userLibraries);

if(customCodeIsEmpty) 
    fileNameInfo.userIncludeDirs = {};
else
    %%% IMPORTANT: We use include directory paths as search paths for
    %%% source files (G85817). Hence, we must tokenize includeDirs before
    %%% user sources
    [fileNameInfo.userIncludeDirs,errorStr] = ...
        sf('Private','tokenize'...
        ,rootDirectory...
        ,customCodeSettings.userIncludeDirs...
        ,'custom include directory paths string'...
        ,{});
    if(~isempty(errorStr))
        construct_coder_error(customCodeSettings.relevantTargetId,errorStr);
    end

    % Legacy interface function
    modelName = get_param(modelH, 'name');
    if (slfeature('LegacyCodeIntegration') == 1) && ~isempty(modelName)
        subdir = 'sim';
        if strcmpi(gMachineInfo.targetName, 'rtw')
            subdir = 'rtw';
        end
        
        legacyDir = rtwprivate('rtw_create_directory_path', ...
                currentDirPath, 'slprj', 'legacy', modelName, subdir);

        fileNameInfo.userIncludeDirs = [ ...
            {fileNameInfo.targetDirName},{currentDirPath}, {rootDirectory}, ...
            {legacyDir},fileNameInfo.userIncludeDirs];
    else
        fileNameInfo.userIncludeDirs = [ ...
            {fileNameInfo.targetDirName},{currentDirPath}, {rootDirectory}, ...
             fileNameInfo.userIncludeDirs];
    end

    fileNameInfo.userIncludeDirs = ordered_unique_paths(fileNameInfo.userIncludeDirs);

    % G400437. Use regexp to tokenize MATLAB path instead of the home-grown tokenize
    searchDirectories = regexp(matlabpath,pathsep,'split');
    if(ispc)
        filterIndices = strncmpi(searchDirectories,matlabroot,length(matlabroot));
    else
        filterIndices = strncmp(searchDirectories,matlabroot,length(matlabroot));
    end
    searchDirectories(filterIndices) = [];
    searchDirectories = [fileNameInfo.userIncludeDirs,searchDirectories];
    searchDirectories = ordered_unique_paths(searchDirectories);
    customCodeString = customCodeSettings.customCode;
    if(~isempty(customCodeString))
        % If there is custom code, include MATLAB's search path in it
        % as it may be including files in these directories
        customCodeIncDirs = extract_relevant_dirs(rootDirectory,searchDirectories,customCodeString);
    else
        customCodeIncDirs = {};
    end
    fileNameInfo.userIncludeDirs = [fileNameInfo.userIncludeDirs,customCodeIncDirs];
    fileNameInfo.userIncludeDirs = ordered_unique_paths(fileNameInfo.userIncludeDirs);
end


userSourceStr = customCodeSettings.userSources;

if(isempty(userSourceStr))
    fileNameInfo.userSources = {};
else
    [fileNameInfo.userSources,errorStr] = ...
        sf('Private','tokenize'...
        ,rootDirectory...
        ,userSourceStr...
        ,'custom source files string'...
        ,searchDirectories);
    if(~isempty(errorStr))
        construct_coder_error(customCodeSettings.relevantTargetId,errorStr);
    end
end

userLibrariesStr = customCodeSettings.userLibraries;

if(isempty(userLibrariesStr))
    fileNameInfo.userLibraries = {};
else
    [fileNameInfo.userLibraries,errorStr] = ...
        sf('Private','tokenize'...
        ,rootDirectory...
        ,userLibrariesStr...
        ,'custom libraries string'...
        ,searchDirectories);
    if(~isempty(errorStr))
        construct_coder_error(customCodeSettings.relevantTargetId,errorStr);
    end
end

fileNameInfo.userMakefiles = {};
fileNameInfo.userAbsSources = {};
fileNameInfo.userAbsPaths = {};
for i=1:length(fileNameInfo.userSources)
    [fileNameInfo.userAbsPaths{i}...
        ,fileNameInfo.userAbsSources{i}...
        ,fileNameInfo.userSources{i}] = ...
        sf('Private','strip_path_from_name',fileNameInfo.userSources{i});
end

% get rid of duplicate paths preserving the order
fileNameInfo.userAbsPaths = ordered_unique_paths(fileNameInfo.userAbsPaths);
fileNameInfo.userIncludeDirs = [fileNameInfo.userIncludeDirs ...
    ,fileNameInfo.userAbsPaths];
fileNameInfo.userIncludeDirs = ordered_unique_paths(fileNameInfo.userIncludeDirs);

fileNameInfo.linkMachines = {};
fileNameInfo.linkLibFullPaths	= {};
fileNameInfo.linkMachinesInlinable = {};
if(~gTargetInfo.codingLibrary)
    [fileNameInfo.linkMachines,fileNameInfo.linkLibFullPaths] = sf('Private','get_link_machine_list',gMachineInfo.machineName,gMachineInfo.targetName);
    for i=1:length(fileNameInfo.linkMachines)
        infoStruct = sf('Private','infomatman','load','binary',fileNameInfo.linkMachines{i},gMachineInfo.mainMachineId,gMachineInfo.targetName);
        fileNameInfo.linkMachinesInlinable{i} = infoStruct.machineInlinable;
    end
end


function orderedList = ordered_unique_paths(orderedList)

orderedList = sf('Private', 'ordered_unique_paths', orderedList);


function newSearchDirectories = extract_relevant_dirs(rootDirectory, searchDirectories, customCodeString)

newSearchDirectories = sf('Private', 'extract_relevant_dirs', rootDirectory, searchDirectories, customCodeString);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function construct_dir_path_error(dirName,errorCreateMsg)
errorMsg = sprintf('Unable to create directory: %s',dirName);
errorMsg = [errorMsg,10,10,errorCreateMsg];
sf('Private','construct_error',[], 'Build', errorMsg, 1, []);
