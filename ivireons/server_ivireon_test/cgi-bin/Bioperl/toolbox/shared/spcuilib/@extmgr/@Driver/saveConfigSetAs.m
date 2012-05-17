function [saved, cfgFile] = saveConfigSetAs(this, cfgFile)
%SAVECONFIGSETAS Save the configuration in a new file.
%   SAVECONFIGSETAS(H) launches a dialog to specify the location of the
%   configuration file and saves the configuration.
%
%   SAVECONFIGSETAS(H, FNAME) saves the configuration in the file specified
%   by FNAME.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/08/24 15:06:18 $

saved = true;

if nargin < 2

    wildExt = sprintf('*.%s', this.FileExtension);
    
    defFile = get(this, 'LastAccessedFile');
    if isempty(defFile)
        defFile = sprintf('untitled.%s', this.FileExtension);
        defPath = pwd;
    else
        [defPath, defFile, defExt] = fileparts(defFile);
        defFile = [defFile defExt];
    end
    
    oldPath = pwd;
    
    % Do not try to move if the default path is ''.
    if ~isempty(defPath)
        cd(defPath);
    end
    
    % If no configuration file is specified, use UIPUTFILE to get
    [cfgFile, path] = uiputfile( ...
        {wildExt, sprintf('Configuration Files (%s)', wildExt); ...
         '*.*',   'All Files (*.*)'}, ...
        'Save Configuration as', defFile);

    cd(oldPath);
    
    % If the 'Cancel' button is pressed, return early.
    if isequal(cfgFile, 0)
        saved = false;
        return;
    end
    
    % attach the path to cfgFile incase it differs from pwd.
    cfgFile = fullfile(path, cfgFile);
end

% Only retain enabled extensions
hConfigDb = copyAllConfigs(this.ConfigDb);

% Prune out properties that are still set to their defaults.
iterator.visitImmediateChildren(hConfigDb, ...
    @(hChild) pruneDefaultProperties(hChild, this.RegisterDb));

% Serialize to file system
save(cfgFile, 'hConfigDb');

% Get the full path to the file we're about to load.

set(this, 'LastAccessedFile', cfgFile);

%% ------------------------------------------------------------------------
function pruneDefaultProperties(hConfig, hRegisterDb)

hRegister = hRegisterDb.findRegister(hConfig);

% Loop over each property and remove if it matches its default.
iterator.visitImmediateChildrenBkwd(hConfig.PropertyDb, ...
    @(hProp) pruneProperty(hProp, hRegister.PropertyDb))

% If we pruned out all the properties, save nothing for faster loading.
if isEmpty(hConfig.PropertyDb)
    hConfig.PropertyDb = [];
end

%% ------------------------------------------------------------------------
function pruneProperty(hProp, hDefPropDb)

hDefaultValue = get(hDefPropDb.findProp(hProp.Name), 'Value');
hCurrentValue = get(hProp, 'Value');

% If the current value matches the default, remove it by disconnecting.
if isequal(hDefaultValue, hCurrentValue)
    disconnect(hProp);
end

% [EOF]
