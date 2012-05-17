function code_watcom_make_file(fileNameInfo)

% CODE_WATCOM_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.14.2.21.6.1 $  $Date: 2010/06/28 16:29:08 $

	global gMachineInfo gTargetInfo
	 
    function emit(format,varargin)
        fprintf(file,format,varargin{:});
    end

	code_machine_objlist_file(fileNameInfo);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.makeBatchFile);
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'Wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end
    create_mexopts_caller_bat_file(file,fileNameInfo);
fprintf(file,'wmake -f %s\n',fileNameInfo.watcomMakeFile);
	fclose(file);


	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.watcomMakeFile);
  sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'Wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	DOLLAR = '$';
	if(~isempty(fileNameInfo.userMakefiles))
		for i=1:length(fileNameInfo.userMakefiles)
fprintf(file,'!include $fileNameInfo.userMakefiles{i}\n');
		end
	end
fprintf(file,'MACHINE     = %s\n',gMachineInfo.machineName);
fprintf(file,'TARGET		= %s\n',gMachineInfo.targetName);

	if ~isempty(gMachineInfo.charts)
fprintf(file,'CHART_SRCS 	= &\n');
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
fprintf(file,'     %s&\n',chartSourceFiles{i});
        end
fprintf(file,'     %s\n',chartSourceFiles{numSrcFiles});
	else
fprintf(file,'CHART_SRCS =\n');
	end
fprintf(file,'MACHINE_SRC	= %s\n',fileNameInfo.machineSourceFile);
	if(~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction)
fprintf(file,'MACHINE_REG = %s\n',fileNameInfo.machineRegistryFile);
	else
fprintf(file,'MACHINE_REG = \n');
	end
	if ~gTargetInfo.codingLibrary && gTargetInfo.codingMEX
fprintf(file,'MEX_WRAPPER = %s\n',fileNameInfo.mexWrapperFile);
	else
fprintf(file,'MEX_WRAPPER =\n');
	end

	if(~isempty(fileNameInfo.userSources))
fprintf(file,'USER_SRCS 	= &\n');
		for i=1:length(fileNameInfo.userSources)-1
fprintf(file,'		%s&\n',fileNameInfo.userSources{i});
		end
fprintf(file,'		%s\n',fileNameInfo.userSources{end});

fprintf(file,'USER_ABS_SRCS 	= &\n');
		for i=1:length(fileNameInfo.userAbsSources)-1
fprintf(file,'		%s&\n',fileNameInfo.userAbsSources{i});
		end
fprintf(file,'		%s\n',fileNameInfo.userAbsSources{end});
		userSrcPathString	= '';
		if(~isempty(fileNameInfo.userAbsPaths))
			userSrcPathString = [fileNameInfo.userAbsPaths{1}];
			for i=2:length(fileNameInfo.userAbsPaths)
				userSrcPathString = [userSrcPathString,';',fileNameInfo.userAbsPaths{i}];
			end
		end
fprintf(file,'USER_SRC_PATHS = %s\n',userSrcPathString);
	else
fprintf(file,' \n');
fprintf(file,'USER_SRC_PATHS	= &\n');
fprintf(file,'USER_SRCS =\n');
fprintf(file,'USER_ABS_SRCS =\n');
fprintf(file,'USER_SRC_PATHS =\n');
	end

mlRootDir = sfAltPathName(fileNameInfo.matlabRoot);

fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.watcomMakeFile);

fprintf(file,'MATLAB_ROOT	= %s\n',mlRootDir);
fprintf(file,' \n');
fprintf(file,'#--------------------------------- Tool Locations -----------------------------\n');
fprintf(file,'#\n');
fprintf(file,'# Modify the following macro to reflect where you have installed\n');
fprintf(file,'# the Watcom C/C++ Compiler.\n');
fprintf(file,'#\n');
fprintf(file,'!ifndef %%WATCOM\n');
fprintf(file,'!error WATCOM environmental variable must be defined\n');
fprintf(file,'!else\n');
fprintf(file,'WATCOM = %s(%%WATCOM)\n',DOLLAR);
fprintf(file,'!endif\n');
fprintf(file,'  \n');
    emit('#---------------------------- Tool Definitions ---------------------------\n');
    emit('\n');
    if strcmp(fileNameInfo.sourceExtension, '.cpp')
        emit('CC     = wpp386\n');
    else
        emit('CC     = wcc386\n');
    end
    emit('LD     = wcl386\n');
    emit('LIBCMD = wlib\n');
    emit('LINKCMD = wlink\n');
    emit('\n');
fprintf(file,'#------------------------------ Include Path -----------------------------\n');
	userIncludeDirString = '';
	if(~isempty(fileNameInfo.userIncludeDirs))
		for i = 1:length(fileNameInfo.userIncludeDirs)
			userIncludeDirString	= [userIncludeDirString,fileNameInfo.userIncludeDirs{i},';'];
		end
	end
