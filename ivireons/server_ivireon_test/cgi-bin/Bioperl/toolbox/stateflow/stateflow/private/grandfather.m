function result = grandfather( command, varargin )
% RESULT = GRANDFATHER( COMMAND, ... )

%	E. Mehran Mestchian
%  Copyright 1995-2010 The MathWorks, Inc.
%  $Revision: 1.45.4.35 $  $Date: 2010/04/21 22:18:59 $

result = [];
switch command
    case 'isproperty' % propName
        % Add the list of all grandfathered properties to the switchyard below.
        propName = varargin{1};
        result = 1;
        switch propName
            case 'chart.decomposition'
            case 'state.decomposition'
            case 'chart.animationColor'
            case 'chart.groupedColor'
            case 'transition.coverageInfo'
            case 'transition.src.intersection'
            case 'transition.dst.intersection'
            case 'transition.drawStyle'
            case 'state.coverageInfo'
            case 'state.eml.treatIntsAsFixpt'
            case 'state.superState'
            case 'target.codeCommand'
            case 'data.range.minimum'
            case 'data.range.maximum'
            case 'data.range'
            case 'data.array'
            case 'data.array.size'
            case 'data.array.firstIndex'
            case 'data.initialValue'
            case 'data.isComplex'
            case 'data.complexity'
            case 'data.lastBuiltInDataType'
            case 'data.dlgFixptMode'
            case 'data.fixptType.lock'
            case 'data.lock'
            case 'data.units'
            otherwise % property is not grandfathered
                result = 0;
                return;
        end
    case 'get' % objId, propName
%         objId = varargin{1};
%         propName = varargin{2};
    case 'set' % objId, propName, propValue
%         objId = varargin{1};
%         propName = varargin{2};
%         propValue = varargin{3};
    case 'preload' % fileName
%         fileName = varargin{1};
    case 'load' % objId, propValuePairs
        objId = varargin{1};
        propValuePairs = varargin{2};
        for i=1:length(propValuePairs)
            prop = propValuePairs{i}{1};
            value = propValuePairs{i}{2};
            switch prop
                case 'state.eml.treatIntsAsFixpt'
                    if value
                        newValue = 'FI_AND_INT';
                    else
                        newValue = 'FI';
                    end
                    
                    sf('set',objId,'.eml.treatAsFi',newValue);
                    
                case 'state.superState',
                    if isequal(value, 'HIDDENGROUPED'),
                        sf('set', objId, '.superState', 'GROUPED');
                    end;
                case 'target.codeCommand'
                case 'transition.drawStyle',
                    if isequal(value, 'CURVE'),
                        sf('set', objId, '.drawStyle', 'STATIC');
                    elseif isequal(value, 'STRAIGHT'),
                        sf('set', objId, '.drawStyle', 'SMART');
                    end;
                case {'data.isComplex', 'data.complexity'}
                    if dataTypeUnInitialized(objId)
                        sf('set', objId, '.props.complexity', value);
                    end
                case 'data.dlgFixptMode'
                    if dataTypeUnInitialized(objId)
                        if value ~= 2
                            sf('set', objId, '.props.type.fixpt.scalingMode', 'SF_FIXPT_BINARY_POINT');
                        else
                            sf('set', objId, '.props.type.fixpt.scalingMode', 'SF_FIXPT_SLOPE_BIAS');
                        end
                    end
                case {'data.fixptType.lock', 'data.lock'}
                    if dataTypeUnInitialized(objId)
                        sf('set', objId, '.props.type.fixpt.lock', value);
                    end
                case 'data.units'
                    if dataTypeUnInitialized(objId)
                        sf('set', objId, '.props.type.units', value);
                    end
            end
        end
    case 'postload' % fileName, objects
