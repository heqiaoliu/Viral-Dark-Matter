function pSetPropertyAndConfiguration(obj, property, value, configuration)
; %#ok Undocumented
%pSetPropertyAndConfiguration Set property and ensure correct configuration
%
%
% pSetPropertyAndConfiguration(obj, property, value, configuration) 

%  Copyright 2008 The MathWorks, Inc.

% Deduce if the current configuration and the suggested config would
% require us to NOT change the configuration
config = distcomp.configurableobject.pGetConfigNameFromConfigPair(obj.Configuration, configuration);
% If the result of the config pair is not empty that implies we should
% endeavour to retain the current configuration on the next set call, so
% tell the configurable object to ignore the next set.
if ~isempty(config)
    obj.IgnoreNextSet = true;
end
try
    % Do the set as requested.
    set(obj, property, value);
    % Ensure that we unset this if the call to set didn't do it.
    obj.IgnoreNextSet = false;
catch err
    % Any error in the set might NOT trigger a call to undo the
    % IgnoreNextSet so ensure that we unset afterwards
    obj.IgnoreNextSet = false;
    rethrow(err)
end
