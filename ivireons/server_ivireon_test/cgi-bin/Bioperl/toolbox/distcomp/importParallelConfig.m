function configName = importParallelConfig(filename)
%importParallelConfig Import a configuration .mat file
%   The importParallelConfig function allows you to import a configuration
%   that was stored in a .mat file.
%
%   CONFIGNAME = importParallelConfig(FILENAME) imports the configuration
%   stored in the specified file and returns the name of the imported
%   configuration.  If FILENAME has no extension, .mat is assumed.
%   Each configuration .mat file contains only one configuration.  If a
%   configuration with the same name already exists, an extension is added
%   to the name of the imported configuration.
%
%   The imported configuration can be used with any functions that support the
%   use of configurations.  importParallelConfig does not set the imported
%   configuration as the default; you can set it as the default configuration
%   by using the defaultParallelConfig function.
%
%   To export a configuration, use the Configurations Manager.  In the MATLAB
%   Parallel menu, select Manage Configurations to open the Configurations
%   Manager.  Configurations that were exported in a previous release are
%   upgraded during import.
%
%   Note that the configurations imported using importParallelConfig are
%   saved as a part of the user's MATLAB preferences, so these configurations
%   are available in your subsequent MATLAB sessions without importing again.
%
%   Examples:
%   Import a configuration from the file Config01.mat and use it to open a
%   pool of MATLAB workers.
%     conf_1 = importParallelConfig('Config01')
%     matlabpool('open', conf_1)
%
%   Import a configuration from file ConfigMaster.mat and set it as the default
%   parallel configuration.
%     def_config = importParallelConfig('ConfigMaster')
%     defaultParallelConfig(def_config)
%
%   See also: defaultParallelConfig

%   Copyright 2009 The MathWorks, Inc.

%   $Revision: 1.1.6.1 $  $Date: 2009/09/23 13:59:16 $

% Check that there is one input
error(nargchk(1, 1, nargin, 'struct'));

suppliedFilename = filename;
% Find out if the filename contains an extension
[~, ~, ext] = fileparts(suppliedFilename);
% Assume .mat extension if none is supplied
if isempty(ext)
    filename = sprintf('%s.mat', filename);
end

% Check that the file exists
if ~exist(filename, 'file')
    error('distcomp:importParallelConfig:InvalidFilename', ...
        'Failed to locate file %s', suppliedFilename)
end

% Do the actual import
configName = distcomp.configuration.importFromFile(filename);

% Refresh the config and select the newly imported one
com.mathworks.toolbox.distcomp.configui.ConfigurationManagerUI.refreshAndSelectConfig(configName);
