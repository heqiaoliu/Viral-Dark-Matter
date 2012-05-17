function create_init_values(component,dataTypes)
%CREATE_INIT_VALUES creates initial value variables in base workspace
%
%   Creates autosar.InitValue objects in base workspace based on information
%   imported from XML files

%   Copyright 2010 The MathWorks, Inc.

if ~slfeature('AutosarInitValues')
    return;
end

numPPorts=length(component.PPorts);
numRPorts=length(component.RPorts);
[allInterfaces{1:numPPorts}]=deal(component.PPorts.Interface);
[allInterfaces{numPPorts+1:numPPorts+numRPorts}]=...
    deal(component.RPorts.Interface);


for i=1:numPPorts+numRPorts;
    interface=allInterfaces{i};
    if ~isempty(interface.Elements)
        initValueName=interface.Elements(1).InitValueName;
        if ~isempty(initValueName)
            unscaledAutosarConst=interface.Elements.InitValueObj;
            if ~isempty(unscaledAutosarConst)
                dataTypeId=interface.Elements.DataTypeId;
                
                % Default init value has the required type and dimensions
                init_value = i_get_init_value(unscaledAutosarConst,dataTypeId,...
                    dataTypes);
                
                if evalin('base',['exist(''' initValueName ''',''var'')']);
                    init_value_from_base=evalin('base', initValueName);
                    if ~isequal(init_value(:),init_value_from_base(:))
                        DAStudio.error('RTW:autosar:initialValueMismatch',...
                                       initValueName);
                    end
                else
                    assignin('base',initValueName,init_value);
                end
            end
        end
    end
end

function default_value = i_get_default_init_value(dataType)

if dataType.IsRecord
    busObjName = dataType.ARName;
    evalin('base',...
        ['assert(exist(''' busObjName ''',''var'')==1 && '...
        'isa(' busObjName ',''Simulink.Bus''),'...
        '''BusObject must already have been created'')']);
    default_value = Simulink.Bus.createMATLABStruct(busObjName);
elseif dataType.IsFixedPoint
    % Convert from stored integer to real-world value
    myType = numerictype(dataType.IsSigned,dataType.WordSize,...
        dataType.FixedPoint.Slope, dataType.FixedPoint.Bias);
    default_value=fi(0,myType);
elseif dataType.IsEnum
    % Convert integer from XML to symbolic value
    enumType=dataType.SLName;
    enumVals = enumeration(enumType);
    default_value=enumVals(1);
elseif dataType.IsBoolean
    default_value=false;
else
    % Only remaining option is a Simulink.AliasType    
    typeName = dataType.ARName;
    evalin('base',...
        ['assert(exist(''' typeName ''',''var'')==1 && '...
        'isa(' typeName ',''Simulink.AliasType''),'...
        '''Simulink.AliasType must already have been created'')']);
    baseType = i_get_base_type(typeName);
    default_value=eval([baseType '(0)']);
end
    
function baseType = i_get_base_type(typeName)

baseType = evalin('base',[typeName '.BaseType']);

if  evalin('base',...
        ['exist(''' baseType ''',''var'')==1 && '...
        'isa(' baseType ',''Simulink.AliasType'')']);
    % Alias to an alias so need to recurse
    baseType = i_get_base_type(baseType);
end

function init_value=i_get_typed_value(default_init_value,value)

init_value = default_init_value;
if ischar(value)
    assert(length(init_value)==1,'Value must be a scalar');
    type=class(default_init_value);
    if isa(default_init_value,'embedded.fi')
        init_value=default_init_value;
        init_value.int = str2double(value);
    elseif strcmp(type,'logical')
        assert(any(strcmp(value,{'true','false'})),...
               ['Initial value for Boolean type must be '...
                'either ''true'' or ''false''']);
        eval(['init_value=' value ';']);
    else
        init_value=feval(type,str2double(value));
    end
else
    numEls = length(value);
    if isstruct(default_init_value);
        fieldNames = fields(default_init_value);
        numFields = length(fieldNames);
        assert(numEls==numFields,...
            'Number of values must match number of fields');
        for i=1:numEls
            fieldName=fieldNames{i};
            default_init_value_sub=eval(['default_init_value.' fieldName]); %#ok<NASGU>
            value_sub = value{i}.Value; %#ok<NASGU>
            eval(['init_value.' fieldName ...
                '=i_get_typed_value(default_init_value_sub, value_sub);']);
        end
    else
        assert(numEls==length(default_init_value),...
            'Number of values must match number of fields');
        for i=1:numEls
            default_init_value_sub=default_init_value(i);
            value_sub = value{i}.Value;
            init_value(i)=i_get_typed_value(default_init_value_sub, value_sub);
        end
    end
    
end


function init_value = i_get_init_value(unscaledAutosarConst,dataTypeId,...
    dataTypes)

dataType=dataTypes.DataType(dataTypeId);
width=dataType.Width;
value=unscaledAutosarConst.Value;
if dataType.IsArray
    assert(width==length(value),'Data type width must match constant value');
    dataTypeId_sub=dataType.BaseDataTypeId;
    dataType_sub=dataTypes.DataType(dataTypeId_sub);
    assert(~dataType_sub.IsArray,'Cannot have an array of arrays');
    default_init_value=i_get_default_init_value(dataType_sub);
    assert(~dataType_sub.IsRecord,'Arrays of buses are not yet supported');
    init_value=repmat(default_init_value, width, 1);
    for i=1:width
        init_value(i)=i_get_typed_value(default_init_value,value{i}.Value);
    end
else
    default_init_value = i_get_default_init_value(dataType);
    init_value=i_get_typed_value(default_init_value,value);
end