fprintf(file,'USER_INCLUDES = %s\n',userIncludeDirString);
fprintf(file,'  \n');
auxIncludeDirString = '';
if ~isempty(fileNameInfo.auxInfo.includePaths)
    for i = 1:length(fileNameInfo.auxInfo.includePaths)
        path = fileNameInfo.auxInfo.includePaths{i};
        auxIncludeDirString = [auxIncludeDirString,path,';'];
    end
end
fprintf(file,'AUX_INCLUDES   = %s\n',auxIncludeDirString);
fprintf(file,'\n');
fprintf(file,'MATLAB_INCLUDES = &\n');
fprintf(file,'%s(MATLAB_ROOT)\\simulink\\include;&\n',DOLLAR);
fprintf(file,'%s(MATLAB_ROOT)\\extern\\include;&\n',DOLLAR);
fprintf(file,'%s;&\n',sfAltPathName(fileNameInfo.sfcMexLibInclude));
fprintf(file,'%s;\n',sfAltPathName(fileNameInfo.sfcDebugLibInclude));
   if (~isempty(fileNameInfo.dspLibInclude))
fprintf(file,'DSP_INCLUDES    = %s;\n',sfAltPathName(fileNameInfo.dspLibInclude));
   else
fprintf(file,'DSP_INCLUDES    =   \n');
   end

fprintf(file,'  \n');
fprintf(file,'INCLUDES = %s(USER_INCLUDES)%s(AUX_INCLUDES)%s(MATLAB_INCLUDES)%s(DSP_INCLUDES)%s(%%INCLUDE)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'  \n');
fprintf(file,'#-------------------------------- C Flags --------------------------------\n');
fprintf(file,' \n');
fprintf(file,'\n');
fprintf(file,'OPT_OPTS = -ox\n');
fprintf(file,'CC_OPTS =   -bd -3s -e25 -ei -fpi87 -zp8 -zq -DMATLAB_MEX_FILE %s(OPT_OPTS) %s(OPTS)\n',DOLLAR,DOLLAR);
fprintf(file,'CFLAGS = %s(CC_OPTS)\n',DOLLAR);
fprintf(file,' \n');
auxLinkFlags = '';
if ~isempty(fileNameInfo.auxInfo.linkFlags)
    for i = 1:length(fileNameInfo.auxInfo.linkFlags)
        flag = fileNameInfo.auxInfo.linkFlags{i};
        auxLinkFlags = [auxLinkFlags,' ',flag];
    end
end
fprintf(file,'AUXLDFLAGS = %s\n',auxLinkFlags);
fprintf(file,'\n');
fprintf(file,'#------------------------------- Source Files ---------------------------------\n');
fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.machineObjListFile);

	stateflowLibraryString = sfAltPathName(fileNameInfo.sfcMexLibFile);
	stateflowLibraryString = [stateflowLibraryString,' ',...
                                 sfAltPathName(fileNameInfo.sfcDebugLibFile)];
   if (~isempty(fileNameInfo.dspLibFile))
      stateflowLibraryString = [stateflowLibraryString,' ',...
                               sfAltPathName(fileNameInfo.dspLibFile)];
   end
   if (~isempty(fileNameInfo.blasLibFile))
      stateflowLibraryString = [stateflowLibraryString,' ',...
                               sfAltPathName(fileNameInfo.blasLibFile)];
   end

fprintf(file,'SFCLIB = %s\n',stateflowLibraryString);

if ~isempty(fileNameInfo.auxInfo.linkObjects)
fprintf(file,'AUX_LNK_OBJS = &\n');
    for i=1:length(fileNameInfo.auxInfo.linkObjects)-1
fprintf(file,'    %s &\n',fileNameInfo.auxInfo.linkObjects{i});
    end
fprintf(file,'    %s\n',fileNameInfo.auxInfo.linkObjects{end});
else
    fprintf(file,'AUX_LNK_OBJS =\n');
end
    
	if(~isempty(fileNameInfo.userLibraries))
fprintf(file,'USER_LIBS = &\n');
		for i=1:length(fileNameInfo.userLibraries)-1
fprintf(file,'	%s &\n',fileNameInfo.userLibraries{i});
		end
fprintf(file,'	%s\n',fileNameInfo.userLibraries{end});
	else
fprintf(file,'USER_LIBS =\n');
	end
	numLinkMachines = length(fileNameInfo.linkLibFullPaths);
	if(~gTargetInfo.codingLibrary && numLinkMachines)
fprintf(file,'LINK_MACHINE_LIBS = &\n');
		for i = 1:numLinkMachines-1
fprintf(file,'	%s &\n',fileNameInfo.linkLibFullPaths{i});
		end
fprintf(file,'	%s\n',fileNameInfo.linkLibFullPaths{end});
	else
