function code_machine_source_file(fileNameInfo,machine,target)
% CODE_MACHINE_SOURCE_FILE(FILENAMEINFO,MACHINE,TARGET)

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.40.2.6 $  $Date: 2008/01/15 19:02:57 $

	global gTargetInfo 

	if gTargetInfo.codingSFunction
    	code_machine_source_file_sfun(fileNameInfo);
    elseif gTargetInfo.codingRTW
    	code_machine_source_file_rtw(fileNameInfo);
    elseif gTargetInfo.codingHDL
        % Do nothing for now
    elseif gTargetInfo.codingPLC
        % Do nothing for now
    else
    	code_machine_source_file_custom(fileNameInfo);
	end

