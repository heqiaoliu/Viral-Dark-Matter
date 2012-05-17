function result = sf_display(compName,msgString,displayLevel)
%SF_DISPLAY(COMPNAME, MSGSTRING)
% writes msgString to the logfile and displays it
% displayLevel == 1 ==> not important
% displayLevel == 2 ==> important message.

%   Vijaya Raghavan
%   Copyright 1995-2009 The MathWorks, Inc.
%   $Revision: 1.6.2.9 $  $Date: 2009/08/23 19:51:55 $

if(nargin<3)
    displayLevel = 1;
end
log_file_manager('add_log',0,msgString);
if testing_stateflow_in_bat
    fprintf(1,'%s',msgString);
end

