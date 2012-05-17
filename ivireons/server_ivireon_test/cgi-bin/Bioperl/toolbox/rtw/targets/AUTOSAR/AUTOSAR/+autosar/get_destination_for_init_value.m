function str = get_destination_for_init_value(dataType)
%GET_DESTINATION_FOR_INIT_VALUE the data type destination for an initial value
      
%   Copyright 2010 The MathWorks, Inc.

% Must keep this order
if (dataType.IsArray==true) || (dataType.IsRecord==true)
    str = strrep(dataType.Type, '-TYPE', '-SPECIFICATION');    
else
    str = strrep(dataType.Type, '-TYPE', '-LITERAL');
end

end

