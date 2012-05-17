function result = parse_data_type_string(data)

%   Copyright 2007-2010 The MathWorks, Inc.

result = [];

hd = idToHandle(sfroot, data);
typeStr = hd.DataType;
dtaItems = get_data_type_items(hd);

try
    dt = Simulink.DataTypePrmWidget.parseDataTypeString(typeStr, dtaItems);
catch ME
    error('Stateflow:UnexpectedError','SL/SF internal error: Failed to parse data type string "%s".\n%s', typeStr, ME.message);
end

if dt.isInherit
    result.mode = 'inherited';
elseif dt.isBuiltin
    result.mode = 'built-in';
    result.type = dtaItems.builtinTypes{dt.indexBuiltin + 1}; % zero based indexing
    if strcmpi(dt.fixptProps.datatypeoverride, 'Inherit')
        result.dtoMode = 'Inherit';
    elseif  strcmpi(dt.fixptProps.datatypeoverride, '''Off''')
        result.dtoMode = 'Off';
    else
        result.dtoMode = 'Inherit';
    end
elseif dt.isFixPt
    result.mode = 'fixed point';
    result.isSigned = (dt.fixptProps.signed == 0);
    result.wordLength = dt.fixptProps.wordLength;
    result.slope = dt.fixptProps.slope;
    result.bias = dt.fixptProps.bias;
    result.fractionLength = dt.fixptProps.fractionLength;
    scalingModeNames = {'binary point', 'slope and bias'}; % Make sure this list matchs the sequence in dtaItems.scalingModes
    result.scalingMode = scalingModeNames{dt.fixptProps.scalingMode + 1};
    if strcmpi(dt.fixptProps.datatypeoverride, 'Inherit')
        result.dtoMode = 'Inherit';
    elseif  strcmpi(dt.fixptProps.datatypeoverride, '''Off''')
        result.dtoMode = 'Off';
    else
        result.dtoMode = 'Inherit';
    end
elseif dt.isExpress
    result.mode = 'expression';
    result.type = dt.str;
elseif dt.isEnumType
    result.mode = 'enumerated';
    result.type = dt.enumClassName;
elseif dt.isBusType
    result.mode = 'bus object';
    result.type = dt.busObjectName;
elseif dt.isExtra
    result.mode = lower(dtaItems.extras(dt.extraProps.indexExtra + 1).name); % zero based indexing
    result.type = dt.extraProps.exprExtra;
else
    result.mode = 'unknown';
end

result.showLockScalingCheck = true;
