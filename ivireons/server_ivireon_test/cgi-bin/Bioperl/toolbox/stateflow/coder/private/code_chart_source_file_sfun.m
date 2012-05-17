function code_chart_source_file_sfun(fileNameInfo, chart, specsIdx)


%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $  $Date: 2010/04/05 22:58:18 $


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%  GLOBAL VARIABLES
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%% Coding options
   global gTargetInfo  gChartInfo gMachineInfo

 	chartNumber = sf('get',chart,'chart.number');
	chartUniqueName = sf('CodegenNameOf',chart);

   fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1}{specsIdx});
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'Wt');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end

fprintf(file,'/* Include files */\n');

   if ~isempty(fileNameInfo.blasIncludeFile)
fprintf(file,'#include "%s"\n',fileNameInfo.blasIncludeFile);
   end
   if ~isempty(fileNameInfo.openMPIncludeFile)
fprintf(file,'#include "%s"\n',fileNameInfo.openMPIncludeFile);
   end
fprintf(file,'#include "%s"\n',[fileNameInfo.machineHeaderFile(1:end-length(fileNameInfo.headerExtension)),'.h']);
fprintf(file,'#include "%s"\n',[fileNameInfo.chartHeaderFiles{chartNumber+1}{specsIdx}(1:end-length(fileNameInfo.headerExtension)),'.h']);
   % Make sure all recorded TFL header files are included into the source file
   tfl = get_param(gMachineInfo.mainMachineName, 'SimTargetFcnLibHandle');
   tflHeaders = tfl.getRecordedUsedHeaders;
   for fileIdx = 1:length(tflHeaders)
fprintf(file,'#include %s\n',tflHeaders{fileIdx});
   end
   tfl.resetUsageCounts;
   if(gChartInfo.codingDebug)
fprintf(file,'#define CHARTINSTANCE_CHARTNUMBER (%schartNumber)\n',gChartInfo.chartInstanceVarName);
fprintf(file,'#define CHARTINSTANCE_INSTANCENUMBER (%sinstanceNumber)\n',gChartInfo.chartInstanceVarName);
fprintf(file,'#include "%s"\n',fileNameInfo.sfDebugMacrosFile);
   end

   code_sfun_imported_functions(file, chart);

   file = dump_module(fileName,file,chart,'source');
   if file < 3
     return;
   end


   file = code_sfun_glue_code(fileNameInfo,file,chart,chartUniqueName,specsIdx);
fprintf(file,'\n');
   fclose(file);
   try_indenting_file(fileName);