fprintf(file,'LINK_MACHINE_LIBS =\n');
	end
	emit('\n');
 
    function objname = src2obj(srcname)
        objname = regexprep(srcname,'(\.c|\.cpp)$','.obj', 'once');
    end

    emit('REQ_OBJS  = &\n');
    for i=1:length(fileNameInfo.userAbsSources)
        userSourceFile = fileNameInfo.userAbsSources{i};
        userObjFile = src2obj(userSourceFile);
        emit('%s &\n', userObjFile);
    end
    for i=1:numel(fileNameInfo.auxInfo.sourceFiles)
        [~, nameStr] = fileparts(fileNameInfo.auxInfo.sourceFiles{i});
        tflObjFile = [nameStr '.obj'];
        emit('%s &\n', tflObjFile);
    end
    for chart=gMachineInfo.charts
        chartNumber = sf('get',chart,'chart.number');
        for i = 1:length(fileNameInfo.chartSourceFiles{chartNumber+1})
            chartSourceFile = fileNameInfo.chartSourceFiles{chartNumber+1}{i};
            chartObjFile = src2obj(chartSourceFile);
            emit('%s &\n', chartObjFile);
        end
    end
    if ~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction
        machineRegistryFile = src2obj(fileNameInfo.machineRegistryFile);
        emit('%s &\n', machineRegistryFile);
    end
    if ~gTargetInfo.codingLibrary && gTargetInfo.codingMEX
        mexWrapperFile = src2obj(fileNameInfo.mexWrapperFile);
        emit('%s &\n', mexWrapperFile);
    end
    machineSourceFile = src2obj(fileNameInfo.machineSourceFile);
    emit('%s\n', machineSourceFile);
    emit('\n');

IPPLIB_NAME = fullfile(matlabroot,'lib',computer('arch'),'libippmwipt.lib');
fprintf(file,'IPPLIB = %s\n',IPPLIB_NAME);
 
fprintf(file,'OBJS = %s(REQ_OBJS)\n',DOLLAR);
	if gTargetInfo.codingLibrary
fprintf(file,'LIBS = %s(USER_LIBS)\n',DOLLAR);
	else
fprintf(file,'LIBS = %s(USER_LIBS) %s(AUX_LNK_OBJS) %s(LINK_MACHINE_LIBS) libmex.lib libmx.lib libfixedpoint.lib libut.lib libmwmathutil.lib libemlrt.lib %s(SFCLIB) %s(IPPLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
	end
fprintf(file,' \n');
fprintf(file,'#----------------------- Exported Environment Variables -----------------------\n');
fprintf(file,'#\n');
fprintf(file,'# Because of the 128 character command line length limitations in DOS, we\n');
fprintf(file,'# use environment variables to pass additional information to the WATCOM\n');
fprintf(file,'# Compiler and Linker\n');
fprintf(file,'#\n');
fprintf(file,' \n');
fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
fprintf(file,'.ERASE\n');
fprintf(file,' \n');
fprintf(file,'.BEFORE\n');
fprintf(file,'	@set INCLUDE=%s(INCLUDES)\n',DOLLAR);
fprintf(file,' \n');
	if gTargetInfo.codingLibrary
fprintf(file,'%s(MACHINE)_%s(TARGET).lib : %s(OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(LIBCMD) -q -n -l %s(MACHINE)_%s(TARGET).lib %s(LIBS) @%s(OBJLIST_FILE) \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);

	else
		if(gTargetInfo.codingMEX && ~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))
fprintf(file,'MEX_FILE_NAME = %s.%s\n',sf('get',gMachineInfo.target,'target.mexFileName'),mexext);
		else
fprintf(file,'MEX_FILE_NAME = %s(MACHINE)_%s(TARGET).%s\n',DOLLAR,DOLLAR,mexext);
		end

fprintf(file,'%s(MEX_FILE_NAME) : %s(MAKEFILE) %s(OBJS) %s(SFCLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(LINKCMD) name %s(MEX_FILE_NAME) system nt_dll export mexFunction %s(LDFLAGS) %s(AUXLDFLAGS) libpath %s library {%s(LIBS)} file {@%s(OBJLIST_FILE)} \n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,fullfile(mlRootDir,'extern\lib\win32\watcom'),DOLLAR,DOLLAR);
	end
fprintf(file,' \n');
fprintf(file,'# Source Path\n');
fprintf(file,'.c : %s(USER_SRC_PATHS)\n',DOLLAR);
fprintf(file,'.cpp : %s(USER_SRC_PATHS)\n',DOLLAR);
fprintf(file,' \n');
fprintf(file,'.c.obj:\n');
fprintf(file,'	@echo %s#%s#%s# Compiling "%s[@"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(CC) %s(CFLAGS) %s[@\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,' \n');
fprintf(file,'.cpp.obj:\n');
fprintf(file,'	@echo %s#%s#%s# Compiling "%s[@"\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(CC) %s(CFLAGS) %s[@\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,' \n');

	fclose(file);
end
