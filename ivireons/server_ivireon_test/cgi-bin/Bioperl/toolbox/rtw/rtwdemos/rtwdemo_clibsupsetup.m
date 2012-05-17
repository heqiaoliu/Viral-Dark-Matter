% Copyright 1994-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2007/11/17 22:01:49 $

function rtwdemo_clibsupsetup(val) 

cs = getActiveConfigSet(bdroot);
set_param(cs,'TargetFunctionLibrary',val);
set_param(bdroot,'dirty','off');