%         fileName = varargin{1};
        ids = varargin{2};		% ids of everything in machine are passed in
        machineId = ids(1);
        sfVersion = sf('get',machineId,'.sfVersion');
        if(sfVersion < 20011061.000000)
            fix_animation_delay_pre_2p0(machineId);
        end
        if(sfVersion < 30011050.000001)
            fix_workspace_scope_pre_3p0(ids);
        end
        
        if (sfVersion > 30000000.000000 && sfVersion <= 30111061.000000)
            fix_corrupted_subgroups(machineId);
        end
        
        if (40000000.000000 <= sfVersion && sfVersion < 40012060.000003)...
                || (sfVersion < 30111061.000003)
            fix_bitops_property_pre_4p0(machineId);
        end
        
        
        if sfVersion < 20011030.000003
            fix_datatype_names_pre_2p0(ids);
        end
        if sfVersion <= 20011030.000005
            fix_output_event_triggers_pre_2p0(ids);
        end
        
        if sfVersion < 20011050.000002
            fix_apply_to_all_libs_pre_2p0(ids);
        end
        
        if sfVersion <= 40212071.000001
            fix_coder_flags_format_pre_4p0(ids);
        end
        
        if sfVersion < 51013000.000003
            fix_truth_table_format_pre_5p0(ids,sfVersion);
        end
        
        if sfVersion >= 64014000.000000 && sfVersion < 65014000.000000
            fix_data_type_expression_pre_6p5(ids);
        end
        
        if sfVersion < 67014000
            fix_continuous_time_charts_pre_6p7(machineId);
        end
        
        if sfVersion < 71014000.000002
            fix_ssid_numbers_pre_7p1(machineId);
        end
        
        
        % this is questionable. We are doing this for all model loads !!
        fix_orphan_subwires();
        
        if sfVersion < 71014000.000006
            fix_eml_fimath_pre_7p1(ids);
        end
        
        if sfVersion < 71014000.000010
            fix_variable_sizing_pre_7p1(machineId);
        end

        if sfVersion < 71014000.000009
            fix_eml_default_fimath_pre_7p1(ids);
        end
        
        if sfVersion < 75014000.000003
            fix_bus_data_size(ids);
        end

    case 'postbind'
        machineId = varargin{1};
        sfVersion = sf('get',machineId,'.sfVersion');
        if sfVersion < 60014000.000001
            postbind_fix_data_props_array_size_pre_6p0(machineId);
        end
        
        if sfVersion < 40212071.000002
            % G94175: we have to wait until post-bind to do this
            % otherwise, we wont detect the corruption.
            fix_corrupted_grouped_bits(machineId);
        end
        
        if sfVersion < 60014000.000003
            postbind_fix_eml_chart_prototype_pre_6p0(machineId);
        end
        
        
        if sfVersion < 60014000.000005
            postbind_fix_config_set_migration_pre_6p0(machineId); 
        end
        
        if sfVersion < 67014000.000001
            postbind_fix_implicit_signal_resolution_and_warn_pre_6p7(machineId);
        end
        
        isLib = sf('get', machineId, 'machine.isLibrary');
        if ((sfVersion < 71014000.000005) && ~isLib) || ((sfVersion < 71014000.000007) && isLib)
            postbind_fix_config_set_migration_pre_7p1(machineId,isLib);
        end
        
        if(sfVersion<73014000.000000)
            postbind_fix_chart_atomic_property_all(machineId);
        end
        
        if (sfVersion<75014000.000002)
            postbind_turnoff_configset_customcode_parsing_pre_10b(machineId);
        end
        
    otherwise
       fprintf(1,'stateflow/private/grandfather: unknown command %s.',command);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = machine_allows_implicit_signal_resolution(machineName)

val = true;
cs = getActiveConfigSet(machineName);

