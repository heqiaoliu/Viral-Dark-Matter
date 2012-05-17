function sf_echo_generating( componentName, fullFileName, printFullPath)

%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.9.2.5 $  $Date: 2009/06/16 05:46:24 $

	if(nargin<3)
		printFullPath = 0;
	end
  % Note: Need the extra space at the end of the display line so that
  %       the hyperlink hand is termintated correctly when moving to
  %       the right of the hyperlinked diagnostic line.
	[filePath,fileName,fileExt] = fileparts(fullFileName);
	if(printFullPath==0)
		sf('Private','sf_display',componentName,sprintf('     "%s%s"\n',fileName,fileExt));
	else
		sf('Private','sf_display',componentName,sprintf('     "%s"\n',fullFileName));
	end

	% delete the corresponding object file as
	% in order to get around gmake bugs with timestamp
	% checking on fast glnx machines G124842
	if(ispc)
		objFile = fullfile(filePath,[fileName,'.obj']);
	else
		objFile = fullfile(filePath,[fileName,'.o']);
	end
	if(exist(objFile,'file'))
        [prevWarnMsg, prevWarnId] = lastwarn;
        warnFlag = warning;
        warning('off'); %#ok<WNOFF>
        try
			sf('Private', 'sf_delete_file', objFile);
        catch ME %#ok<NASGU>
        end
        lastwarn(prevWarnMsg, prevWarnId);
        warning(warnFlag);
	end
	return;
