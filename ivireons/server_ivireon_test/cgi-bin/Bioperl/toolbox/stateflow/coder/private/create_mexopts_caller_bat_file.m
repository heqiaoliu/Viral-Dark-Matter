function create_mexopts_caller_bat_file(file,fileNameInfo)

% Copyright 2007 The MathWorks, Inc.

	if(~isempty(fileNameInfo.mexOptsFile))
    [pathStr, mexOptsFile, ext] = fileparts(fileNameInfo.mexOptsFile);
    copyfile(fileNameInfo.mexOptsFile,fileNameInfo.targetDirName,'f');
fprintf(file,'call "%s%s"\n',mexOptsFile,ext);
	end

