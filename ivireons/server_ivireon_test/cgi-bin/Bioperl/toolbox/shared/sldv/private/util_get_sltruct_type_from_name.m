function structType = util_get_sltruct_type_from_name(dtypeStr)

%   Copyright 2009 The MathWorks, Inc.

    structType = [];
    cmd = ['exist(''', dtypeStr, ''', ''var'')'];
    varExists = evalin('base', cmd);
    if varExists
        tmpVar = evalin('base', dtypeStr);
        if isa(tmpVar,'Simulink.StructType')
            structType = tmpVar;
        end
    end
end