function [isNumeric, baseTypeStr] = util_is_sim_numeric_type(dataTypeStr)
% Check for Simulink NumericType, and return the corresponding matlab base type
% or numerictype in case of fixed point types.
    isNumeric = false;    
    baseTypeStr = dataTypeStr;
    nameExists = evalin('base',['exist(''',dataTypeStr,''')']);
    if(nameExists)
        try
            typObj = evalin('base', dataTypeStr);      
            baseTypeStr = typObj.DataTypeMode;
            if(isa(typObj,'Simulink.NumericType'))
                if(strncmp(baseTypeStr, 'Fixed', 5))
                    numType = sldvshareprivate('util_get_numerictype', typObj);
                    baseTypeStr = numType.tostring();
                else
                    baseTypeStr = lower(baseTypeStr);
                end
                isNumeric = true;
            end
        catch Mex %#ok<NASGU>
            return;
        end
    end
end