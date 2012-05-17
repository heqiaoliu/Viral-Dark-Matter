function code_msvc_make_file(fileNameInfo)
% CODE_MSVC_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.20.4.28.4.1 $  $Date: 2010/06/23 17:29:02 $

	global gMachineInfo gTargetInfo
	code_machine_objlist_file(fileNameInfo);


	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);
  sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'Wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end
    create_mexopts_caller_bat_file(file,fileNameInfo);
fprintf(file,'nmake -f %s\n',fileNameInfo.msvcMakeFile);
	fclose(file);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.msvcMakeFile);
  sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'Wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end


	DOLLAR = '$';
fprintf(file,'# ------------------- Required for MSVC nmake ---------------------------------\n');
fprintf(file,'# This file should be included at the top of a MAKEFILE as follows:\n');
fprintf(file,'\n');
fprintf(file,'\n');
	if(~isempty(fileNameInfo.userMakefiles))
		for i=1:length(fileNameInfo.userMakefiles)
fprintf(file,'!include "%s"\n',fileNameInfo.userMakefiles{i});
		end
	end
        if(strcmp(computer,'PCWIN64'))
fprintf(file,'CPU = AMD64\n');
        end
fprintf(file,'!include <ntwin32.mak>\n');
fprintf(file,'\n');
fprintf(file,'MACHINE     = %s\n',gMachineInfo.machineName);
fprintf(file,'TARGET      = %s\n',gMachineInfo.targetName);
	if ~isempty(gMachineInfo.charts)
fprintf(file,'CHART_SRCS 	= \\\n');
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
fprintf(file,'     %s\\\n',chartSourceFiles{i});
        end
fprintf(file,'     %s\n',chartSourceFiles{numSrcFiles});
	else
fprintf(file,'CHART_SRCS =\n');
	end
fprintf(file,'MACHINE_SRC	= %s\n',fileNameInfo.machineSourceFile);
	if(~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction)
fprintf(file,'MACHINE_REG = %s\n',fileNameInfo.machineRegistryFile);
	else
fprintf(file,'MACHINE_REG =\n');
	end
	if ~gTargetInfo.codingLibrary && gTargetInfo.codingMEX
fprintf(file,'MEX_WRAPPER = %s\n',fileNameInfo.mexWrapperFile);
	else
fprintf(file,'MEX_WRAPPER =\n');
	end

   	userAbsSources = {};
   	userSources    = {};
   	for i=1:length(fileNameInfo.userAbsSources)
   		[pathStr, nameStr, extStr] = fileparts(fileNameInfo.userAbsSources{i});
   		extStr = lower(extStr);
   		if(strcmp(extStr, '.c') || strcmp(extStr,'.cpp'))
   			userAbsSources{end+1} = fileNameInfo.userAbsSources{i};
   			userSources{end+1}    = fileNameInfo.userSources{i};
   		else
   			error('Stateflow:UnexpectedError',['Unrecognized file extension: ' extStr]);
   		end
   	end

fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.msvcMakeFile);

fprintf(file,'MATLAB_ROOT	= %s\n',fileNameInfo.matlabRoot);
fprintf(file,'BUILDARGS   =\n');

fprintf(file,'\n');
fprintf(file,'#--------------------------- Tool Specifications ------------------------------\n');
fprintf(file,'#\n');
fprintf(file,'#\n');
fprintf(file,'MSVC_ROOT1 = %s(MSDEVDIR:SharedIDE=vc)\n',DOLLAR);
fprintf(file,'MSVC_ROOT2 = %s(MSVC_ROOT1:SHAREDIDE=vc)\n',DOLLAR);
fprintf(file,'MSVC_ROOT  = %s(MSVC_ROOT2:sharedide=vc)\n',DOLLAR);
fprintf(file,'\n');
fprintf(file,'# Compiler tool locations, CC, LD, LIBCMD:\n');
fprintf(file,'CC     = cl.exe\n');
fprintf(file,'LD     = link.exe\n');
fprintf(file,'LIBCMD = lib.exe\n');

fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
fprintf(file,'\n');
	userIncludeDirString = '';
	if(~isempty(fileNameInfo.userIncludeDirs))
		for i = 1:length(fileNameInfo.userIncludeDirs)
            thisIncDir = fileNameInfo.userIncludeDirs{i};
            if ~isempty(regexp(thisIncDir, '^[a-zA-Z]+:$', 'once'))
                % G602058: MSVC has a bug that a drive root represented by
                % "c:" is not recognized. The workaround is to use "c:\."
                thisIncDir = [thisIncDir '\.'];
            end
			userIncludeDirString	= [userIncludeDirString,' /I "',thisIncDir,'"'];
		end
	end
fprintf(file,'USER_INCLUDES   = %s\n',userIncludeDirString);
auxIncludeDirString = '';
if ~isempty(fileNameInfo.auxInfo.includePaths)
    for i = 1:length(fileNameInfo.auxInfo.includePaths)
        path = fileNameInfo.auxInfo.includePaths{i};
        auxIncludeDirString = [auxIncludeDirString,' /I "',path,'"'];
    end
end
fprintf(file,'AUX_INCLUDES   = %s\n',auxIncludeDirString);

fprintf(file,'ML_INCLUDES     = /I "%s(MATLAB_ROOT)\\extern\\include"\n',DOLLAR);
fprintf(file,'SL_INCLUDES     = /I "%s(MATLAB_ROOT)\\simulink\\include"\n',DOLLAR);
fprintf(file,'SF_INCLUDES     = /I "%s" /I "%s"\n',fileNameInfo.sfcMexLibInclude,fileNameInfo.sfcDebugLibInclude);
fprintf(file,'\n');
if (~isempty(fileNameInfo.dspLibInclude))
fprintf(file,'DSP_INCLUDES    = /I "%s"\n',fileNameInfo.dspLibInclude);
else
fprintf(file,'DSP_INCLUDES    =\n');
end
fprintf(file,'\n');
fprintf(file,'COMPILER_INCLUDES = /I "%s(MSVC_ROOT)\\include"\n',DOLLAR);
fprintf(file,'\n');
fprintf(file,'INCLUDE_PATH = %s(USER_INCLUDES) %s(AUX_INCLUDES) %s(ML_INCLUDES) %s(SL_INCLUDES) %s(SF_INCLUDES) %s(DSP_INCLUDES)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'LIB_PATH     = "%s(MSVC_ROOT)\\lib"\n',DOLLAR);

fprintf(file,'\n');
if(gTargetInfo.codingOpenMP)
fprintf(file,'CFLAGS = %s(COMPFLAGS) /MD /openmp\n',DOLLAR);
fprintf(file,'LDFLAGS = /nologo /openmp /dll /OPT:NOREF /export:mexFunction\n');
else
fprintf(file,'CFLAGS = %s(COMPFLAGS) /MD \n',DOLLAR);
fprintf(file,'LDFLAGS = /nologo /dll /OPT:NOREF /export:mexFunction\n');
end
auxLinkFlags = '';
if ~isempty(fileNameInfo.auxInfo.linkFlags)
    for i = 1:length(fileNameInfo.auxInfo.linkFlags)
        flag = fileNameInfo.auxInfo.linkFlags{i};
        auxLinkFlags = [auxLinkFlags,' ',flag];
    end
end
fprintf(file,'AUXLDFLAGS = %s\n',auxLinkFlags);
fprintf(file,'\n');


fprintf(file,'#----------------------------- Source Files -----------------------------------\n');
fprintf(file,'\n');
fprintf(file,'REQ_SRCS  = %s(MACHINE_SRC) %s(MACHINE_REG) %s(MEX_WRAPPER) %s(CHART_SRCS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
	if(~isempty(userAbsSources))
fprintf(file,'USER_ABS_OBJS 	= \\\n');
		for i=1:length(userAbsSources)
			[pathStr, nameStr] = fileparts(userAbsSources{i});
			objStr = [nameStr '.obj'];
fprintf(file,'		"%s" \\\n',objStr);
		end
	else
fprintf(file,'USER_ABS_OBJS =\n');
	end
fprintf(file,'\n');
if ~isempty(fileNameInfo.auxInfo.sourceFiles)
fprintf(file,'AUX_ABS_OBJS = \\\n');
    for i=1:numel(fileNameInfo.auxInfo.sourceFiles)
        [pathStr, nameStr] = fileparts(fileNameInfo.auxInfo.sourceFiles{i});
        objStr = [nameStr '.obj'];
fprintf(file,'		"%s" \\\n',objStr);
    end
else
fprintf(file,'AUX_ABS_OBJS =\n');
end
fprintf(file,'\n');
fprintf(file,'REQ_OBJS = %s(REQ_SRCS:.cpp=.obj)\n',DOLLAR);
fprintf(file,'REQ_OBJS2 = %s(REQ_OBJS:.c=.obj)\n',DOLLAR);
fprintf(file,'OBJS = %s(REQ_OBJS2) %s(USER_ABS_OBJS) %s(AUX_ABS_OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.machineObjListFile);

	stateflowLibraryString = ['"', fileNameInfo.sfcMexLibFile ,'"'];
	stateflowLibraryString = [stateflowLibraryString,' "', fileNameInfo.sfcDebugLibFile ,'"'];


fprintf(file,'SFCLIB = %s\n',stateflowLibraryString);

if ~isempty(fileNameInfo.auxInfo.linkObjects)
fprintf(file,'AUX_LNK_OBJS = \\\n');
    for i=1:length(fileNameInfo.auxInfo.linkObjects)-1
fprintf(file,'     "%s" \\\n',fileNameInfo.auxInfo.linkObjects{i});
    end
fprintf(file,' "%s"\n',fileNameInfo.auxInfo.linkObjects{end});
else
    fprintf(file,'AUX_LNK_OBJS =\n');
end
    
	if(~isempty(fileNameInfo.userLibraries))
fprintf(file,'USER_LIBS = \\\n');
		for i=1:length(fileNameInfo.userLibraries)-1
fprintf(file,'	"%s" \\\n',fileNameInfo.userLibraries{i});
		end
fprintf(file,'	"%s"\n',fileNameInfo.userLibraries{end});
	else
fprintf(file,'USER_LIBS =\n');
	end
	numLinkMachines = length(fileNameInfo.linkLibFullPaths);
	if(numLinkMachines)
fprintf(file,'LINK_MACHINE_LIBS = \\\n');
		for i = 1:numLinkMachines-1
fprintf(file,'	"%s" \\\n',fileNameInfo.linkLibFullPaths{i});
		end
fprintf(file,'	"%s"\n',fileNameInfo.linkLibFullPaths{end});
	else
fprintf(file,'LINK_MACHINE_LIBS =\n');
	end

fprintf(file,'\n');
if (~isempty(fileNameInfo.dspLibFile))
fprintf(file,'DSP_LIBS    = "%s"\n',fileNameInfo.dspLibFile);
else
fprintf(file,'DSP_LIBS    =\n');
end

if (~isempty(fileNameInfo.blasLibFile))
fprintf(file,'BLAS_LIBS   = "%s"\n',fileNameInfo.blasLibFile);
else
fprintf(file,'BLAS_LIBS   =\n');
end

fprintf(file,'\n');
fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
fprintf(file,'\n');
	if gTargetInfo.codingLibrary
fprintf(file,'%s(MACHINE)_%s(TARGET).lib : %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(AUX_LNK_OBJS) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	%s(LD) -lib /OUT:%s(MACHINE)_%s(TARGET).lib @%s(OBJLIST_FILE) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Created Stateflow library %s@\n',DOLLAR);

	else
		if(gTargetInfo.codingMEX && ~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))

fprintf(file,'MEX_FILE_NAME_WO_EXT = %s\n',sf('get',gMachineInfo.target,'target.mexFileName'));
		else
fprintf(file,'MEX_FILE_NAME_WO_EXT = %s(MACHINE)_%s(TARGET)\n',DOLLAR,DOLLAR);
		end
fprintf(file,'MEX_FILE_NAME = %s(MEX_FILE_NAME_WO_EXT).%s\n',DOLLAR,mexext);
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
        mapCsfBinary = '';

		if(~isempty(mapCsfBinary))
fprintf(file,'MEX_FILE_CSF =  %s(MEX_FILE_NAME_WO_EXT).csf\n',DOLLAR);
		else
fprintf(file,'MEX_FILE_CSF =\n');
		end

fprintf(file,'all : %s(MEX_FILE_NAME) %s(MEX_FILE_CSF)\n',DOLLAR,DOLLAR);
fprintf(file,'\n');
		libMexDir = fullfile(matlabroot,'extern','lib',computer('arch'),'microsoft');
        libMATLABDir = fullfile(fileNameInfo.matlabRoot,'lib',computer('arch'));
fprintf(file,'MEXLIB = "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"\n',fullfile(libMexDir,'libmx.lib'),fullfile(libMexDir,'libmex.lib'),fullfile(libMexDir,'libmat.lib'),fullfile(libMexDir,'libfixedpoint.lib'),fullfile(libMexDir,'libut.lib'),fullfile(libMexDir,'libmwmathutil.lib'),fullfile(libMexDir,'libemlrt.lib'),fullfile(libMATLABDir,'libippmwipt.lib'));
fprintf(file,'\n');
fprintf(file,'%s(MEX_FILE_NAME) : %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(AUX_LNK_OBJS) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	%s(LD) %s(LDFLAGS) %s(AUXLDFLAGS) /OUT:%s(MEX_FILE_NAME) /map:"%s(MEX_FILE_NAME_WO_EXT).map" %s(USER_LIBS) %s(SFCLIB) %s(AUX_LNK_OBJS) %s(MEXLIB) %s(LINK_MACHINE_LIBS) %s(DSP_LIBS) %s(BLAS_LIBS) @%s(OBJLIST_FILE)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
    switch gTargetInfo.compilerName
        case {'msvc80','msvc90','msvc100'}
fprintf(file,'     mt -outputresource:"%s(MEX_FILE_NAME);2" -manifest "%s(MEX_FILE_NAME).manifest"\n',DOLLAR,DOLLAR);
    end
fprintf(file,'	@echo ### Created %s@\n',DOLLAR);
fprintf(file,'\n');
		if(~isempty(mapCsfBinary))
fprintf(file,'%s(MEX_FILE_CSF) : %s(MEX_FILE_NAME)\n',DOLLAR,DOLLAR);
fprintf(file,'	"%s" %s(MEX_FILE_NAME)\n',mapCsfBinary,DOLLAR);
		end
	end

fprintf(file,'.c.obj :\n');
fprintf(file,'	@echo ### Compiling "%s<"\n',DOLLAR);
fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s<"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
fprintf(file,'.cpp.obj :\n');
fprintf(file,'	@echo ### Compiling "%s<"\n',DOLLAR);
fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s<"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
		for i=1:length(userAbsSources)
			[pathStr, nameStr] = fileparts(userAbsSources{i});
			objFileName = [nameStr '.obj'];
fprintf(file,'%s :	"%s"\n',objFileName,userSources{i});
fprintf(file,'	@echo ### Compiling "%s"\n',userSources{i});
fprintf(file,'	%s(CC) %s(CFLAGS) %s(INCLUDE_PATH) "%s"\n',DOLLAR,DOLLAR,DOLLAR,userSources{i});
		end

	fclose(file);
