function data = util_get_enum_defaultvalue(className)

%   Copyright 2010 The MathWorks, Inc.

    enumVals = enumeration(className);
    cmdStr = [className '.' 'getIndexOfDefaultValue(''' className ''')'];
    data = enumVals(evalin('base',cmdStr)); 
end