function factoryViews = getFactoryViews(h, name)
% getFactoryViews
% This method provides the fixed list of pre-defined views.

%   Copyright 2009 The MathWorks, Inc.

factoryMap   = ...
    {...
    'Default',                  @getDefaultView
    'Data Objects',             @getDataObjectsView
    'Data Type Objects'         @getDataTypeObjectsView
    'Block Data Types',         @getBlockDataTypesView
    'System I/O',               @getSystemIOView
    'Signals',                  @getSignalsView
    'Storage Class',            @getStorageClassView
    'Model Reference',          @getModelReferenceView    
    'Stateflow',                @getStateflowView
    };

factoryViews = [];
switch nargin
    case 2
        % Return the requested factory view
        index = strmatch(name, {factoryMap{:, 1}});
        if ~isempty(index)
            factoryViews = feval(factoryMap{index, 2}, h);
        end
        
    otherwise
        % Return all factory views
        for i = 1:length(factoryMap)
            factoryViews = [factoryViews feval(factoryMap{i, 2}, h)];
        end
end


%=====================================================================
% FACTORY VIEW DEFINITIONS
%=====================================================================
function viewDef = getDefaultView(h)

viewDef = l_CreateView(h, ...
    'Default', ...
    {...
        'BlockType'
    }, ...
    {}, ...
    'Generic view - select "Show Details" to add properties' ...
    );

%=====================================================================
function viewDef = getDataObjectsView(h)

viewDef = l_CreateView(h, ...
    'Data Objects', ...
    {...
        'Value'
        'DataType'
        'Min'
        'Max'
        'Dimensions'
        'StorageClass'
        'Complexity'
        'InitialValue'
        'SampleTime'
    }, ...
    {}, ...
    'Show common properties for data objects and workspace variables' ...
);

%=====================================================================
function viewDef = getDataTypeObjectsView(h)

viewDef = l_CreateView(h, ...
    'Data Type Objects', ...
    {...
        'DataTypeMode'
        'Signedness'
        'WordLength'
        'FractionLength'
        'Slope'
        'Bias'
        'IsAlias'
        'HeaderFile'
        'BaseType'
     }, ...
    {}, ...
    'Show common properties for data type objects' ...
);

%=====================================================================
function viewDef = getBlockDataTypesView(h)

viewDef = l_CreateView(h, ...
    'Block Data Types', ...
    {...
        'BlockType'
        'OutDataTypeStr'
        'OutMin'
        'OutMax'
        'LockScale'
        'DataType'
        'Min',
        'Max'
        'AccumDataTypeStr'
        'ParamDataTypeStr',
        'ParamMin'
        'ParamMax'                
    }, ...
    {}, ...
    'Show properties related to setting block data types' ...
);

%=====================================================================
function viewDef = getSystemIOView(h)

viewDef = l_CreateView(h, ...
    'System I/O', ...
    {...
        'BlockType'
        'Port'
        'UseBusObject'
        'BusObject'
        'OutDataTypeStr'
        'LockScale'
        'OutMin'
        'OutMax'
        'PortDimensions'
        'SampleTime'
        'SignalType'
        'IconDisplay'
        'InitialOutput'
        'OutputWhenDisabled'
    }, ...
    {}, ...
    'Show properties of Inport/Outport blocks' ...
);


%=====================================================================
function viewDef = getSignalsView(h)

viewDef = l_CreateView(h, ...
    'Signals', ...
    {...
        'SourcePort'
        'SignalPropagation'
        'MustResolveToSignalObject'
        'DataLogging'
        'TestPoint'
        'SignalObjectPackage'
        'StorageClass'
    }, ...
    {''}, ...
    'Show properties of signals' ...
);

%=====================================================================
function viewDef = getStorageClassView(h)

viewDef = l_CreateView(h, ...
    'Storage Class', ...
    {...
        'RTWInfo.Alias'
        'StorageClass'
        'HeaderFile'
        'RTWInfo.CustomAttributes.StructName'
        'RTWInfo.CustomAttributes.GetFunction'
        'RTWInfo.CustomAttributes.SetFunction'
        'RTWInfo.CustomAttributes.MemorySection'
        'RTWInfo.CustomAttributes.Owner'
        'RTWInfo.CustomAttributes.DefinitionFile',
        'RTWInfo.CustomAttributes.PersistenceLevel'
    }, ...
    {''}, ...
    'Show properties for configuring appearance of data in generated code' ...
);

%=====================================================================
function viewDef = getModelReferenceView(h)

viewDef = l_CreateView(h, ...
    'Model Reference', ...
    {...
        'BlockType'
        'ModelName'
        'ParameterArgumentNames'
        'ParameterArgumentValues'
        'SimulationMode'
    }, ...
    {''}, ...
    'Show properties for model reference blocks' ...
);

%=====================================================================
function viewDef = getStateflowView(h)

viewDef = l_CreateView(h, ...
    'Stateflow', ...
    {...
        'Scope'
        'Port'
        'Resolve Signal'
        'DataType'
        'Props.Array.Size'
        'Props.InitialValue'
        'CompiledType'
        'CompiledSize'
        'Trigger'
    }, ...
    {''}, ...
    'Show properties for Stateflow data and events' ...
);

%=====================================================================
% HELPER SUBFUNCTIONS
%=====================================================================
function viewDef = l_CreateView(h, name, props, matchProps, desc)

viewDef = DAStudio.MEView(name, desc);

for idx = 1:size(props,1)
  thisProp = props{idx};
  if (idx == 1)
    viewDef.Properties = DAStudio.MEViewProperty(thisProp);
  else
    viewDef.Properties(idx) = DAStudio.MEViewProperty(thisProp);
  end
  
  % Set if this is a "matching" property
  if ismember(thisProp, matchProps)
    viewDef.Properties(idx).isMatching = true;
  end
end
viewDef.InternalName = ['TMW_' name '_' release_version];
    
% EOF
