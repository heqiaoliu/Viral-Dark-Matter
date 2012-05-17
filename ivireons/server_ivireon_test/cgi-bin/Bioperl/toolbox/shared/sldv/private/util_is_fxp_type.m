function [status, fxpTypeInfo] = util_is_fxp_type(signalDataTypeStr)
    status = false;
    fxpTypeInfo = [];
    
    if nargout>1
        getTypeInfo = true;
    else
        getTypeInfo = false;
    end
        
    if (strncmp(signalDataTypeStr, 'sfix', 4) ||...
            strncmp(signalDataTypeStr, 'ufix', 4) ||...
            strncmp(signalDataTypeStr, 'flt', 3))        
        status = true;
        if getTypeInfo
            fixdtType = fixdt(signalDataTypeStr);
            fxpTypeInfo = util_get_numerictype(fixdtType);
        end
    elseif (strncmp(signalDataTypeStr,'fixdt',5) || ...
             strncmp(signalDataTypeStr,'numerictype',11))
        % This case can only happen is dataType is originated from an Simulink.BusElement 
        try
            fxpTypeObj = evalin('base',signalDataTypeStr);
        catch Mex %#ok<NASGU>
            fxpTypeObj = [];
        end

        if ~isempty(fxpTypeObj)
            status = true;
            if getTypeInfo
                if isa(fxpTypeObj,'Simulink.NumericType')
                    fxpTypeInfo = util_get_numerictype(fxpTypeObj);
                else
                    fxpTypeInfo = fxpTypeObj;
                end
            end
        end
    end
end