function code_intel_make_file(fileNameInfo)
% CODE_INTEL_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/13 05:20:07 $

global gMachineInfo gTargetInfo
code_machine_objlist_file(fileNameInfo);

    function emit(format,varargin)
        fprintf(file,format,varargin{:});
    end

fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);
sf_echo_generating('Coder',fileName);
file = fopen(fileName,'Wt');
if file<3
    construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
end
create_mexopts_caller_bat_file(file,fileNameInfo);
emit('nmake -f %s\n',fileNameInfo.intelMakeFile);
fclose(file);

fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.intelMakeFile);
sf_echo_generating('Coder',fileName);
file = fopen(fileName,'Wt');
if file<3
    construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
end

emit('# ------------------- Required for MSVC nmake ---------------------------------\n');
emit('# This file should be included at the top of a MAKEFILE as follows:\n');
emit('\n');
emit('\n');
if ~isempty(fileNameInfo.userMakefiles)
    for i=1:length(fileNameInfo.userMakefiles)
        emit('!include "%s"\n',fileNameInfo.userMakefiles{i});
    end
end
if strcmp(computer,'PCWIN64')
    emit('CPU = AMD64\n');
end
emit('!include <ntwin32.mak>\n');
emit('\n');
emit('MACHINE     = %s\n',gMachineInfo.machineName);
emit('TARGET      = %s\n',gMachineInfo.targetName);

if ~isempty(gMachineInfo.charts)
    emit('CHART_SRCS 	= \\\n');

    numSrcFiles = 0;
    for chart = gMachineInfo.charts
        chartNumber = sf('get',chart,'chart.number');
        numSrcFiles = numSrcFiles + length(fileNameInfo.chartSourceFiles{chartNumber+1});
    end
    chartSourceFiles = cell(1, numSrcFiles);

    idx = 1;
    for chart = gMachineInfo.charts
        chartNumber = sf('get',chart,'chart.number');
        for i = 1:length(fileNameInfo.chartSourceFiles{chartNumber+1})
            chartSourceFiles{idx} = fileNameInfo.chartSourceFiles{chartNumber+1}{i};
            idx = idx + 1;
        end
    end

    for i = 1:(numSrcFiles-1)
        emit('		%s\\\n', chartSourceFiles{i});
    end
    emit('		%s\n', chartSourceFiles{numSrcFiles});
else
    emit('CHART_SRCS =\n');
end

emit('MACHINE_SRC	= %s\n',fileNameInfo.machineSourceFile);
if ~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction
    emit('MACHINE_REG = %s\n',fileNameInfo.machineRegistryFile);
else
    emit('MACHINE_REG =\n');
end
if ~gTargetInfo.codingLibrary && gTargetInfo.codingMEX
    emit('MEX_WRAPPER = %s\n',fileNameInfo.mexWrapperFile);
else
    emit('MEX_WRAPPER =\n');
end

userAbsSources = {};
userSources    = {};
for i=1:length(fileNameInfo.userAbsSources)
    [~, ~, extStr] = fileparts(fileNameInfo.userAbsSources{i});
    extStr = lower(extStr);
    if strcmp(extStr, '.c') || strcmp(extStr,'.cpp')
        userAbsSources{end+1} = fileNameInfo.userAbsSources{i}; %#ok<AGROW>
        userSources{end+1}    = fileNameInfo.userSources{i}; %#ok<AGROW>
    else
        error('Stateflow:UnexpectedError',['Unrecognized file extension: ' extStr]);
    end
end

emit('MAKEFILE    = %s\n',fileNameInfo.intelMakeFile);

emit('MATLAB_ROOT	= %s\n',fileNameInfo.matlabRoot);
emit('BUILDARGS   =\n');

emit('\n');
emit('#--------------------------- Tool Specifications ------------------------------\n');
emit('#\n');
emit('#\n');
emit('MSVC_ROOT1 = $(MSDEVDIR:SharedIDE=vc)\n');
emit('MSVC_ROOT2 = $(MSVC_ROOT1:SHAREDIDE=vc)\n');
emit('MSVC_ROOT  = $(MSVC_ROOT2:sharedide=vc)\n');
emit('\n');
emit('# Compiler tool locations, CC, LD, LIBCMD:\n');
emit('CC     = icl.exe\n');
emit('LD     = link.exe\n');
emit('LIBCMD = lib.exe\n');

emit('#------------------------------ Include/Lib Path ------------------------------\n');
emit('\n');
userIncludeDirString = '';
if ~isempty(fileNameInfo.userIncludeDirs)
    for i = 1:length(fileNameInfo.userIncludeDirs)
        userIncludeDirString = ...
            [userIncludeDirString,' /I "',fileNameInfo.userIncludeDirs{i},'"']; %#ok<AGROW>
    end
end
emit('USER_INCLUDES   = %s\n',userIncludeDirString);
auxIncludeDirString = '';
if ~isempty(fileNameInfo.auxInfo.includePaths)
    for i = 1:length(fileNameInfo.auxInfo.includePaths)
        path = fileNameInfo.auxInfo.includePaths{i};
        auxIncludeDirString = [auxIncludeDirString,' /I "',path,'"']; %#ok<AGROW>
    end
