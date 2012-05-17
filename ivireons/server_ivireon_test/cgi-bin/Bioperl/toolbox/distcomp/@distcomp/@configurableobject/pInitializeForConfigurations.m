function pInitializeForConfigurations(obj, sectionName)
; %#ok Undocumented
%pInitializeForConfigurations(obj, sectionName) Prepare this object for reading 
%   property when other properties are set.  Do not call this on a class which
%   has instance properties.
%   Returns an empty vector if the object obj is empty or if it does not have
%   the 'Configuration' property.

%  Copyright 2005-2006 The MathWorks, Inc.

% We cache the last class handle we used and the properties we created listeners
% on.  By doing so, we assume that the class only has class properties and that
% it has no instance properties.
    persistent LAST_CLASSHANDLE;
    persistent LAST_PROPERTIES;
    
    if isempty(obj)
        return;
    end
    
    c = obj.classhandle;
    if (isempty(LAST_CLASSHANDLE) || (c ~= LAST_CLASSHANDLE))
        % Need to initialize or update our cached properties.
        LAST_CLASSHANDLE = c;
        LAST_PROPERTIES = iGetPropertiesForListening(c);
    end
    obj.ConfigurationSection = sectionName;    
    if isempty(LAST_PROPERTIES)
        return;
    end
    % Create a listener that calls obj when any of the publicly settable properties
    % of obj, except for Configuration, have been changed.
    obj.ConfigurationListener = handle.listener(obj, LAST_PROPERTIES, ...
                                                'PropertyPostSet', ...
                                                @distcomp.configurableobject.pPostConfigurablePropertySet);
    obj.ConfigurationListener.CallbackTarget = obj;
end

function props = iGetPropertiesForListening(hClass)
%iGetPropertiesForListening Return all the configurable properties of the class.
    
% Verify that the class implements the configuration interface by looking for
% the configuration property.
    if isempty(hClass.findprop('Configuration'))
        % Object does not have a Configuration property, so there is nothing to do.
        props = [];
        return;
    end
    
    % Get all the configurable properties from the configpropstorage.
    configProps = distcomp.configpropstorage.getConfigurableProperties(hClass.Name);
    if isempty(configProps)
        % Object does not have any configurable properties.
        props = [];
        return;
    end
    % We now have a cell array containing the names of the configurable 
    % properties, and we get the schema.prop corresponding to those names.
    for i = length(configProps):-1:1 
        props(i) = hClass.findprop(configProps{i}); %#ok Growing via indexing.
    end
end
    
