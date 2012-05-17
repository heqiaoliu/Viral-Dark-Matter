function typeArg = pMapSchedClassTypeToFRType(schedClass)
; %#ok Undocumented
%Static method that maps a scheduler class type to findResource's type argument.

%  Copyright 2007 The MathWorks, Inc.

% Strip of the initial distcomp. part when present.
schedClass = regexprep(schedClass, '^distcomp\.', '');

schedInfo = com.mathworks.toolbox.distcomp.configurations.FindResourceType.createFromClassName(schedClass);
if isempty(schedInfo)
    error('distcomp:configuration:InvalidType', ...
          'The scheduler class ''%s'' is not a recognized scheduler class.', ...
          schedClass);
end    
typeArg = char(schedInfo.getResourceType());