end
emit('AUX_INCLUDES   = %s\n',auxIncludeDirString);

emit('ML_INCLUDES     = /I "$(MATLAB_ROOT)\\extern\\include"\n');
emit('SL_INCLUDES     = /I "$(MATLAB_ROOT)\\simulink\\include"\n');
emit('SF_INCLUDES     = /I "%s" /I "%s"\n',fileNameInfo.sfcMexLibInclude,fileNameInfo.sfcDebugLibInclude);
emit('\n');
if (~isempty(fileNameInfo.dspLibInclude))
    emit('DSP_INCLUDES    = /I "%s"\n',fileNameInfo.dspLibInclude);
else
    emit('DSP_INCLUDES    =\n');
end
emit('\n');
emit('COMPILER_INCLUDES = /I "$(MSVC_ROOT)\\include"\n');
emit('\n');
emit('INCLUDE_PATH = $(USER_INCLUDES) $(AUX_INCLUDES) $(ML_INCLUDES) $(SL_INCLUDES) $(SF_INCLUDES) $(DSP_INCLUDES)\n');
emit('LIB_PATH     = "$(MSVC_ROOT)\\lib"\n');

emit('\n');

emit('CFLAGS = $(COMPFLAGS) /MD\n');
emit('LDFLAGS = /nologo /dll /OPT:NOREF /export:mexFunction\n');
auxLinkFlags = '';
if ~isempty(fileNameInfo.auxInfo.linkFlags)
    for i = 1:length(fileNameInfo.auxInfo.linkFlags)
        flag = fileNameInfo.auxInfo.linkFlags{i};
        auxLinkFlags = [auxLinkFlags,' ',flag]; %#ok<AGROW>
    end
end
emit('AUXLDFLAGS = %s\n', auxLinkFlags);
emit('\n');

emit('#----------------------------- Source Files -----------------------------------\n');
emit('\n');
emit('REQ_SRCS  = $(MACHINE_SRC) $(MACHINE_REG) $(MEX_WRAPPER) $(CHART_SRCS)\n');
emit('\n');
if ~isempty(userAbsSources)
    emit('USER_ABS_OBJS 	= \\\n');
    for i=1:length(userAbsSources)
        [~, nameStr] = fileparts(userAbsSources{i});
        objStr = [nameStr '.obj'];
        emit('		"%s" \\\n',objStr);
    end
else
    emit('USER_ABS_OBJS =\n');
end
emit('\n');
if ~isempty(fileNameInfo.auxInfo.sourceFiles)
    emit('AUX_ABS_OBJS = \\\n');
    for i=1:numel(fileNameInfo.auxInfo.sourceFiles)
        [~, nameStr] = fileparts(fileNameInfo.auxInfo.sourceFiles{i});
        objStr = [nameStr '.obj'];
        emit('		"%s" \\\n',objStr);
    end
else
    emit('AUX_ABS_OBJS =\n');
end
emit('\n');
emit('REQ_OBJS = $(REQ_SRCS:.cpp=.obj)\n');
emit('REQ_OBJS2 = $(REQ_OBJS:.c=.obj)\n');
emit('OBJS = $(REQ_OBJS2) $(USER_ABS_OBJS) $(AUX_ABS_OBJS)\n');
emit('OBJLIST_FILE = %s\n',fileNameInfo.machineObjListFile);

stateflowLibraryString = ['"', fileNameInfo.sfcMexLibFile ,'"'];
stateflowLibraryString = [stateflowLibraryString,' "', fileNameInfo.sfcDebugLibFile ,'"'];

emit('SFCLIB = %s\n',stateflowLibraryString);

if ~isempty(fileNameInfo.auxInfo.linkObjects)
    emit('AUX_LNK_OBJS = \\\n');
    for i=1:length(fileNameInfo.auxInfo.linkObjects)-1
        emit('     "%s" \\\n',fileNameInfo.auxInfo.linkObjects{i});
    end
    emit(' "%s"\n',fileNameInfo.auxInfo.linkObjects{end});
else
    emit('AUX_LNK_OBJS =\n');
end

if ~isempty(fileNameInfo.userLibraries)
    emit('USER_LIBS = \\\n');
    for i=1:length(fileNameInfo.userLibraries)-1
        emit('	"%s" \\\n',fileNameInfo.userLibraries{i});
    end
    emit('	"%s"\n',fileNameInfo.userLibraries{end});
else
    emit('USER_LIBS =\n');
end
numLinkMachines = length(fileNameInfo.linkLibFullPaths);
if numLinkMachines
    emit('LINK_MACHINE_LIBS = \\\n');
    for i = 1:numLinkMachines-1
        emit('	"%s" \\\n',fileNameInfo.linkLibFullPaths{i});
    end
    emit('	"%s"\n',fileNameInfo.linkLibFullPaths{end});
else
    emit('LINK_MACHINE_LIBS =\n');
end

