function code_machine_header_file(fileNameInfo)
% CODE_MACHINE_HEADER_FILE(FILENAMEINFO)

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.49.2.6 $  $Date: 2008/01/15 19:02:56 $

   global gTargetInfo

   if gTargetInfo.codingSFunction
      code_machine_header_file_sfun(fileNameInfo);
   elseif gTargetInfo.codingRTW
      code_machine_header_file_rtw(fileNameInfo);
   elseif gTargetInfo.codingHDL
      % Do nothing for now
   elseif gTargetInfo.codingPLC
      % Do nothing for now
   else
      code_machine_header_file_custom(fileNameInfo);
   end

	 		