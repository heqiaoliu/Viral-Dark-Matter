function pInit(obj)
; %#ok Undocumented
% Initialization method for distcomp.typechecker.

%   Copyright 2007 The MathWorks, Inc.

% Initialize the typechecker object.  This is the only place in this class where
% we apply introspection to infer the names and data types of the properties of
% this class.

% We leave most of the object properties in their default state so that this
% object can act as a storage for their default values.

% Get a handle to all the properties that represent data types.
props = obj.classhandle.Properties;
props = props(~strcmp(get(props, {'Name'}), 'PropertyInfo'));

% Use introspection to get the names and types of these properties.
names = get(props, {'Name'});
datatypes = get(props, {'DataType'});

% Use introspection to get the enum values for the enumerable data types.
enumValues = cell(size(names));
for i = 1:length(datatypes)
    typehandle = findtype(datatypes{i});
    if isa(typehandle, 'schema.EnumType')
        enumValues{i} = typehandle.Strings;
    else
        enumValues{i} = {};
    end
end

obj.PropertyInfo = struct('PropertyName', names, ...
                          'Type', datatypes, ...
                          'EnumValues', enumValues);
    
