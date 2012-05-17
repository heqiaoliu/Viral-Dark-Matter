function name = init_value_name_for_datatype(dataTypeName, maxShortNameLen)
%INIT_VALUE_NAME_FOR_DATATYPE returns the default initial value name

%   Copyright 2010 The MathWorks, Inc.

    name = arxml.arxml_private('p_create_aridentifier', ...
                               ['DefaultInitValue_' dataTypeName],...
                               maxShortNameLen);
    
end
