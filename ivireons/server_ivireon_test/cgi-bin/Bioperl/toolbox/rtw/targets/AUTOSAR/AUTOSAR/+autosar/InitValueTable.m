classdef InitValueTable < handle
    %INITVALUETABLE holds all initial values
    
    %   Copyright 2010 The MathWorks, Inc.
    
    properties (SetAccess=private,GetAccess=public)
        InitValues;
        AddedNodes;
    end
    
    methods (Access=public, Static=true)
        
        function  initValueName_sub=getSubsidiaryInitValueName...
                (initValueName,eDataType,i, maxNameLen)
            
            initValueName_sub = arxml.arxml_private...
                ('p_create_aridentifier', ...
                [ initValueName '_', eDataType.ARName, '_', num2str(i)], maxNameLen);
            
        end
        
    end
    
    
    methods (Access=public)
        
        function this = InitValueTable
            this.InitValues=containers.Map('KeyType','char','ValueType','any');
            this.AddedNodes=containers.Map('KeyType','char','ValueType','char');
        end
        
        function initValueStruct = getInitValue(this, name)
            if this.InitValues.isKey(name)
                initValueStruct=this.InitValues(name);
            else
                initValueStruct=[];
            end
        end
        
        function initValueStructOut = getInitValueDeReferenced(this, name, dataTypeTable)
            
            initValueStruct = getInitValue(this, name);
            
            if isempty(initValueStruct)
                return;
            end
            
            eDataTypeId=initValueStruct.dataTypeId;
            initValueObj=initValueStruct.value;
            
            eDataType = dataTypeTable.DataType(eDataTypeId);
            
            % Traverse the hierarchy of the initial value object
            isRecord = strcmp(eDataType.Type,'RECORD-TYPE');
            isArray = strcmp(eDataType.Type,'ARRAY-TYPE');
            
            if isArray
                numEls=length(initValueObj);
                assert(eDataType.Width==numEls,...
                    'Data type width must match constant value');
                dataTypeId_sub=eDataType.BaseDataTypeId;
                eDataType_sub=dataTypeTable.DataType(dataTypeId_sub);
                assert(~eDataType_sub.IsArray,'Cannot have an array of arrays');
                for i=1:numEls
                    initValueStruct_sub=this.getInitValueDeReferenced...
                        (initValueObj{i}, dataTypeTable);
                    initValueStructOut.dataTypeId=initValueStruct_sub.dataTypeId;
                    value(i)=initValueStruct_sub.value; %#ok<AGROW>
                end
                initValueStructOut.value=value(:);
            end
            
            if isRecord
                numEls=length(eDataType.Elements);
                assert(numEls==length(initValueObj),...
                    'Number of values must match number of fields');
                initValue_sub=struct;
                for i=1:numEls
                    fieldName=eDataType.Elements(i).Name;
                    initValueObj_sub=initValueObj{i};
                    
                    initValueStruct_sub=this.getInitValueDeReferenced...
                        (initValueObj_sub, dataTypeTable);                    
                    initValue_sub.(fieldName)=initValueStruct_sub.value;

                end
 
                initValueStructOut.value=initValue_sub;
                initValueStructOut.dataTypeId=eDataTypeId;
            end
            
            if ~isRecord &&  ~isArray
                initValueStructOut=initValueStruct;
            end
            
        end
        
        function addUserDefinedInitValue...
                (this, initValueName, dataTypeTable, ...
                eDataTypeId, maxNameLen)
            % Check if this the default name for this data type
            dataTypeName=dataTypeTable.DataType(eDataTypeId).ARName;
            if strcmp(initValueName,....
                    autosar.init_value_name_for_datatype(dataTypeName,...
                                                         maxNameLen));
                initValueFromTable=this.getInitValue(initValueName);
                assert(~isempty(initValueFromTable),...
                    'The default initial value must already have been added');
                if evalin('base',['exist(''' initValueName ''',''var'')==1'])
                    initValueFromBase = evalin('base',initValueName);
                    initValueFromTable = this.getInitValueDeReferenced...
                        (initValueName, dataTypeTable);
                    if ~isequal(initValueFromBase,initValueFromTable.value)
                        DAStudio.error('RTW:autosar:defaultInitObjIsModified',...
                            initValueName);
                    end
                end
            else
                % We have a non-default user-defined initial value
                if ~evalin('base',['exist(''' initValueName ''',''var'')==1'])
                    DAStudio.error('RTW:autosar:initValueMissing', initValueName)
                end
                initValue = evalin('base',initValueName);
                userDefined=true;
                this.addInitValue(initValueName, initValue, ...
                    dataTypeTable, eDataTypeId, userDefined, maxNameLen);
            end
            
        end
        
        function addInitValue...
                (this, initValueName, initValueObj, dataTypeTable, ...
                 eDataTypeId, userDefined, maxNameLen)
            
            eDataType = dataTypeTable.DataType(eDataTypeId);
            
            % Traverse the hierarchy of the initial value object
            isRecord = strcmp(eDataType.Type,'RECORD-TYPE');
            isArray = strcmp(eDataType.Type,'ARRAY-TYPE');
            
            if isArray
                numEls=eDataType.Width;
                if ~ischar(initValueObj)
                    % We have an actual value, not a reference
                    numEls=length(initValueObj);
                    assert(length(initValueObj)==numEls,...
                        'Data type width must match constant value');
                end
                dataTypeId_sub=eDataType.BaseDataTypeId;
                eDataType_sub=dataTypeTable.DataType(dataTypeId_sub);
                assert(~eDataType_sub.IsArray,'Cannot have an array of arrays');
                initValueNames_sub = cell(1,numEls);
                for i=1:numEls
                    if userDefined
                        initValueName_sub=autosar.InitValueTable.getSubsidiaryInitValueName...
                            (initValueName,eDataType,i, maxNameLen);
                        this.addInitValue(initValueName_sub, initValueObj(i),...
                                          dataTypeTable, dataTypeId_sub, userDefined, maxNameLen);
                    else
                        initValueName_sub=autosar.init_value_name_for_datatype...
                            (eDataType_sub.ARName, maxNameLen);
                    end
                    initValueNames_sub{i}=initValueName_sub;
                end
            end
            
            if isRecord
                numEls=length(eDataType.Elements);
                if isstruct(initValueObj);
                    fieldNames = fields(initValueObj);
                    numFields = length(fieldNames);
                    assert(numEls==numFields,...
                        'Number of values must match number of fields');
                    initValueNames_sub = cell(1,numEls);
                    for i=1:numEls
                        
                        fieldName=fieldNames{i};
                        initValueObj_sub=eval(['initValueObj.' fieldName]);
                        
                        eDataType_subId = eDataType.Elements(i).DataTypeId;
                        if userDefined
                            initValueName_sub = ...
                                autosar.InitValueTable.getSubsidiaryInitValueName...
                                (initValueName,eDataType,i, maxNameLen);
                            this.addInitValue(initValueName_sub, initValueObj_sub,...
                                              dataTypeTable, eDataType_subId, ...
                                              userDefined, maxNameLen);
                        else
                            eDataType_sub=dataTypeTable.DataType(eDataType_subId);
                            initValueName_sub=autosar.init_value_name_for_datatype...
                            (eDataType_sub.ARName, maxNameLen);
                        end
                        initValueNames_sub{i}=initValueName_sub;
                    end
                else
                    numRefs = length(initValueObj);
                    assert(numEls==numRefs,...
                        'Number of values must match number of fields');
                    initValueNames_sub = initValueObj;
                end
            end
            
            initValueARName = initValueName;
            
            if isRecord || isArray
                initValue=initValueNames_sub;
            else
                initValue = initValueObj;
            end
            
            initValueStruct.value=initValue;
            initValueStruct.dataTypeId=eDataTypeId;
            initValueStruct.userDefined=userDefined;
            
            % look to see if initial value has already has been defined
            existingInitValueStruct=this.getInitValue(initValueARName);
            
            if ~isempty(existingInitValueStruct)
                assert(isequal(existingInitValueStruct, initValueStruct),...
                       'Conflicting initial values');
            else
                this.InitValues(initValueARName)=initValueStruct;
            end
        end
        
        function addValueNodeContent...
                (this, initValueARName, valueNode, ivPkgNode, dataTypeTable, ...
                 initialValuePackage, dataTypePackage, xsdver, maxNameLen)

            assert(this.InitValues.isKey(initValueARName),...
                   'the initial value must already have been registered');

            valueStruct=this.InitValues(initValueARName);
            eDataTypeId=valueStruct.dataTypeId;
            initValue = valueStruct.value;
            userDefined = valueStruct.userDefined;
            
            eDataType = dataTypeTable.DataType(eDataTypeId);
            
            % Default Attribute Name/Value
            attribName = [];
            attribValue = [];
            if xsdver>=2
                attribName = 'DEST';
            end
            
            if eDataType.IsArray
                if xsdver>=2
                    attribValue = 'ARRAY-TYPE';
                end
                % Get the base data type
                baseDataType = dataTypeTable.DataType(eDataType.BaseDataTypeId);
                
                % Create the ArraySpecification element and add the TypeRef and
                % Destination
                arrayNode = arxml.arxml_private('p_add_named_node', valueNode,...
                                                'ARRAY-SPECIFICATION',...
                                                initValueARName, maxNameLen);
                arxml.arxml_private('p_add_node', arrayNode,...
                                    'TYPE-TREF', [dataTypePackage,'/',...
                                    eDataType.ARName],...
                                    attribName, attribValue);
                
                % Each ArrayElement will be created below this node
                elementNode = arxml.arxml_private('p_add_node', arrayNode,...
                                                  'ELEMENTS', [], [], []);
                
                % Walk through each array element
                for ii = 1:eDataType.Width
                    shortName=autosar.InitValueTable.getSubsidiaryInitValueName...
                              (initValueARName,eDataType,ii, maxNameLen);
                    if userDefined
                        % User defined value for each element
                        initValueName=shortName;
                    else
                        % Each element has default init value
                        initValueName=autosar.init_value_name_for_datatype...
                            (baseDataType.ARName, maxNameLen);
                    end
                    
                    if ~userDefined
                        % For default values we use a reference
                        eNode = arxml.arxml_private('p_add_named_node', elementNode,...
                                                    'CONSTANT-REFERENCE', shortName,...
                                                    maxNameLen);
                        
                        if xsdver>=2
                            attribValue = baseDataType.Type;
                        end
                        arxml.arxml_private('p_add_node', eNode,...
                                            'TYPE-TREF', [dataTypePackage,...
                                            '/',baseDataType.ARName],...
                                            attribName, attribValue);
                        
                        if xsdver>=2
                            attribValue = 'CONSTANT-SPECIFICATION';
                        end
                        arxml.arxml_private('p_add_node', eNode,...
                                            'CONSTANT-REF',...
                                            [initialValuePackage,'/', initValueName],...
                                            attribName, attribValue);
                        this.addConstantSpecificationNode...
                            (initValueName, ivPkgNode, dataTypeTable, ...
                             initialValuePackage, dataTypePackage, xsdver, maxNameLen)
                    else
                        this.addValueNodeContent...
                            (initValueName, elementNode, ivPkgNode, dataTypeTable, ...
                             initialValuePackage, dataTypePackage, xsdver, maxNameLen)
                    end
                end
                
            elseif eDataType.IsRecord
                if xsdver>=2
                    attribValue = 'RECORD-TYPE';
                end
                
                % Create the RecordSpecification element and add the TypeRef and
                % Destination
                recNode = arxml.arxml_private('p_add_named_node', valueNode,...
                                              'RECORD-SPECIFICATION',...
                                              initValueARName, maxNameLen);
                arxml.arxml_private('p_add_node', recNode,...
                                    'TYPE-TREF', [dataTypePackage,...
                                    '/',eDataType.ARName],...
                                    attribName, attribValue);
                
                % Ecah RecordElement will be created below this node
                elementNode = arxml.arxml_private('p_add_node', recNode,...
                                                  'ELEMENTS', [], [], []);
                
                for ii = 1:numel(eDataType.Elements)
                    % Get the base data type
                    baseDataType = dataTypeTable.DataType...
                        (eDataType.Elements(ii).DataTypeId);
                    if iscell(initValue) && ischar(initValue{ii})
                        % Using pre-defined sub-element names (default
                        % values)
                        elInitValueARName=initValue{ii};
                    else
                        % Use the generated name
                        if userDefined
                            elInitValueARName = ...
                                autosar.InitValueTable.getSubsidiaryInitValueName...
                                (initValueARName,eDataType,ii, maxNameLen);
                        else
                            elInitValueARName = ...
                                autosar.init_value_name_for_datatype...
                                (baseDataType.ARName, maxNameLen);
                        end
                    end
                    
                    if ~userDefined
                        % For default values we use a reference
                        fieldName=eDataType.Elements(ii).Name;
                        eNode = arxml.arxml_private('p_add_named_node', elementNode,...
                                                    'CONSTANT-REFERENCE', ...
                                                    fieldName, maxNameLen);
                        
                        if xsdver>=2
                            attribValue = baseDataType.Type;
                        end
                        arxml.arxml_private('p_add_node', eNode,...
                                            'TYPE-TREF', [dataTypePackage,'/',baseDataType.ARName],...
                                            attribName, attribValue);
                        
                        if xsdver>=2
                            attribValue = 'CONSTANT-SPECIFICATION';
                        end
                        arxml.arxml_private('p_add_node', eNode,...
                                            'CONSTANT-REF',...
                                            [initialValuePackage,'/',elInitValueARName],...
                                            attribName, attribValue);

                        this.addConstantSpecificationNode...
                            (elInitValueARName,ivPkgNode, dataTypeTable, ...
                             initialValuePackage, dataTypePackage, xsdver, maxNameLen)
                    else
                        this.addValueNodeContent...
                            (elInitValueARName, elementNode, ivPkgNode, dataTypeTable, ...
                             initialValuePackage, dataTypePackage, xsdver, maxNameLen)
                    end
                end
                    
            else
                
                % Handle special case for boolean
                if eDataType.IsBoolean
                    if initValue
                        valueStr = 'true';
                    else
                        valueStr = 'false';
                    end
                elseif isa(initValue,'embedded.fi')
                    if strcmp(class(initValue),'embedded.fi')
                        % Non-default initial value uses a fi object;
                        % we need to output
                        % the stored integer value
                        valueStr = sprintf('%d',initValue.int);
                    else
                        % Default initial value uses the base type
                        valueStr = sprintf('%d',initValue);
                    end
                elseif eDataType.IsEnum
                    % Need the stored integer value
                    valueStr = sprintf('%d',initValue.cast('int32'));
                else
                    valueStr =  sprintf('%.21g',initValue);
                end
                
                
                % Create the TypeLiteral element and add the TypeRef and
                % Destination
                eNode = arxml.arxml_private...
                        ('p_add_named_node', valueNode,...
                         autosar.get_destination_for_init_value(eDataType),...
                         initValueARName, maxNameLen);
                
                if xsdver>=2
                    attribValue = eDataType.Type;
                end
                arxml.arxml_private('p_add_node', eNode,...
                                    'TYPE-TREF', [dataTypePackage,'/',eDataType.ARName],...
                                    attribName, attribValue);
                
                % Add the value
                arxml.arxml_private('p_add_node', eNode, 'VALUE', valueStr, [], []);
                
            end

        end

        
        function  addConstantSpecificationNode...
                (this, initValueARName, ivPkgNode, dataTypeTable, ...
                 initialValuePackage, dataTypePackage, xsdver, maxNameLen)
            
            if ~this.AddedNodes.isKey(initValueARName); % protect against multiple definition
                this.AddedNodes(initValueARName)='1';
                
                % Create the ConstantSpecification named node
                constNode = arxml.arxml_private('p_add_named_node', ivPkgNode, ...
                                                'CONSTANT-SPECIFICATION',...
                                                initValueARName, maxNameLen, true);
                valueNode = arxml.arxml_private('p_add_node', constNode, 'VALUE', ...
                                                [], [], []);
                

                this.addValueNodeContent(initValueARName, valueNode, ...
                                         ivPkgNode, dataTypeTable, ...
                                         initialValuePackage, dataTypePackage,...
                                         xsdver, maxNameLen);
                
            end
        end
    end
end
