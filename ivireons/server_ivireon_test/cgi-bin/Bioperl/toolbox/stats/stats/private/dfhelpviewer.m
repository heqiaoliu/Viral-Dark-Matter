function dfhelpviewer(topic, errorname)
% DFHELPVIEWER  is a helper file for the Distribution Fitting Toolbox 
% DFHELPVIEWER Displays help for Distribution Fitting TOPIC. If the map file 
% cannot be found, an error is displayed using ERRORNAME

%   Copyright 2003-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $

mapfilename = [docroot '/toolbox/stats/stats.map'];
try
    helpview(mapfilename, topic);
catch
    message = sprintf('Unable to display help for %s\n', errorname);
    errordlg(message);
end
