function [isEnum enumClsName]= util_is_enum_type(dtypeStr)
 % Combine the first check of 'Enum' to extract the class and evaluate
 % in the base workspace.
 % At this point, enum type name can be of the form of 'Enum:
 % enumClassName' or just 'enumClassName'. 

%   Copyright 2009 The MathWorks, Inc.

    isEnum = false;
    if(strncmp(dtypeStr, 'Enum: ', 6))
      enumClsName = dtypeStr(7:end);
    else
      enumClsName = dtypeStr;
    end
    try
      mch = evalin('base', strcat('?',enumClsName));
      if(strcmp(mch.SuperClasses{1}.Name, 'Simulink.IntEnumType'))
        isEnum = true;
      end
    catch Mex
      return;
    end
end