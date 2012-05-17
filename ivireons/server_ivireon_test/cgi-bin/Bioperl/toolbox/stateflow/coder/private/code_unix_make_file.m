function code_unix_make_file(fileNameInfo)
% CODE_UNIX_MAKE_FILE(FILENAMEINFO)

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.8.2.24 $  $Date: 2010/04/05 22:58:22 $
	
	global gMachineInfo gTargetInfo
	code_machine_objlist_file(fileNameInfo);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.unixMakeFile);
   sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'Wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	DOLLAR = '$';
fprintf(file,'#--------------------------- Tool Specifications -------------------------\n');
fprintf(file,'#\n');
fprintf(file,'# Modify the following macros to reflect the tools you wish to use for\n');
fprintf(file,'# compiling and linking your code.\n');
fprintf(file,'#\n');
	if(~isempty(fileNameInfo.userMakefiles))
		for i=1:length(fileNameInfo.userMakefiles)
fprintf(file,'include $fileNameInfo.userMakefiles{i}\n');
		end
	end
	if(gTargetInfo.codingMakeDebug)
fprintf(file,'CC = %s/bin/mex -g\n',matlabroot);
	else
fprintf(file,'CC = %s/bin/mex\n',matlabroot);
	end
fprintf(file,'LD = %s(CC)\n',DOLLAR);
fprintf(file,' \n');
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
fprintf(file,'MACHINE_REG = \n');
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

fprintf(file,'MAKEFILE    = %s\n',fileNameInfo.unixMakeFile);

fprintf(file,'MATLAB_ROOT	= %s\n',fullfile(sf('Root'),'..','..','..'));
fprintf(file,'BUILDARGS   = \n');
	

fprintf(file,'#------------------------------ Include/Lib Path ------------------------------\n');
fprintf(file,' \n');
userIncludeDirString = '';
if ~isempty(fileNameInfo.userIncludeDirs)
    for i = 1:length(fileNameInfo.userIncludeDirs)
        path = fileNameInfo.userIncludeDirs{i};
        userIncludeDirString = [userIncludeDirString,'-I',path,' ']; %#ok<AGROW>
    end
end
fprintf(file,'USER_INCLUDES = %s\n',userIncludeDirString);
auxIncludeDirString = '';
if ~isempty(fileNameInfo.auxInfo.includePaths)
    for i = 1:length(fileNameInfo.auxInfo.includePaths)
        path = fileNameInfo.auxInfo.includePaths{i};
        auxIncludeDirString = [auxIncludeDirString,'-I',path,' ']; %#ok<AGROW>
    end
end
fprintf(file,'AUX_INCLUDES = %s\n',auxIncludeDirString);
fprintf(file,'MATLAB_INCLUDES = -I%s(MATLAB_ROOT)/simulink/include \\\n',DOLLAR);
fprintf(file,'						-I%s(MATLAB_ROOT)/extern/include \\\n',DOLLAR);
fprintf(file,'						-I%s \\\n',fileNameInfo.sfcMexLibInclude);
fprintf(file,'						-I%s\n',fileNameInfo.sfcDebugLibInclude);
fprintf(file,'\n');
if (~isempty(fileNameInfo.dspLibInclude))
fprintf(file,'DSP_INCLUDES    = -I%s\n',fileNameInfo.dspLibInclude);
else
fprintf(file,'DSP_INCLUDES    =\n');
end 
fprintf(file,'\n');
fprintf(file,'INCLUDE_PATH = %s %s %s(MATLAB_INCLUDES) %s(DSP_INCLUDES) %s(COMPILER_INCLUDES)\n',userIncludeDirString,auxIncludeDirString,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,' \n');

fprintf(file,'#----------------- Compiler and Linker Options --------------------------------\n');
fprintf(file,' \n');
fprintf(file,'# Optimization Options\n');
	if(gTargetInfo.codingMakeDebug)
fprintf(file,'OPT_OPTS = \n');
    else
fprintf(file,'OPT_OPTS = -O\n');
    end
fprintf(file,'\n');
fprintf(file,'# Parallel Options\n');
    if(gTargetInfo.codingOpenMP)
fprintf(file,'PAR_OPTS = CFLAGS=\\"-fopenmp -fPIC\\" \n');
    else
fprintf(file,'PAR_OPTS = \n');
    end
