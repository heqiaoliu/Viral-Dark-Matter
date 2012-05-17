function [propVals, dataValue] = get_valid_data_property_values(data, propName)

% Copyright 2005-2010 The MathWorks, Inc.

    if strcmp(propName, 'Props.Type.Hybrid')
        [methodStrs, methodValue] = get_default_property_values(data, 'Props.Type.Method');
        methods = { 'SF_UNKNOWN_TYPE',...       % Primitive
                    'SF_INHERITED_TYPE',...
                    'SF_PARAMETERIZED_TYPE',...
                    'SF_SIMULINK_OBJECT_TYPE',...
                    'SF_ENUM_TYPE',...
                    'SF_CUSTOM_INTEGER_TYPE'};
        methods = cell2struct(methodStrs, methods, 2);
        switch methodValue,
        case methods.SF_UNKNOWN_TYPE
            propName = 'Props.Type.Primitive';
        case methods.SF_PARAMETERIZED_TYPE
            propName = 'Props.Type.Expression';
        case methods.SF_SIMULINK_OBJECT_TYPE
            propName = 'Props.Type.BusObject';
        case methods.SF_ENUM_TYPE
            propName = 'Props.Type.EnumType';
        otherwise
            dataValue = '';
            propVals = {};
            return;
        end
    end

    [strs, dataValue] = get_default_property_values(data, propName);
    
    if strcmp(propName, 'Scope')
        scopeStrs = strs;
        scopeValue = dataValue;
    else
        [scopeStrs, scopeValue] = get_default_property_values(data, 'Scope');
    end
        
    if isnumeric(dataValue)
        dataValue = num2str(dataValue);
    end
    
    parent = data.up;
        
    scopes = {  'LOCAL_DATA',...
                'INPUT_DATA',...
                'OUTPUT_DATA',...
                'IMPORTED_DATA',...
                'EXPORTED_DATA',...
                'TEMPORARY_DATA',...
                'CONSTANT_DATA',...
                'FUNCTION_INPUT_DATA',...
                'FUNCTION_OUTPUT_DATA',...
                'PARAMETER_DATA',...
                'DATA_STORE_MEMORY_DATA'};
    scopes = cell2struct(scopeStrs, scopes, 2);
    
    isChartLocalDSM = isequal(scopeValue, scopes.DATA_STORE_MEMORY_DATA) && ...
        isequal(parent.class, 'Stateflow.Chart') && ...
        data.IsChartLocalDSM && ...
        sf('feature', 'subchartComponents');
    
    switch propName
    case 'Scope'        
        switch parent.class
        case 'Stateflow.EMChart'
            propVals = {scopes.PARAMETER_DATA};
        otherwise
            propVals = {scopes.LOCAL_DATA, scopes.CONSTANT_DATA, scopes.PARAMETER_DATA};
        end
                
        switch parent.class
        case {'Stateflow.Chart', 'Stateflow.TruthTableChart'}
            propVals = [propVals, {scopes.INPUT_DATA, scopes.OUTPUT_DATA, scopes.DATA_STORE_MEMORY_DATA}];
        case {'Stateflow.EMChart'}
            if ~sf('Feature', 'EML GlobalVariables')
                propVals = [propVals, {scopes.INPUT_DATA, scopes.OUTPUT_DATA}];
            else
                propVals = [propVals, {scopes.INPUT_DATA, scopes.OUTPUT_DATA, scopes.DATA_STORE_MEMORY_DATA}];
            end
        case {'Stateflow.Function', 'Stateflow.EMFunction', 'Stateflow.TruthTable'}
            propVals = [propVals, {scopes.INPUT_DATA, scopes.OUTPUT_DATA, scopes.TEMPORARY_DATA}];
        case {'Simulink.BlockDiagram', 'Stateflow.Machine'}
            propVals = [propVals, {scopes.IMPORTED_DATA, scopes.EXPORTED_DATA}];
        end
        
    case 'Port'  
        propVals = {};
        switch scopeValue
        case {scopes.INPUT_DATA, scopes.OUTPUT_DATA}
            portCount = length(find(parent, '-depth', 1, '-isa', 'Stateflow.Data', 'Scope', scopeValue)); %#ok<GTARG>
            propVals = regexp(num2str(1:portCount), '\d*', 'match');
        end
        
    case 'Props.Type.Primitive'
        primitives = {  'SF_DOUBLE_TYPE',...
                        'SF_SINGLE_TYPE',...
                        'SF_INT32_TYPE',...
                        'SF_INT16_TYPE',...
                        'SF_INT8_TYPE',...
                        'SF_UINT32_TYPE',...
                        'SF_UINT16_TYPE',...
                        'SF_UINT8_TYPE',...
                        'SF_BOOLEAN_TYPE',...
                        'SF_MATLAB_TYPE'};
        primitives = cell2struct(strs, primitives, 2);

        propVals = strs;
        
        switch scopeValue
        case {scopes.CONSTANT_DATA, scopes.INPUT_DATA, scopes.OUTPUT_DATA, scopes.PARAMETER_DATA, scopes.DATA_STORE_MEMORY_DATA}
            propVals(strmatch(primitives.SF_MATLAB_TYPE, propVals, 'exact')) = [];
        end
        
        % If primitive somehow gets in invalid 'unknown' value, treat it as if it is 'double'
        % G386174. Do not show "unknown" as valid built-in types.
        if strcmpi(dataValue, 'unknown')
            dataValue = 'double';
        end
        
    case 'InitializeMethod'
        modes = {   'INITIALIZATION_EXPRESSION',...
                    'INITIALIZATION_PARAMETER',...
                    'INITIALIZATION_NOT_NEEDED'};
        modes = cell2struct(strs, modes, 2);
        
        switch scopeValue
            case {scopes.INPUT_DATA, scopes.PARAMETER_DATA, scopes.IMPORTED_DATA}
                propVals = {modes.INITIALIZATION_NOT_NEEDED};
            case scopes.CONSTANT_DATA
                propVals = {modes.INITIALIZATION_EXPRESSION};
            case scopes.OUTPUT_DATA
                switch parent.class
                    case {'Stateflow.EMChart', 'Stateflow.TruthTableChart'}
                        propVals = {modes.INITIALIZATION_NOT_NEEDED};
                    otherwise
                        propVals = {modes.INITIALIZATION_EXPRESSION, modes.INITIALIZATION_PARAMETER};
                end
            case scopes.DATA_STORE_MEMORY_DATA
                if isChartLocalDSM
                    propVals = {modes.INITIALIZATION_EXPRESSION, modes.INITIALIZATION_PARAMETER};
                else
                    propVals = {modes.INITIALIZATION_NOT_NEEDED};
                end
                
            otherwise
                propVals = {modes.INITIALIZATION_EXPRESSION, modes.INITIALIZATION_PARAMETER};
        end
        
        % If data use bus object mode, no initial value is needed.
        if strcmp(data.Props.Type.Method, 'Bus Object') || data.Props.ResolveToSignalObject
            propVals = {modes.INITIALIZATION_NOT_NEEDED};
        end
        
    case 'Props.Type.Method'
        modes = {   'SF_UNKNOWN_TYPE',...       % Primitive
                    'SF_INHERITED_TYPE',...
                    'SF_PARAMETERIZED_TYPE',...
                    'SF_SIMULINK_OBJECT_TYPE',...
                    'SF_ENUM_TYPE',...
                    'SF_CUSTOM_INTEGER_TYPE'};
        modes = cell2struct(strs, modes, 2);
        
        isMachineData = strcmp(data.up.class, 'Simulink.BlockDiagram');

        dataCannotBeBus = isMachineData;
        switch scopeValue
        case {scopes.CONSTANT_DATA, scopes.DATA_STORE_MEMORY_DATA}
            dataCannotBeBus = true;
        case scopes.PARAMETER_DATA
            if ~sf('Feature', 'Tunable Struct Parameter')
                dataCannotBeBus = true;
            end
        end
        
        dataCannotBeEnum = ((slfeature('EnumDataTypesInSimulink') == 0) || ...
                            isMachineData || ...
                            isequal(scopeValue,scopes.CONSTANT_DATA));
                       
        propVals = {modes.SF_UNKNOWN_TYPE, modes.SF_PARAMETERIZED_TYPE};
        if(~dataCannotBeEnum)
            propVals = [propVals, {modes.SF_ENUM_TYPE}];
        end
        if ~dataCannotBeBus
            propVals = [propVals, {modes.SF_SIMULINK_OBJECT_TYPE}];
        end
        propVals = [propVals, {modes.SF_CUSTOM_INTEGER_TYPE}];
        
        switch scopeValue
            case {scopes.INPUT_DATA, scopes.OUTPUT_DATA}
                switch parent.class
                    case {'Stateflow.Chart', 'Stateflow.TruthTableChart','Stateflow.EMChart'}
                        propVals = [{modes.SF_INHERITED_TYPE}, propVals];
                end
            case scopes.PARAMETER_DATA
                propVals = [{modes.SF_INHERITED_TYPE}, propVals];
            case scopes.DATA_STORE_MEMORY_DATA
                if ~isChartLocalDSM
                    propVals = {modes.SF_INHERITED_TYPE};
                end
        end
        
    case 'Props.Type.Fixpt.ScalingMode'
        scalings = {'SF_FIXPT_NONE',...
                    'SF_FIXPT_BINARY_POINT',...
                    'SF_FIXPT_SLOPE_BIAS'};
        scalings = cell2struct(strs, scalings, 2);
         
        propVals = {scalings.SF_FIXPT_NONE, scalings.SF_FIXPT_BINARY_POINT, scalings.SF_FIXPT_SLOPE_BIAS};
        
    case 'Props.Complexity'
        complexities = {'SF_COMPLEX_NO',...
                        'SF_COMPLEX_YES',...
                        'SF_COMPLEX_INHERITED'};
        complexities = cell2struct(strs, complexities, 2);
        
        switch scopeValue
            case {scopes.INPUT_DATA, scopes.OUTPUT_DATA}
                switch parent.class
                    case {'Stateflow.Chart', 'Stateflow.TruthTableChart','Stateflow.EMChart'}
                        propVals = strs;
                    otherwise
                        propVals = {complexities.SF_COMPLEX_NO, complexities.SF_COMPLEX_YES};
                end
            case scopes.PARAMETER_DATA
                propVals = strs;
            case scopes.DATA_STORE_MEMORY_DATA
                if ~isChartLocalDSM
                    propVals = {complexities.SF_COMPLEX_INHERITED};
                else
                    propVals = {complexities.SF_COMPLEX_NO, complexities.SF_COMPLEX_YES};
                end
            case scopes.LOCAL_DATA
                propVals = {complexities.SF_COMPLEX_NO, complexities.SF_COMPLEX_YES};
            otherwise
                propVals = {complexities.SF_COMPLEX_NO, complexities.SF_COMPLEX_YES};
        end
             
    case 'DataType'
        dtaItems = get_data_type_items(data);
        propVals = dtaItems.validValues;
        
    otherwise
        propVals = strs;
        return;
    end

    if isempty(strmatch(dataValue,propVals,'exact'))
        propVals = [{dataValue}, propVals];        
    end
