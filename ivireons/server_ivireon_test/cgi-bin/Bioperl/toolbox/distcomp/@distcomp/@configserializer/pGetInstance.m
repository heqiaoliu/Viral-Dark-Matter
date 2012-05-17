function varargout = pGetInstance(varargin)
; %#ok Undocumented
%Static method that returns the singleton for distcomp.configserializer.
%
% cs = distcomp.configserializer.pGetInstance() returns the singleton
% instance of distcomp.configserializer. 
%
% pGetInstance can also be called with a single input to aid testing.
%
% distcomp.configserializer.pGetInstance( 'deployed', CONFIGFILE ) 
% makes future calls to pGetInstance behave as if they are called from 
% a deployed application with MCR Userdata ParallelConfiguration set to 
% CONFIGFILE.
% This will clear the undo history.
%
% distcomp.configserializer.pGetInstance( 'normal' ) undoes a call to
% pGetInstance( 'deployed', CONFIGFILE ).
%
% Example:
%
%  % setup configserializer to be a deployed instance.
%  distcomp.configserializer.pGetInstance( 'deployed', configFile );
%  [def, all] = defaultParallelConfig();
%  % reset configserializer to be a normal instance.
%  distcomp.configserializer.pGetInstance( 'normal' );

%   Copyright 2007-2009 The MathWorks, Inc.

%  $Revision: 1.1.6.5 $  $Date: 2009/05/14 16:49:49 $ 

persistent serializer; % the singleton
persistent testOverride; % testing override
if isempty( testOverride )
    testOverride.deployed = false;
    testOverride.configFile = '';
end

if nargin > 0
    % This is the testing entry point
    % Can't be called with any outputs
    error( nargoutchk(0,0, nargout) );
    % Force serializer to empty, so next call will regenerate.
    testOverride.deployed = strcmp( varargin{1}, 'deployed' );
    if testOverride.deployed
        error( nargchk(2,2,nargin) );
        testOverride.configFile = varargin{2};
    end
    serializer = [];
    return;
elseif isempty( serializer )
    % Need to create singleton instance
    if isdeployed 
        cfgFile = getmcruserdata( 'ParallelConfigurationFile' );
        GetInstance = @()iGetDeployedInstance( cfgFile );
    elseif testOverride.deployed
        % Deployed instance
        GetInstance = @()iGetDeployedInstance( testOverride.configFile );
    else
        % Normal instance
        GetInstance = @iGetInstance;
    end    
    serializer = GetInstance();
end

% Return the singleton
varargout{1} = serializer;

% Need to mlock so that the serializer can safely retain the undo history.
mlock;

% -------------------------------------------------------------------------
function obj = iGetInstance( )

obj = distcomp.configserializer;
obj.pResetUndoHistory()
obj = iInitFromPrefs( obj );

% -------------------------------------------------------------------------
function obj = iGetDeployedInstance( cfgFile )
obj = distcomp.configserializer;
obj.pResetUndoHistory()
obj.CacheInvariantMode = 'deployed';
obj.FlushCache = false;

obj = iInitFromConfigFile( obj, cfgFile );

% -------------------------------------------------------------------------
function serializer = iInitFromPrefs( serializer )

