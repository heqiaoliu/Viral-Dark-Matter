function [oldConfig, allConfigs] = pctDefaultParallelConfig(newConfig)
; %#ok Undocumented
% Helper function for defaultParallelConfig.  Returns the names of all the 
% configurations and the current default configuration.  If a new default name 
% is supplied, then sets it as the default and returns the name of the old default.

%    Copyright 2009 The MathWorks, Inc.

%   $Revision: 1.1.6.1 $  $Date: 2009/09/23 13:59:17 $

allConfigs = distcomp.configserializer.getAllNames();
oldConfig  = distcomp.configserializer.getCurrentName();

if (nargin > 0)
    % Set the default configuration.  This will check whether the config
    % exists.
    distcomp.configserializer.setCurrentName(newConfig);
end
