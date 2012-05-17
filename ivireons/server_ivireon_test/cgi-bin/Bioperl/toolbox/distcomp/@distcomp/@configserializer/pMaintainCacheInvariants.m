function modified = pMaintainCacheInvariants(obj)
; %#ok Undocumented
%Maintain configuration invariants.
%   Return true if and only if we modified obj.Cache.

%   Copyright 2007-2008 The MathWorks, Inc.

% Invariants:
% - Configuration names are non-empty strings.
% - The local configuration exists
% - The current configuration is set
% - The current configuration exists
% - The configuration names are unique
%
% When "deployed" these remain largely the same, except we no longer
% guarantee there is a config called 'local' (in fact we remove it).
%
% If these invariants can not be maintained an error is thrown. This only
% happens when "deployed".

% Define 2 variables updated and used in a number of checks
modified = false;
allNames = {};
% Define helper function used in a number of checks
isString = @(str) ischar(str) && size(str, 2) == length(str);

if strcmp( obj.CacheInvariantMode, 'deployed' )
    emptyConfigStruct = struct( 'Name', {}, 'Values', {} );
    nEnsureNotEmpty( emptyConfigStruct );
    nEnsureValidConfigNames( emptyConfigStruct );
    nEnsureNoLocalSchedulers();
    nEnsureValidCurrentConfig( '' );
else
    localConfigStruct = struct( 'Name', 'local', 'Values', {{}} );
    nEnsureNotEmpty( localConfigStruct );
    nEnsureValidConfigNames( localConfigStruct );
    nEnsureLocalConfigExists;
    nEnsureValidCurrentConfig( 'local' );    
end

    function nEnsureNotEmpty( defaultConfigStruct )
        % Make sure that we have at least one configuration.
        % If empty, uses input as new struct.
        if isempty(obj.Cache.configurations)
            % The user doesn't have any configurations.
            obj.Cache.configurations = defaultConfigStruct;
            modified = true;
        end
    end

    function nEnsureValidConfigNames( defaultConfigStruct )
        % Check configuration names:
        % - can be read (resets to passed in struct if can't)
        % - are strings (removes if not)
        % - not empty   (removes if empty)
        % - are unique  (removes duplicates)
        
        % Make sure the configuration names can be read.
        try
            allNames = {obj.Cache.configurations.Name};
        catch err %#ok<NASGU>
            % This means that the configurations were so broken that we
            % couldn't collect the names into a cell array.  We erase them all!
            warning('distcomp:configuration:InvalidConfigurations', ...
                ['Cannot read the configuration names. ',...
                'Resetting configurations.']);
            obj.Cache.configurations = defaultConfigStruct;
            allNames = {obj.Cache.configurations.Name};
            modified = true;
        end

        % Make sure the configuration names are all strings.
        ind = ~cellfun(isString, allNames);
        if any(ind)
            warning('distcomp:configuration:InvalidConfigurations', ...
                'Removing %d configuration(s) with invalid names.', nnz(ind));
            obj.Cache.configurations(ind) = [];
            allNames = {obj.Cache.configurations.Name};
        end

        % Make sure that the configuration names are non-empty.
        ind = cellfun(@isempty, allNames);
        if any(ind)
            warning('distcomp:configuration:EmptyName', ...
                'Found a configuration with an empty name.  Removing it.');
            obj.Cache.configurations(ind) = [];
            allNames = {obj.Cache.configurations.Name};
            modified = true;
        end

        % Make sure that the configuration names are unique.
        [uniqueNames, ind] = unique(allNames);
        if length(uniqueNames) ~= length(allNames)
            warning('distcomp:configuration:DuplicateNames', ...
                ['There are duplicates in the configuration names.  ', ...
                'Removing the duplicates.']);
            obj.Cache.configurations = obj.Cache.configurations(ind);
            modified = true;
        end
    end

    function nEnsureLocalConfigExists()
        % Make sure we have the local configuration.
        if ~any(strcmp(allNames, 'local'))
            obj.Cache.configurations(end + 1).Name = 'local';
            obj.Cache.configurations(end).Values = {};
            allNames = {obj.Cache.configurations.Name};
            modified = true;
        end
    end

    function nEnsureValidCurrentConfig( defaultCurrentConfig )
        % Checks current configuration
        % - is a string
        % - exists
        % and sets it to passed in default if not.

        % Make sure the current configuration is set to a string value.
        try
            current = obj.Cache.current;
            if ~isString(current)
                obj.Cache.current = defaultCurrentConfig;
                modified = true;
            end
        catch err %#ok<NASGU>
            % There was no current field in the cache.
            obj.Cache.current = defaultCurrentConfig;
            modified = true;
        end

        % Make sure that the current configuration
        % exists.
        if ~any(strcmp(allNames, obj.Cache.current))
            obj.Cache.current = defaultCurrentConfig;
            modified = true;
        end
    end

    function nEnsureNoLocalSchedulers
        % Find local scheds and remove them
        numCfgs = length(obj.Cache.configurations);
        current = obj.Cache.current;
        for nc = numCfgs:-1:1
            cfg = obj.Cache.configurations(nc);            
            % This configuration is "local" - we need to remove it.
            if iIsConfigLocal( cfg )                                
                % This config is the current config
                if strcmp( cfg.Name, current )
                    obj.Cache.current = '';
                end         
                obj.Cache.configurations(nc) = [];
                modified = true;                                
            end
        end
        % There may be NO configurations or the current configuration might be the empty.
        if isempty( obj.Cache.current )
            error( 'distcomp:configserializer:NoLocalSchedulerWhenDeployed',...
                   ['Default parallel configuration "%s" is not valid in deployed applications.\n\n',...
                    'The local scheduler cannot be used in deployed applications. ',...
                    'To specify a valid scheduler set the "ParallelConfigurationFile" ',...
                    'MCR userdata key to the full path of a parallel configuration file.'], current );
        end
    end
end

function isLocal = iIsConfigLocal( cfg )
isLocalType = ~isempty( cfg.Values ) && strcmp( cfg.Values.findResource.Type, 'local' );
isCalledLocal = strcmp( cfg.Name, 'local' ) && isempty(cfg.Values);
isLocal = isLocalType || isCalledLocal;
end