fprintf(file,'        \n');
fprintf(file,'# General User Options\n');
fprintf(file,'OPTS =\n');
fprintf(file,' \n');
fprintf(file,'CC_OPTS = %s(OPT_OPTS) %s(OPTS) %s(PAR_OPTS)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'CPP_REQ_DEFINES = -DMATLAB_MEX_FILE\n');
fprintf(file,' \n');
fprintf(file,'# Uncomment this line to move warning level to W4\n');
fprintf(file,'# cflags = %s(cflags:W3=W4)\n',DOLLAR);
fprintf(file,'CFLAGS = %s(CC_OPTS) %s(CPP_REQ_DEFINES) %s(INCLUDE_PATH)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,' \n');
fprintf(file,'LDFLAGS = \n');
fprintf(file,' \n');
auxLinkFlags = '';
if ~isempty(fileNameInfo.auxInfo.linkFlags)
    for i = 1:length(fileNameInfo.auxInfo.linkFlags)
        flag = fileNameInfo.auxInfo.linkFlags{i};
        auxLinkFlags = [auxLinkFlags,' ',flag];
    end
end
fprintf(file,'AUXLDFLAGS = %s\n',auxLinkFlags);

fprintf(file,'#----------------------------- Source Files -----------------------------------\n');
fprintf(file,' \n');
fprintf(file,'REQ_SRCS  = %s(MACHINE_SRC) %s(MACHINE_REG) %s(MEX_WRAPPER) %s(CHART_SRCS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
	if(~isempty(userAbsSources))
fprintf(file,'USER_ABS_OBJS 	= \\\n');
		for i=1:length(userAbsSources)
			[pathStr, nameStr] = fileparts(userAbsSources{i});
			objStr = [nameStr '.o'];
fprintf(file,'		%s \\\n',objStr);
		end
	else
fprintf(file,'USER_ABS_OBJS =\n');
	end
fprintf(file,'\n');
if ~isempty(fileNameInfo.auxInfo.sourceFiles)
fprintf(file,'AUX_ABS_OBJS = \\\n');
    for i=1:numel(fileNameInfo.auxInfo.sourceFiles)
        [pathStr, nameStr] = fileparts(fileNameInfo.auxInfo.sourceFiles{i});
        objStr = [nameStr '.o'];
fprintf(file,'		%s \\\n',objStr);
    end
fprintf(file,'\n');
else
fprintf(file,'AUX_ABS_OBJS =\n');
end

fprintf(file,'REQ_OBJS = %s(REQ_SRCS:.cpp=.o)\n',DOLLAR);
fprintf(file,'REQ_OBJS2 = %s(REQ_OBJS:.c=.o)\n',DOLLAR);
fprintf(file,'OBJS = %s(REQ_OBJS2) %s(USER_ABS_OBJS) %s(AUX_ABS_OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'OBJLIST_FILE = %s\n',fileNameInfo.machineObjListFile);
	stateflowLibraryString = fileNameInfo.sfcMexLibFile;
	stateflowLibraryString = [stateflowLibraryString,' ',fileNameInfo.sfcDebugLibFile];
   if (~isempty(fileNameInfo.dspLibFile))
	stateflowLibraryString = [stateflowLibraryString,' ',fileNameInfo.dspLibFile];
   end
fprintf(file,'SFCLIB = %s\n',stateflowLibraryString);

if ~isempty(fileNameInfo.auxInfo.linkObjects)
fprintf(file,'AUX_LNK_OBJS = \\\n');
    for i=1:length(fileNameInfo.auxInfo.linkObjects)-1
fprintf(file,'    %s \\\n',fileNameInfo.auxInfo.linkObjects{i});
    end
fprintf(file,'    %s\n',fileNameInfo.auxInfo.linkObjects{end});
else
fprintf(file,'AUX_LNK_OBJS =\n');
end

	if(~isempty(fileNameInfo.userLibraries))
fprintf(file,'USER_LIBS = \\\n');
		for i=1:length(fileNameInfo.userLibraries)-1
fprintf(file,'	%s \\\n',fileNameInfo.userLibraries{i});
		end
fprintf(file,'	%s\n',fileNameInfo.userLibraries{end});
	else
fprintf(file,'USER_LIBS =\n');
	end
	numLinkMachines = length(fileNameInfo.linkLibFullPaths);
	if(numLinkMachines)
fprintf(file,'LINK_MACHINE_LIBS = \\\n');
		for i = 1:numLinkMachines-1
fprintf(file,'	%s \\\n',fileNameInfo.linkLibFullPaths{i});
		end
fprintf(file,'	%s\n',fileNameInfo.linkLibFullPaths{end});
	else
fprintf(file,'LINK_MACHINE_LIBS =\n');
	end

	arch = lower(computer);
fprintf(file,'FIXEDPOINTLIB = -L%s/bin/%s -lfixedpoint\n',matlabroot,arch);
fprintf(file,'UTLIB = -lut\n');
fprintf(file,'EMLRTLIB = -lemlrt\n');
fprintf(file,'MWMATHUTILLIB = -lmwmathutil\n');
fprintf(file,'BLASLIB= -lmwblascompat32\n');
fprintf(file,'IPPLIB = -L%s/bin/%s -lippmwipt\n',matlabroot,arch);
    if(gTargetInfo.codingOpenMP)
fprintf(file,'PARLIB = -lgomp\n');
    else
fprintf(file,'PARLIB = \n');
    end
 
fprintf(file,'  MAPCSF = %s/tools/%s/mapcsf\n',matlabroot,arch);
fprintf(file,'   # RUN_MAPCSF_ON_UNIX is defined only if MAPCSF exists on this platform.\n');
fprintf(file,'   ifneq (%s(wildcard %s(MAPCSF)),) # run MAPCSF if it exists on this platform\n',DOLLAR,DOLLAR);
fprintf(file,'      RUN_MAPCSF_ON_UNIX =  %s/tools/%s/mapcsf %s@\n',matlabroot,arch,DOLLAR);
fprintf(file,'   endif\n');

fprintf(file,' \n');
fprintf(file,'#--------------------------------- Rules --------------------------------------\n');
fprintf(file,' \n');
	if gTargetInfo.codingLibrary

fprintf(file,'DO_RANLIB = ranlib %s(MACHINE)_%s(TARGET).a\n',DOLLAR,DOLLAR);
fprintf(file,' \n');
fprintf(file,'%s(MACHINE)_%s(TARGET).a : %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(AUX_LNK_OBJS) %s(USER_LIBS)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	ar ruv %s(MACHINE)_%s(TARGET).a %s(OBJS)\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(DO_RANLIB)\n',DOLLAR);
	else
		if(gTargetInfo.codingMEX && ~isempty(sf('get',gMachineInfo.target,'target.mexFileName')))
fprintf(file,'MEX_FILE_NAME = %s.%s\n',sf('get',gMachineInfo.target,'target.mexFileName'),mexext);
		else
fprintf(file,'MEX_FILE_NAME = %s(MACHINE)_%s(TARGET).%s\n',DOLLAR,DOLLAR,mexext);
		end
fprintf(file,' \n');
fprintf(file,' %s(MEX_FILE_NAME): %s(MAKEFILE) %s(OBJS) %s(SFCLIB) %s(AUX_LNK_OBJS) %s(USER_LIBS) %s(MEXLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	@echo ### Linking ...\n');
fprintf(file,'	%s(CC) -silent LDFLAGS="\\%s%sLDFLAGS %s(AUXLDFLAGS)" -output %s(MEX_FILE_NAME) %s(OBJS) %s(AUX_LNK_OBJS) %s(USER_LIBS) %s(LINK_MACHINE_LIBS) %s(SFCLIB) %s(FIXEDPOINTLIB) %s(UTLIB) %s(MWMATHUTILLIB) %s(EMLRTLIB) %s(BLASLIB) %s(PARLIB) %s(IPPLIB)\n',DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'	%s(RUN_MAPCSF_ON_UNIX)\n',DOLLAR);
fprintf(file,'\n');
	end
fprintf(file,'%%.o :	%%.c\n');
fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
fprintf(file,'%%.o :	%%.cpp\n');
fprintf(file,'	%s(CC) -c %s(CFLAGS) %s<\n',DOLLAR,DOLLAR,DOLLAR);
fprintf(file,'\n');
		for i=1:length(fileNameInfo.userAbsSources)
			objFileName = fileNameInfo.userAbsSources{i};
			objFileName = code_unix_change_ext(objFileName, 'o');
fprintf(file,'%s :	%s\n',objFileName,fileNameInfo.userSources{i});
fprintf(file,'	%s(CC) -c %s(CFLAGS) %s\n',DOLLAR,DOLLAR,fileNameInfo.userSources{i});
		end

	fclose(file);

function result = code_unix_change_ext(filename, ext)

[path_str, name_str] = fileparts(filename);

result = [name_str '.' ext];
