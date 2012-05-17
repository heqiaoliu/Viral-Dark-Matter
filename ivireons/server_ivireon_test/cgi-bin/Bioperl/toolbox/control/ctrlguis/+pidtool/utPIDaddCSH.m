function utPIDaddCSH(mapfile,javaComp,topic)
% PID helper function

% This function add CSH links to GUI components

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2010/03/26 17:21:32 $

mapfile = fullfile(docroot,'toolbox',mapfile,sprintf('%s.map',mapfile));
com.mathworks.mlwidgets.help.SimpleContextHelpProvider.setHelpForComponent(javaComp,mapfile,topic);
com.mathworks.mlwidgets.help.ContextHelpPopupTriggerHandler.attachTo(javaComp);