if ~isempty(cs) && cs.isValidParam('SignalResolutionControl')
    updateVal = true;
    if isa(cs,'Simulink.ConfigSetRef')
        if isempty(cs.WSVarName) || ~evalin('base',['exist(''' cs.WSVarName ''',''var'');']) || ...
                ~evalin('base',['isa(' cs.WSVarName ',''Simulink.ConfigSet'');'])
            % No need to generate a warning message here reporting that the ConfigSet
            % object does not exist in the base workspace, or there exists one but is
            % not a Simulin.ConfigSet object. The model loading process should have
            % generated such warning already.
            updateVal = false;
        end
    end
    
    if updateVal
        val = ~strcmpi(cs.get_param('SignalResolutionControl'), 'UseLocalSettings');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function postbind_fix_implicit_signal_resolution_and_warn_pre_6p7(machineId)
% Disable implicit signal resolution for chart outputs. Apply for pre7b models

machineName = sf('get', machineId, 'machine.name');
mdlAllowImplicitSigRes = machine_allows_implicit_signal_resolution(machineName);

allCharts = sf('get', machineId, 'machine.charts');
hChartBlks = chart2block(allCharts);

for hChart = hChartBlks(:)'
    if mdlAllowImplicitSigRes
        sfb = find_system(hChart, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'BlockType', 'S-Function');
        portHandles = get_param(sfb, 'PortHandles');
        
        for i = 2:length(portHandles.Outport) % First port reserved for fcn call outputs
            thisPort = get_param(portHandles.Outport(i), 'Object');
            if strcmpi(thisPort.MustResolveToSignalObject, 'off')
                resolved = isSignalObjectResolved(sfb, thisPort.Name);
                if resolved
                    enforceExplicitSignalResolutionForPort(hChart, thisPort);
                end
            end
        end
    end
    
    set_param(hChart, 'PermitHierarchicalResolution', 'ExplicitOnly');
end

%------------------------------------------------------------------------------
function [doesResolve, blocked] = isSignalObjectResolved(hSrc, name)
% Check whether name resolves to signal object in base workspace.

doesResolve = false;
blocked = false;

if iscvar(name)
    % Check for blocks that are inside subsystems that prevent hierarchical resolution
    parent = get_param(hSrc, 'Parent');
    while strcmp(get_param(parent, 'Type'), 'block')
        if strcmp(get_param(parent, 'PermitHierarchicalResolution'), 'All')
            parent = get_param(parent, 'Parent');
        else
            %% EARLY RETURN:
            %% Parent system does not permit hierarchical scoping.
            blocked = true;
            return;
        end
    end
    
    % Check if signal object exists in base workspace
    varExists = evalin('base', ['exist(''', name, ''', ''var'');']);
    if ((varExists) && ...
            (evalin('base', ['isa(', name, ', ''Simulink.Signal'');'])))
        doesResolve = true;
    end
end

%------------------------------------------------------------------------------
function enforceExplicitSignalResolutionForPort(sfChart, port)

%sfChart = get_param(port.Parent, 'Parent');
sigLabel = port.Name;
outportBlk = find_system(sfChart, ...
    'SearchDepth', 1, ...
    'LookUnderMasks', 'on', ...
    'Name',           sigLabel, ...
    'BlockType',      'Outport');

if length(outportBlk) ~= 1
    return;
end

% MOVE SIGNAL LABEL TO PARENT SUBSYSTEM (Stateflow chart)
sfPorts    = get_param(sfChart, 'PortHandles');
sfPortNo   = str2double(get_param(outportBlk, 'Port'));
port   = get_param(sfPorts.Outport(sfPortNo), 'Object');
if ~strcmp(port.Name, sigLabel)
    if ~isempty(port.Name)
        DAStudio.warning('Simulink:tools:RenameStateflowOutputSignal', ...
            port.Name, sigLabel, sfChart);
    end
    port.Name = sigLabel;
end

port.MustResolveToSignalObject = false;
port.RTWStorageClass = 'ExportedGlobal';
port.RTWStorageTypeQualifier = '';
port.RTWStorageClass = 'Auto';
port.MustResolveToSignalObject = true;

%--------------------------------------------------------------------------
function uninited = dataTypeUnInitialized(dataId)

[typeMode, typePrim] = sf('get', dataId, '.props.type.method', '.props.type.primitive');
uninited = (typeMode == 0) && (typePrim == 0);

%------------------------------------------------------------------------------
function fix_ssid_numbers_pre_7p1(machineId)
% assign SSId numbers for older models
allCharts = sf('get', machineId, 'machine.charts');

for i = 1 : length(allCharts)
    
    chartId = allCharts(i);
    
    % get all objects in the chart
    objs = [sf('get', chartId, 'chart.states'), ...
        sf('get', chartId, 'chart.transitions'), ...
        sf('get', chartId, 'chart.junctions'), ...
        sf('DataIn', chartId), ...
        sf('EventsIn', chartId)];
    
    % assign sequential SSIds to all objects in the list
    for j = 1 : length(objs)
        sf('set', objs(j), '.ssIdNumber', j);
    end
    
    % update high water mark
    sf('set', chartId, '.ssIdHighWaterMark', j);
    
    %    sf('set', objs, '.ssIdNumber', [1:1:length(objs)]');
    %    sf('set', chartId, '.ssIdHighWaterMark', length(objs));
    
end

%------------------------------------------------------------------------------
function result = flag_value(flags,str)

index = strfind(flags,str);
if(~isempty(index))
    len = index(1)+length(str)+1;
    if (len <= length(flags)) && (flags(len)=='1')
        %if flags(index(1)+length(str)+1)=='1'
        result = 'on';
    else
        result = 'off';
    end
else
    if (strcmp(flags,'echo') || strcmp(flags,'databitsets') || strcmp(flags,'statebitsets'))
        result = 'off'; % default value for echo databitsets statebitsets
    else
        result = 'on';  % default value for debug overflow comments
    end
end

%------------------------------------------------------------------------------
function settings = get_target_settings(target, targetName, isLib)

settings.customCode        = sf('get', target, 'target.customCode');
settings.userIncludeDirs   = sf('get', target, 'target.userIncludeDirs');
settings.userLibraries     = sf('get', target, 'target.userLibraries');
settings.customInitializer = sf('get', target, 'target.customInitializer');
settings.customTerminator  = sf('get', target, 'target.customTerminator');
settings.userSources       = sf('get', target, 'target.userSources');
settings.description       = sf('get', target, 'target.description');

sf('set', target, 'target.customCode',        '');
sf('set', target, 'target.userIncludeDirs',   '');
sf('set', target, 'target.userLibraries',     '');
sf('set', target, 'target.customInitializer', '');
sf('set', target, 'target.customTerminator',  '');
sf('set', target, 'target.userSources',       '');
sf('set', target, 'target.description',       '');

if isLib
    % useLocalCmCdSettings
    if sf('get', target, 'target.useLocalCustomCodeSettings')
        settings.useLocalCmCdSettings = 'on';
    else
        settings.useLocalCmCdSettings = 'off';
    end
    
else
    
    % reservedNames is only used in non-library models
    settings.reservedNames = sf('get', target, 'target.reservedNames');
    sf('set', target, 'target.reservedNames', '');
    
    %if ~sf('get', target, 'target.applyToAllLibs');
    %    disp(['Warning: Option ''Use these custom code settings for all '...
    %          'libraries'' is obsolete. Please use ''Use local custom code '...
    %          'settings (do not inherit from main model)'' in library models.']);
    %end
    
    codeFlags = sf('get', target, 'target.codeFlags');
    
    if strcmp(targetName, 'sfun')
        % debug, overflow, echo
        settings.echo     = flag_value(codeFlags, 'echo');
        settings.debug    = flag_value(codeFlags, 'debug');
        settings.overflow = flag_value(codeFlags, 'overflow');
        sf('set', target, 'target.codeFlags', '');
    end
    
    if strcmp(targetName, 'rtw')
        settings.comments     = flag_value(codeFlags, 'comments');
        settings.databitsets  = flag_value(codeFlags, 'databitsets');
        settings.statebitsets = flag_value(codeFlags, 'statebitsets');
        % preservenames, preservenameswithparent, exportcharts are not preserved in ConfigSet
        % So do not clear codeflags for rtw non-library models
    end
end

%------------------------------------------------------------------------------
function append_cs_description(cs, description, targetName)

if ~isempty(description) && ~strcmp(description, 'Default Simulink S-Function Target.')
    if strcmp(targetName, 'rtw')
        header = ['* Real-Time Workshop Target Description' sprintf('\n')];
    else
        header = ['* Simulation Target Description' sprintf('\n')];
    end
    
    if isempty(cs.Description)
        cs.Description = [header description sprintf('\n')];
    else
        cs.Description = [cs.Description sprintf('\n\n') header description sprintf('\n')];
    end
end

%------------------------------------------------------------------------------
function fix_animation_delay_pre_2p0(machineId)
%In 1.06, we were storing animation delay as an index into the debugger
%pop-up , i.e, 0-4. In 1.2 onwards , we are storing the actual value of the delay.
%hence the conversion. G42321
animationDelay = sf('get',machineId,'machine.debug.animation.delay');
animationDelay = animationDelay/5.0;
sf('set',machineId,'machine.debug.animation.delay',animationDelay);

%------------------------------------------------------------------------------
function fix_workspace_scope_pre_3p0(ids)
% prior to rationalizing workspace data
workspaceData = sf('find',ids,'data.scope','WORKSPACE_DATA');
for i=1:length(workspaceData)
    dataSize = sf('get',workspaceData(i),'data.parsedInfo.array.size');
    if(~isempty(dataSize) && dataSize>0)
        if(~isempty(sf('get',sf('get',workspaceData(i),'data.linkNode.parent'),'machine.id')))
            % machine parented vector data
            sf('set',workspaceData(i),'data.scope','EXPORTED_DATA','data.initFromWorkspace',1);
        else
            % chart parented vector data
            sf('set',workspaceData(i),'data.scope','LOCAL_DATA','data.initFromWorkspace',1);
        end
    else
        sf('set',workspaceData(i),'data.scope','PARAMETER_DATA');
    end
end
tempData = sf('find',ids,'data.scope','TEMPORARY_DATA');
tempDataParents = sf('get',tempData,'data.linkNode.parent');
for i=1:length(tempDataParents)
    if(~isempty(sf('find',tempDataParents(i),'~state.type',2)))
        % parented by a state that is not a function. change type to local
        sf('set',tempData(i),'data.scope','LOCAL_DATA');
    end
end

%--------------------------------------------------------------------------
function fix_bitops_property_pre_4p0(machineId)
% move bitops property from target to machine/charts.

allTargets = sf('TargetsOf',machineId);
sfunTarget = sf('find',allTargets,'target.name','sfun');
% get property from sfun target and apply to all charts and machine
enableBitOps = ~isempty(findstr(sf('get',sfunTarget,'target.codeFlags'),'bitops'));
allCharts = sf('get',machineId,'machine.charts');
sf('set',allCharts,'chart.actionLanguage',enableBitOps);
sf('set',machineId,'machine.defaultActionLanguage',enableBitOps);
% check for inconsistent settings across targets; strip out old flags
count = 0;
for t = allTargets
    flags = sf('get',t,'target.codeFlags');
    [s f] = regexp(flags,'[+\-]bitops', 'once');
    if(~isempty(s))
        count = count + 1;
        flags(s:f) = [];
        sf('set',t,'target.codeFlags',flags);
    end
end
if (0 < count) && (count < length(allTargets))
    fprintf(1,'Warning: In model ''%s'' some targets enable C-like bit operations while other targets do not.',...
        sf('get',machineId,'machine.name'));
    if(enableBitOps)
        fprintf(1,'         Bit operations have been enabled on all charts, consistent with sfun target.');
    else
        fprintf(1,'         Bit operations have been disabled on all charts, consistent with sfun target.');
    end
end

%--------------------------------------------------------------------------
function fix_datatype_names_pre_2p0(ids)
% Upgrade the old data types to new mapping compatible with Simulink
for dataId = sf('get',ids,'data.id')'
    dataType = sf('get',dataId,'data.dataType');
    switch(dataType)
        case {'Boolean (unsigned char)','Boolean (1 bit)'}
            dataType ='boolean';
        case {'Nibble (4 bits)','Byte (unsigned char)'}
            dataType ='uint8';
        case {'Word (unsigned short)'}
            dataType = 'uint16';
        case {'Word (unsigned long)'}
            dataType = 'uint32';
        case {'Byte (signed char)'}
            dataType ='int8';
        case {'Integer (short)'}
            dataType = 'int16';
        case {'Integer (long)'}
            dataType ='int32';
        case {'Real (float)'}
            dataType = 'single';
        case {'Real (double)','double',''}
            dataType = 'double';
        case {'State'}
            dataType = 'State';
        otherwise
            fprintf(1,'Warning: loading an improper Stateflow data type ''%s'' #%d. Reverting to double.',dataType,dataId);
            dataType = 'double';
    end
    sf('set',dataId,'data.dataType',dataType);
end

%--------------------------------------------------------------------------
function fix_output_event_triggers_pre_2p0(ids)
% change output rising/falling edge events into 'either edge' events
outputEventIds = sf('find',ids,'event.scope','OUTPUT_EVENT');
risingEventIds = sf('find',outputEventIds,'event.trigger','RISING_EDGE_EVENT');
if ~isempty(risingEventIds)
    sf('set',risingEventIds,'event.trigger','EITHER_EDGE_EVENT');
    disp('Warning: The following output rising-edge events have been converted to either-edge events:');
    for id = risingEventIds
        disp(['         ' sf('FullNameOf',id,'/')]);
    end
end
fallingEventIds = sf('find',outputEventIds,'event.trigger','FALLING_EDGE_EVENT');
if ~isempty(fallingEventIds)
    sf('set',fallingEventIds,'event.trigger','EITHER_EDGE_EVENT');
    disp('Warning: The following output falling-edge events have been converted to either-edge events:');
    for id = fallingEventIds
        disp(['         ' sf('FullNameOf',id,'/')]);
    end
end

%--------------------------------------------------------------------------
function fix_apply_to_all_libs_pre_2p0(ids)
sfunId = sf('find',ids,'target.name','sfun');
if ~isempty(sfunId)
    sf('set',sfunId,'.applyToAllLibs',1);
end

%--------------------------------------------------------------------------
function fix_coder_flags_format_pre_4p0(ids)
% parse codeFlags on all targets and reformat them
targets = sf('get',ids,'target.id');
simpleFlags = { 'debug';
    'telemetry';
    'preservenames';
    'preservenameswithparent';
    'exportcharts';
    'project';
    'multiinstanced'};

for target = targets(:)'
    oldFlags = sf('get',target,'target.codeFlags');
    newFlags = {};
    newValues = {};

    % handle the easy cases
    for i = 1:length(simpleFlags)
        flag = simpleFlags{i};
        % first check for the new style
        flagIsOne = ~isempty(regexp(oldFlags,['\s',flag,'=1'], 'once'));
        flagIsZero = ~isempty(regexp(oldFlags,['\s',flag,'=0'], 'once'));
        if(~flagIsOne && ~flagIsZero)
            % now check for the old style
            val = ~isempty(regexp(oldFlags, ['[+\-]' flag], 'once'));
        elseif flagIsOne
            val = 1;
        else
            val = 0;
        end
        newFlags{end+1} = flag; %#ok<*AGROW>
        newValues{end+1} = val;
    end

    % this flag got split into two
    val = ~isempty(regexp(oldFlags, '[+\-]bitsets', 'once'));
    newFlags{end+1} = 'statebitsets';
    newValues{end+1} = val;

    newFlags{end+1} = 'databitsets';
    newValues{end+1} = val;

    % fix the inverted polarity of these
    val = isempty(regexp(oldFlags, '[+\-]nocomments', 'once'));
    newFlags{end+1} = 'comments';
    newValues{end+1} = val;

    val = isempty(regexp(oldFlags, '[+\-]noecho', 'once'));
    newFlags{end+1} = 'echo';
    newValues{end+1} = val;

    val = isempty(regexp(oldFlags, '[+\-]noinitializer', 'once'));
    newFlags{end+1} = 'initializer';
    newValues{end+1} = val;

    % merge two switches that should be a single multi-valued switch
    % ioformat = 0  ==> use global io
    % ioformat = 1  ==> pack io into structures
    % ioformat = 2  ==> use individual arguments for io
    if ~isempty(regexp(oldFlags, '[+\-]globalio', 'once'))
        newFlags{end+1} = 'ioformat';
        newValues{end+1} = 0;
    elseif ~isempty(regexp(oldFlags, '[+\-]nopackio', 'once'))
        newFlags{end+1} = 'ioformat';
        newValues{end+1} = 2;
    else
        newFlags{end+1} = 'ioformat';
        newValues{end+1} = 1;
    end

    flagString = '';
    for i=1:length(newFlags)
        flagString = sprintf('%s %s=%d', flagString, newFlags{i}, newValues{1, i});
    end
    sf('set', target, 'target.codeFlags', flagString);
end

%--------------------------------------------------------------------------
function fix_truth_table_format_pre_5p0(ids,sfVersion)
% Convert truth table format
truthtables = sf('find',ids,'state.truthTable.isTruthTable',1);
if(sfVersion < 51013000.000002)
    for i = 1:length(truthtables)
        ttId = truthtables(i);

        predArray = sf('get', ttId, 'state.truthTable.predicateArray');
        if ~isempty(predArray)
            newPredArray = predArray(:,[1,3:end]);
            for r = 1:size(newPredArray, 1)-1
                if ~isempty(predArray{r,2})
                    newPredArray{r,2} = [predArray{r,2} ':' 10 newPredArray{r,2}];
                end
            end
            sf('set', ttId, 'state.truthTable.predicateArray', newPredArray);
        end

        actArray = sf('get', ttId, 'state.truthTable.actionArray');
        if ~isempty(actArray)
            newActArray = actArray(:,[1 3]);
            for r = 1:size(newActArray, 1)
                if ~isempty(actArray{r,2})
                    newActArray{r,2} = [actArray{r,2} ':' 10 newActArray{r,2}];
                end
            end
            sf('set', ttId, 'state.truthTable.actionArray', newActArray);
        end
    end
end
% set autogen field for objects in truthtable
for i = 1:length(truthtables)
    ttId = truthtables(i);
    ttData = sf('DataIn',ttId);
    ttData = sf('find',ttData,'data.scope','TEMPORARY_DATA');
    sf('set',ttData,'data.autogen.isAutoCreated',1);
end

%--------------------------------------------------------------------------
function fix_data_type_expression_pre_6p5(ids)
% Move data props type expression string to bus object string if the
% type method is "Bus Object". Applicable models created in R2006a.
for dataId = sf('find', ids, 'data.props.type.method', 'SF_SIMULINK_OBJECT_TYPE')
    busObj = sf('get', dataId, 'data.props.type.expression');
    sf('set', dataId, 'data.props.type.busObject', busObj);
end

%--------------------------------------------------------------------------
function fix_continuous_time_charts_pre_6p7(machineId)
% From Stateflow R2007b, continuous time Stateflow charts are treated as
% plant models.
allCharts = sf('get',machineId,'machine.charts');
chartsWithCt = sf('find', allCharts, 'chart.updateMethod', 2);
if ~isempty(chartsWithCt)
    warnMsg = sprintf(...
        ['The following chart(s) in the model ''%s'' have continuous\n', ...
        'update method:\n\n%s\n\n', ...
        'The behavior of continuous time Stateflow charts has changed\n', ...
        'significantly in R2007b. Please read the documentation for the\n', ...
        'changed behavior.'], ...
        sf('get', machineId, 'machine.name'), ...
        sf('get', chartsWithCt, 'chart.name'));
    disp(warnMsg);
    % warndlg(warnMsg, 'Warning: Stateflow Continuous Chart');
end

%--------------------------------------------------------------------------
function fix_orphan_subwires()
%
% g333803, Find and fix orphan subwires (can happen via an unknown model
% corruption).
%
orphanSubWires = sf('find','all','transition.type',1,'transition.subLink.parent',0, 'transition.src.intersection.space', 0);

% These orphans can be fixed simply by looking at them.
L = length(orphanSubWires);
for i=1:L
    subwire = orphanSubWires(i);
    parent = sf ('get', subwire, '.linkNode.parent');
    sf('RebuildHierarchy', parent);
end

if L > 0
    disp('Stateflow model corruption detected and fixed...please resave this model.');
end

%--------------------------------------------------------------------------
% From R2010b on, Stateflow and EML support arrays of buses. 
% In prior releases, chart inputs and outputs always were scalars,
% so the size field was ignored (it could have contained some valid size, e.g. [3 5]
% but the size won't be read).
% To avoid backward incompatibility, if an older model is loaded,
% for all chart inputs and outputs that have bus types, 'size' field must be 
% reset to "[1]'.
function fix_bus_data_size(ids)
for dataId = sf('find', ids, 'data.props.type.method', 'SF_SIMULINK_OBJECT_TYPE')
    sf('set', dataId, 'data.props.array.size', '1');
end

%--------------------------------------------------------------------------
function fix_eml_fimath_pre_7p1(ids)
% From R2008b all EML models have a new parameter 'fimathForFiConstructors' in the "Ports
% and Data Manager'. This value is set to 1 ('Same as FIMATH for fixed-point input signals')
% by default for models created in R2008b onwards. For older models (R2008a and earlier)
% this value is to be set to 0 ('MATLAB Factory Default')
emlIds = sf('find',ids,'state.eml.isEML',1);
emlIds = [emlIds sf('find',ids,'state.truthTable.isTruthTable',1,'state.truthTable.useEML',1)];
for idx = 1:length(emlIds)
    sf('set',emlIds(idx),'state.eml.fimathForFiConstructors',0);
end

%--------------------------------------------------------------------------
function fix_variable_sizing_pre_7p1(machineId)
% Variable sizing is introduced in R2009b. Older models by default open without variable sizing.
allCharts = sf('get',machineId,'machine.charts');
sf('set', allCharts, 'chart.supportVariableSizing', 0);

%--------------------------------------------------------------------------
function fix_eml_default_fimath_pre_7p1(ids)

% Starting in R2009b all EML models have a new parameter
% "EmlDefaultFimath" in the "Ports & Data Manager". This value is
% set to "Same As MATLAB" by default  or all modesl created in
% R2009b onwards. For older modesl (R2009a and earlier) this
% property did not exist. Instead there just the "InputFimath" (or
% fimathString" property that was set to the EML default fimath.
% So the code below does:
% 1) Sets the "EmlDefaultFimath" property to "SpecifyOther" (1)
% 2) Makes sure that the fimath string is correct.
emlIds = sf('find',ids,'state.eml.isEML',1);
emlIds = [emlIds sf('find',ids,'state.truthTable.isTruthTable',1,'state.truthTable.useEML',1)];
oldDefaultFimath = ['fimath(...' 10 ...
    '''RoundMode'', ''floor'',...' 10 ...
    '''OverflowMode'', ''wrap'',...' 10 ...
    '''ProductMode'', ''KeepLSB'', ''ProductWordLength'', 32,...' 10 ...
    '''SumMode'', ''KeepLSB'', ''SumWordLength'', 32,...' 10 ...
    '''CastBeforeSum'', true)'];
newDefaultFimath = ['fimath(...' 10 ...
    ')'];
for idx = 1:length(emlIds)
    sf('set',emlIds(idx),'state.eml.emlDefaultFimath',1);
    % If the fimathString is set to 'fimath' it means that the
    % model is using the factory setting for fimath and has not
    % been changed by the user. In that case set the
    % fimathString to the old (<=R2009a) factory setting.
    if strcmpi(sf('get',emlIds(idx),'state.eml.fimathString'),newDefaultFimath)
        sf('set',emlIds(idx),'state.eml.fimathString',oldDefaultFimath);
    end
end


%--------------------------------------------------------------------------
function postbind_fix_data_props_array_size_pre_6p0(machineId)
%%% VERY IMPORTANT: This needs to be done in postbind
%%% for the instance object to contain info on port handles
% Reconcile vector size string '1,10', '[10,1]' to '10' for pre R14 beta 1
% models
dataIds = sf('DataIn',machineId);
for dataId = dataIds(:)'
    dataSize = sf('get',dataId,'data.parsedInfo.array.size');
    if length(dataSize) == 2
        if dataSize(1) == 1 && dataSize(2) == 1
            sf('set',dataId,'data.props.array.size','');
        elseif dataSize(1) == 1
            sf('set',dataId,'data.props.array.size',int2str(dataSize(2)));
        elseif dataSize(2) == 1
            sf('set',dataId,'data.props.array.size',int2str(dataSize(1)));
        else
            % No need to reconcile
        end
    end
end

%--------------------------------------------------------------------------
function postbind_fix_eml_chart_prototype_pre_6p0(machineId)
% eML chart contains parameter data must force sync prototype
emlBlks = eml_blocks_in(machineId);
for i = 1:length(emlBlks)
    ioData = sf('DataOf', emlBlks(i));
    if ~isempty(sf('find', ioData, 'data.scope', 'PARAMETER_DATA'))
        % eML chart parameter data presents, force sync
        sf('EmlChartFixPrototype', emlBlks(i));
    end
end

%--------------------------------------------------------------------------
function postbind_fix_config_set_migration_pre_6p0(machineId)
% RTW target settings (non-library) now in configset
isLib = sf('get', machineId, 'machine.isLibrary');
modelName  = sf('get', machineId, 'machine.name');
allTargets = sf('TargetsOf', machineId);
rtwTargets = sf('find', allTargets, 'target.name', 'rtw');

if ~isempty(rtwTargets)
    % Get RTW settings from configset
    cs = getActiveConfigSet(modelName);
    % Check to see if configset available, libraries don't have one
    if ~isempty(cs) && ~isLib
        rtwSettings = cs.getComponent('any', 'Real-Time Workshop');
        for i = 1 : length(rtwTargets)
            rtwtarget = rtwTargets(i);
            settings = get_target_settings(rtwtarget, 'rtw', false);

            rtwSettings.CustomHeaderCode  = [rtwSettings.CustomHeaderCode  settings.customCode];
            rtwSettings.CustomInclude     = [rtwSettings.CustomInclude     settings.userIncludeDirs];
            rtwSettings.CustomLibrary     = [rtwSettings.CustomLibrary     settings.userLibraries];
            rtwSettings.CustomInitializer = [rtwSettings.CustomInitializer settings.customInitializer];
            rtwSettings.CustomTerminator  = [rtwSettings.CustomTerminator  settings.customTerminator];
            rtwSettings.CustomSource      = [rtwSettings.CustomSource      settings.userSources];
            append_cs_description(cs, settings.description, 'rtw');
        end
    end
end

%--------------------------------------------------------------------------
function postbind_turnoff_configset_customcode_parsing_pre_10b(machineId)
% Do not parse custom C code to help reporting unresolved chart symbols for
% model saved prior to 10b AND "lcc" is not the current mex compiler.

if sf('get', machineId, 'machine.isLibrary')
    return;
end

compilerInfo = compilerman('get_compiler_info');
if strcmp(compilerInfo.compilerName, 'lcc')
    return;
end

modelName  = sf('get', machineId, 'machine.name');
cs = getActiveConfigSet(modelName);

% Do not change param value via Simulink.ConfigSetRef
if isa(cs, 'Simulink.ConfigSet')
    set_param(cs, 'SimParseCustomCode', 'off');
end

%--------------------------------------------------------------------------
function postbind_fix_config_set_migration_pre_7p1(machineId,isLib)

% sfun and rtw target settings (both non-library models and library models) now in ConfigSet
modelName  = sf('get', machineId, 'machine.name');
allTargets = sf('TargetsOf', machineId);
cs         = getActiveConfigSet(modelName);
sfuntarget = sf('find', allTargets, 'target.name', 'sfun');

if ~isempty(cs)
    % If cs is Simulink.ConfigSetRef, cs.getComponent will return empty
    if isa(cs, 'Simulink.ConfigSetRef')
        if ~isempty(cs.WSVarName) && evalin('base',['exist(''' cs.WSVarName ''',''var'');'])  && ...
                evalin('base',['isa(' cs.WSVarName ',''Simulink.ConfigSet'');'])

            % Check consistency between ConfigSetRef object with sfun target settings
            csref        = evalin('base',cs.WSVarName);
            sfunSettings = csref.getComponent('any', 'Simulation Target');
            if (~isempty(sfuntarget)) && ~isempty(sfunSettings)
                settings   = get_target_settings(sfuntarget, 'sfun', isLib);
                consistent = false;

                if strcmp(sfunSettings.SimCustomHeaderCode,  settings.customCode)        && ...
                        strcmp(sfunSettings.SimUserIncludeDirs,   settings.userIncludeDirs)   && ...
                        strcmp(sfunSettings.SimUserLibraries,     settings.userLibraries)     && ...
                        strcmp(sfunSettings.SimCustomInitializer, settings.customInitializer) && ...
                        strcmp(sfunSettings.SimCustomTerminator,  settings.customTerminator)  && ...
                        strcmp(sfunSettings.SimUserSources,       settings.userSources)       && ...
                        strcmp(sfunSettings.SimCustomSourceCode,  '')

                    if isLib
                        consistent = strcmp(sfunSettings.SimUseLocalCustomCode, settings.useLocalCmCdSettings);
                    else
                        consistent = strcmp(sfunSettings.SimReservedNames,      settings.reservedNames) && ...
                            strcmp(sfunSettings.SFSimOverflowDetection,settings.overflow) && ...
                            strcmp(sfunSettings.SFSimEnableDebug,      settings.debug) && ...
                            strcmp(sfunSettings.SFSimEcho,             settings.echo);
                    end
                end

                if ~consistent
                    DAStudio.warning('Simulink:tools:ConflictConfigSetRefStateflowTargets', modelName, cs.WSVarName);

                    csnew = copy(csref);
                    csnew.set_param('SimCustomHeaderCode',  settings.customCode);
                    csnew.set_param('SimUserIncludeDirs',   settings.userIncludeDirs);
                    csnew.set_param('SimUserLibraries',     settings.userLibraries);
                    csnew.set_param('SimCustomInitializer', settings.customInitializer);
                    csnew.set_param('SimCustomTerminator',  settings.customTerminator);
                    csnew.set_param('SimUserSources',       settings.userSources);
                    append_cs_description(csnew, settings.description, 'sfun');
                    if isLib
                        csnew.set_param('SimUseLocalCustomCode', settings.useLocalCmCdSettings);
                    else
                        csnew.set_param('SimReservedNameArray', slprivate('cs_reserved_names_to_array', settings.reservedNames));
                        csnew.set_param('SFSimOverflowDetection',settings.overflow);
                        csnew.set_param('SFSimEnableDebug',      settings.debug);
                        csnew.set_param('SFSimEcho',             settings.echo);
                    end

                    attachConfigSet(modelName, csnew, true); % Model is dirty now
                    setActiveConfigSet(modelName, csnew.Name);
                end
            else
                disp('Internal error: Can not find Stateflow sfun target/ConfigSet Simulation Target');
            end
        else
            DAStudio.warning('Simulink:tools:PotentialConflictConfigSetRefStateflowTargets', ...
                cs.WSVarname, modelName, cs.WSVarname);
        end
    else

        sfunSettings = cs.getComponent('any', 'Simulation Target');
        if (~isempty(sfuntarget)) && (~isempty(sfunSettings))
            settings = get_target_settings(sfuntarget, 'sfun', isLib);

            sfunSettings.SimCustomHeaderCode  = [sfunSettings.SimCustomHeaderCode  settings.customCode];
            sfunSettings.SimUserIncludeDirs   = [sfunSettings.SimUserIncludeDirs   settings.userIncludeDirs];
            sfunSettings.SimUserLibraries     = [sfunSettings.SimUserLibraries     settings.userLibraries];
            sfunSettings.SimCustomInitializer = [sfunSettings.SimCustomInitializer settings.customInitializer];
            sfunSettings.SimCustomTerminator  = [sfunSettings.SimCustomTerminator  settings.customTerminator];
            sfunSettings.SimUserSources       = [sfunSettings.SimUserSources       settings.userSources];
            append_cs_description(cs, settings.description, 'sfun');

            if isLib
                sfunSettings.SimUseLocalCustomCode = settings.useLocalCmCdSettings;
            else
                sfunSettings.SimReservedNameArray = slprivate('cs_reserved_names_to_array',[sfunSettings.SimReservedNames settings.reservedNames]);
                sfunSettings.SFSimOverflowDetection = settings.overflow;
                sfunSettings.SFSimEnableDebug       = settings.debug;
                sfunSettings.SFSimEcho              = settings.echo;
            end
        end
    end

    rtwtarget   = sf('find', allTargets, 'target.name', 'rtw');
    rtwSettings = cs.getComponent('any', 'Real-Time Workshop');
    if (~isempty(rtwtarget)) && isLib && (~isempty(rtwSettings))
        settings = get_target_settings(rtwtarget, 'rtw', isLib);

        if isLib
            rtwSettings.CustomHeaderCode     = [rtwSettings.CustomHeaderCode  settings.customCode];
            rtwSettings.CustomInclude        = [rtwSettings.CustomInclude     settings.userIncludeDirs];
            rtwSettings.CustomLibrary        = [rtwSettings.CustomLibrary     settings.userLibraries];
            rtwSettings.CustomInitializer    = [rtwSettings.CustomInitializer settings.customInitializer];
            rtwSettings.CustomTerminator     = [rtwSettings.CustomTerminator  settings.customTerminator];
            rtwSettings.CustomSource         = [rtwSettings.CustomSource      settings.userSources];
            rtwSettings.RTWUseLocalCustomCode = settings.useLocalCmCdSettings;
            append_cs_description(cs, settings.description, 'rtw');
        end
        rtwSettings.RTWUseSimCustomCode = 'off';
    end
end % if configset exists

%--------------------------------------------------------------------------
function postbind_fix_chart_atomic_property_all(machineId)

charts = sf('get',machineId,'machine.charts');
instances = sf('get',charts,'chart.instance');
blockHandles = sf('get',instances,'instance.simulinkBlock');

for i=1:length(blockHandles)
   chart = charts(i);
   inputEvents = sf('find',sf('EventsOf',chart),'event.scope','INPUT_EVENT');
   if(strcmp(get_param(blockHandles(i),'TreatAsAtomicUnit'),'off'))
       if(isempty(inputEvents))
           safe_set_param(blockHandles(i),'RTWSystemCode','Auto');
       end
       safe_set_param(blockHandles(i),'TreatAsAtomicUnit','on'); 
   end
end
