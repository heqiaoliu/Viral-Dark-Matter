function code_chart_header_file_sfun(fileNameInfo, chart, specsIdx)


%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.18 $  $Date: 2009/11/13 05:19:52 $

    global gChartInfo gTargetInfo

    %%% Collect all testpoint data and states. This calculation is instance
    %%% dependent, hence has to be done in chart code gen loop.
    gChartInfo.testPoints = sf('TestPointsIn', chart, 0.0, gChartInfo.codingDebug && ~gTargetInfo.codingExtMode);
    gChartInfo.hasTestPoint = ~isempty(gChartInfo.testPoints.data) || ~isempty(gChartInfo.testPoints.state);

    check_include_custom_bus_header(chart);
   
	chartNumber = sf('get',chart,'chart.number');
	chartUniqueName = sf('CodegenNameOf',chart);

	fileName = fullfile(fileNameInfo.targetDirName,fileNameInfo.chartHeaderFiles{chartNumber+1}{specsIdx});
    sf_echo_generating('Coder',fileName);

	file = fopen(fileName,'Wt');
	if file<3
		construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
		return;
	end

fprintf(file,'#ifndef __%s_h__\n',chartUniqueName);
fprintf(file,'#define __%s_h__\n',chartUniqueName);
fprintf(file,'\n');
fprintf(file,'/* Include files */\n');
fprintf(file,'#include "sfc_sf.h"\n');
fprintf(file,'#include "sfc_mex.h"\n');
fprintf(file,'#include "rtwtypes.h"\n');

   if gChartInfo.hasTestPoint
fprintf(file,'#include "rtw_capi.h"\n');
fprintf(file,'#include "rtw_modelmap.h"\n');
   end

fprintf(file,'\n');

   file = dump_module(fileName,file,chart,'header');
   if file < 3
     return;
   end

fprintf(file,'extern void sf_%s_get_check_sum(mxArray *plhs[]);\n',chartUniqueName);
fprintf(file,'extern void %s_method_dispatcher(SimStruct *S, int_T method, void *data);\n',chartUniqueName);
fprintf(file,'\n');
fprintf(file,'#endif\n');
fprintf(file,'\n');
	fclose(file);
	try_indenting_file(fileName);

    
function check_include_custom_bus_header(chart)

global gMachineInfo

needIncludeCustomBusHeader = false;
structData = sf('GetChartStructData', chart, 1);
for i = 1:length(structData)
    data = idToHandle(sfroot, structData(i));
    headerFile = sf('Private', 'get_bus_object_header_file', data.CompiledType, true);
    if ~isempty(headerFile)
        needIncludeCustomBusHeader = true;
        break;
    end
end

if needIncludeCustomBusHeader
    customCodeSettings = get_custom_code_settings(gMachineInfo.target, gMachineInfo.parentTarget);
    if isempty(regexp(customCodeSettings.customCode, '(^|\n)\s*#include\s*"[^"\n]+"', 'once'))
        msg = sprintf('Data ''%s'' (#%d) has compiled type defined by bus object ''%s'', which specifies custom header file ''%s''.', ...
                      data.Name, data.Id, data.CompiledType, headerFile);
        msg = sprintf('%s\nThis custom header file, which contains typedef for the bus object type, must be directly or indirectly included in model''s simulation target options, ''Custom Code=>Include Code'' field.', msg);
        msg = sprintf('%s\nNo valid ''#include "<headerfile>"'' is detected in ''Custom Code=>Include Code'' field for simulation target ''sfun'' (#%d).', msg, customCodeSettings.relevantTargetId);
        construct_coder_error(chart, msg, 1);
    end
end
