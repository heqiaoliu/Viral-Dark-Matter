classdef SimulinkMan < handle
    % For Mathworks internal use only.
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    
    properties
        stateId = 0;
        chartId = 0;
        chartBlockH = 0;
        instanceId = 0;
        sfunH = 0;
        demuxH = 0;
        terminatorH = 0;
        subsysH = 0;
    end
    
    methods
        % Publicly visible instance methods.
        
        function self = SimulinkMan(stateId)
            % Initializes necessary info
            
            self.stateId = stateId;
            self.chartId = sf('get', stateId, '.chart');
            
            if self.chartId == 0
                % Sometimes a state which is on the Stateflow 'cut' buffer
                % is also "initialized". In this case, we want to figure
                % out the chart-ID using the Simulink way because the
                % DB_state is already disconnected from the DB_chart.
                self.subsysH = sf('get', self.stateId, '.simulink.blockHandle');
                parentH = get_param(self.subsysH, 'Parent');
                self.chartId = sfprivate('block2chart', parentH);
            end
            
            self.instanceId = sf('get', self.chartId, '.instances');
            self.chartBlockH = sf('get', self.instanceId, '.simulinkBlock');
            self.sfunH = sf('get', self.instanceId, '.sfunctionBlock');
            self.demuxH = sf('get', self.instanceId, '.demuxBlock');
            self.terminatorH = sf('get', self.instanceId, '.terminatorBlock');
            
            blockName = sf('get', self.stateId, '.simulink.blockName');
            if isempty(blockName)
                machineId = sf('get', self.chartId, '.machine');
                sfVersion = sf('get',machineId,'.sfVersion');
                if sfVersion < 71014000.000008
                    % Migration path for 8b models which used to bind from
                    % a Simulink subsystem to the corresponding Stateflow
                    % object using persistent UserData stored on the
                    % Simulink subsystem.
                    %
                    % Unfortunately, this cannot be done cleanly in
                    % grandfather.m because we get here before the
                    % 'postbind' phase which is the only time we can
                    % actually do the migration.
                    ssId = sf('get', self.stateId, '.ssIdNumber');
                    self.subsysH = Stateflow.SLUtils.findSystem(self.chartBlockH, 'UserData', ssId);
                    if ishandle(self.subsysH)
                        set_param(self.subsysH, 'UserDataPersistent', 'off');
                    end
                else
                    self.subsysH = [];
                end
            else
                self.subsysH = Stateflow.SLUtils.findSystem(self.chartBlockH, 'Name', blockName);
            end
            
        end
        
        function copyToClipboard(self, doUnifiedCopy)
            % Called when a simulink function call subsystem is copied over
            % to the clipboard.
            
            if ~ishandle(self.subsysH)
                return
            end
            
            % Unlock if necessary... g474803
            modelH = bdroot(self.subsysH);
            prevLock = Stateflow.SLUtils.unlockModel(modelH);
            prevDirty = get_param(modelH, 'dirty');
            restoreDirty = onCleanup(@() set_param(modelH, 'dirty', prevDirty, 'lock', prevLock));
            
            % First make a copy of this block under the mask. The name is
            % not really important because we are immediately going to move
            % the block to the simulink scratch pad.
            scratchH = Stateflow.SLUtils.addBlock(self.chartBlockH, 'built-in/Subsystem', ' ScratchPad ', 'MakeNameUnique', 'on');
            
            try
                stateName = sf('get', self.stateId, '.name');
                if isempty(stateName)
                    stateName = '?';
                end
                h = Stateflow.SLUtils.addBlock(scratchH, self.subsysH, stateName, 'MakeNameUnique', 'on');
            catch ME
                delete_block(scratchH);
                if strcmpi(ME.identifier, 'Simulink:Commands:AddBlockUnsavedLibrary')
                    DAStudio.warning('Stateflow:slinsf:UnsavedLibraryCopy');
                    % The clipboard is all screwed up now and paste will
                    % fail horribly if we do not do this. g473781
                    sf('FlushClipboard');
                    return;
                end
                rethrow(ME);
            end
            
            sf('set', self.stateId, '.simulink.blockHandle', h);
            sf('set', self.stateId, '.simulink.blockName', 'invalid/name');
            
            % move to simulink_DELETE graph.
            if doUnifiedCopy
                self.doAdditionalCopyOperations(h);
            end
            Stateflow.SLUtils.deleteToClipboard(h);
            delete_block(scratchH);
        end
        
        function destroySubsystem(self, numInputs, numOutputs)
            % This function is called when a Simulink function is deleted.
            %
            % Note that rather than calling the delete_block method, we
            % call an internal method which moves the block to the
            % SIMULINK_delete graph. This means that the handle is still
            % valid and can be used in the add_block method if we want to
            % copy from it.
            
            % Make sure that the Model explorer is not showing any "stale"
            % dialogs by explicitly broadcasting this event. Normally
            % Simulink would have broadcasted this event but since the
            % subsystem corresponding to the chart is not actually present
            % in the ME, this event has to be thrown by us. g474773,
            % g473996
            ed = DAStudio.EventDispatcher;
            subsysUddH = get_param(self.subsysH, 'Object');
            parentUddH = subsysUddH.getParent;
            ed.broadcastEvent('ChildRemovedEvent', parentUddH, subsysUddH);
            
            if ishandle(self.subsysH)
                Stateflow.SLUtils.deleteAllLines(self.subsysH);
                Stateflow.SLUtils.deleteToClipboard(self.subsysH);
                
                % g522557: When a SL function is cut/deleted, make sure
                % that its name is invalidated otherwise when we press undo
                % and try to resurrect the state, we might mistakenly bind
                % it an existing subsystem.
                sf('set', self.stateId, '.simulink.blockName', 'invalid/name');
            end
            sf('Instance', 'adjust_sfunction_block', self.instanceId, -numOutputs, -numInputs);
            self.adjustInstanceConnectionsAfterRemoval;
        end
        
    end
    
    methods(Static)
        % Publicly visible static methods.
        
        function redoInnerLayout(chartBlockH)
            % Adjusts the positions of the blocks under the mask.
            
            demuxH = Stateflow.SLUtils.findSystem(chartBlockH, 'BlockType', 'Demux'); %#ok<PROP>
            sfunH = Stateflow.SLUtils.findSystem(chartBlockH, 'BlockType', 'S-Function'); %#ok<PROP>
            demuxPos = get_param(demuxH, 'Position'); %#ok<PROP>
            sfunPos = get_param(sfunH, 'Position'); %#ok<PROP>
            
            x = sfunPos(1);
            w = sfunPos(3) - sfunPos(1);
            
            y = demuxPos(4) + 30;
            subsysHandles = Stateflow.SLUtils.findSystem(chartBlockH, 'BlockType', 'SubSystem');
            for i=1:length(subsysHandles)
                portHandles = get_param(subsysHandles(i), 'PortHandles');
                numInports = length(portHandles.Inport);
                numOutports = length(portHandles.Outport);
                
                h = min(15*max([numInports, numOutports]) + 30, 1000);
                
                set_param(subsysHandles(i), 'Position', [x, y, x+w, y+h]);
                
                y = y + h + 30;
            end
            
            mergeHandles = Stateflow.SLUtils.findSystem(chartBlockH, 'BlockType', 'Merge');
            for i=1:length(mergeHandles)
                lineHandles = get_param(mergeHandles(i), 'LineHandles');
                lineH = lineHandles.Outport;
                dstBlockH = get_param(lineH, 'DstBlockHandle');
                if ishandle(dstBlockH)
                    dstpos = get_param(dstBlockH, 'Position');
                    set_param(mergeHandles(i), 'Position', [dstpos(1)-100, dstpos(2), dstpos(3)-100, dstpos(4)]);
                end
            end
        end
        
        function syncMachinePrototypes(machineId, isSimulating)
            % Sync from the Stateflow prototype to the Simulink prototype. At one
            % point this used to be in the other direction, however, to deal with
            % strange model corruptions such as in g469084, we do it in the SF->SL
            % direction. The sync from SL->SF is dynamic so we do not need to wait
            % for so long.
            %
            % This function is called when the model is saved and at the beginning
            % of model-update.
            
            % Unlock if its a library.
            modelH = sf('get', machineId, '.simulinkModel');
            prevLock = Stateflow.SLUtils.unlockModel(modelH);
            lockRestore = onCleanup(@() set_param(modelH, 'lock', prevLock));
            
            % g634482: Prevent spurious warnings during renaming.
            warnState = warning('off', 'all');
            warnRestore = onCleanup(@() warning(warnState));
            
            sf('MachineSyncSLFunctions', machineId, isSimulating);
        end
        
        function yn = chartNeedsToasting(chartId)
            % Are any of the internal connections to the subsystems
            % invalid?
            %
            % returns true if any of the input/output ports of the
            % S-function and inner subsystems are disconnected. This
            % signals the instance load method to resync and redo all the
            % internal connections
            
            % do an early return if chart has no simfcns etc. This is
            % expensive:  G551427
            allStates = sf('get',chartId,'chart.states');
            simFcns = sf('find',allStates,'state.simulink.isSimulinkFcn',1);
            atomicSubcharts = sf('find',allStates,'state.simulink.isComponent',1);
            hasSimFcns = (~isempty(simFcns) || ~isempty(atomicSubcharts));
            
            if(~hasSimFcns)
                yn = false;
                return;
            end
            
            instanceId = sf('get', chartId, '.instance'); %#ok<PROP>
            chartBlockH = sf('get', instanceId, '.simulinkBlock'); %#ok<PROP>
            
            % g475099: When a chart with mild corruptions is copied over to the
            % clipboard, we do not want to consider unconnected inports as being
            % bad.
            if Stateflow.SLUtils.isOnClipboard(chartBlockH) %#ok<PROP>
                yn = false;
                return
            end
            
            subBlocks = Stateflow.SLUtils.findSystem(chartBlockH); %#ok<PROP>
            for i=1:length(subBlocks)
                maskType = get_param(subBlocks(i), 'MaskType');
                blockType = get_param(subBlocks(i), 'BlockType');
                if strcmpi(blockType, 'Demux') || strcmpi(blockType, 'Reference')
                    continue
                end
                
                % In the presence of unbound inports/outports, there might
                % be disconnected ports for atomic subchart wrappers. For
                % SL in SF functions however, everything needs to be nicely
                % connected..
                if ~strcmpi(maskType, 'StateflowAtomicSubchartWrapper') && ...
                        ~strcmpi(maskType, 'Stateflow') && ...
                        Stateflow.SLUtils.isAnyPortDisconnected(subBlocks(i))
                    yn = true;
                    return
                end
            end
            
            yn = false;
        end
        
        function flushUnifiedClipboard
            if sf('feature', 'SLSFUnifiedCopyBuffer')
                sf('FlushClipboard');
            end
        end
        
        function onSimulinkBlockCopy(blockH, portHandles)
            % Gets called by Simulink when something is copied over to the
            % SIMULINK_scrap graph.
            
            if ~sf('feature', 'SLSFUnifiedCopyBuffer')
                return
            end
            
            if isStateflowBlock(blockH)
                
                if sf('feature', 'subchartComponents')
                    blockName = normalizeNames({get_param(blockH, 'Name')});
                    blockName = blockName{1};
                    isLink = ~isempty(get_param(blockH, 'ReferenceBlock'));
                    sf('CopyChartToClipboard', blockH, blockName, isLink);
                else
                    % Make sure to flush the Stateflow clipboard. g571127
                    sf('FlushClipboard');
                end
                
            elseif isempty(get_param(blockH, 'ReferenceBlock')) && hasFcnCallTriggerPort(portHandles)
                % g541647: For now, we do not handle a linked library block
                % because we cannot handle a linked subsystem directly
                % underneath the Stateflow mask.
                fcnName = normalizeNames({get_param(blockH, 'Name')});
                fcnName = fcnName{1};
                
                [inportH, inportNames] = getPortNames(portHandles, 'Inport');
                [outportH, outportNames] = getPortNames(portHandles, 'Outport');
                protoType = Stateflow.SLUtils.getGenericPrototype(fcnName, inportNames, outportNames);
                sf('CopySimulinkFcnToClipboard', blockH, inportH, inportNames, outportH, outportNames, protoType, fcnName);
                
            else
                % This is necessary because each time Simulink copies new
                % stuff to the clipboard, it destroys the original objects.
                % Therefore, objects on the Stateflow clipboard might be
                % pointing to stale object handles.
                sf('FlushClipboard');
                
            end
            
            function names = normalizeNames(names)
                for i=1:length(names)
                    newname = regexprep(names{i}, '\W', '_');
                    if isempty(regexp(newname, '^[_a-zA-Z]', 'once'))
                        newname = ['a' newname]; %#ok<AGROW>
                    end
                    names{i} = newname;
                end
            end
            
            function yn = isStateflowBlock(blockH)
                yn = strcmpi(get_param(blockH, 'BlockType'), 'SubSystem') && ...
                    strcmpi(get_param(blockH, 'MaskType'), 'Stateflow');
            end
            
            function yn = hasFcnCallTriggerPort(portHandles)
                for i=1:length(portHandles)
                    if strcmpi(get_param(portHandles(i), 'BlockType'), 'TriggerPort') && ...
                            strcmpi(get_param(portHandles(i), 'TriggerType'), 'function-call')
                        yn = true;
                        return
                    end
                end
                yn = false;
            end
            
            function [portTypeHandles, portNames] = getPortNames(allPortHandles, portType)
                portTypeHandles = find_system(allPortHandles, 'BlockType', portType);
                portNums = str2double(get_param(portTypeHandles, 'Port'));
                [~, idx] = sort(portNums);
                % g541636: Important to normalize the port names to be a
                % cell-array.
                portNames = cellstr(get_param(portTypeHandles(idx), 'Name'));
                portNames = normalizeNames(portNames);
            end
            
        end
        
        function flushSimulinkClipboard()
            Stateflow.SLUtils.flushSimulinkClipboard();
        end
        
        function createChartLocalDSMs(chartId)
            
            chartData = sf('DataOf', chartId);
            chartLocalDSMs = [sf('find', chartData, '.scope', 'DATA_STORE_MEMORY_DATA', '.isChartLocalDsm', 1), ...
                sf('find', chartData', '.scope', 'LOCAL_DATA', '.subchart.isMappedToSubchart', 1)];
            
            lchartBlockH = sfprivate('chart2block', chartId);
            existingDsmHandles = Stateflow.SLUtils.findSystem(lchartBlockH, 'BlockType', 'DataStoreMemory');
            
            if isempty(chartLocalDSMs)
                delete_block(existingDsmHandles)
                return
            end
            
            existingDsmNames = cellstr(get_param(existingDsmHandles, 'DataStoreName'));
            dsmUsedFlag = zeros(size(existingDsmHandles));
            dsmUddHandles = idToHandle(sfroot, chartLocalDSMs);
            for i=1:length(dsmUddHandles)
                ensureDsmForData(dsmUddHandles(i));
            end
            
            % delete unused DSMs
            delete_block(existingDsmHandles(~dsmUsedFlag));
            
            % Reposition all chart local DSMs.
            allDsms = Stateflow.SLUtils.findSystem(lchartBlockH, 'BlockType', 'DataStoreMemory');
            for i=1:length(allDsms)
                Stateflow.SLUtils.setPosition(allDsms(i), 40*i, 15, 20, 20);
                set_param(allDsms(i), 'ShowName', 'off');
            end
            
            function ensureDsmForData(dataH)
                idx = strmatch(dataH.Name, existingDsmNames, 'exact');
                if isempty(idx)
                    dsmH = Stateflow.SLUtils.addBlock(lchartBlockH, 'built-in/DataStoreMemory', ' ', 'MakeNameUnique', 'on');
                else
                    dsmH = existingDsmHandles(idx);
                    dsmUsedFlag(idx) = 1;
                end
                
                % Set name
                set_param(dsmH, 'DataStoreName', dataH.Name);
                
                % Set type
                if regexp(dataH.DataType, 'type\s*\(\s*\w+\s*\)')
                    sfprivate('construct_error', dataH.Id, 'Interface', ...
                        DAStudio.message('Stateflow:subchart:IllegalDataTypeOfMappedLocal', ...
                        dataH.DataType, dataH.Name, dataH.Id), ...
                        0);
                end
                set_param(dsmH, 'OutDataTypeStr', dataH.DataType);
                
                % Set complexity
                if strcmpi(dataH.Props.Complexity, 'on')
                    set_param(dsmH, 'SignalType', 'complex');
                else
                    set_param(dsmH, 'SignalType', 'real');
                end
                
                % Set 'resolve to signal'
                if dataH.Props.ResolveToSignalObject
                    set_param(dsmH, 'StateMustResolveToSignalObject', 'on');
                else
                    set_param(dsmH, 'StateMustResolveToSignalObject', 'off');
                end
                
                % Set 'lock against fixpt scaling tool'
                if dataH.Props.Type.Fixpt.Lock
                    set_param(dsmH, 'LockScale', 'on');
                else
                    set_param(dsmH, 'LockScale', 'off');
                end
                
                % Set diagnostics to 'none'.
                set_param(dsmH, 'WriteAfterReadMsg', 'none');
                set_param(dsmH, 'WriteAfterWriteMsg', 'none');
                set_param(dsmH, 'ReadBeforeWriteMsg', 'none');
                
                % construct the initial value string. This is where things
                % get really complicated because of the difference in the
                % way the sizes of ports and DSMs are specified. For a SF
                % data object/Simulink port, size is specified explicitly
                % whereas for DSMs the size follows from the initial value.
                dataInitVal = dataH.Props.InitialValue;
                if isempty(dataInitVal)
                    dataInitVal = '0';
                end
                dataSize = dataH.Props.Array.Size;
                if isempty(dataSize)
                    dataSize = '1';
                end
                
                if dataH.Props.ResolveToSignalObject
                    dsmInitVal = '[]';
                else
                    dsmInitVal = sprintf('Stateflow.SLINSF.SimulinkMan.getDSMInitVal(%s, %s, ''%s'')', dataSize, dataInitVal, dataH.Name);
                end
                set_param(dsmH, 'InitialValue', dsmInitVal);

                try
                    dsmSize = slResolve(dataSize, dsmH);
                catch  %#ok<CTCH>
                    % Ignore the error. We'll let Simulink deal with it
                    % later.
                    dsmSize = [];
                end
                
                % g651441: Consider a local data 'foo' which is mapped to
                % an atomic subchart DSM. We want to make sure that the
                % following happens:
                % 1. If the user specifies the size of 'foo' as '4', then
                %    a. foo[0][0] should be an error
                %    b. foo[0] should work.
                % 2. If the user specifies the size of 'foo' as '[1 4]'
                % then
                %    a. foo[0][2] should work
                %    b. foo[1][2] should ERROR
                % 3. If the user specifies the size of 'foo' as '[4 1]'
                % then
                %   a. foo[2][1] should ERROR
                %   b. foo[2][0] should work
                if length(dsmSize) == 1
                    set_param(dsmH, 'VectorParams1D', 'on');
                else
                    set_param(dsmH, 'VectorParams1D', 'off');
                end
            end
            
        end
        
        function dsmInitVal = getDSMInitVal(dataSize, dataInitVal, dataName)
            if length(dataInitVal) ~= 1 && ~isequal(dataSize, size(dataInitVal))
                msg = DAStudio.message('Stateflow:subchart:ChartLocalDSMSizeError', dataName, num2str(dataSize), num2str(size(dataInitVal)));
                error('Stateflow:DSMSizeMismatch', msg);
            else
                if length(dataSize) == 1
                    dsmInitVal = ones(dataSize,1).*dataInitVal;
                else
                    dsmInitVal = ones(dataSize).*dataInitVal;
                end
            end
        end
        
        function gotoParent(blockH)
            % This function gets called when the "Up" menu button is
            % pressed in one of three situations:
            % 1. In a Simulink subsystem which is inside a Stateflow chart
            % 2. In a Stateflow chart which is inside a Stateflow chart
            % 3. In a Stateflow chart which is _not_ inside a Stateflow
            % chart.
            
            parentH = get_param(get_param(blockH, 'Parent'), 'Handle');
            open_system(parentH, 'force');
            
            if Stateflow.SLUtils.isStateflowBlock(parentH)
                parentChartId = sfprivate('block2chart', parentH);
                substateIds = sf('get', parentChartId, '.states');
                parentStateId = sf('find', substateIds, '.simulink.blockName', get_param(blockH, 'Name'));
                assert(~isempty(parentStateId));
                
                sfH = idToHandle(sfroot, parentStateId);
                sfH.subviewer.view;
                % Selecting [] is important because if the state was
                % already selected, doing a select on the same ID actually
                % deselects it.
                sf('Select', parentChartId, []);
                sf('Select', parentChartId, sfH.Id);
                
                % Unfortunately, we need to set this because the
                % sfH.subviewer.view might open up the library chart.
                if ~isempty(get_param(parentH, 'ReferenceBlock')) || ...
                        ~isempty(get_param(parentH, 'TemplateBlock'))
                    sf('set', parentChartId, '.activeInstance', parentH);
                end
            else
                selectedH = Stateflow.SLUtils.findSystem(parentH, 'FindAll', 'on', 'selected', 'on');
                for i=1:length(selectedH)
                    set_param(selectedH(i), 'Selected', 'off');
                end
                
                set_param(blockH, 'Selected', 'on');
            end
        end
        
        function deleteBlock(blockH)
            if ishandle(blockH)
                delete_block(blockH);
            end
        end
    end
    
    methods(Access=protected)
        
        function safeToSync = ensureSubsystemExists(self, isInitializing)
            % Ensures that the subsystem exists for a Simulink function
            % state.
            
            if isempty(self.subsysH)
                createSubsystem();
            end
            
            % g587479: In some crazy corner cases, we can actually have a
            % linked subsystem underneath us. In this case, we cannot sync.
            if ~isempty(get_param(self.subsysH, 'ReferenceBlock'))
                safeToSync = false;
                return
            end
            
            % g541650: With unified copy/paste, we could have pasted a
            % read-only subsystem underneath the Stateflow mask. This is
            % not supported.
            set_param(self.subsysH, 'Permissions', 'ReadWrite');
            
            % g475099: When a chart is on the clipboard, its very risky to
            % change it around too much because Simulink doesn't get a
            % chance to respond to our changes.
            if Stateflow.SLUtils.isOnClipboard(self.subsysH)
                safeToSync = false;
                return
            end
            
            % When the user updates the Stateflow prototype, we are called
            % with the "sync" command. As part of doing this, we issue
            % commands to change the names/numbers of ports beneath the
            % function call subsystem. This in turn makes Simulink call
            % simfcn_man with the "portNumsChanged" command. When this
            % happens, we should temporarily ignore the Simulink command.
            h = get_param(self.subsysH, 'Object');
            if getappdata(h, 'StateflowIsSyncing') == true
                safeToSync = false;
                return;
            else
                safeToSync = true;
            end
            
            setappdata(h, 'StateflowIsSyncing', true);
            
            self.ensureTriggerPortExists;
            
            fullName = self.getFullName();
            if ~isequal(get_param(self.subsysH, 'Name'), fullName)
                if ~isInitializing
                    Stateflow.SLUtils.setNameSafely(self.subsysH, fullName);
                else
                    DAStudio.warning('Stateflow:slinsf:CorruptionDuringInit', ...
                        [get_param(self.subsysH, 'Parent') '/' get_param(self.subsysH, 'Name')], ...
                        [get_param(self.subsysH, 'Parent') '/' fullName]);
                end
            end
            
            sf('set', self.stateId, '.simulink.blockHandle', self.subsysH);
            sf('set', self.stateId, '.simulink.blockName', get_param(self.subsysH, 'Name'));
            
            % We create a PreDeleteFcn callback on certain ports to make it
            % hard to remove those blocks. However, that callback is also
            % called when the containing chart is deleted. Hence when the
            % outer chart is being deleted, we disable the call-back.
            safeBlocks = self.getUndeletableBlocks();
            for i=1:length(safeBlocks)
                set_param(safeBlocks(i), 'PreDeleteFcn', 'Stateflow.SLINSF.SimulinkMan.unsafePredeleteFcn');
                set_param(safeBlocks(i), 'CopyFcn', 'set_param(gcbh,''PreDeleteFcn'','''')');
                
                blockUddH = get_param(safeBlocks(i), 'Object');
                setappdata(blockUddH, 'StateflowOkToDelete', false);
            end
            
            set_param(self.subsysH, 'PreDeleteFcn', 'Stateflow.SLINSF.SimulinkMan.removePreDeleteFcn');
            set_param(self.subsysH, 'UndoDeleteFcn', 'Stateflow.SLINSF.SimulinkMan.restorePreDeleteFcn');
            
            function createSubsystem
                % Create a function call subsystem.
                
                fullName = self.getFullName();
                origBlock = sf('get', self.stateId, '.simulink.blockHandle');
                if ~ishandle(origBlock)
                    origBlock = 'built-in/Subsystem';
                end
                self.subsysH = Stateflow.SLUtils.addBlock(self.chartBlockH, origBlock, fullName, 'MakeNameUnique', 'on');
            end
            
        end
        
        function ensureTriggerPortExists(self)
            % Ensures that a subsystem has a function call trigger port.
            
            trigH = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'TriggerPort');
            if isempty(trigH)
                trigH = Stateflow.SLUtils.addBlock(self.subsysH, 'built-in/TriggerPort', 'f');
            end
            set_param(trigH, 'TriggerType', 'function-call');
            self.postProcessTriggerPort(trigH);
        end
        
        function postProcessTriggerPort(~, trigH) %#ok<INUSD>
            % By default do nothing.
        end
        
        function adjustInstanceConnectionsAfterRemoval(self)
            % XXX TEMPORARY till we get synthesized Simulink trigger block
            % in place.
            sf('Instance', 'adjust_demux_block', self.instanceId, -1);
        end
        
        function fullName = getFullName(self)
            % Gets the full dot-delimited path to the current state from
            % the chart root.
            
            fullName = sf('FullName', self.stateId, self.chartId, '.');
            
            % g569304: When we copy over a SL function from a chart which
            % is inside a chart within a subsystem, the fullName contains
            % '/' characters because the .treeNode of the DB_state is not
            % quite up to date. Just use the last part of the fullName for
            % now. Later the state will be re-synced after a full hierarchy
            % rebuild and things will become fine.
            [~, name, ext] = fileparts(fullName);
            fullName = [name ext];
            if isempty(fullName)
                fullName = '?';
            end
        end
        
        function ensureConnectionToDemux(self, demuxIndex)
            % Ensure that the demuxIndex outport of the Demux block is
            % connected to the trigger inport of the wrapper subsystem.
            
            if self.terminatorH > 0
                numDemuxOutputs = 0;
            else
                ports = get_param(self.demuxH, 'ports');
                numDemuxOutputs = ports(2);
            end
            if numDemuxOutputs < demuxIndex
                sf('Instance', 'adjust_demux_block', self.instanceId, demuxIndex - numDemuxOutputs);
            end
            if ~isempty(Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'TriggerPort'))
                Stateflow.SLUtils.ensureConnection(self.demuxH, demuxIndex, self.subsysH, 'Trigger');
            end
        end
        
        function [nRenamed, nDeleted, nCreated, err] = syncPorts(self, inputNames, outputNames)
            % Sync the inports/outports of the inner subsystem
            
            moveAwayOutports;
            [nRenamed, nDeleted, nCreated, err]  = syncPortsType('Inport', inputNames);
            [nR, nD, nC, e] = syncPortsType('Outport', outputNames);
            
            nRenamed = nRenamed + nR;
            nDeleted = nDeleted + nD;
            nCreated = nCreated + nC;
            err = err || e;
            
            
            function moveAwayOutports
                % rename all outports which conflict with inputs
                
                oldOutputPorts = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Outport');
                
                if isempty(inputNames) || isempty(oldOutputPorts)
                    return
                end
                
                for i=1:length(oldOutputPorts)
                    portH = oldOutputPorts(i);
                    portName = get_param(portH, 'Name');
                    if strmatch(portName, inputNames, 'exact')
                        self.renamePort(portH, [' ' portName]);
                    end
                end
            end
            
            function [nRenamed, nDeleted, nCreated, err] = syncPortsType(portType, newNames)
                % Sync the inports/outports of the subsystem
                
                nRenamed = 0;
                nDeleted = 0;
                nCreated = 0;
                
                oldHandles = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', portType);
                oldNames = cellstr(get_param(oldHandles, 'Name'));
                oldLineHandles = get_param(self.subsysH, 'LineHandles');
                oldLineHandles = oldLineHandles.(portType);
                
                % first all port names which already existed can be readily
                % re-numbered. Remember them for later.
                newHandles = repmat(-1, 1, length(newNames));
                for i=1:length(newNames)
                    idx = strmatch(newNames{i}, oldNames, 'exact');
                    if ~isempty(idx)
                        newHandles(i) = oldHandles(idx);
                        
                        % remove this from consideration when we attempt
                        % renaming.
                        oldNames(idx) = [];
                        oldHandles(idx) = [];
                        oldLineHandles(idx) = [];
                    end
                end
                
                % Rename as many of the old ports to the new names as possible.
                err = false;
                for i=1:length(newNames)
                    % if we cannot find any more of the old ports to
                    % rename, then we are done. We'll need to create new
                    % ports.
                    if isempty(oldNames)
                        break
                    end
                    
                    % there's already a port for this name
                    if ishandle(newHandles(i))
                        continue
                    end
                    
                    nRenamed = nRenamed + 1;
                    
                    % rename one of the old ports. Ideally, we would choose
                    % an old port whose name most closely matches with this
                    % one :)
                    newHandles(i) = oldHandles(1);
                    err = self.renamePort(newHandles(i), newNames{i}) || err;
                    
                    % remove the old port from consideration
                    oldNames(1) = [];
                    oldHandles(1) = [];
                    oldLineHandles(1) = [];
                end
                
                % delete the rest of the old ports
                for i=1:length(oldHandles)
                    if ishandle(oldLineHandles(i))
                        delete_line(oldLineHandles(i));
                    end
                    nDeleted = nDeleted + 1;
                    
                    self.deletePort(oldHandles(i));
                end
                
                % now create new ports if necessary. Also ensure they are
                % numbered properly.
                for i=1:length(newHandles)
                    if ~ishandle(newHandles(i))
                        newHandles(i) = self.createPort(i, portType, newNames{i});
                        nCreated = nCreated + 1;
                    end
                    % If there was some renaming which needed to happen,
                    % need to transmit that info up so that we can take
                    % action.
                    if ~strcmp(get_param(newHandles(i), 'Name'), newNames{i})
                        err = true;
                    end
                    set_param(newHandles(i), 'Port', num2str(i));
                end
            end
            
        end
        
        function err = renamePort(self, portH, newName) %#ok<MANU>
            err = Stateflow.SLUtils.setNameSafely(portH, newName);
        end
        
        function deletePort(self, portH) %#ok<MANU>
            delete_block(portH);
        end
        
        function portH = createPort(self, i, portType, newName) %#ok<INUSL>
            portH = Stateflow.SLUtils.addBlock(self.subsysH, ['built-in/', portType], newName);
        end
        
        function blockHandles = getUndeletableBlocks(~)
            blockHandles = [];
        end
        
        function doAdditionalCopyOperations(~, ~)
            % Default implementation does nothing.
        end
        
    end
    
    methods(Static)
        % All of these methods are to prevent deletion of ports which are
        % automatically created.
        
        function unsafePredeleteFcn
            % Called when a trigger port lying inside an SLFunction is
            % deleted. We want to throw an error unless the outer container
            % is also being deleted.
            trigH = get_param(gcbh, 'Object');
            if ~isequal(getappdata(trigH, 'StateflowOkToDelete'), true)
                DAStudio.error('Stateflow:slinsf:AttemptFcnPortDeletion')
            end
        end
        
        function removePreDeleteFcn(blockH)
            if nargin < 1
                blockH = gcbh;
            end
            blocks = Stateflow.SLUtils.findSystem(blockH);
            for i=1:length(blocks)
                if strcmp(get_param(blocks(i), 'PreDeleteFcn'), 'Stateflow.SLINSF.SimulinkMan.unsafePredeleteFcn')
                    blockUddH = get_param(blocks(i), 'Object');
                    setappdata(blockUddH, 'StateflowOkToDelete', true);
                end
            end
        end
        
        function restorePreDeleteFcn(blockH)
            if nargin < 1
                blockH = gcbh;
            end
            blocks = Stateflow.SLUtils.findSystem(blockH);
            for i=1:length(blocks)
                if strcmp(get_param(blocks(i), 'PreDeleteFcn'), 'Stateflow.SLINSF.SimulinkMan.unsafePredeleteFcn')
                    blockUddH = get_param(blocks(i), 'Object');
                    setappdata(blockUddH, 'StateflowOkToDelete', false);
                end
            end
        end
        
    end
    
    methods(Static)
        
        function removeOutportConnections(blockH)
            lineHandles = get_param(blockH, 'LineHandles');
            
            srcBlockH = get_param(lineHandles.Inport, 'SrcBlockHandle');
            if strcmp(get_param(srcBlockH, 'BlockType'), 'Merge')
                Stateflow.SLUtils.deleteAllLines(srcBlockH);
                delete_block(srcBlockH);
            else
                delete_line(lineHandles.Inport);
            end
        end
        
    end
end
