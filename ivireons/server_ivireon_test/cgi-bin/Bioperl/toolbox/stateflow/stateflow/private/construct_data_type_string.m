function typeStr = construct_data_type_string(data)

%   Copyright 2007-2010 The MathWorks, Inc.

typeStr = ''; %#ok<NASGU>
hd = idToHandle(sfroot, data);

switch lower(hd.Props.Type.Method)
    case 'inherited'
        typeStr = 'Inherit: Same as Simulink';
    case 'built-in'
        typeStr = hd.Props.Type.Primitive;
        if strcmp(hd.Props.Type.Fixpt.dataTypeOverride, 'Off')
            typeStr = ['fixdt(''', typeStr, ''', ''DataTypeOverride'', ''Off'')'];
        end
    case 'expression'
        typeStr = hd.Props.Type.Expression;
    case 'enumerated'
        typeStr = ['Enum: ' hd.Props.Type.EnumType];
    case 'bus object'
        typeStr = ['Bus: ' hd.Props.Type.BusObject];
    case 'fixed point'
        signed = num2str(hd.Props.Type.Signed);
        wordLength = hd.Props.Type.WordLength;
        
        switch lower(hd.Props.Type.Fixpt.ScalingMode)
            case 'none'
                typeStr = Simulink.DataTypePrmWidget.fixdtFieldsToString(signed, wordLength, '0');
            case 'binary point'
                fractionLength = hd.Props.Type.Fixpt.FractionLength;
                typeStr = Simulink.DataTypePrmWidget.fixdtFieldsToString(signed, wordLength, fractionLength);
                if strcmp(hd.Props.Type.Fixpt.dataTypeOverride, 'Off')
                        typeStr = strrep(typeStr, ')', ', ''DataTypeOverride'', ''Off'')');
                end
            case 'slope and bias'
                slope = hd.Props.Type.Fixpt.Slope;
                bias = hd.Props.Type.Fixpt.Bias;
                typeStr = Simulink.DataTypePrmWidget.fixdtFieldsToString(signed, wordLength, slope, bias);
                if strcmp(hd.Props.Type.Fixpt.dataTypeOverride, 'Off')
                        typeStr = strrep(typeStr, ')', ', ''DataTypeOverride'', ''Off'')');
                end
            otherwise
                error('Stateflow:UnexpectedError','Unknown fixpt scaling mode.');
        end
    otherwise
        error('Stateflow:UnexpectedError','Unknown type method.');
end