emit('\n');
if ~isempty(fileNameInfo.dspLibFile)
    emit('DSP_LIBS    = "%s"\n',fileNameInfo.dspLibFile);
else
    emit('DSP_LIBS    =\n');
end

if ~isempty(fileNameInfo.blasLibFile)
    emit('BLAS_LIBS   = "%s"\n',fileNameInfo.blasLibFile);
else
    emit('BLAS_LIBS   =\n');
end

emit('\n');
emit('#--------------------------------- Rules --------------------------------------\n');
emit('\n');
if gTargetInfo.codingLibrary
    emit('$(MACHINE)_$(TARGET).lib : $(MAKEFILE) $(OBJS) $(SFCLIB) $(AUX_LNK_OBJS) $(USER_LIBS)\n');
    emit('	@echo ### Linking ...\n');
    emit('	$(LD) -lib /OUT:$(MACHINE)_$(TARGET).lib @$(OBJLIST_FILE) $(USER_LIBS)\n');
    emit('	@echo ### Created Stateflow library $@\n');
    
else
    if gTargetInfo.codingMEX && ~isempty(sf('get',gMachineInfo.target,'target.mexFileName'))
        emit('MEX_FILE_NAME_WO_EXT = %s\n',sf('get',gMachineInfo.target,'target.mexFileName'));
    else
        emit('MEX_FILE_NAME_WO_EXT = $(MACHINE)_$(TARGET)\n');
    end
    emit('MEX_FILE_NAME = $(MEX_FILE_NAME_WO_EXT).%s\n',mexext);
    mapCsfBinary = fullfile(fileNameInfo.matlabRoot,'bin',computer('arch'),'mapcsf.exe');
    if(~exist(mapCsfBinary,'file'))
        mapCsfBinary = fullfile(fileNameInfo.matlabRoot,'tools',computer('arch'),'mapcsf.exe');
        if(~exist(mapCsfBinary,'file'))
            mapCsfBinary = fullfile(fileNameInfo.matlabRoot,'tools','nt','mapcsf.exe');
            if(~exist(mapCsfBinary,'file'))
                mapCsfBinary = '';
            end
        end
    end
    
    if ~isempty(mapCsfBinary)
        emit('MEX_FILE_CSF =  $(MEX_FILE_NAME_WO_EXT).csf\n');
    else
        emit('MEX_FILE_CSF =\n');
    end
    
    emit('all : $(MEX_FILE_NAME) $(MEX_FILE_CSF)\n');
    emit('\n');
    libMexDir = fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft');
    emit('MEXLIB = "%s" "%s" "%s" "%s" "%s" "%s" "%s"\n',fullfile(libMexDir,'libmx.lib'),fullfile(libMexDir,'libmex.lib'),fullfile(libMexDir,'libmat.lib'),fullfile(libMexDir,'libfixedpoint.lib'),fullfile(libMexDir,'libut.lib'),fullfile(libMexDir,'libmwmathutil.lib'),fullfile(libMexDir,'libemlrt.lib'));
    emit('\n');
    emit('$(MEX_FILE_NAME) : $(MAKEFILE) $(OBJS) $(SFCLIB) $(AUX_LNK_OBJS) $(USER_LIBS)\n');
    emit('	@echo ### Linking ...\n');
    emit('	$(LD) $(LDFLAGS) $(AUXLDFLAGS) /OUT:$(MEX_FILE_NAME) /map:"$(MEX_FILE_NAME_WO_EXT).map" $(USER_LIBS) $(SFCLIB) $(AUX_LNK_OBJS) $(MEXLIB) $(LINK_MACHINE_LIBS) $(DSP_LIBS) $(BLAS_LIBS) @$(OBJLIST_FILE)\n');
    switch gTargetInfo.compilerName
        case 'intelc11msvs2008'
            emit('     mt -outputresource:"$(MEX_FILE_NAME);2" -manifest "$(MEX_FILE_NAME).manifest"\n');
    end
    emit('	@echo ### Created $@\n');
    emit('\n');
    if ~isempty(mapCsfBinary)
        emit('$(MEX_FILE_CSF) : $(MEX_FILE_NAME)\n');
        emit('	"%s" $(MEX_FILE_NAME)\n',mapCsfBinary);
    end
end

emit('.c.obj :\n');
emit('	@echo ### Compiling "$<"\n');
emit('	$(CC) $(CFLAGS) $(INCLUDE_PATH) "$<"\n');
emit('\n');
emit('.cpp.obj :\n');
emit('	@echo ### Compiling "$<"\n');
emit('	$(CC) $(CFLAGS) $(INCLUDE_PATH) "$<"\n');
emit('\n');
for i=1:length(userAbsSources)
    [~, nameStr] = fileparts(userAbsSources{i});
    objFileName = [nameStr '.obj'];
    emit('%s :	"%s"\n',objFileName,userSources{i});
    emit('	@echo ### Compiling "%s"\n',userSources{i});
    emit('	$(CC) $(CFLAGS) $(INCLUDE_PATH) "%s"\n',userSources{i});
end

fclose(file);
end