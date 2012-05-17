function pv = distcompConfigSection(configName, sectionName)
; %#ok Undocumented
%distcompConfigSection Return a section of a user configuration for the
%Parallel Computing Toolbox.
%   PV = distcompConfigSection(CONFIGNAME, SECTIONNAME) loads the user
%   configuration CONFIGNAME and returns a structure containing the section
%   SECTIONNAME of that configuration.
%   A section of a configuration stores all the PV-pairs associated with a
%   single function or object method.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.10.7 $  $Date: 2007/11/09 19:49:19 $

    persistent LAST_CONFIGNAME;
    persistent LAST_SECTIONNAME;
    persistent LAST_PV;
    persistent CACHE_COUNTER;

    if isempty(configName)
        pv = struct([]);
        return;
    end

    if ~(ischar(configName) && size(configName, 2) == numel(configName))
        error('distcomp:config:InvalidInput', ...
              'The configuration name must be a string');
    end
    if ~(ischar(sectionName) && size(sectionName, 2) == numel(sectionName))
        error('distcomp:config:InvalidInput', ...
              'The section name must be a string');
    end

    % Use the cached value when possible.
    currentCacheCounter = distcomp.configserializer.getCacheCounter();
    if ~isempty(LAST_CONFIGNAME) ...
            && strcmp(LAST_CONFIGNAME, configName) ...
            && strcmp(LAST_SECTIONNAME, sectionName) ...
            && CACHE_COUNTER == currentCacheCounter
        pv = LAST_PV;
        return;
    end

    % We don't have any cached information or it is out of date.
    allNames = distcomp.configserializer.getAllNames();
    if ~any(strcmp(configName, allNames))
        error('distcomp:config:NoSuchConfiguration',  ...
              ['Could not find the configuration ''%s''.\n', ...
               'Valid configurations are:\n%s'], ...
              configName, iGetConfigStr(allNames));
    end
    % Rely on the error messages in the object.
    config = distcomp.configuration(configName);
    pv = config.getAllEnabledInSection(sectionName);

    % Cache the values we obtained.
    LAST_CONFIGNAME = configName;
    LAST_SECTIONNAME = sectionName;
    LAST_PV = pv;
    CACHE_COUNTER = currentCacheCounter;
end

function configStr = iGetConfigStr(allNames)
% Given a cell array of strings, {'a', 'b', 'c'}, returns the string
% 'a, b, and c.'
    if numel(allNames) == 1
        configStr = allNames{1};
        return;
    end
    allNames = strcat('''', allNames, '''');
    allNames(1:end - 2) = strcat(allNames(1:end - 2), {', '});
    allNames{end - 1} = [allNames{end - 1}, ', and '];
    configStr = [allNames{:}, '.'];
end
