function configName = pSetConfiguration(obj, configName)
; %#ok Undocumented
%PSETCONFIGURATION Loads the appropriate section of the specified 
%  configuration, sets this object to the values returned.
%
%  configName = PSETCONFIGURATION(JOB, configName)

%  Copyright 2005-2008 The MathWorks, Inc.

if isempty(configName)
    return;
end
configStruct = distcompConfigSection(configName, obj.ConfigurationSection);
if isempty(configStruct)
    return;
end

% Disable the property listener while we set the object properties
% according to the configuration.
obj.ConfigurationListener.Enabled = 'off';
obj.ConfigurationCurrentlyBeingSet = configName;
obj.IsBeingConfigured = true;
obj.PostConfigurationFcns = cell(0, 2);

try
    set(obj, configStruct);
    % Run any post-configuration tasks after the set
    obj.pFinalizeConfiguration();
catch err    
    configSection = obj.ConfigurationSection;
    % Re-enable the property listener and other configuration setting state           
    try
        obj.ConfigurationListener.Enabled = 'on';
        obj.ConfigurationCurrentlyBeingSet = '';
        obj.IsBeingConfigured = false;
        obj.PostConfigurationFcns = cell(0, 2);
    catch dummyErr %#ok<NASGU>
    end
    
    throw( MException(err.identifier,...
        'Error when using the ''%s'' section of the configuration ''%s'':\n%s', configSection, configName, err.message) );
end
% Re-enable the property listener and other configuration setting state
obj.ConfigurationListener.Enabled = 'on';
obj.ConfigurationCurrentlyBeingSet = '';
obj.IsBeingConfigured = false;
obj.PostConfigurationFcns = cell(0, 2);
