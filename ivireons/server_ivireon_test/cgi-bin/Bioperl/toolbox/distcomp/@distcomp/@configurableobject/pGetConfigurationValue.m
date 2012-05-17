function values = pGetConfigurationValue(obj, propertyNames)
; %#ok Undocumented
% gets the values in a format that is compatible with a configuration
% for the specified properties.

% Copyright 2009 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2009/10/12 17:27:40 $


% default behaviour is just to use get
values = get(obj, propertyNames);