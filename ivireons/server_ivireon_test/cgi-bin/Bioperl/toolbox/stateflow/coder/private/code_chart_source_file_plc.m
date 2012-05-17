function code_chart_source_file_plc(fileNameInfo,chart)


%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2009/11/13 05:20:01 $


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%  GLOBAL VARIABLES
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %%%%%%%%%%%%%%%%%%%%%%%%% Coding options
   global gTargetInfo gChartInfo gMachineInfo

   chartNumber = sf('get',chart,'chart.number');

   fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartSourceFiles{chartNumber+1});
   sf_echo_generating('Coder',fileName);

   file = fopen(fileName,'Wb');
   if file<3
      construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
      return;
   end

   
   try
       str = sf('Cg','emit_plc',chart);
   catch
       fclose(file);
       construct_coder_error([],sprintf('Errors occurred while generating file: %s.',fileName),1);
   end
   
   eStr = str{1};
   aStr = str{2};
   
   if sf('Private','is_sf_chart',chart)
       chartType = 'sf_chart';
   elseif sf('Private','is_eml_chart',chart)
       chartType = 'eml_chart';
   else
       chartType = 'unknown_chart';
   end
   
fprintf(file,'%s\n',get_boiler_plate_plc_comment(chartType,chart));
fprintf(file,'%s\n',eStr);
fprintf(file,'%s\n',aStr);
   
   fclose(file);
   %% try_indenting_file(fileName);
   