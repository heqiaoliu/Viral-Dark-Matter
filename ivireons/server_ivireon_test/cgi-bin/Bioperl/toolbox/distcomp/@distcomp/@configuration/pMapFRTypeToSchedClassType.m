function schedType = pMapFRTypeToSchedClassType(typeArg)
; %#ok Undocumented
%Static method that map findResource's type argument to actual scheduler class types.

%  Copyright 2007 The MathWorks, Inc.

schedInfo = com.mathworks.toolbox.distcomp.configurations.FindResourceType.createFromResourceType(typeArg);
if isempty(schedInfo)
    error('distcomp:configuration:InvalidType', ...
          'The scheduler type ''%s'' is not a recognized scheduler type.', ...
          typeArg);
end    
schedType = char(schedInfo.getClassName());
