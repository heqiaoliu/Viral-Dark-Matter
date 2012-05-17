function values = pGetConfigurationValue(obj, propertyNames)
; %#ok Undocumented
% gets the values in a format that is compatible with a configuration
% for the specified properties.

% Copyright 2009 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2009/10/12 17:27:38 $

% default behaviour is just to use get
values = get(obj, propertyNames);

% DataLocation is a special case - if the storage is a filestorage,
% we need to ask the storage what its configuration value is.
isDataLocation = strcmpi(propertyNames, 'DataLocation');
if any(isDataLocation) && isa(obj.Storage, 'distcomp.filestorage')
    dataLocationConfigValue = obj.Storage.pGetFullPCAndUnixStorageLocation;
    values{isDataLocation} = dataLocationConfigValue;
end


