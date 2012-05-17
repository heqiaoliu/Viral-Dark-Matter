classdef SimfcnMan < Stateflow.SLINSF.SimulinkMan
    % For Mathworks internal use only.

    %   Copyright 2009-2010 The MathWorks, Inc.

    methods
        
        function self = SimfcnMan(stateId)
            % Constructor
            
            % Defined in SimulinkMan
            self = self@Stateflow.SLINSF.SimulinkMan(stateId);
        end

        function sync(self, isInitializing)
            % Syncs the inports and outports of the subsystem.
            %
            % Also ensure that the subsystem itself exists. We also create
            % the function call trigger port if it does not exist.

            safeToSync = self.ensureSubsystemExists(isInitializing);
            if ~safeToSync
                return
            end
            
            % Since outputs from the S-function are inputs to the
            % subsystem, a left-right orientation minimizes line
            % intersections.
            set_param(self.subsysH, 'Orientation', 'left');

            subsysUddH = get_param(self.subsysH, 'Object');
            removeListeners();
            
            [~, sfInputNames] = self.getInputOutputData('input');
            [~, sfOutputNames] = self.getInputOutputData('output');
            
            [~, ~, ~, err] = self.syncPorts(sfInputNames, sfOutputNames);

            restoreListeners();
            self.syncPortProps();
            
            % If there was an error going from SF to SL, we had better sync
            % from SL to SF just to make things consistent. However, do not
            % sync from SL to SF when initializing because we are not yet
            % ready for it.
            if err && ~isInitializing
                DAStudio.warning('Stateflow:slinsf:ErrorSettingPortName');
                self.syncFromSLToSF(true);
            end
            
            % safe to respond to Simulink events again.
            setappdata(subsysUddH, 'StateflowIsSyncing', false);

            function removeListeners
                % remove any previously existing listener.
                setappdata(subsysUddH, 'ObjectAddedListener', []);
                setappdata(subsysUddH, 'ObjectRemovedListener', []);
                
                % remove name change listeners on ports.
                portHandles = [Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Inport');
                    Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Outport')];
                for i=1:length(portHandles)
                    portH = get(portHandles(i), 'Object');
                    setappdata(portH, 'NameChangeListener', []);
                end
            end
            
            function restoreListeners
                % re-add a listener to listen on port additions.
                l1 = handle.listener(subsysUddH, 'ObjectChildAdded', @Stateflow.SLINSF.SimfcnMan.onChildAdded);
                l2 = handle.listener(subsysUddH, 'ObjectChildRemoved', @Stateflow.SLINSF.SimfcnMan.onChildRemoved);
                % Store the listener on the object so that it persists.
                % Otherwise, the listener dies as soon as this function
                % returns.
                setappdata(subsysUddH, 'ObjectAddedListener', l1);
                setappdata(subsysUddH, 'ObjectRemovedListener', l2);
                
                % Add NameChange listeners on all children not just on
                % inports/outports.
                children = Stateflow.SLUtils.findSystem(subsysUddH.Handle);
                for i=1:length(children)
                    child = children(i);
                    childH = get_param(child, 'Object');
                    l = handle.listener(childH, 'NameChangeEvent', @Stateflow.SLINSF.SimfcnMan.onBlockNameChange);
                    setappdata(childH, 'NameChangeListener', l);
                end
            end
        
        end
        
        function [nInDelta, nOutDelta] = updateConnections(self, inIndex, outIndex, demuxIndex)
            % Updates the connections between the subsystem and the
            % S-function.
            
            Stateflow.SLUtils.deleteAllLines(self.subsysH);
            numPorts = get_param(self.subsysH, 'Ports');
            
            inportBlocks = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Inport');
            outportBlocks = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Outport');
            
            if numPorts(1) ~= length(inportBlocks) || ...
                    numPorts(2) ~= length(outportBlocks)
                DAStudio.warning('Stateflow:slinsf:HolesInPortNumbers', ...
                    [get_param(self.subsysH, 'Parent') '/' get_param(self.subsysH, 'Name')]);
            end
            
            portHandles = get_param(self.sfunH, 'PortHandles');
            outputPorts = portHandles.Outport;
            
            for i=1:length(inportBlocks)
                portNum = str2double(get_param(inportBlocks(i), 'Port'));
                Stateflow.SLUtils.addLine(self.sfunH, outIndex+i-1, self.subsysH, portNum);
                
                % g523482: Null out the names on the output ports which go
                % to SL functions.
                set_param(outputPorts(outIndex+i-1), 'Name', '');
            end
            
            for i=1:length(outportBlocks)
                portNum = str2double(get_param(outportBlocks(i), 'Port'));
                Stateflow.SLUtils.addLine(self.subsysH, portNum, self.sfunH, inIndex+i-1);
            end
            
            % subsystem outputs are s-function inputs and vice-versa.
            nInDelta = length(outportBlocks);
            nOutDelta = length(inportBlocks);
            
            % Adjust the number of demux ports so that we have something to
            % connect to.
            ports = get_param(self.demuxH, 'ports');
            numDemuxOutputs = ports(2);
            if self.terminatorH ~= 0
                numDemuxOutputs = 0;
            end
            if numDemuxOutputs < demuxIndex
                sf('Instance', 'adjust_demux_block', self.instanceId, demuxIndex - numDemuxOutputs);
            end
            
            add_line(get_param(self.subsysH, 'Parent'), ...
                [get_param(self.demuxH, 'Name') '/' num2str(demuxIndex)], ...
                [get_param(self.subsysH, 'Name') '/Trigger']);
        end

        function openSubsystem(self)
            % Opens the Simulink function call subsystem.
            
            % If activeInst > 0 and is a valid handle, then it means we are
            % editing a library instance. In this case, we want to open the
            % linked subsystem rather than opening the actual library
            % subsystem. g473930
            activeInst = sf('get', self.chartId, '.activeInstance');
            if activeInst > 0 && ishandle(activeInst)
                name = get_param(self.subsysH, 'Name');
                localSubsysH = Stateflow.SLUtils.findSystem(activeInst, 'Name', name);
                open_system(localSubsysH);
            elseif ishandle(self.subsysH)
                open_system(self.subsysH)
            end
        end

        function yn = needsToasting(self, inIndex, outIndex, demuxIndex, numInputs, numOutputs)
            % Find out if the function call subsystem has exactly the
            % connection profile which is stored in the C++ object.
            try
                verifyConnectionBetween(self.demuxH, 'Outport', demuxIndex, self.subsysH, 'Trigger', 1);
                for i=1:numInputs
                    verifyConnectionBetween(self.sfunH, 'Outport', outIndex+i-1, self.subsysH, 'Inport', i);
                end
                for i=1:numOutputs
                    verifyConnectionBetween(self.subsysH, 'Outport', i, self.sfunH, 'Inport', inIndex+i-1);
                end
                fullName = self.getFullName();
                if ~isequal(get_param(self.subsysH, 'Name'), fullName)
                    error('Stateflow:slinsf:IncorrectName', 'Name mismatch');
                end
                self.syncPortProps();
                yn = false;
            catch %#ok<CTCH>
                yn = true;
            end

            function verifyConnectionBetween(fromBlockH, fromType, fromIndex, toBlockH, toType, toIndex)
                % Verifies the port fromIndex of fromBlockH is connected to
                % port toIndex of toBlockH. fromType and toType give the
                % types of the output and input port.
                fromLineHandles = get_param(fromBlockH, 'LineHandles');
                fromLines = fromLineHandles.(fromType);
                assert(fromIndex >= 1 && fromIndex <= length(fromLines), 'Stateflow:slinsf:WrongConnection', 'Invalid fromIndex');

                toLineHandles = get_param(toBlockH, 'LineHandles');
                toLines = toLineHandles.(toType);
                assert(toIndex >= 1 && toIndex <= length(toLines), 'Stateflow:slinsf:WrongConnection', 'Invalid toIndex');

                if ~isequal(fromLines(fromIndex), toLines(toIndex))
                    error('Stateflow:slinsf:WrongConnection', 'The two ports are not connected');
                end
            end

        end

        function syncFromSLToSF(self, isSyncing)
            % Syncs the prototype from a Simulink subsystem to a Stateflow
            % function object.

            % This function needs to be in the public area because it is
            % called from onSimPrototypeChanged, a static function

            newPrototype = getSimulinkPrototype(self.subsysH, self.stateId);
            oldPrototype = getStateflowPrototype(self.stateId);

            if ~strcmp(newPrototype, oldPrototype)
                % Use the UDD API to change the labelString rather than
                % sf('set') because we actually _want_ to destroy the undo
                % stack in SF. Otherwise, weird interactions between
                % Stateflow edits and unrecorded SL edits cause strange
                % bugs. g462966
                % 
                % However, if we are here because of errors during SF->SL
                % syncing, it might be during an undo operation when it is
                % unsafe to destroy the undo stack. Therefore use the
                % sf('set') method which retains the undo stack. g475563.
                if isSyncing
                    sf('set', self.stateId, '.labelString', newPrototype);
                else
                    r = sfroot;
                    fcnH = r.idToHandle(self.stateId);
                    fcnH.labelString = newPrototype;
                end
            else
                % the bus properties are already synced when the label is
                % modified. Hence do this only when the labels are already
                % identical. In this case, the user might have changed the
                % bus properties.
                self.syncPortProps();
            end

            function proto = getSimulinkPrototype(blockH, fcnId)
                % Gets the candidate prototype of the Simulink subsystem.

                inputNames = getPortNames(blockH, 'Inport');
                outputNames = getPortNames(blockH, 'Outport');

                % Note that we take the name of the function from the
                % Stateflow object because the user is never expected to
                % change the name except by editing the Stateflow
                % prototype. Also, the name of the Simulink subsystem
                % contains '.' if the state is nested inside another state.
                % Another reason is that because Stateflow doesn't enforce
                % name uniqueness, the name of the Simulink subsystem might
                % be temporarily "off".
                proto = Stateflow.SLUtils.getGenericPrototype(sf('get', fcnId, '.name'), inputNames, outputNames);

                function names = getPortNames(blockH, portType)
                    % Gets the names of the input/output ports of a
                    % Simulink subsystem.
                    %
                    % Also does a bit of sanity checking/enforcement if the
                    % port names contain funny characters.

                    handles = Stateflow.SLUtils.findSystem(blockH, 'BlockType', portType);

                    % cellstr() is to homogenize the return value of
                    % get_param to a cell array of strings (otherwise we
                    % get either a string or a cell depending on the number
                    % of inports).
                    names = cellstr(get_param(handles, 'Name'));
                    portNums = str2double(get_param(handles, 'port'));
                    [~, sortIdx] = sort(portNums);
                    names = names(sortIdx);
                    handles = handles(sortIdx);

                    % This loop ensures that there are no funny names
                    % amongst the simulink ports.
                    for i=1:length(names)
                        if isempty(regexp(names{i}, '^[_a-zA-Z]\w*$', 'once'))
                            newname = regexprep(names{i}, '\W', '_');
                            if isempty(regexp(newname, '^[_a-zA-Z]', 'once'))
                                newname = ['a' newname]; %#ok<AGROW>
                            end
                            DAStudio.warning('Stateflow:slinsf:BadSimulinkPortName', ...
                                             [get_param(blockH, 'Parent') '/' names{i}], ...
                                             [get_param(blockH, 'Parent'), '/', newname]);
                            names{i} = newname;
                            set_param(handles(i), 'Name', names{i});
                        end
                    end
                end

            end

            function proto = getStateflowPrototype(fcnId)
                % Gets the candidate prototype of the Stateflow object.

                [~, inputNames] = self.getInputOutputData('input');
                [~, outputNames] = self.getInputOutputData('output');

                proto = Stateflow.SLUtils.getGenericPrototype(sf('get', fcnId, '.name'), inputNames, outputNames);
            end

        end

    end
    
    methods(Access=protected)
        
        function deletePort(self, portH) %#ok<MANU>
            % rather than plainly deleting the port, we move it to the
            % SIMULINK_delete graph from where it can be recovered if
            % necessary (for example on an undo operation).
            Stateflow.SLUtils.deleteToClipboard(portH);
        end
        
        function portH = createPort(self, i, portType, newName)
            % Create a port within the Simulink subsystem

            if strcmp(portType, 'Inport')
                sfDataScope = 'INPUT';
            else
                sfDataScope = 'OUTPUT';
            end
            allData = sf('DataOf', self.stateId);
            dataIds = sf('find', allData, 'data.scope', ['FUNCTION_', upper(sfDataScope), '_DATA']);
            sfId = dataIds(i);

            reposition = false;
            
            % First check if there is an old port which we deleted which is
            % still lying around. If so, resurrect it rather than copying
            % over a completely new port.
            origBlock = sf('get', sfId, '.simulink.blockHandle');
            if ~ishandle(origBlock) || ~strcmpi(get_param(origBlock, 'BlockType'), portType)
                origBlock = ['built-in/' portType];
                % only reposition a block if we are adding it for the first
                % time. Not repositioning has the benefit that previous
                % connections automatically get remade.
                reposition = true;
            end
            portH = Stateflow.SLUtils.addBlock(self.subsysH, origBlock, ...
                newName, 'MakeNameUnique', 'on');
            
            if reposition
                % only change the position of an inport if it is newly
                % created.
                if strcmpi(portType(1:2), 'in')
                    x = 20;
                else
                    x = 200;
                end
                y = 100 + 30*i;
                w = 30;
                h = 14;
                set_param(portH, 'Position', [x, y, x+w, y+h]);
            end
            set_param(portH, 'Port', num2str(i));
        end
       
        function syncPortProps(self)
            % Syncs the port properties of a Stateflow function and the
            % corresponding Simulink subsystem.

            sfIds = self.getInputOutputData('Input');
            portHandles = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Inport');
            syncPortPropsHelper(sfIds, portHandles);

            sfIds = self.getInputOutputData('Output');
            portHandles = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Outport');
            syncPortPropsHelper(sfIds, portHandles);

            function syncPortPropsHelper(sfIds, portHandles)
                % Slurps the properties from the Simulink port objects and
                % applies them to the Stateflow data objects.

                r = sfroot;
                for i=1:length(portHandles)
                    % sync the bus properties so that the bus selector
                    % works.
                    sfH = r.idToHandle(sfIds(i));
                    if isempty(sfH)
                        continue
                    end

                    dataType = get_param(portHandles(i), 'OutDataTypeStr');
                    if ~isempty(regexp(dataType, '^Inherit:\s', 'once'))
                        ensureThat('sfH.Props.Type.Method', 'Inherited');
                        ensureThat('sfH.Props.Type.BusObject', '');
                    else
                        ensureThat('sfH.DataType', dataType);
                    end
                    
                    % Var size signal. Turns out that it _is_ safe to first
                    % say that the signal is variable sized. Simulink will
                    % later tell us that it is not really variable sized
                    % and the right thing should happen.
                    varSizeSig = char(get_param(portHandles(i), 'VarSizeSig'));
                    if strcmpi(varSizeSig, 'yes')
                        sfH.Props.Array.IsDynamic = 1;
                    elseif strcmpi(varSizeSig, 'inherit') && strcmpi(sfH.Scope, 'output')
                        sfH.Props.Array.IsDynamic = 1;
                    else
                        sfH.Props.Array.IsDynamic = 0;
                    end
                end

                function ensureThat(lhs, rhs)
                    % Ensures that the variable called `lhs` has the value
                    % `rhs` in the caller's workspace.
                    if ~strcmp(evalin('caller', lhs), rhs)
                        evalin('caller', sprintf('%s = ''%s'';', lhs, rhs));
                    end
                end

            end

        end
            
        function [dataIds, names] = getInputOutputData(self, scope)
            % Gets the data IDs and names of the Simulink subsystem

            allData = sf('DataOf', self.stateId);
            dataIds = sf('find', allData, 'data.scope', ['FUNCTION_', upper(scope), '_DATA']);

            if nargout < 2
                return
            end

            names = cell(size(dataIds));
            for i=1:length(dataIds)
                names{i} = sf('get', dataIds(i), '.name');
            end

        end

        function blockHandles = getUndeletableBlocks(self)
            blockHandles = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'TriggerPort');
        end
        
        function doAdditionalCopyOperations(self, copiedBlockH) %#ok<MANU>
            % Break the link (if any) otherwise there are errors removing
            % the PreDeleteFcn call back of the trigger port inside the
            % subsystem. g473781.
            set_param(copiedBlockH, 'LinkStatus', 'none')
            
            if ~sf('feature', 'SLSFUnifiedCopyBuffer')
                return
            end
            
            set_param(copiedBlockH, 'Orientation', 'right');
            Stateflow.SLUtils.copyToCopyBuffer(copiedBlockH);
        end
        
    end

    methods(Static)
        % Generic helper functions

        function parentH = getParentUDI(block)
            % Gets the UDD handle of the Stateflow object which is the
            % parent of the Stateflow.SLFunction object which corresponds
            % to this block.

            blockObj = get_param(block, 'Object');
            self = Stateflow.SLINSF.SimfcnMan.getEventInfo(blockObj);
            r = sfroot;

            if isempty(self)
                % try to see if its under a linkchart and if so return a
                % LinkChart.
                % We can get called here even before Simulink has given
                % Stateflow a chance to bind to the Simulink block. In this
                % case, instanceId can be empty.
                
                linkChartId = blockObj.up.Userdata;
                if ~isempty(linkChartId) && ~isempty(sf('find', 'all', 'linkchart.id', linkChartId))
                    parentH = r.idToHandle(blockObj.up.UserData);
                    return
                end

                parentH = blockObj.up;
                return
            end
            parentId = sf('get', self.stateId, '.treeNode.parent');
            parentH = r.idToHandle(parentId);
        end

        function newMsg = translateIOError(genericIOError)
            % "Translate" an error message which refers to hidden SL in SF
            % ports to a form which makes more sense to the user.

            newMsg = '';

            portNum = str2double(genericIOError.port);
            chartH = get_param(genericIOError.chartPath, 'Handle');
            chartId = sfprivate('block2chart', chartH);
            if isempty(chartId)
                return
            end

            sfunH = Stateflow.SLUtils.findSystem(chartH, 'BlockType', 'S-Function');

            % Find out the destination of the portNum port of the
            % internal S-Function which this error message is referring to.
            portType = [genericIOError.io(1:end-3), 'port'];
            lineHandles = get_param(sfunH, 'LineHandles');

            if strcmpi(portType, 'inport')
                lineH = lineHandles.Inport(portNum);
            elseif strcmpi(portType, 'outport')
                lineH = lineHandles.Outport(portNum);
            else
                return
            end

            if strcmpi(portType, 'inport')
                otherBlockH = get_param(lineH, 'SrcBlockHandle');
                otherPortNum = get_param(get_param(lineH, 'SrcPortHandle'), 'PortNumber');
            else
                otherBlockH = get_param(lineH, 'DstBlockHandle');
                otherPortNum = get_param(get_param(lineH, 'DstPortHandle'), 'PortNumber');
            end

            if strcmpi(get_param(otherBlockH, 'BlockType'), 'SubSystem')
                % This is a hidden input/output which is connected to a
                % subsystem underneath the mask.

                % Figure out the port which feeds this line
                if strcmpi(portType, 'inport')
                    innerPorts = Stateflow.SLUtils.findSystem(otherBlockH, 'BlockType', 'Outport');
                else
                    innerPorts = Stateflow.SLUtils.findSystem(otherBlockH, 'BlockType', 'Inport');
                end
                innerPortH = innerPorts(otherPortNum);

                newMsg = DAStudio.message('Stateflow:slinsf:TranslateIOError', ...
                                          get_param(innerPortH, 'Name'), ...
                                          get_param(innerPortH, 'Parent'), ...
                                          genericIOError.prefix, ...
                                          get_param(innerPortH, 'Name'), ...
                                          get_param(innerPortH, 'Parent'), ...
                                          genericIOError.suffix);

            end
        end

    end

    methods(Static)
        % All these methods are there to support syncing from SL into SF.

        function portNumsChanged(subsysH)
            % Called by Simulink whenever port numbers within a subsystem
            % inside a Stateflow mask are changed.

            Stateflow.SLINSF.SimfcnMan.onSimPrototypeChanged(subsysH);
        end
        
        function self = getEventInfo(subsysUddH)
            % Given a UDD handle to a Simulink.Subsystem, find out the
            % other self for it such as the Stateflow.SLFunction it
            % corresponds to, which chart it belongs to etc.

            % NOTE: Use the UDD handle rather than the Simulink handle. For
            % some reason, the UDD handle is valid for a while longer than
            % the Simulink handle. Therefore although grandParentH.UserData
            % works below,
            %
            %   get_param(grandParentH.Handle, 'UserData')
            %
            % will error out. g463548

            blockName = subsysUddH.Name;
            grandParentH = subsysUddH.up;
            instanceId = grandParentH.UserData;

            % For some odd reason, onSimPrototypeChanged is called via
            % 'bdclose all', after the Stateflow object is unloaded. In
            % this case, doing a simple block2chart caused problems. Hence
            % a "safer" version.
            % We can get called here even before Simulink has given
            % Stateflow a chance to bind to the Simulink block. In this
            % case, instanceId can be empty.
            if isempty(instanceId) || isempty(sf('find', 'all', 'instance.id', instanceId))
                % If we cannot find an instance object with this ID, it
                % means that Stateflow has already unloaded the chart.
                self = [];
                return
            end

            chartId = sf('get', instanceId, '.chart');
            functionIds = sf('FunctionsIn', chartId);
            fcnId = sf('find', functionIds, ...
                       'state.simulink.isSimulinkFcn', 1, ...
                       'state.simulink.blockName', blockName);

            % When a model is being closed, then we get the
            % onChildRemoved() call-back for whatever reason. By this time,
            % Stateflow has unloaded the chart leading to an empty function
            % id.
            if isempty(fcnId)
                % retry once using the blockHandle to see if someone tried
                % to rename the subsystem out from underneath us.
                fcnId = sf('find', functionIds, ...
                           'state.simulink.isSimulinkFcn', 1, ...
                           'state.simulink.blockHandle', subsysUddH.Handle);
                if isempty(fcnId)
                    self = [];
                    return
                else
                    % rename it back.
                    isSyncing = getappdata(subsysUddH, 'StateflowIsSyncing');
                    if isempty(isSyncing) || isSyncing == 0
                        % g540332: Sometimes with ME open, we get callbacks
                        % in the middle of syncing from SF to SL. Do not
                        % panic and rename at that time.
                        DAStudio.warning('Stateflow:slinsf:UnsafeRenamingAttempt');
                        subsysUddH.Name = sf('get', fcnId, '.simulink.blockName');
                    end
                end
            end

            self = Stateflow.SLINSF.SimfcnMan(fcnId);
        end
        
        function onSimPrototypeChanged(subsysH)
            % Called when the Simulink prototype has changed. This is
            % called dynamically as ports are
            % renamed/added/deleted/renumbered.
            %
            % When this function is called, we want to modify the Stateflow
            % function prototype so that it matches the prototype expressed
            % in Simulink. "The truth is in Simulink."

            % Only respond to Simulink events if they are not generated via
            % the 'sync' command.
            h = get_param(subsysH, 'Object');
            if getappdata(h, 'StateflowIsSyncing') == true
                return
            end

            self = Stateflow.SLINSF.SimfcnMan.getEventInfo(get_param(subsysH, 'Object'));
            if isempty(self)
                return
            end

            % When a port is deleted before adjusting the S-function
            % inputs/outputs, the S-function block contains a dangling
            % line. Need to delete the line so that input can be connected
            % to.
            Stateflow.SLUtils.deleteAllInvalidLines(self.sfunH);
            self.syncFromSLToSF(false);

            % If there are disconnected lines from the subsystem, then need
            % to toast things.
            if Stateflow.SLUtils.isAnyPortDisconnected(self.subsysH)
                sf('Toast', self.chartId);
            end

            % There are way too many weird ways in which the undo mechanism
            % can be broken when new blocks are added/deleted on the SL
            % side. Just to be on the safe side, just clear the undo stack
            % for now. In the future, we might want to minimize this a bit.
            % g467449
            sf('ClearChartUndoStack', self.chartId);

        end

        function onChildAdded(hSrc, event)
            % Call back for a block being added. This call-back is created
            % by adding a listener in the sync() method above.

            % It might be very tempting to only respond to Inports/Outports
            % being added to the subsystem. However, _any_ block can
            % interfere with SF objects on the undo stack. Therefore, we
            % need to be aggressive here.
            if ~strcmpi(event.child.type, 'block')
                return
            end
            l = handle.listener(event.child, 'NameChangeEvent', @Stateflow.SLINSF.SimfcnMan.onBlockNameChange);
            setappdata(event.child, 'NameChangeListener', l);
            Stateflow.SLINSF.SimfcnMan.onSimPrototypeChanged(hSrc.Handle);
        end

        function onBlockNameChange(hSrc, event) %#ok<INUSD>
            % Triggered when any block is renamed by the user. This
            % callback is installed by us when we create new
            % inports/outports or detect new inports/outports being added.

            % Sometimes when you CTRL-G a set of existing blocks, the
            % blocks still retain their listeners even though they have
            % been moved one level deeper. In this case, remove the
            % listener. 
            grandParentH = hSrc.getParent.Parent;
            if ~strcmpi(get_param(grandParentH, 'MaskType'), 'Stateflow')
                setappdata(hSrc, 'NameChangeListener', []);
                return
            end

            Stateflow.SLINSF.SimfcnMan.onSimPrototypeChanged(hSrc.getParent.Handle);
        end

        function onChildRemoved(hSrc, event) %#ok<INUSD>
            % Call back for a block being removed. This callback is created
            % by adding a listener in the sync() method above. Note that we
            % are being pretty aggressive about responding to all sorts of
            % objects being removed, not just inports/outports. This is
            % because the interaction of the SL actions with the SF undo
            % buffer is just too weird to leave this open.

            % This callback gets triggered when the user does "Restore
            % Library link". At that time, the Simulink block hierarchy
            % seems to be screwed up. Therefore, these two calls are liable
            % to fail. g473807
            try
                parentH = get_param(hSrc.handle, 'Parent');
                get_param(parentH, 'UserData');
            catch ME %#ok<NASGU>
                return
            end

            % Return if we detect that we are unloading (bdclose all)
            self = Stateflow.SLINSF.SimfcnMan.getEventInfo(hSrc);
            if isempty(self)
                return
            end

            Stateflow.SLINSF.SimfcnMan.onSimPrototypeChanged(hSrc.Handle);
        end

    end

end

