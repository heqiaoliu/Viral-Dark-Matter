function code_chart_source_file(fileNameInfo, chart, specsIdx)
%   Copyright 1995-2010 The MathWorks, Inc.
   global  gTargetInfo

   if gTargetInfo.codingSFunction
       code_chart_source_file_sfun(fileNameInfo,chart,specsIdx);
   elseif gTargetInfo.codingRTW
       code_chart_source_file_rtw(fileNameInfo,chart,specsIdx);
   elseif gTargetInfo.codingHDL
       % Do nothing!  The empty elsif avoids entering the 'else' clause.
   elseif gTargetInfo.codingPLC
       code_chart_source_file_plc(fileNameInfo,chart);
   else
       code_chart_source_file_custom(fileNameInfo,chart);
   end

