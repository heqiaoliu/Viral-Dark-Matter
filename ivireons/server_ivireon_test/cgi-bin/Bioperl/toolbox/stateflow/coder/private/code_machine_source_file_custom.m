function code_machine_source_file_custom(fileNameInfo)
% CODE_MACHINE_SOURCE_FILE(FILENAMEINFO,MACHINE,TARGET)

%   Copyright 1995-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2006/06/20 20:46:25 $


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%  GLOBAL VARIABLES
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	global gMachineInfo  gTargetInfo
		
    machine = gMachineInfo.machineId;

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.machineSourceFile);
    sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'Wt');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end             
    
fprintf(file,'%s\n',get_boiler_plate_comment('machine',gMachineInfo.machineId));
    customCodeSettings = get_custom_code_settings(gMachineInfo.target,gMachineInfo.parentTarget);
    customCodeString = customCodeSettings.customCode;

fprintf(file,'/* Include files */   \n');
	if(~isempty(customCodeString))
fprintf(file,'#define IN_SF_MACHINE_SOURCE 1\n');
	end
fprintf(file,'#include "%s"\n',fileNameInfo.machineHeaderFile);
	for i = 1:length(fileNameInfo.chartHeaderFiles)
fprintf(file,'#include "%s"\n',fileNameInfo.chartHeaderFiles{i});
	end
fprintf(file,'\n');
   file = dump_module(fileName,file,machine,'source');
   if file < 3
     return;
   end
   
fprintf(file,'\n');
	fclose(file);
	try_indenting_file(fileName);

