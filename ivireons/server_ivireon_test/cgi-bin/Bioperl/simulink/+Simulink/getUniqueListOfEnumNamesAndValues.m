function [enumStrings, enumValues] = getUniqueListOfEnumNamesAndValues(metaClass)
%GETUNIQUELISTOFENUMNAMESANDVALUES Helper function to get names and underlying values
%   for an enumerated class.  The list is sorted by underlying value and any
%   duplicate underlying values are removed.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $   $Date: 2008/11/13 18:28:34 $

assert(isa(metaClass, 'meta.class'));
assert(metaClass < ?Simulink.IntEnumType);

className = metaClass.Name;
[enumVals, enumNames] = enumeration(className);
dblVals = double(enumVals);

enumStrAndVal = {};

% Get unique list of enumerated values
for idx = 1:length(enumNames)
    thisEnumString = enumNames{idx};
    thisEnumValue  = dblVals(idx);
    
    % Add this enum if underlying value is not already included
    % (Column1 contains strings, Column2 contains underlying values)
    if (isempty(enumStrAndVal) || ...
        ~any(([enumStrAndVal{:,2}]==thisEnumValue)))
        enumStrAndVal{end+1,1} = thisEnumString; %#ok
        enumStrAndVal{end,  2} = thisEnumValue;  %#ok
    end
end

% Sort list in increasing order of underlying value
enumStrAndVal = sortrows(enumStrAndVal, 2);

enumStrings = enumStrAndVal(:,1);
enumValues  = cell2mat(enumStrAndVal(:,2));

% EOF
