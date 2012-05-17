function obj = getInstance
;%#ok Undocumented
%Return a singleton.

%  Copyright 2007 The MathWorks, Inc.

persistent storage;
if isempty(storage)
    % Create and initialize a new singleton.
    % We don't need to mlock the object because it only performs lazy introspection.
    storage = distcomp.configpropstorage;
    storage.PropertyInfo = distcomp.configpropstorage.pGetAllConfigurableProperties();
end

obj = storage;
