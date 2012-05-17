function [loaded, cfgFile] = loadConfigSet(this, cfgFile, cfgDb)
%LOADCONFIGSET Load extension configuration properties.
%   LOADCONFIGSET(H) opens a dialog to chose where to load a file
%   containing a configuration set and then loads the configuration set.
%
%   LOADCONFIGSET(H, FNAME) loads the configuration set specified by FNAME.

% Loads a ConfigDb database, not a ScopeCfg
% We don't recall scope position, docking, etc, in a config set
% (That's the business of an instrument set!)

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/05/23 08:12:05 $

loaded = true;

if nargin < 3
    cfgDb = [];
end

if nargin < 2
    
    wildExt = sprintf('*.%s', this.FileExtension);
    
    % If no configuration file is specified, use UIPUTFILE to get one.
    [cfgFile, path] = uigetfile( ...
        {wildExt, sprintf('Configuration Files (%s)', wildExt); ...
         '*.*',   ' All Files(*.*)'}, ...
        'Load Configuration');
    
    % If the 'Cancel' button is pressed, return early.
    if isequal(cfgFile, 0)
        loaded = false;
        return;
    end
    
    % attach the path to cfgFile incase it differs from pwd.
    cfgFile = fullfile(path, cfgFile);
end

if isempty(cfgFile)
    if isempty(cfgDb)
        loadedConfigDb = [];
        cfgFile = '';
    else
        % If we've been passed a configuration database, use its settings.
        loadedConfigDb = cfgDb;
    end
else
    % Try to load specified config file into separate ConfigDb object
    if ischar(cfgFile)
        
        [loadedConfigDb loaded] = extmgr.ConfigDb.createAndLoad(cfgFile, this.MessageLog);
        
        % If we could not load the file, return early, nothing to do and
        % the message has already been sent to the message log.
        if ~loaded
            return;
        end
        
        % If we were passed a configuration database, merge it with the
        % loaded database.
        if ~isempty(cfgDb)
            simpleMergeOver(loadedConfigDb, cfgDb);
        end
    else
        % If we've been passed a configuration database, use its settings.
        loadedConfigDb = cfgDb;
    end
end

% If we have no configurations to use in the driver, return early.
if isempty(loadedConfigDb)
    loaded = false;
    return;
end

% Prune out any configurations that do not have a matching register.
iterator.visitImmediateChildrenBkwd(loadedConfigDb, ...
    @(hConfig) pruneConfig(hConfig, this.RegisterDb));

hConfigDb = this.ConfigDb;
oldEnableState = hConfigDb.AllowConfigEnableChangedEvent;
hConfigDb.AllowConfigEnableChangedEvent = false;

% Disable all extensions.  Allow the loaded file to set up the currently
% enabled configurations.
set(allChild(hConfigDb), 'Enable', false);

% Merge loaded config set over shallow, to yield an
% "active" config set that user sees and works with
% Operation includes copying new config set name.
%
% The outcome is that we'll have a dst config defined for all extensions
% found during registration, and hence, we'll be able to enable each one
% during dialog interaction, etc.
%
% But the property-level content of each needs to be merged at a later
% time.  That "later time" is when the config is enabled, and is done by
% processall() which calls mergePropDb(). That is a deeper level merge and
% considers obsolete, undefined, etc.
%
% No enable-listeners fire here, since this is all just instance-copy
% operations without a change in property value
%
simpleMergeOver(hConfigDb, loadedConfigDb);

% Enforce type constraints 'EnableAll' and 'EnableOne'.
imposeTypeConstraints(this);

hConfigDb.AllowConfigEnableChangedEvent = oldEnableState;

% React to any enabled extension configurations only if the Allow flag was
% set to true when we entered this function.
if oldEnableState
    processAll(this);
end

% Cache the full path to the file that was loaded.
set(this, 'LastAccessedFile', which(cfgFile));

%% ------------------------------------------------------------------------
function pruneConfig(hConfig, hRegisterDb)

if isempty(hRegisterDb.findRegister(hConfig))
    
    % When we develop a mechanism to allow extension authors to change
    % extension type and names, we can call that from here.  If its not
    % registered, check if its registered as an "old" name that needs to be
    % converted.
    disconnect(hConfig)
end

% [EOF]
