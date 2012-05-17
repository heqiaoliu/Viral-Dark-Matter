% RTWMAKECFG adds include and source directories to rtw make files.
%   makeInfo=RTWMAKECFG returns a structured array containing build
%   info.Please refer to the rtwmakecfg API section in the Real-Time workshop
%   Documentation for details on the format of this structure.  

%   Copyright 1994-2005 The MathWorks, Inc.

%   $Revision: 1.3.2.3 $Date:


function makeInfo=rtwmakecfg()
  makeInfo.includePath = {...
      fullfile(matlabroot,'toolbox','fuzzy','fuzzy','src') };
  makeInfo.sourcePath = { ...
      fullfile(matlabroot,'toolbox','fuzzy','fuzzy','src') };
  disp('### Include Fuzzy Logic Toolbox directories');
