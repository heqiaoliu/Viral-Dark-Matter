function code_chart_header_file(fileNameInfo, chart, specsIdx)


%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.51.2.10 $  $Date: 2009/11/13 05:19:50 $

	
   global gTargetInfo
    
   if gTargetInfo.codingSFunction
      code_chart_header_file_sfun(fileNameInfo,chart,specsIdx);
   elseif gTargetInfo.codingRTW
      code_chart_header_file_rtw(fileNameInfo,chart,specsIdx);
   elseif gTargetInfo.codingHDL
      %code_chart_header_file_hdl(fileNameInfo,chart);
   elseif gTargetInfo.codingPLC
      %code_chart_header_file_plc(fileNameInfo,chart);
   else
      code_chart_header_file_custom(fileNameInfo,chart);   
   end

