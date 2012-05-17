function dtaItems = get_data_type_items(h)

%   $Revision: 1.1.6.5 $  $Date: 2009/12/28 04:52:01 $
%   Copyright 2007-2009 The MathWorks, Inc.

dtaItems.inheritRules = {};
dtaItems.builtinTypes = {};
dtaItems.scalingModes = {};
dtaItems.signModes = {};
dtaItems.extras = [];
dtaItems.validValues = {};

validModes = get_valid_data_property_values(h, 'Props.Type.Method');

if exist_in_cell_list(validModes, 'Inherited')
    dtaItems.inheritRules = {'Inherit: Same as Simulink'};
end

if exist_in_cell_list(validModes, 'Built-in')
    dtaItems.builtinTypes = get_valid_data_property_values(h, 'Props.Type.Primitive');
end

if exist_in_cell_list(validModes, 'Fixed point')
    dtaItems.scalingModes = {'UDTBinaryPointMode', 'UDTSlopeBiasMode'};
    dtaItems.signModes = {'UDTSignedSign', 'UDTUnsignedSign'};
end

if exist_in_cell_list(validModes, 'Bus Object')
    dtaItems.supportsBusType = true;
end

if exist_in_cell_list(validModes, 'Enumerated')
    if slfeature('EnumDataTypesInSimulink') >= 2
        dtaItems.supportsEnumType = true;
    else
        dtaItems.extras = [dtaItems.extras struct('name', 'Enumerated', 'header', 'Enum', 'hint', '<enum type name>', 'container', [], 'setval', [], 'getval', [])];
    end 
end

% Get the list of items for the pulldown in the spreadsheet view of the Model Explorer. The
% item '<data type expression>' is excluded from the list.
dtaItems.validValues = Simulink.DataTypePrmWidget.getDataTypeAllowedItems(dtaItems);
[found loc] = ismember('<data type expression>', dtaItems.validValues);
if found
    dtaItems.validValues(loc) = [];
end

function result = exist_in_cell_list(c, item)

result = false;
for i = 1:length(c)
    if isequal(c{i}, item)
        result = true;
        break;
    end
end
