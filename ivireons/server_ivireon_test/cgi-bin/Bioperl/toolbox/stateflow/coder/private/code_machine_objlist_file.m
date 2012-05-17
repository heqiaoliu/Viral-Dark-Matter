function [objectFileList, sourceFileList] = code_machine_objlist_file(fileNameInfo,extraSourceFileList,extraLibraryList)

% [OBJECTFILELIST, SOURCEFILELIST] = CODE_MACHINE_OBJLIST_FILE(FILENAMEINFO,EXTRASOURCEFILELIST,EXTRALIBRARYLIST)

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.6.2.11 $  $Date: 2009/07/03 14:41:57 $

	global gMachineInfo gTargetInfo

	if(nargin<3)
		extraLibraryList = {};
	end
	if(nargin<2)
		extraSourceFileList= {};
	end
	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineObjListFile);
    sf_echo_generating('Coder',fileName);
	file = fopen(fileName,'Wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
	end

	objectFileCount = length(fileNameInfo.userAbsSources)...
                            +length(fileNameInfo.auxInfo.sourceFiles)...
                            +length(gMachineInfo.charts)...
                            +(~gTargetInfo.codingLibrary & gTargetInfo.codingSFunction)...
                            +(~gTargetInfo.codingLibrary & gTargetInfo.codingMEX)+1;


	objectFileList = cell(1,objectFileCount);
        sourceFileList = cell(1,length(fileNameInfo.userAbsSources));
	counter = 1;
	for i=1:length(fileNameInfo.userAbsSources)
		thisSourceFile = fileNameInfo.userAbsSources{i};
		[pathStr,nameStr] = fileparts(thisSourceFile);
		thisObjFile = [nameStr,'.obj'];
fprintf(file,'%s\n',thisObjFile);
		sourceFileList{counter} = fileNameInfo.userSources{i};
		objectFileList{counter} = thisObjFile;
		counter = counter+1;
	end
    for i=1:length(fileNameInfo.auxInfo.sourceFiles)
        thisSourceFile = fileNameInfo.auxInfo.sourceFiles{i};
        [pathStr,nameStr] = fileparts(thisSourceFile);
        thisObjFile = [nameStr,'.obj'];
fprintf(file,'%s\n',thisObjFile);
        counter = counter+1;
    end
	for chart=gMachineInfo.charts
		chartNumber = sf('get',chart,'chart.number');
        for i = 1:length(fileNameInfo.chartSourceFiles{chartNumber+1})
            thisSourceFile = fileNameInfo.chartSourceFiles{chartNumber+1}{i};
            sourceFileList{counter} = thisSourceFile;
            [pathStr,nameStr] = fileparts(thisSourceFile);
            thisObjFile = [nameStr,'.obj'];
fprintf(file,'%s\n',thisObjFile);
            objectFileList{counter} = thisObjFile;
            counter = counter+1;
        end
	end
	if ~gTargetInfo.codingLibrary && gTargetInfo.codingSFunction
		thisSourceFile = fileNameInfo.machineRegistryFile;
		sourceFileList{counter} = thisSourceFile;
		[pathStr,nameStr] = fileparts(thisSourceFile);
		thisObjFile = [nameStr,'.obj'];
fprintf(file,'%s\n',thisObjFile);
		objectFileList{counter} = thisObjFile;
		counter = counter+1;
	end
	if ~gTargetInfo.codingLibrary && gTargetInfo.codingMEX
		thisSourceFile = fileNameInfo.mexWrapperFile;
		sourceFileList{counter} = thisSourceFile;
		[pathStr,nameStr] = fileparts(thisSourceFile);
		thisObjFile = [nameStr,'.obj'];
fprintf(file,'%s\n',thisObjFile);
		objectFileList{counter} = thisObjFile;
		counter = counter+1;
	end
	thisSourceFile = fileNameInfo.machineSourceFile;
	sourceFileList{counter} = thisSourceFile;
	[pathStr,nameStr] = fileparts(thisSourceFile);
	thisObjFile = [nameStr,'.obj'];
fprintf(file,'%s\n',thisObjFile);
	objectFileList{counter} = thisObjFile;
	counter = counter+1;

	for i=1:length(extraSourceFileList)
		[pathName,thisSourceFile] = sf('Private','strip_path_from_name',extraSourceFileList{i});
		[pathStr,nameStr] = fileparts(thisSourceFile);
		thisObjFile = [nameStr,'.obj'];
fprintf(file,'%s\n',thisObjFile);
		sourceFileList{counter} = extraSourceFileList{i};
		objectFileList{counter} = thisObjFile;
		counter = counter+1;
	end

	for i=1:length(extraLibraryList)
fprintf(file,'%s\n',extraLibraryList{i});
		objectFileList{counter} = extraLibraryList{i};
		counter = counter+1;
	end

	fclose(file);
