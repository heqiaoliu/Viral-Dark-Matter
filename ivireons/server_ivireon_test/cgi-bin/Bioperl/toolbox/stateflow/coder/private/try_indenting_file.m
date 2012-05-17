function try_indenting_file(fileName)
% TRY_INDENTING_FILE(FILENAME)

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.6.2.7 $  $Date: 2009/06/16 05:46:27 $

	global gTargetInfo

	if gTargetInfo.codingRTW || gTargetInfo.codingHDL || gTargetInfo.codingPLC
		%%% we indent all these files as part of RTW build procedure. no need to do it now.
		return;
	end
	try
		sf('Private','c_beautifier',fileName);
    catch ME %#ok<NASGU>
	end
 
