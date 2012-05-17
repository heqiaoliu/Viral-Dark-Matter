
%   Copyright 2008-2009 The MathWorks, Inc.

classdef BlockSimState < Stateflow.SimState.SimStateContainer

    properties (SetAccess = private, Hidden)
        SimStateInfo = [];
        RootSystem = '';
        DataHandles = [];
        NodeHandles = [];
    end

    methods (Access = private, Static, Hidden)
        
        function result = objIsChart(h)
            result = ~isempty(sf('get', h.Id, 'chart.isa'));
        end
        
        function result = objIsContainer(h)
            result = Stateflow.SimState.BlockSimState.objIsChart(h) || ...
                     ~isempty(sf('get', h.Id, 'state.isa'));
        end
        
        function result = objIsState(h)
            result = h.isa('Stateflow.State') || h.isa('Stateflow.AtomicSubchart');
        end
        
        function result = objIsStateLike(h)
            result = Stateflow.SimState.BlockSimState.objIsState(h) || ...
                     Stateflow.SimState.BlockSimState.objIsChart(h);
        end
        
        function path = getObjPath(h)
            if ~Stateflow.SimState.BlockSimState.objIsContainer(h)
                h = h.up;
            end
            
            path = [];
            while ~Stateflow.SimState.BlockSimState.objIsChart(h)
                path = [h path]; %#ok<AGROW>
                h = h.up;
            end
        end
        
        function p = getSimSateDataProps(type, hSrc, name, chartPath)
            import Stateflow.SimState.SimStateData
            
            p.Name = name;
            p.Description = '';
            p.Range.Minimum = [];
            p.Range.Maximum = [];
            p.InitialValue = [];
            p.Type = '';
            p.Size = '';
            
            chartSLHandle = get_param(chartPath, 'Handle');

            switch type
                case SimStateData.SFSS_CHART_OUTPUT
                    p.Name = hSrc.Name;
                    p.Description = 'Block output data';
                    dpi = sf('DataParsedInfo', hSrc.Id, chartSLHandle);
                    % G622430. Data parsed info may not be available in the
                    % case of of model reference when top and sub models
                    % all refer to the same library chart.
                    if ~isempty(dpi)
                        p.Range.Minimum = dpi.range.minimum;
                        p.Range.Maximum = dpi.range.maximum;
                        p.InitialValue = dpi.initialval;
                        p.Type = dpi.compiled.type;
                        p.Size = dpi.compiled.size;
                    end
                case SimStateData.SFSS_STATE_OUTPUT_DATA
                    p.Name = hSrc.Name;
                    p.Description = 'State output data';
                    dpi = sf('DataParsedInfo', hSrc.Id, chartSLHandle);
                    if ~isempty(dpi)
                        p.Type = dpi.compiled.type;
                        p.Size = dpi.compiled.size;
                    end
                case {SimStateData.SFSS_CHART_LOCAL, SimStateData.SFSS_CT_DATA}
                    p.Name = hSrc.Name;
                    p.Description = 'Local scope data';
                    dpi = sf('DataParsedInfo', hSrc.Id, chartSLHandle);
                    if ~isempty(dpi)
                        p.Range.Minimum = dpi.range.minimum;
                        p.Range.Maximum = dpi.range.maximum;
                        p.InitialValue = dpi.initialval;
                        p.Type = dpi.compiled.type;
                        p.Size = dpi.compiled.size;
                    end
                case SimStateData.SFSS_EML_PERSISTENT
                    p.Description = 'Embedded MATLAB function persistent data';
                case SimStateData.SFSS_STATE_IS_ACTIVE
                    p.Name = '$isActive';
                    p.Description = 'Is state active';
                case SimStateData.SFSS_STATE_ACTIVE_CHILD
                    p.Name = '$activeChild';
                    p.Description = 'Active child of state';
                case SimStateData.SFSS_STATE_PREV_ACTIVE_CHILD
                    p.Name = '$prevActiveChild';
                    p.Description = 'Previously active child for state with history junction';
                case SimStateData.SFSS_TEMPORAL_COUNTER
                    p.Name = ['$' p.Name];
                    p.Description = 'Temporal counter';
                case SimStateData.SFSS_CHANGE_DETECTION_START_BUFFER
                    p.Name = ['$' p.Name];
                    p.Description = 'Change detection start buffer';
                case SimStateData.SFSS_PREVIOUS_COUNT
                    p.Name = '$prevTick';
                    p.Description = 'Absolute time temporal logic var';
                case SimStateData.SFSS_OUTPUT_EVENT_COUNTER
                    p.Name = ['$' p.Name];
                    p.Description = 'Output event counter';
                case SimStateData.SFSS_OUTPUT_EVENT_DATA
                    p.Name = ['$' p.Name];
                    p.Description = 'Block output event data';
                case SimStateData.SFSS_SUBCHART_SIMSTATE_INFO
                    p.Name = ['$' p.Name];
                    p.Description = 'Atomic subchart simulation data';
                otherwise
                    error('Stateflow:UnexpectedError', 'Invalid sime state data type.');
            end
            
            if strcmp(p.Size, '1')
                p.Size = '[1, 1]';
            end
        end

        function [info, hParent] = computeSimStateDataInfo(chartPath, rawCtx, ctxInfo)
            numData = length(rawCtx);
            aCellArr = cell(1, numData);

            hParent = aCellArr;
            dSource = aCellArr;
            dType = aCellArr;
            dIndex = aCellArr;
            dValue = aCellArr;
            dName = aCellArr;
            dDesc = aCellArr;
            dRange = aCellArr;
            dInitVal = aCellArr;
            dAuxInfo = aCellArr;
            dDataType = aCellArr;
            dSize = aCellArr;
            
            for i = 1 : numData
                thisData = ctxInfo.varInfo(i);
                hSrc = Stateflow.SimState.SimStateObject.getHandleBySource(chartPath, thisData.srcId);
                p = Stateflow.SimState.BlockSimState.getSimSateDataProps(thisData.type, hSrc, thisData.name, chartPath);
                
                hParent{i} = hSrc;
                if ~Stateflow.SimState.BlockSimState.objIsContainer(hSrc)
                    hParent{i} = hSrc.up;
                end
                
                dSource{i} = thisData.srcId;
                dType{i} =  thisData.type;
                dIndex{i} = i;
                dValue{i} = rawCtx{i};
                dName{i} = p.Name;
                dDesc{i} = p.Description;
                dRange{i} = p.Range;
                dInitVal{i} = p.InitialValue;
                dAuxInfo{i} = thisData.auxInfo;
                dDataType{i} = p.Type;
                dSize{i} = p.Size;
                
                if isempty(p.Type)
                    dDataType{i} = class(dValue{i});
                end
                if isempty(p.Size)
                    dSize{i} = sprintf('%dx', size(dValue{i}));
                    dSize{i}(end) = '';
                end
            end
            
            c = [dSource; dType; dIndex; dValue; dName; dDesc; dRange; dInitVal; dAuxInfo; dDataType; dSize];
            f = {'source', 'type', 'index', 'value', 'name', 'desc', 'range', 'initval', 'auxinfo', 'dtype', 'size'};
            info = cell2struct(c, f, 1);
        end
        
        function p = getSimStateContainerProps(h)
            import Stateflow.SimState.SimStateContainer
            
            p.Name = h.Name;
            p.Type = SimStateContainer.SFSS_UNKNOWN_CONTAINER;
            p.Decomp = SimStateContainer.SFSS_DECOMP_UNKNOWN;
            p.Source = 0;
            
            switch h.class
                case {'Stateflow.Chart', 'Stateflow.EMChart', 'Stateflow.TruthTableChart'}
                    p.Type = SimStateContainer.SFSS_CHART;
                case {'Stateflow.State', 'Stateflow.AtomicSubchart'}
                    switch h.Type
                        case 'OR'
                            p.Type = SimStateContainer.SFSS_OR_STATE;
                        case 'AND'
                            p.Type = SimStateContainer.SFSS_AND_STATE;
                        otherwise
                            error('Stateflow:UnexpectedError', 'Unexpected state type.');
                    end
                case 'Stateflow.Box'
                    p.Type = SimStateContainer.SFSS_BOX;
                case {'Stateflow.Function', 'Stateflow.EMFunction', 'Stateflow.SLFunction', 'Stateflow.TruthTable'}
                    p.Type = SimStateContainer.SFSS_FUNCTION;
                otherwise
                    error('Stateflow:UnexpectedError', 'Unexpected container type.');
            end
            
            dh = h;
            if h.isa('Stateflow.AtomicSubchart')
                dh = h.Subchart;
            end
            if dh.isa('Stateflow.Chart') || h.isa('Stateflow.State')
                switch dh.Decomposition
                    case 'PARALLEL_AND'
                        p.Decomp = SimStateContainer.SFSS_DECOMP_PARALLEL_AND;
                    case 'EXCLUSIVE_OR'
                        p.Decomp = SimStateContainer.SFSS_DECOMP_EXCLUSIVE_OR;
                    otherwise
                        error('Stateflow:UnexpectedError', 'Unexpected state decomposition.');
                end
            end
            
            if p.Type ~= SimStateContainer.SFSS_CHART
                p.Source = sf('get', h.Id, 'state.ssIdNumber');
            end
        end

        function info = computeSimStateHierInfo(chartPath, dataInfo, hDataParent)
            hChart = Stateflow.SimState.SimStateObject.getHandleBySource(chartPath, 0);
            if hChart.isa('Stateflow.Chart')
                % Containers are Chart, States, Boxes, Functions
                containers = sf('get', hChart.Id, 'chart.states');
                containers = sf('find', containers, 'state.isNoteBox', 0); % Get rid of annotations
                
                % Sort containers by name, so that they are sorted when added to a parent
                numContainers = length(containers);
                names = cell(1, numContainers);
                for i = 1 : numContainers
                    names{i} = sf('get', containers(i), 'state.name');
                end
                [~, index] =  sort(names);
                containers = containers(index);
                
                containers = [hChart.Id containers];
            else
                containers = hChart.Id; % EML block, Truth Table block
            end
            numContainers = length(containers);
            sortedStates = [hChart.Id sf('SubstatesIn', hChart.Id)]; % Including chart itself
            aCellArr = cell(1, numContainers);
            
            cName = aCellArr;
            cType = aCellArr;
            cSource = aCellArr;
            cDecomp = aCellArr;
            cIdxSiblns = aCellArr;
            cSubstates = aCellArr;
            cChildren = aCellArr;
            cData = aCellArr;
            cTemporalCounters = aCellArr;
            cStateOutputData = aCellArr;
            cIdxStates = aCellArr;
            
            for i = 1 : numContainers
                objId = containers(i);
                h = idToHandle(sfroot, objId);
                p = Stateflow.SimState.BlockSimState.getSimStateContainerProps(h);
                
                cName{i} = p.Name;
                cType{i} = p.Type;
                cSource{i} = p.Source;
                cDecomp{i} = p.Decomp;
                
                if h.up.isa('Stateflow.Object')
                    pIdx = find(containers == h.up.Id);
                    if ~isscalar(pIdx)
                        error('Stateflow:UnexpectedError', 'Failed to find state parent.');
                    end
                    cChildren{pIdx}(end + 1) = i;
                end
                
                if Stateflow.SimState.BlockSimState.objIsStateLike(h)
                    sIdx = find(sortedStates == h.Id);
                    if ~isscalar(sIdx)
                        error('Stateflow:UnexpectedError', 'Failed to find state in chart states list.');
                    end
                    cIdxStates{i} = sIdx;
                    
                    sortedSubstates = sf('SubstatesOf', objId);
                    for j = 1 : length(sortedSubstates)
                        ssIdx = find(containers == sortedSubstates(j));
                        if ~isscalar(ssIdx)
                            error('Stateflow:UnexpectedError', 'Failed to find substate.');
                        end
                        cSubstates{i}(end + 1) = ssIdx;
                        if ~isempty(cIdxSiblns{ssIdx})
                            error('Stateflow:UnexpectedError', 'Substate claimed by multiple parents.');
                        end
                        cIdxSiblns{ssIdx} = j;
                    end
                end
            end
            
            for i = 1 : length(dataInfo)
                thisData = dataInfo(i);
                
                cIdx = find(containers == hDataParent{i}.Id);
                if ~isscalar(cIdx)
                    error('Stateflow:UnexpectedError', 'Failed to find data parent.');
                end
                cData{cIdx}(end + 1) = i;
                
                if thisData.type == Stateflow.SimState.SimStateData.SFSS_STATE_OUTPUT_DATA
                    hData = Stateflow.SimState.SimStateObject.getHandleBySource(chartPath, thisData.source);
                    sIdx = find(containers == hData.OutputState.Id);
                    if ~isscalar(sIdx) || ~isempty(cStateOutputData{sIdx})
                        error('Stateflow:UnexpectedError', 'Failed to find state for state output data.');
                    end
                    cStateOutputData{sIdx} = i;
                end
                
                if thisData.type == Stateflow.SimState.SimStateData.SFSS_TEMPORAL_COUNTER
                    for j = 1 : length(thisData.auxinfo.os)
                        hState = Stateflow.SimState.SimStateObject.getHandleBySource(chartPath, thisData.auxinfo.os(j));
                        sIdx = find(containers == hState.Id);
                        if ~isscalar(sIdx) || ~Stateflow.SimState.BlockSimState.objIsState(hState)
                            error('Stateflow:UnexpectedError', 'Failed to find owner state for temporal counter.');
                        end
                        cTemporalCounters{sIdx}(end + 1) = i;
                    end
                end
            end
            
            c = [cName; cType; cSource; cDecomp; cIdxSiblns; cSubstates; cChildren; cData; cStateOutputData; cTemporalCounters; cIdxStates];
            f = {'name', 'type', 'source', 'decomp', 'idxsiblns', 'substates', 'children', 'data', 'outdata', 'tc', 'idxstate'};
            info = cell2struct(c, f, 1);
        end
               
    end
    
    methods (Static, Hidden)

        function info = computeSimStateInfo(chartPath, rawCtx, ctxInfo)
            % Chart SimStateInfo is a structure cotains all state data values, 
            % and necessary data infos and chart state hierarchical infos.
            % This is the chart simctx saved with model sim state.

            % This method requires model being open
            hChart = Stateflow.SimState.SimStateObject.getHandleBySource(chartPath, 0);
            info.versions.version = 1.0;
            info.versions.sfVersion = sf('Version', 1);
            info.versions.tmwVersion = version;
            info.isStateflow = true; % IMPORTANT: This is a flag for SL MCOS ModelSimState class to identify Stateflow block sim state.
            info.chartPath = chartPath;
            info.chartType = hChart.class;
            info.chartIsPlantModel = sf('IsChartPlantModel', hChart.Id);
            info.rootSystem = bdroot(chartPath);
            info.checksum = ctxInfo.chartChecksum;
            [info.dataInfo, hDataParent] = Stateflow.SimState.BlockSimState.computeSimStateDataInfo(chartPath, rawCtx, ctxInfo);
            info.hierInfo = Stateflow.SimState.BlockSimState.computeSimStateHierInfo(chartPath, info.dataInfo, hDataParent);
            info.baseStateCfg = ones(1, length([info.hierInfo.idxstate])) .* -1; % "-1", uninitialized base config
        end
        
        function rawCtx = getRawCtxFromSimStateInfo(simStateInfo, ctxInfo)
            if isequal(ctxInfo.chartChecksum, simStateInfo.checksum)
                % If checksum matches, data indexes are still valid.
                rawCtx = {simStateInfo.dataInfo.value}';
                % Append base state configuration.
                rawCtx{end + 1} = simStateInfo.baseStateCfg;
            else
                % Partial load is not supported for now.
                error('Stateflow:SimStateError', 'Chart checksum doesn''t match that in saved state data.');
            end
        end
        
        function hCtx = constructHierarchicalContext(simStateInfo)
            % Create all data objects
            numData = length(simStateInfo.dataInfo);
            hData = cell(numData, 1);
            for i = 1 : numData
                dInfo = simStateInfo.dataInfo(i);
                hData{i} = Stateflow.SimState.SimStateData(dInfo.name, dInfo.type, dInfo.source, dInfo.index, dInfo.value, dInfo.desc, dInfo.range, dInfo.initval, dInfo.dtype, dInfo.size, dInfo.auxinfo);
            end
            
            % Create all container objects
            numNodes = length(simStateInfo.hierInfo);
            hNodes = cell(numNodes, 1);
            for i = 1 : numNodes
                cInfo = simStateInfo.hierInfo(i);
                switch cInfo.type
                    case Stateflow.SimState.SimStateContainer.SFSS_CHART
                        hNodes{i} = Stateflow.SimState.BlockSimState(cInfo.name, simStateInfo.chartPath, cInfo.decomp, simStateInfo);
                    otherwise
                        hNodes{i} = Stateflow.SimState.SimStateContainer(cInfo.name, cInfo.type, cInfo.source, cInfo.decomp, cInfo.idxsiblns);
                end
            end
            
            % Connect all objects to a tree using hier info
            root = hNodes{1}; % The first hier node is always chart
            root.DataHandles = hData;
            root.NodeHandles = hNodes;
            for i = 1 : numNodes
                hN = hNodes{i};
                hN.Root = root;
                cInfo = simStateInfo.hierInfo(i);
                
                for j = 1 : length(cInfo.data)
                    hD = hData{cInfo.data(j)};
                    hD.Root = root;                    
                    hN.appendData(hD);
                end
                
                for j = 1 : length(cInfo.children)
                    hCN = hNodes{cInfo.children(j)};
                    hN.appendChild(hCN);
                end
                
                for j = 1 : length(cInfo.substates)
                    hSS = hNodes{cInfo.substates(j)};
                    hN.appendSubstate(hSS);
                end
                
                for j = 1 : length(cInfo.tc)
                    hTC = hData{cInfo.tc(j)};
                    hN.appendTemporalCounter(hTC);
                end
                
                if ~isempty(cInfo.outdata)
                    hOD = hData{cInfo.outdata};
                    hN.attachStateOutputData(hOD);
                end
            end
            
            for i = 1 : numNodes
                hN = hNodes{i};
                if hN.isAtomicSubchart
                    hN.adoptSubchart;
                end
            end
            
            % Initialize base state configuration
            if simStateInfo.baseStateCfg(1) < 0 % Uninitialized
                for i = 1 : numNodes
                    sIdx = simStateInfo.hierInfo(i).idxstate;
                    if ~isempty(sIdx) % A state or chart
                        simStateInfo.baseStateCfg(sIdx) = double(hNodes{i}.isActive);
                    end
                end
                root.SimStateInfo.baseStateCfg = simStateInfo.baseStateCfg;
            end
            
            % Return the tree context root
            hCtx =  root;
        end
        
    end
        
    methods
        
        function obj = BlockSimState(name, path, decomp, info)
            obj = obj@Stateflow.SimState.SimStateContainer(name, Stateflow.SimState.SimStateContainer.SFSS_CHART, path, decomp, []);
            obj.RootSystem = info.rootSystem;
            obj.SimStateInfo = info;
        end

        function objClone = clone(obj)
            objClone = Stateflow.SimState.BlockSimState.constructHierarchicalContext(obj.getSimStateInfo);
        end
        
        function highlightActiveStates(obj)
            obj.openRootSystem;
            actStates = obj.getActiveStates;
            numActStates = length(actStates);
            ids = zeros(1, numActStates);
            for i = 1 : numActStates
                ids(i) = actStates(i).getSourceHandle.Id;
            end
            chart = obj.getSourceHandle.Id;
            sf('Open', chart);
            sf('Highlight', chart, ids);
        end
        
        function removeHighlighting(obj)
            if obj.isRootSystemOpen
                chart = obj.getSourceHandle.Id;
                sf('Highlight', chart, []);
            end
        end
        
        function [result, messages] = checkStateConsistency(obj, verbose)
            result = true;
            messages = {};
            
            if nargin < 2
                verbose = true;
            end
            
            for i = 1 : length(obj.NodeHandles)
                thisObj = obj.NodeHandles{i};
                if thisObj.isStateLike
                    [consist, ~, msg] = thisObj.isStateConsistentInternal;
                    if ~consist
                        result = false;
                        messages{end + 1} = msg; %#ok<AGROW>
                    end
                end
            end
            
            if verbose
                if result
                    fprintf(1, 'States are consistent!\n');
                else
                    fprintf(1, 'The following state inconsistencies are found ...\n');
                    for i = 1 : length(messages)
                        fprintf(1, '%d. %s\n', i, messages{i});
                    end
                end
            end
        end
        
        function result = isStateConsistent(obj)
            result = obj.checkStateConsistency(false);
        end

    end

    methods (Hidden)
        
        function highlightActiveStatesPassive(obj)
            if obj.isRootSystemOpen
                chart = obj.getSourceHandle;
                currHighlites = sf('get', chart.Id, 'chart.highlightList');
                if chart.Visible && ~isempty(currHighlites)
                    actStates = obj.getActiveStates;
                    numActStates = length(actStates);
                    ids = zeros(1, numActStates);
                    for i = 1 : numActStates
                        ids(i) = actStates(i).getSourceHandle.Id;
                    end
                    %sf('Open', chart.Id);
                    sf('Highlight', chart.Id, ids);
                end
            end
        end

        function actStates = getActiveStates(obj)
            actStates = [];
            if obj.isActive
                for i = 2 : length(obj.NodeHandles)
                    hN = obj.NodeHandles{i};
                    if hN.isActive
                        actStates = [actStates hN]; %#ok<AGROW>
                        if hN.isAtomicSubchart
                            substates = hN.getActiveSubchartStates;
                            actStates = [actStates substates]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
        
        function info = getSimStateInfo(obj)
            % Update values store in simStateInfo
            for i = 1 : length(obj.NodeHandles)
                hN = obj.NodeHandles{i};
                if hN.isAtomicSubchart
                    hN.refreshSubchartInfo;
                end
            end
            
            for i = 1 : length(obj.SimStateInfo.dataInfo)
                obj.SimStateInfo.dataInfo(i).value = obj.DataHandles{i}.Value;
            end
            info = obj.SimStateInfo;
        end
        
    end
    
end
