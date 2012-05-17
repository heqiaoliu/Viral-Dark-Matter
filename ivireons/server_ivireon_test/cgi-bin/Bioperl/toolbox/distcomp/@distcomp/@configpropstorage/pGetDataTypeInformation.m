function datatypes = pGetDataTypeInformation(className, propertyNames)
%Static method to get the data types of propertyNames in className.
%   Uses introspection.

% Copyright 2007 The MathWorks, Inc.

hpackage = findpackage('distcomp');
hclass = findclass(hpackage, className);
if isempty(hclass)
    error('distcomp:configpropstorage:InvalidClassName', ...
          'Could not find the class %s.', className);
end
datatypes = cell(size(propertyNames));
for i = 1:length(propertyNames)
    currProp = propertyNames{i};
    prop = findprop(hclass, currProp);
    if isempty(prop)
        error('distcomp:configpropstorage:InvalidPropertyName', ...
              'Could not find the property %s in the class %s.', ...
              currProp, className);
    end
    datatypes{i} = prop.DataType;
end

