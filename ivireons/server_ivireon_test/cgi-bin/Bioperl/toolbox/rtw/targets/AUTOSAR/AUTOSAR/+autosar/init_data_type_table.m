function out = init_data_type_table(initValueTable, type)
%INIT_DATA_TYPE_TABLE initialized the data type table

%   Copyright 2007-2010 The MathWorks, Inc.

% type: 'sl' or 'rtw'
if nargin < 2
    type = 'sl';
end

isRTW = false;
if strcmp(type, 'rtw')
    isRTW = true;
end

% INIT_DATA_TYPE_TABLE Initialize the DataType Table

% Default AUTOSAR DataType Names
arNames = {'Boolean', 'SInt8', 'SInt16', 'SInt32',...
    'UInt8', 'UInt16', 'UInt32', 'Float', 'Double'};

% MATLAB types
matlabTypes = {'logical', 'int8', 'int16', 'int32',...
        'uint8', 'uint16', 'uint32', 'single', 'double'};

% Default Simulink (RTW) DataType Names
if isRTW==false
    slNames = {'boolean', 'int8', 'int16', 'int32',...
        'uint8', 'uint16', 'uint32', 'single', 'double'};
else
    slNames = {'boolean_T', 'int8_T', 'int16_T', 'int32_T',...
        'uint8_T', 'uint16_T', 'uint32_T', 'real32_T', 'real_T'};
end

% Default Minimum value
minVal = {0, intmin('int8'), intmin('int16'), intmin('int32'),...
    0, 0, 0, realmin('single'), realmin};

% Default Maximum value
maxVal = {1, intmax('int8'), intmax('int16'), intmax('int32'),...
    intmax('uint8'), intmax('uint16'), intmax('uint32'), realmax('single'), realmax};

% Default Word size
wordSize = [8, 8, 16, 32, 8, 16, 32, 32, 64];

% Default AUTOSAR Type
if isRTW==true
    arType = [{'BOOLEAN-TYPE'}, repmat({'INTEGER-TYPE'},1,6), repmat({'REAL-TYPE'},1,2)];
end

% Some flags
isSigned = [false, true(1,3), false(1,3), true(1,2)];
isBoolean = [true, false(1,8)];
isInteger = [false, true(1,6), false(1,2)];
isFloat = [false(1,7), true(1,2)];

nbDataTypes = numel(isFloat);

% Build the table
out.IDs = 1:nbDataTypes;
out.NumDataTypes = nbDataTypes;
out.NumBuiltinDataTypes = nbDataTypes;
out.ARNames = arNames;
out.SLNames = slNames;
out.DataType(1:nbDataTypes) = ...
    arxml.arxml_private('p_init_data_type', 'init_data_type_struct');

for ii = 1:nbDataTypes
    if isRTW==true
        out.DataType(ii).Type = arType{ii};
    end
    out.DataType(ii).DataTypeId = ii;
    out.DataType(ii).BaseDataTypeId = ii;
    out.DataType(ii).ARName = arNames{ii};
    out.DataType(ii).SLName = slNames{ii};
    out.DataType(ii).Min = minVal{ii};
    out.DataType(ii).Max = maxVal{ii};
    out.DataType(ii).WordSize = wordSize(ii);
    out.DataType(ii).IsSigned = isSigned(ii);
    out.DataType(ii).IsBoolean = isBoolean(ii);
    out.DataType(ii).IsInteger = isInteger(ii);
    out.DataType(ii).IsFloat = isFloat(ii);
    if isRTW==true
        initValueName=['DefaultInitValue_' arNames{ii}];
        defaultInitValue=eval([matlabTypes{ii} '(0);']);
        userDefined=false;
        initValueTable.addInitValue(initValueName, defaultInitValue, ...
                                    out, ii, userDefined)     
    end
end

end
