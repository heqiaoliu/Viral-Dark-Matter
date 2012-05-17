function [oldConfig, allConfigs] = defaultParallelConfig(varargin)
%defaultParallelConfig controls the default parallel computing configuration
%   The defaultParallelConfig function allows you to programmatically get
%   and set the default parallel configuration, as well as obtain a list
%   of all valid configurations.  
%
%   [CONFIG, ALLCONFIGS] = defaultParallelConfig returns the name of the
%   default parallel computing configuration, as well as a cell array
%   containing the names of all available configurations.
%
%   [OLDCONFIG, ALLCONFIGS] = defaultParallelConfig(NEWCONFIG) sets the
%   default parallel computing configuration to be NEWCONFIG and returns the
%   previous default configuration as well as a cell array containing the
%   names of all available configurations.
%
%   Note that the settings specified for defaultParallelConfig are saved as a
%   part of the user's MATLAB preferences.
%
%   The cell array ALLCONFIGS always contains a configuration called 'local'
%   for the local scheduler.  The default configuration returned by
%   defaultParallelConfig is guaranteed to be found in ALLCONFIGS.
%
%   If the default configuration has been deleted, or if it has never been
%   set, defaultParallelConfig returns 'local' as the default
%   configuration.
%
%   See also: MATLABPOOL, PMODE, findResource.

%  Copyright 2007-2009 The MathWorks, Inc.

% call the helper function to set the actual default
[oldConfig, allConfigs] = pctDefaultParallelConfig(varargin{:});

if (nargin > 0)
    % Refresh the config and select the new default one
    com.mathworks.toolbox.distcomp.configui.ConfigurationManagerUI.refreshAndSelectConfig(varargin{1});
end