% NB pFlushCache defines the format of the preferences for PCT configurations.  
% It is a structure with the following fields:
%   configurations      an array of structs
%   current             the name of the current default configuration
%   versionNumber       the version number in which the preferences were saved (this 
%                       will usually be the current version, except when MATLAB 
%                       has just been upgraded.
try
    allPrefs = getpref(serializer.Group);
catch err %#ok<NASGU>
    allPrefs = struct([]);
end

currentVersionNumber = com.mathworks.toolbox.distcomp.util.Version.VERSION_NUM;
% See if the preferences were from the same version.  The version field was introduced
% in R2009b, so the field may not exist in the configurations structure.
if isempty(allPrefs)
    % If allPrefs is empty, then no (old) configurations exist and we can safely assume
    % that the version is the current version
    preferencesVersion = currentVersionNumber;
else
    if isfield(allPrefs, 'versionNumber')
        preferencesVersion = allPrefs.versionNumber;
    else
        % The configuration struct had no version associated with it - i.e. it was created
        % before R2009b (which was when the version was included).  We assume that the 
        % configuration came from R2009a (version 9).
        preferencesVersion = 9;
    end
end
% If preferences are from the current version, they don't need upgrading
isCurrentVersion = (preferencesVersion == currentVersionNumber);

emptyConfigurationsStruct = struct([]);
if isfield(allPrefs, 'configurations')
    try
        if ~isCurrentVersion
            allPrefs.configurations = iUpgradeAllConfigurationsInPreferences( ...
                allPrefs.configurations, preferencesVersion);
        end
        % Now set the configurations in the Cache
        serializer.Cache.configurations = allPrefs.configurations;
    catch err %#ok<NASGU>
        % The upgrade may have failed so set to the empty struct so 
        % that pMaintainCacheInvariants won't display a warning to the user.  
        serializer.Cache.configurations = emptyConfigurationsStruct;
    end
else
    serializer.Cache.configurations = emptyConfigurationsStruct;
end

defaultCurrentConfiguration = 'local';
if isfield(allPrefs, 'current')
    serializer.Cache.current = allPrefs.current;
else
    serializer.Cache.current = defaultCurrentConfiguration;
end

% Make sure that the cache invariants are true and flush the cache if they
% weren't.  If the preferences weren't from the current version, we should
% also flush to ensure that we skip the upgrade next time we try to load them.
if serializer.pMaintainCacheInvariants() || ~isCurrentVersion
    serializer.pFlushCache();
end

% -------------------------------------------------------------------------
function serializer = iInitFromConfigFile( serializer, configFileName )

if ~isempty( configFileName )
    % NB distcomp.configuration.loadconfigfile will also upgrade the values
    % structure, so no need to do it explicitly in here.
    [name, values] = distcomp.configuration.loadconfigfile( configFileName );
    %  Initialize the cache with the loaded config
    serializer.Cache.configurations.Name = name;
    serializer.Cache.configurations.Values = values;
    serializer.Cache.current = name;
    try
        % Check the invariants
        serializer.pMaintainCacheInvariants();
    catch err
        if strcmp( err.identifier, 'distcomp:configserializer:NoLocalSchedulerWhenDeployed' )
            error( err.identifier,...
                   ['Parallel configuration file "%s" defines a configuration ',...
                    'called "%s" that specifies a local scheduler.\n\n',...
                    'The local scheduler cannot be used in deployed applications. ',...
                    'To specify a valid scheduler set the "ParallelConfigurationFile" MCR userdata key ',...
                    'to the full path of a parallel configuration file.'], configFileName, name  );
        else
            rethrow( err );
        end    
    end
else
    serializer = iInitFromPrefs( serializer );
end


% -------------------------------------------------------------------------
function [configurations, configsWereModifiedByUpgrade] = iUpgradeAllConfigurationsInPreferences(configurations, originalVersion)
configsWereModifiedByUpgrade = false;

% Keep track of which configurations couldn't be upgraded so that we can remove them.
numConfigurations = length(configurations);
configsFailedToUpgrade = false(numConfigurations, 1);
for i = 1:numConfigurations
    currentValues = configurations(i).Values;
    try
        upgradedValues = distcomp.configuration.upgradeConfigValuesStructToCurrentVersion( ...
            currentValues, originalVersion);
        if ~isequal(upgradedValues, currentValues)
            configsWereModifiedByUpgrade = true;
            configurations(i).Values = upgradedValues;
        end
    catch err %#ok<NASGU>
        configsFailedToUpgrade(i) = true;
    end
end

% Remove those configurations that couldn't be upgraded.  
if any(configsFailedToUpgrade)
    configsWereModifiedByUpgrade = true;
    warning('distcomp:configserializer:incompatibleConfiguration', ...
        'Removing the following configurations because they could not be upgraded to the current version: %s', ...
        sprintf('\n\t%s', configurations(configsFailedToUpgrade).Name));
    configurations(configsFailedToUpgrade) = [];
end
