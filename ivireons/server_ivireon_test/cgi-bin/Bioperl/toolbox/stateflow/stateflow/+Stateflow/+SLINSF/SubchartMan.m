classdef SubchartMan < Stateflow.SLINSF.SimulinkMan
    % For Mathworks internal use only.
    
    %   Copyright 2009-2010 The MathWorks, Inc.
    
    properties
        subchartH = [];
        subchartId = 0;
        brokenLinkH = [];
        linkStatus = 0;
        linkChartId = 0;
    end
    
    properties(Constant)
        % This needs to be maintained in sync with the enumeration in
        % StateCompManager.hpp
        SUBCHART_LINK_NONE = 0;
        SUBCHART_LINK_RESOLVED = 1;
        SUBCHART_LINK_UNRESOLVED = 2;
        SUBCHART_LINK_INACTIVE = 3;
    end
    
    %% Publicly accessible interface to this class.
    methods
        
        function self = SubchartMan(stateId)
            % Constructor
            
            % Defined in SimulinkMan
            self = self@Stateflow.SLINSF.SimulinkMan(stateId);
            
            if Stateflow.SLUtils.isOnClipboard(self.chartBlockH)
                return
            end
            
            if isempty(self.subsysH)
                return
            end
            
            if strcmpi(get_param(self.subsysH, 'BlockType'), 'Subsystem')
                if strcmp(get_param(self.subsysH, 'MaskType'), 'Stateflow')
                    % New style mask magic.
                    self.subchartH = self.subsysH;
                else
                    % Old style mask magic.
                    self.subchartH = Stateflow.SLUtils.findSystem(self.subsysH, 'MaskType', 'Stateflow');
                end
                
                if ~isempty(self.subchartH)
                    try
                        self.subchartId = sfprivate('block2chart', self.subchartH);
                    catch ME %#ok<NASGU>
                        % Try to refresh the LinkStatus and see if it is
                        % actually a broken link. This can happen under
                        % rare circumstances if the rug was pulled from
                        % under our feet. g587169
                        get_param(self.subchartH, 'LinkStatus');
                        assert(strcmpi(get_param(self.subchartH, 'BlockType'), 'Reference'));
                        
                        self.brokenLinkH = self.subchartH;
                        self.subchartId = 0;
                        self.subchartH = [];
                    end
                    self.linkStatus = Stateflow.SLINSF.SubchartMan.getLinkStatus(self.subchartH);
                    if self.linkStatus == Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_RESOLVED
                        self.linkChartId = get_param(self.subchartH, 'UserData');
                        if isempty(self.linkChartId)
                            self.linkChartId = sf('find', 'all', 'linkchart.handle', self.subchartH);
                        end
                    end
                else
                    self.brokenLinkH = Stateflow.SLUtils.findSystem(self.subsysH, 'BlockType', 'Reference');
                    self.subchartId = 0;
                end
                
            elseif strcmpi(get_param(self.subsysH, 'BlockType'), 'Reference')
                self.brokenLinkH = self.subsysH;
                self.subchartId = 0;
                self.linkStatus = Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_UNRESOLVED;
            end
            
        end
        
        function [subchartId, linkStatus, linkChartId] = sync(self)
            self.ensureSubchartExists;

            subchartId = self.subchartId;
            linkStatus = self.linkStatus;
            linkChartId = self.linkChartId;
        end
        
        function [subchartId, err] = syncForced(self, demuxIndex, throwError, doSync)  %#ok<INUSL>
            % This method is called during simulation.
            
            permQ = self.relaxPermissions;
            
            if doSync
                % The reason for the doSync flag is because we call
                % syncForced from updateConnections also which can itself
                % get called during model load time. At that time, it is
                % harmful to do syncing (especially with isInitializing =
                % false) because renaming subsystems etc at model load time
                % is dangerous.
                self.sync;
            end
            
            subchartId = self.subchartId;
            err = false;
            
            % When a model containing linked atomic subcharts if first
            % loaded, then the subchart might not yet be loaded leading to
            % an empty subchartId.
            if isempty(self.subchartId) || (self.subchartId == 0)
                if throwError
                    sourceBlock = get_param(self.brokenLinkH, 'SourceBlock');
                    slashIdx = findstr(sourceBlock, '/');
                    libName = sourceBlock(1:slashIdx-1);
                    blockName = sourceBlock(slashIdx+1:end);
                    stateName = sf('get', self.stateId, '.name');
                    subviewer = sf('get', self.stateId, '.subviewer');
                    msg = DAStudio.message('Stateflow:subchart:BrokenLinkAtomicSubchart', ...
                        blockName, libName, stateName, self.stateId);
                    
                    sfprivate('construct_error', [subviewer, self.stateId], 'Interface', msg, 0);
                    err = true;
                end
                self.restorePermissions(permQ);
                return
            end
            
            if doSync
                self.syncSubchartProps;
            end
            
            if throwError
                err = self.checkPreliminaryRestrictions;
                if err
                    self.restorePermissions(permQ);
                    return
                end
            end

            % Need to refresh the link so that any new inputs/outputs in a
            % library block are available for connection.
            get_param(self.subsysH, 'LinkStatus');
            
            err = self.connectIOPorts(throwError);
            self.restorePermissions(permQ);
        end
        
        function syncSubchartProps(self)
            if self.linkStatus == self.SUBCHART_LINK_RESOLVED || ...
                    self.subchartId == 0
                return
            end
            
            modelH = bdroot(self.subsysH);
            prevDirty = get_param(modelH, 'Dirty');
            restoreDirty = onCleanup(@() set_param(modelH, 'dirty', prevDirty));
            
            subchartUddH = idToHandle(sfroot, self.subchartId);
            chartUddH = idToHandle(sfroot, self.chartId);
            
            subchartUddH.StrongDataTypingWithSimulink = 1;
            subchartUddH.ChartUpdate = 'INHERITED';
            subchartUddH.StateMachineType = 'Classic';
            
            subchartUddH.EnableNonTerminalStates = chartUddH.EnableNonTerminalStates;
            subchartUddH.NonTerminalMaxCounts = chartUddH.NonTerminalMaxCounts;
            subchartUddH.NonTerminalUnstableBehavior = chartUddH.NonTerminalUnstableBehavior;
        end
        
        function err = checkPreliminaryRestrictions(self)
            err = false;
            if sf('IsChartPlantModel', self.chartId)
                throwPrelimError(self.stateId, 'NoAtomicSubchartInPlantModelChart', ...
                    sf('get', self.stateId, '.name'), self.stateId);
            end
            
            if sf('IsChartPlantModel', self.subchartId)
                throwPrelimError(self.stateId, 'IllegalPlantModelAsAtomicSubchart', ...
                    sf('get', self.stateId, '.name'), self.stateId);
            end
            
            if ~isempty(sf('find', self.chartId, '.stateMachineType', 'MOORE_MACHINE'))
                throwPrelimError(self.stateId, 'NoAtomicSubchartInMooreChart');
            end
            
            if ~isempty(sf('find', self.subchartId, '.stateMachineType', 'MOORE_MACHINE'))
                throwPrelimError(self.stateId, 'NoMooreChartsAsAtomicSubcharts');
            end
            
            if sf('get', self.chartId, '.disableImplicitCasting') == 0
                throwPrelimError(self.stateId, 'IllegalWeakDataTypingMainChart', ...
                    sf('get', self.chartId, '.name'), ...
                    sf('get', self.stateId, '.name'), ...
                    self.chartId);
            end
            
            if sf('get', self.subchartId, '.disableImplicitCasting') == 0
                throwPrelimError(self.stateId, 'IllegalWeakDataTypingSubChart', ...
                    sf('get', self.subchartId, '.name'), self.subchartId);
            end
            
            events = sf('EventsOf', self.subchartId);
            
            inputEvents = sf('find', events, '.scope', 'INPUT_EVENT');
            if ~isempty(inputEvents)
                throwPrelimError(self.stateId, ...
                    'IllegalSubchartInputEvents', ...
                    sf('get', self.stateId, '.name'), self.stateId, ...
                    sf('get', inputEvents(1), '.name'), inputEvents(1));
            end
            
            outputEvents = sf('find', events, '.scope', 'OUTPUT_EVENT');
            if ~isempty(outputEvents)
                throwPrelimError(self.stateId, ...
                    'IllegalSubchartOutputEvents', ...
                    sf('get', self.stateId, '.name'), self.stateId, ...
                    sf('get', outputEvents(1), '.name'), outputEvents(1));
            end
            
            % Local events in the presence of outgoing transitions produce
            % wrong results because we need to exercise the outgoing
            % transition logic from within the subchart. (g641994)
            localEvents = sf('find', events, '.scope', 'LOCAL_EVENT');
            if ~isempty(localEvents)
                srcTrans = sf('get', self.stateId, '.srcTransitions');
                if ~isempty(srcTrans)
                    throwPrelimError(self.stateId, ...
                        'IllegalSubchartLocalEventsWithOuterTransitions', ...
                        sf('get', localEvents(1), '.name'), localEvents(1));
                end
            end
            
            if sf('get', self.chartId, '.enableNonTerminalStates') == false && ...
                    sf('get', self.subchartId, '.enableNonTerminalStates') == true
                throwPrelimError(self.stateId, ...
                    'IllegalSuperStepForAtomicSubchart', ...
                    sf('get', self.stateId, '.name'), self.stateId);
            end
            
            function throwPrelimError(id, key, varargin)
                err = true;
                msg = DAStudio.message(['Stateflow:subchart:' key], varargin{:});
                sfprivate('construct_error', id, 'Interface', msg, 0);
            end
        end
        
        function subchartId = updateConnections(self, demuxIndex)
            % At this point, we are assured that the subsystem itself
            % exists.
            self.syncForced(demuxIndex, false, false);
            subchartId = self.subchartId;
        end
        
        function permQ = relaxPermissions(self)
            % relax permissions all the way up from self.subsysH so that
            % we can begin mucking around with the connections
            
            permQ = {};
            currentH = self.chartBlockH;
            while 1
                if ~isempty(get_param(currentH, 'ReferenceBlock'))
                    break
                end
                
                permQ{end+1} = {currentH, get_param(currentH, 'Permissions')}; %#ok<AGROW>
                set_param(currentH, 'Permissions', 'ReadWrite');
                currentH = get_param(get_param(currentH, 'Parent'), 'Handle');
                if ~strcmpi(get_param(currentH, 'Type'), 'block')
                    break
                end
            end
        end
        
        function restorePermissions(~, permQ)
            for i=1:length(permQ)
                currentH = permQ{i}{1};
                perm = permQ{i}{2};
                
                set_param(currentH, 'Permissions', perm);
            end
        end
        
        function openSubsystem(self)
            instanceH = sf('get', self.chartId, '.activeInstance');
            if instanceH > 0 && ishandle(instanceH)
                activeChartH = instanceH;
            else
                activeChartH = sfprivate('chart2block', self.chartId);
            end
            blockName = sf('get', self.stateId, '.simulink.blockName');
            activeSubsysH = Stateflow.SLUtils.findSystem(activeChartH, 'Name', blockName);
            open_system(activeSubsysH);
            
            % set gcs and gcb to help SLDV users.
            set_param(0, 'CurrentSystem', activeChartH);
            set_param(activeChartH, 'CurrentBlock', blockName);
        end
        
        function id = getSubchartId(self)
            id = self.subchartId;
        end
        
        function scope = getProposedScope(self, symName)
            % If there is an undefined symbol with the name 'symName' in
            % the subchart, what is the best proposed scope for that symbol
            % based on a same named symbol in the containing chart?
            rt = sfroot;
            chartUddH = rt.idToHandle(self.chartId);
            chartDataUddH = chartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Name', symName);
            if ~isempty(chartDataUddH)
                scope = upper(chartDataUddH.scope);
            else
                scope = '';
            end
        end
        
    end
    
    %% Misc methods for UI support.
    methods(Static)
        
        function linkStatus = getLinkStatus(blockH)
            if isempty(blockH)
                linkStatus = Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_UNRESOLVED;
            else
                % See comments in private/slsf.m/blk_copy_and_real_copy for
                % why we are using 'StaticLinkStatus' instead of
                % 'LinkStatus'.
                % WISH: SA: Need to figure out a good test case for this.
                switch (get_param(blockH, 'StaticLinkStatus'))
                    case 'none'
                        linkStatus = Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_NONE;
                    case 'resolved'
                        linkStatus = Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_RESOLVED;
                    case 'inactive'
                        linkStatus = Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_INACTIVE;
                    otherwise
                        linkStatus = Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_NONE;
                end
            end
        end
        
        function sfH = getSubchartState(objUddH)
            % Given a Stateflow.Chart, a Stateflow.LinkChart or a
            % Simulink.SubSystem, get the corresponding Stateflow.State it
            % is bound to.
            
            sfH = [];
            
            if isa(objUddH, 'Stateflow.Chart')
                subsysUddH = objUddH.up;
            elseif isa(objUddH, 'Stateflow.LinkChart')
                subsysUddH = get_param(objUddH.Path, 'Object');
            elseif isa(objUddH, 'Simulink.SubSystem')
                subsysUddH = objUddH;
            else
                assert(false, 'Stateflow:AssertionFailed', 'Unexpected argument to Stateflow.SLINSF.SubchartMan.getSubchartState');
                subsysUddH = [];
            end
            
            if isempty(subsysUddH)
                return;
            end
            
            [yn, parentUddH] = Stateflow.SLINSF.SubchartMan.isUsedAsComponent(subsysUddH.Handle);
            if ~yn
                return
            end
            
            chartId = sfprivate('block2chart', parentUddH.Handle);
            stateIds = sf('get', chartId, '.states');
            stateId = sf('find', stateIds, 'state.simulink.isComponent', 1, ...
                'state.simulink.blockName', subsysUddH.Name);
            
            if ~isempty(stateId)
                r = sfroot;
                sfH = r.idToHandle(stateId);
            end
        end
        
        function [yn, parentUddH] = isUsedAsComponent(arg)
            % arg can either be the full path to the S-Function block
            % inside the Stateflow chart or the handle to the Stateflow
            % chart itself.
            if ~sf('feature', 'subchartComponents')
                yn = false;
                return
            end
            
            subsysUddH = get_param(arg, 'Object');
            if isa(subsysUddH, 'Simulink.SFunction')
                subsysUddH = subsysUddH.up;
            end
            
            parentUddH = subsysUddH.up;
            yn = ~isempty(parentUddH) && isa(parentUddH, 'Simulink.SubSystem') && strcmp(parentUddH.MaskType, 'Stateflow');
        end
        
        function parentUddH = chartGetParentUdi(chartId)
            chartUddH = idToHandle(sfroot, chartId);
            subchartStateUddH = Stateflow.SLINSF.SubchartMan.getSubchartState(chartUddH);
            if isempty(subchartStateUddH)
                % Note the double .up because the first up gives the
                % Simulink.SubSystem which corresponds to the Stateflow
                % mask.
                chartUpH = chartUddH.up;
                if ~isempty(chartUpH)
                    parentUddH = chartUpH.up;
                else
                    parentUddH = [];
                end
            else
                parentUddH = subchartStateUddH.getParent;
            end
        end
        
        function proxyUddH = chartGetDialogProxyUdi(chartId)
            chartUddH = idToHandle(sfroot, chartId);
            subchartStateUddH = Stateflow.SLINSF.SubchartMan.getSubchartState(chartUddH);
            if ~isempty(subchartStateUddH)
                proxyUddH = subchartStateUddH;
            else
                proxyUddH = idToHandle(sfroot, chartId);
            end
        end
        
        function openProps(stateId)
            rt = sfroot;
            h = rt.idToHandle(stateId);
            h.dialog;
            dlg = DAStudio.ToolRoot.getOpenDialogs(h);
            % When the ME is also showing this state, then we get multiple
            % dialog open with the last being the newly opened dialog.
            dlg = dlg(end);
            dlg.setActiveTab('sfStatedlg_Tabs', 1);
        end
        
        function onLinkStatusChange(blockH, realCopyFlag)
            subsysUddH = get_param(blockH, 'Object');
            sfH = Stateflow.SLINSF.SubchartMan.getSubchartState(subsysUddH);
            if ~isempty(sfH)
                if realCopyFlag
                    % Strictly speaking, we could be either inactive or
                    % none at this point. However, Simulink does not
                    % provide us a way to determine what.
                    linkStatus_ = Stateflow.SLINSF.SubchartMan.SUBCHART_LINK_NONE;
                    
                    % At the time Simulink calls slsf when a link break
                    % happens, the block still has a non-empty
                    % 'ReferenceBlock' property. Therefore, doing
                    % block2chart will take us to the library which is
                    % wrong.
                    subchartId_ = sf('get', get_param(blockH, 'UserData'), '.chart');
                else
                    linkStatus_ = Stateflow.SLINSF.SubchartMan.getLinkStatus(blockH);
                    subchartId_ = sfprivate('block2chart', blockH);
                end
                
                if ~realCopyFlag
                    linkChartId_ = get_param(blockH, 'UserData');
                    if isempty(linkChartId_)
                        % This can happen when we load library models which
                        % contain Stateflow charts and the library is not
                        % actually loaded by Stateflow.
                        linkChartId_ = 0;
                    end
                else
                    linkChartId_ = 0;
                end
                sf('SetSubchartLinkStatus', sfH.Id, subchartId_, ...
                    linkChartId_, linkStatus_);
            end
        end
        
        function enableStrongDataTyping(chartId)
            rt = sfroot;
            h = rt.idToHandle(chartId);
            h.view;
            h.Machine.Locked = 0;
            h.Machine.getParent.Lock = 'off';
            dlgsOld = DAStudio.ToolRoot.getOpenDialogs(h);
            h.dialog;
            dlgsNew = DAStudio.ToolRoot.getOpenDialogs(h);
            dlg = setdiff(dlgsNew, dlgsOld);
            dlg.setWidgetValue('sfChartdlg_Use Strong Data Typing with Simulink I/O', true);
        end
    end
    
    %% Methods for converting a state into an atomic subchart
    methods
        
        function cloneState(self, stateUddH, accFromState, moveTopLevelFcns)
            % Given a newly created subchart component, create an internal
            % subchart component which has a single state at the top level
            % which is the stateUddH.
            subchartUddH = idToHandle(sfroot, self.subchartId);
            
            % Copy the state into the state.
            clipboard = Stateflow.Clipboard;
            clipboard.copy(stateUddH);
            clipboard.pasteTo(subchartUddH);
            
            % Gather all the data which the subchart component accesses
            % from the container chart. These symbols need to be replicated
            % on the subchart.
            sfIds = unique(accFromState(1,:));
            sfIds = sf('get', sfIds, 'data.id');
            
            if ~isempty(sfIds)
                sfHandles = idToHandle(sfroot, sfIds);
                
                % Copy the data.
                clipboard.copy(sfHandles);
                clipboard.pasteTo(subchartUddH);
            end
            
            % Convert all newly created local data in the subchart to
            % "import from container"
            subchartDataIds = sf('DataOf', subchartUddH.Id);
            subchartLocalDataIds = sf('find', subchartDataIds, '.scope', 'LOCAL_DATA');
            sf('set', subchartLocalDataIds, '.scope', 'DATA_STORE_MEMORY_DATA');
            
            % At this point, subchartUddH has a single top-level state.
            % This state needs to be removed and all the internal stuff
            % moved to one level up.
            innerStateH = subchartUddH.find('-isa', 'Stateflow.State', '-depth', 1);
            
            % remove any grouping/subchartedness
            innerStateH.IsSubchart = 0;
            innerStateH.IsGrouped = 0;
            
            hasHistoryJunction = ~isempty(innerStateH.find('-isa', 'Stateflow.Junction', 'Type', 'HISTORY', '-depth', 1));
            hasTrivialLabel = isequal(innerStateH.labelString, '?') || ~isempty(regexp(innerStateH.labelString, '^\w*$', 'once'));
            hasTransitionsTouchingState = ~isempty(innerStateH.find('-isa', 'Stateflow.Transition', 'Source', innerStateH, '-or', 'Destination', innerStateH));
            
            if ~hasHistoryJunction
                % If the top-level state has a history junction, then
                % moving its data up means it gets initialized every time
                % rather than only once. (g598185)
                Stateflow.SLINSF.SubchartMan.moveDataEvents(innerStateH, subchartUddH);
            end
            
            if hasTrivialLabel && ~hasHistoryJunction && ~hasTransitionsTouchingState
                % preserve the semantics by setting the decomposition of
                % the chart to be the decomposition of the state
                subchartUddH.Decomposition = innerStateH.Decomposition;
                delete(innerStateH);
            elseif moveTopLevelFcns
                % line all the sub-functions up along the right of the
                % inner state.
                
                innerStatePos = innerStateH.Position;
                left = innerStatePos(1) + innerStatePos(3) + 10;
                top = innerStatePos(2);
                
                subFcns = sf('FunctionsOf', innerStateH.Id);
                subFcnHandles = idToHandle(sfroot, subFcns);
                for i=1:length(subFcnHandles)
                    fcnH = subFcnHandles(i);
                    
                    pos = fcnH.Position;
                    % before we move, group so that all the internal
                    % contents move with it.
                    if isa(fcnH, 'Stateflow.Function')
                        isGrouped = fcnH.isGrouped;
                        fcnH.isGrouped = 1;
                    end
                    
                    pos = [left, top, pos(3:4)];
                    fcnH.Position = pos;
                    
                    if isa(fcnH, 'Stateflow.Function')
                        fcnH.isGrouped = isGrouped;
                    end
                    
                    top = top + pos(4) + 20;
                end
            end
            
            self.calculateDefaultBindings;
            self.sync;
            self.connectIOPorts(false);
            subchartUddH.Visible = 0;
            
        end
        
        function calculateDefaultBindings(self)
            if isempty(self.subchartId)
                return
            end
            
            rt = sfroot;
            outerChartUddH = rt.idToHandle(self.chartId);
            innerChartUddH = rt.idToHandle(self.subchartId);
            
            calculateBindingsForScope('Input');
            calculateBindingsForScope('Output');
            calculateBindingsForDSM;
            
            function calculateBindingsForScope(scope)
                outerDataH = outerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', scope);
                innerDataH = innerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', scope);
                
                calculateBindingsForData(innerDataH, outerDataH);
            end
            
            function calculateBindingsForDSM
                innerDataH = innerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', 'Data Store Memory');
                outerDataH = [outerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', 'Data Store Memory');
                    outerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', 'Local')];
                
                calculateBindingsForData(innerDataH, outerDataH);
            end
            
            function calculateBindingsForData(innerDataH, outerDataH)
                outerDataNames = cell(size(outerDataH));
                for ii=1:length(outerDataH)
                    outerDataNames{ii} = outerDataH(ii).Name;
                end
                
                innerDataNames = cell(size(innerDataH));
                for ii=1:length(innerDataH)
                    innerDataNames{ii} = innerDataH(ii).Name;
                end
                
                bindingSpec = cell(size(innerDataNames));
                for i=1:length(innerDataNames)
                    idx = strmatch(innerDataNames{i}, outerDataNames, 'exact');
                    if ~isempty(idx)
                        bindingSpec{i} = sprintf('%d %s\n', innerDataH(i).SSIdNumber, outerDataNames{idx});
                    else
                        bindingSpec{i} = sprintf('%d\n', innerDataH(i).SSIdNumber);
                    end
                end
                
                if ~isempty(bindingSpec)
                    bindingSpecTxt = horzcat(bindingSpec{:});
                else
                    bindingSpecTxt = '';
                end
                
                origBinding = sf('get', self.stateId, '.simulink.binding');
                newBinding = [origBinding bindingSpecTxt];
                sf('set', self.stateId, '.simulink.binding', newBinding);
            end
            
        end
        
        function ids = getSymbolsAccessed(self)
            % returns a 1xN vector of all chart level data objects which
            % are used within the subchart.
            
            [~, ~, ~, subToMainIdMap] = self.getBindingMap;
            
            subchartDataIds = subToMainIdMap.keys;
            ids = zeros(size(subchartDataIds));
            for i=1:length(subchartDataIds)
                subchartDataId = subchartDataIds{i};
                chartDataId = subToMainIdMap(subchartDataId);
                ids(i) = chartDataId;
            end           
        end
        
    end
    
    methods(Static)
        
        function [numWarnings, needsDSMTransforms, accFromState, accToState] = checkSubchartRestrictions(outerStateH, showMsgBox)
            if nargin < 2 || isempty(showMsgBox)
                showMsgBox = 1;
            end
            
            numWarnings = 0;
            needsDSMTransforms = false;
            accFromState = [];
            accToState = [];
            
            stateId = outerStateH.Id;
            chartId = outerStateH.chart.Id;
            
            slsfnagctlr('Clear');
            slsfnagctlr('Dismiss');
            
            numWarnings = checkPreliminaryChartRestrictions + numWarnings;
            if numWarnings > 0
                slsfnagctlr;
                return
            end
            
            exportChartFcns = sf('get', chartId, '.exportChartFunctions');
            
            MACHINE_ISA = sf('get', 'default', 'machine.isa');
            CHART_ISA = sf('get', 'default', 'chart.isa');
            STATE_ISA = sf('get', 'default', 'state.isa');
            DATA_ISA = sf('get', 'default', 'data.isa');
            FUNC_STATE = 2;
            
            [accFromState, accToState, crossing] = sf('GetExternalAccesses', outerStateH.Id);
            collectSymbolsFromSubcharts;
            
            numWarnings = checkAccessFromState(accFromState) + numWarnings;
            numWarnings = checkAccessToState(accToState) + numWarnings;
            numWarnings = checkCrossingTransitions(crossing) + numWarnings;
            numWarnings = checkStatesWithOutput() + numWarnings;
            
            if numWarnings == 0 && showMsgBox
                msgbox('No violations of subchart restrictions found.', 'Check Atomic Subchart Restrictions');
            else
                slsfnagctlr;
            end
            
            function numWarnings = checkPreliminaryChartRestrictions
                numWarnings = 0;
                
                if ~isempty(sf('find', chartId, '.stateMachineType', 'MOORE_MACHINE'))
                    msg = DAStudio.message('Stateflow:subchart:NoAtomicSubchartInMooreChart');
                    sfprivate('construct_warning', chartId, 'Parse', msg);
                    numWarnings = numWarnings + 1;
                end
                
                if ~isempty(sf('find', chartId, 'chart.updateMethod', 'CONTINUOUS'))
                    msg = DAStudio.message('Stateflow:subchart:ConvertErrorContinuousChart');
                    sfprivate('construct_warning', chartId, 'Parse', msg);
                    numWarnings = numWarnings + 1;
                end
                
                if sf('get', chartId, 'chart.disableImplicitCasting') == 0
                    msg = DAStudio.message('Stateflow:subchart:ConvertErrorStrongDataTyping', chartId);
                    sfprivate('construct_warning', chartId, 'Parse', msg);
                    numWarnings = numWarnings + 1;
                end
                
            end
            
            function collectSymbolsFromSubcharts
                substateIds = sf('SubstatesIn', stateId);
                atomicSubchartIds = sf('find', substateIds, 'state.simulink.isComponent', 1);
                for i=1:length(atomicSubchartIds)
                    subchartMan = Stateflow.SLINSF.SubchartMan(atomicSubchartIds(i));
                    ids = subchartMan.getSymbolsAccessed;
                    
                    if ~isempty(ids)
                        ids = [ids; [chartId; stateId]*ones(size(ids))]; %#ok<AGROW>
                    end
                    accFromState = [accFromState, ids]; %#ok<AGROW>
                end
            end
            
            function pushWarning(sourceId, msgId, varargin)
                msg = DAStudio.message(msgId, varargin{:});
                sfprivate('construct_warning', sourceId, 'Parse', msg);
            end
            
            function name = fullNameOf(objId)
                name = sf('FullNameOf', objId, chartId, '.');
            end
            
            function numWarnings = checkAccessFromState(accFromState)
                numWarnings = 0;
                for i=1:size(accFromState, 2)
                    objId = accFromState(1,i);
                    containerId = accFromState(2,i);
                    userId = accFromState(3,i);
                    
                    if ~isAccessibleFromState(objId, containerId, userId)
                        numWarnings = numWarnings + 1;
                    end
                end
            end
            
            function numWarnings = checkAccessToState(accToState)
                numWarnings = 0;
                for i=1:size(accToState, 2)
                    objId = accToState(1,i);
                    containerId = accToState(2,i);
                    userId = accToState(3,i);
                    
                    warn = 0;
                    if containerId ~= stateId
                        warn = 1;
                    else
                        objIsa = sf('get', objId, '.isa');
                        if ~(objIsa == STATE_ISA && sf('get', objId, '.type') == FUNC_STATE)
                            warn = 1;
                        end
                    end
                    if warn
                        numWarnings = numWarnings + 1;
                        objName = sf('FullName', objId, chartId, '.');
                        pushWarning(userId, 'Stateflow:subchart:ConvertErrorInvalidAccessToNonTopLevelFcn', objId, objName, userId)
                    end
                end
            end
            
            function yn = isAccessibleFromState(objId, containerId, userId)
                yn = 1;
                
                containerIsa = sf('get', containerId, '.isa');
                if ~(containerIsa == MACHINE_ISA || (containerIsa == CHART_ISA && containerId == chartId))
                    pushWarning(userId, 'Stateflow:subchart:ConvertErrorAccessToNonChartLevelObj', fullNameOf(objId), objId, fullNameOf(userId));
                    yn = 0;
                    return;
                end
                
                objIsa = sf('get', objId, '.isa');
                if objIsa == STATE_ISA
                    if ~exportChartFcns
                        pushWarning(userId, 'Stateflow:subchart:ConvertErrorTopLevelFcnNotExported', fullNameOf(objId), objId, fullNameOf(userId), sf('get', chartId, '.name'), chartId);
                        yn = 0;
                    end
                elseif objIsa == DATA_ISA
                    isLocal = sf('get', objId, '.scope') == 0; % 0 is local
                    if isLocal
                        yn = canLocalBeTransformedSafely(objId, userId);
                    else
                        yn = 1;
                    end
                else
                    pushWarning(userId, 'Stateflow:subchart:ConvertErrorAccessToNonChartLevelObj', fullNameOf(objId), objId, fullNameOf(userId));
                    yn = 0;
                end
                
            end
            
            function yn = canLocalBeTransformedSafely(dataId, userId)
                yn = 1;
                
                rt = sfroot;
                dataH = idToHandle(rt, dataId);
                
                isSimpleType = strcmpi(dataH.Props.Type.Method, 'built-in');
                if ~isSimpleType || strcmp(dataH.DataType, 'ml')
                    pushWarning(userId, 'Stateflow:subchart:ConvertErrorAccessToNonSimpleType', dataH.Name, dataH.Id, fullNameOf(userId), userId);
                    yn = 0;
                end
                
                sizeSpec = dataH.Props.Array.Size;
                if ~isempty(sizeSpec)
                    re_number = '\s*[-+]?\s*(\d+(\.\d*)?|\.\d+)(e[-+]?\d+)?\s*';
                    re_numbers = [ re_number '([\s,]' re_number ')*'];
                    re_spec = ['^\s*(\[)?' re_numbers '(?(1)\])\s*$'];
                    if isempty(regexp(sizeSpec, re_spec, 'once'))
                        pushWarning(userId, 'Stateflow:subchart:ConvertErrorAccessToNonStaticSize', sizeSpec, dataH.Name, dataH.Id);
                        yn = 0;
                    end
                end
                
                if strcmpi(dataH.Props.Complexity, 'on')
                    pushWarning(userId, 'Stateflow:subchart:ConvertErrorAccessToComplexLocal', dataH.Name, dataH.Id, userId);
                    yn = 0;
                end
            end
            
            function numWarnings = checkCrossingTransitions(crossingTransitions)
                if ~isempty(sf('find', stateId, 'state.superState', 'SUBCHART'))
                    subViewer = sf('get', stateId, '.subviewer');
                    allTrans = sf('TransitionsOf', subViewer);
                    
                    subSrc = sf('find', allTrans, '~.subLink.before', 0, '.src.id', stateId);
                    subDst = sf('find', allTrans, '~.subLink.next', 0, '.dst.id', stateId);
                    crossingTransitions = [crossingTransitions, subSrc, subDst];
                end
                
                numWarnings = 0;
                for i=1:length(crossingTransitions)
                    trans = crossingTransitions(i);
                    pushWarning(trans, 'Stateflow:subchart:ConvertErrorSuperTransition', trans);
                    numWarnings = numWarnings + 1;
                end
            end
            
            function numWarnings = checkStatesWithOutput
                substateIds = sf('SubstatesIn', stateId);
                statesWithOutput = sf('find', substateIds, '~state.outputData', 0);
                numWarnings = length(statesWithOutput);
                for i=1:length(statesWithOutput)
                    substateId = statesWithOutput(i);
                    substateName = sf('get', substateId, '.name');
                    msg = DAStudio.message('Stateflow:subchart:ConvertErrorStateWithOutputActivity', substateName, substateId);
                    sfprivate('construct_warning', substateId, 'Parse', msg);
                end
            end
        end
        
        function newStateH = createSubchart(stateH)
            % Given an "atomic" state which has valid data sharing with the
            % parent, create a subchart component out of it.
            
            [numWarnings, ~, accFromState, accToState] = Stateflow.SLINSF.SubchartMan.checkSubchartRestrictions(stateH, 0);
            if numWarnings > 0
                newStateH = [];
                return;
            end
            
            waitH = waitbar(0, DAStudio.message('Stateflow:subchart:PleaseWaitForConversion'));
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('MESleepEvent');
            
            siblingIds = Stateflow.SLINSF.SubchartMan.cacheStateInformation(stateH);
            
            % First convert the state into a subchart so that copying it
            % brings over the entire hierarchy. It is also important to do
            % it before we create the atomic subchart so that the
            % exec-order of the children is not changed (g593222)
            stateH.IsSubchart = 1;
            
            % create a new empty atomic subchart at the same position with
            % the same name.
            subviewerH = stateH.subviewer;
            newStateH = Stateflow.AtomicSubchart(subviewerH);
            newStateH.Name = stateH.Name;
            newStateH.Position = stateH.Position;
            
            % Clone the original state contents into the new empty atomic
            % subchart.
            waitbar(0.1, waitH);
            subchartObj = Stateflow.SLINSF.SubchartMan(newStateH.Id);
            subchartObj.cloneState(stateH, accFromState, ~isempty(accToState));
            waitbar(0.8, waitH);
            
            Stateflow.SLINSF.SubchartMan.transferStateInformation(...
                stateH, newStateH, siblingIds);
            
            flush(Stateflow.Clipboard);
            ed.broadcastEvent('MEWakeEvent');
            close(waitH);
        end
        
        function siblingIds = cacheStateInformation(srcH)
            % Cache all the execution orders of the states belonging to the
            % parent. This seems to work even if the parent has exclusive
            % or decomposition. We are relying on siblingIds being sorted
            % according to execution order.
            parentH = srcH.getParent;
            siblingIds = sf('SubstatesOf', parentH.Id);
        end
        
        function transferStateInformation(srcH, dstH, siblingIds)
            siblingIds(siblingIds == srcH.Id) = dstH.Id;
            sf('TransferStateInformation', srcH.Id, dstH.id);
            
            % Remove the redness of dstH
            subviewerH = dstH.subviewer;
            sf('Select', subviewerH.Id, dstH.Id);
            
            chartH = srcH.Chart;
            outTransitions = chartH.find('-isa', 'Stateflow.Transition', 'Source', srcH);
            inTransitions = chartH.find('-isa', 'Stateflow.Transition', 'Destination', srcH);
            
            % Sort out transitions according to execution order
            execOrders = zeros(size(outTransitions));
            for i=1:length(outTransitions)
                execOrders(i) = outTransitions(i).ExecutionOrder;
            end
            [~, idx] = sort(execOrders);
            outTransitions = outTransitions(idx);
            
            % Reconnect all the incoming/outgoing transitions to the new
            % component. We skip over the inner transitions which are
            % connected on the inside to the state.
            inTransitions(~ishandle(inTransitions)) = [];
            for i=1:length(inTransitions)
                if inTransitions(i).getParent.Id ~= srcH.Id
                    inTransitions(i).Destination = dstH;
                end
            end
            
            outTransitions(~ishandle(outTransitions)) = [];
            for i=1:length(outTransitions)
                if outTransitions(i).getParent.Id ~= srcH.Id
                    outTransitions(i).Source = dstH;
                    if chartH.UserSpecifiedStateTransitionExecutionOrder
                        outTransitions(i).ExecutionOrder = i;
                    end
                end
            end
            
            delete(srcH);
            
            % Restore execution order of siblings/self.
            sf('set', siblingIds, '.executionOrder', (1:length(siblingIds))');
        end
        
        function moveDataEvents(srcUddH, dstUddH)
            clipboard = Stateflow.Clipboard;
            innerObjs = [srcUddH.find('-isa', 'Stateflow.Data', '-depth', 1);
                srcUddH.find('-isa', 'Stateflow.Event', '-depth', 1)];
            
            if ~isempty(innerObjs)
                % Stateflow.Clipboard does not flush the clipboard if an
                % empty copy operation is done. We end up pasting the thing
                % which was copied over previously.
                clipboard.copy(innerObjs);
                clipboard.pasteTo(dstUddH);
                for ii=1:length(innerObjs)
                    delete(innerObjs(ii));
                end
            end
        end
        
    end
    
    %% Methods for converting an atomic subchart into an ordinary subchart
    methods
        
        function newCloneStateUddH = copyIntoNormalState(self)
            atomicSubchartUddH = idToHandle(sfroot, self.stateId);
            
            % first make sure that all the inputs/outputs have trivial
            % bindings by refactoring the existing diagram (if necessary)
            [~, innerData, ~, subToMainIdMap] = self.getBindingMap;
            subchartDataIds = subToMainIdMap.keys;
            for i=1:length(subchartDataIds)
                dataId = subchartDataIds{i};
                outerDataId = subToMainIdMap(dataId);
                dataName = sf('get', outerDataId, '.name');
                Stateflow.SLINSF.SubchartMan.refactorData(self.subchartId, dataId, dataName);
            end
            % Delete all bound data from the chart. The rest should be
            % transferred over to the new state.
            innerDataUddH = idToHandle(sfroot, innerData);
            for i=1:length(innerDataUddH)
                delete(innerDataUddH(i));
            end
            
            % The subviewer in which the current Stateflow.AtomicSubchart
            % lives.
            subviewerUddH = atomicSubchartUddH.SubViewer;
            
            % Create a wrapper state which contains all the stuff inside
            % the original chart.
            sf('Open', self.subchartId);
            limits = sf('get', self.subchartId, '.subviewS.objectLimits');
            
            innerChartUddH = idToHandle(sfroot, self.subchartId);
            
            newInnerState = Stateflow.State(innerChartUddH);
            width = limits(2)-limits(1);
            height = limits(4)-limits(3);
            newInnerState.Position = [limits(1)-10, limits(3)-10, width+20, height+20];
            
            % Make it grouped so that copying it will copy over the
            % contents inside it.
            newInnerState.IsGrouped = 1;
            
            % Create a new state inside the present subviewer
            newCloneStateUddH = Stateflow.State(subviewerUddH);
            newCloneStateUddH.IsSubchart = 1;
            newCloneStateUddH.Name = sf('get', self.stateId, '.name');
            newCloneStateUddH.Position = atomicSubchartUddH.Position;
            newCloneStateUddH.Decomposition = innerChartUddH.Decomposition;
            
            % Copy over the rest of the data/events from the atomic
            % subchart to the new state.
            Stateflow.SLINSF.SubchartMan.moveDataEvents(innerChartUddH, newCloneStateUddH);
            
            % Copy the inner state into the clone state.
            clipboard = Stateflow.Clipboard;
            clipboard.copy(newInnerState);
            clipboard.pasteTo(newCloneStateUddH);
            
            % delete the temporary state at the top-level inside
            % newCloneStateUddH.
            tempStateH = newCloneStateUddH.getHierarchicalChildren;
            tempStateH.IsGrouped = 0;
            delete(tempStateH);
            
            % If there is a single state at the top-level even now, then we
            % can move its label to the top-level and delete it. This
            % prevents an extra state seeming to appear
            % g602397
            newTopStates = newCloneStateUddH.find('-isa', 'Stateflow.State', '-depth', 1);
            newTopAscs = newCloneStateUddH.find('-isa', 'Stateflow.AtomicSubchart', '-depth', 1);
            if length(newTopStates) == 2 && isempty(newTopAscs)
                topState = newTopStates(2);
                outTransitions = newCloneStateUddH.find('-isa', 'Stateflow.Transition', 'Source', topState);
                inTransitions = newCloneStateUddH.find('-isa', 'Stateflow.Transition', 'Destination', topState);
                
                % If there are any incoming/outgoing transitions on this
                % top-level state, we cannot remove the state.
                if isempty(outTransitions) && isempty(inTransitions)
                    newCloneStateUddH.labelString = topState.labelString;
                    Stateflow.SLINSF.SubchartMan.moveDataEvents(topState, newCloneStateUddH);
                    
                    topState.IsSubchart = 0;
                    topState.IsGrouped = 0;
                    delete(topState);
                end
            end
        end
        
        function refactorDataBinding(self, refactorId, newName)
            [~, subchartDataIds, subToMainNameMap, ~] = self.getBindingMap;
            
            origName = sf('get', refactorId, '.name');
            ssIdSpec = cell(size(subchartDataIds));
            for i=1:length(subchartDataIds)
                subchartDataId = subchartDataIds(i);
                subchartDataName = sf('get', subchartDataId, '.name');
                mainName = subToMainNameMap(subchartDataName);
                if isequal(origName, mainName)
                    mainName = newName;
                end
                
                ssid = sf('get', subchartDataId, '.ssIdNumber');
                ssIdSpec{i} = sprintf('%d %s\n', ssid, mainName);
            end
            
            newBindingStr = [ssIdSpec{:}];
            sf('set', self.stateId, '.simulink.binding', newBindingStr);
        end
        
        function err = errorCheckBindingsForUnatomicizing(self)
            err = false;
            [~, subchartDataIds, subToMainNameMap] = self.getBindingMap;
            
            slsfnagctlr('Clear');
            slsfnagctlr('Dismiss');
            
            requireNoEml = false;
            nonTrivialMappingLHS = '';
            nonTrivialMappingRHS = '';
            
            for i=1:length(subchartDataIds)
                dataId = subchartDataIds(i);
                dataName = sf('get', dataId, '.name');
                mainName = subToMainNameMap(dataName);
                if isempty(regexp(mainName, '^[a-zA-Z_]\w*$', 'once'))
                    % Mapped to a non-word. This might happen with
                    % parameters. In the presence of such mappings,
                    % definitely, do NOT unatomicize the subchart as it
                    % leads to very confusing end-results.
                    % This leads to all sorts of very confusing behaviors.
                    
                    msg = DAStudio.message('Stateflow:subchart:UnatomInvalidParamBindings', dataName, mainName);
                    sfprivate('construct_warning', dataId, 'Parse', msg);
                    err = true;
                    return
                end
                
                if ~isequal(mainName, dataName)
                    nonTrivialMappingLHS = dataName;
                    nonTrivialMappingRHS = mainName;
                    requireNoEml = true;
                end
            end
            
            if requireNoEml
                allFcns = sf('FunctionsIn', self.subchartId);
                emlFcns = sf('find', allFcns, '.eml.isEML', 1);
                
                if ~isempty(emlFcns)
                    emlFcnId = emlFcns(1);
                    emlFcnName = sf('get', emlFcnId, '.name');                    
                    msg = DAStudio.message('Stateflow:subchart:UnatomEmlFcns', ...
                        nonTrivialMappingLHS, ...
                        nonTrivialMappingRHS, ...
                        emlFcnName, emlFcnId);

                    sfprivate('construct_warning', self.stateId, 'Parse', msg);
                    err = true;
                end
            end
        end
        
    end
    
    methods(Static)
        
        function newStateUddH = convertToNormalSubchart(atomicSubchartUddH)
            newStateUddH = [];
            
            subchartMan = Stateflow.SLINSF.SubchartMan(atomicSubchartUddH.Id);
            if isempty(subchartMan.subchartH)
                msgbox(DAStudio.message('Stateflow:subchart:CannotUnatomicBrokenLink'), DAStudio.message('Stateflow:subchart:ConvertErrorTitle'));
                return;
            end
            
            linkStatStr = get_param(subchartMan.subchartH, 'StaticLinkStatus');
            if strcmp(linkStatStr, 'resolved')
                msgbox(DAStudio.message('Stateflow:subchart:CannotUnatomicLinkedSubchart'), DAStudio.message('Stateflow:subchart:ConvertErrorTitle'));
                return
            end

            err = subchartMan.errorCheckBindingsForUnatomicizing;
            if err
                slsfnagctlr;
                return
            end
            
            % Only unatomicize if the following conditions are met:
            % 1. If all data mappings are trivial, then all is well.
            % 2. If there are parameter mappings which are expressions (not
            % just mapping to other parameters), then bail out because its
            % very risky to unatomicize.
            % 3. If there are non-parameter mappings which are non-trivial,
            % then its OK to unatomicize as long as there are no EML
            % functions in the subchart because we will not be able to
            % refactor them.
            % 4. After unatomicizing, we might have to create parameter and
            % DSM data at the container chart level if they previously did
            % not exist.
            
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('MESleepEvent');
            
            siblingIds = ...
                Stateflow.SLINSF.SubchartMan.cacheStateInformation(atomicSubchartUddH);
            
            newStateUddH = subchartMan.copyIntoNormalState;
            
            Stateflow.SLINSF.SubchartMan.transferStateInformation(...
                atomicSubchartUddH, newStateUddH, siblingIds);
            
            flush(Stateflow.Clipboard);
            ed.broadcastEvent('MEWakeEvent');
            
        end
        
        function refactorData(chartId, refactorId, newName)
            
            refactorAstUses;
            refactorAtomicSubchartUses;
            
            function refactorAstUses
                % create a map from the use Ids to the uses.
                uses = containers.Map(0, [0 0 0]);
                uses.remove(0);
                
                % Traverse all ASTs within the chart finding all uses of
                % refactorId.
                Stateflow.Ast.visitAllAstsInChart(chartId, @traverseAstForUse);
                
                userIds = uses.keys;
                for i=1:length(userIds)
                    userId = userIds{i};
                    
                    % get all uses of refactorId within this userId.
                    usesWithin = uses(userId);
                    % sort by starting index. We sort in descending order so
                    % that the last use of the id comes first in the list. This
                    % way when we modify the labelString, the preceding indices
                    % stay valid.
                    if ~isempty(usesWithin)
                        [~, idx] = sort(usesWithin(:,2), 1, 'descend');
                        usesWithin = usesWithin(idx, :);
                    end
                    
                    label = sf('get', userId, '.labelString');
                    
                    % Replace all uses of refactorId within the label-string.
                    for j=1:size(usesWithin, 1)
                        startPos = usesWithin(j, 1);
                        endPos = usesWithin(j, 2);
                        
                        label = [label(1:startPos-1), newName, label(endPos+1:end)];
                    end
                    
                    sf('set', userId, '.labelString', label);
                end
                
                function traverseAstForUse(userId, ast)
                    if isa(ast, 'Stateflow.Ast.Id')
                        usedId = ast.id;
                        if usedId == refactorId
                            startPos  = ast.treeStart;
                            
                            % g594295: In the presence of qualified
                            % identifiers (which can happen with struct
                            % refs), only refactor the first bit.
                            snippet = ast.sourceSnippet;
                            firstWord = regexp(snippet, '\w+', 'once', 'match');
                            endPos = startPos + length(firstWord) - 1;
                            
                            % Loop grows unbounded...
                            userUses = [];
                            if uses.isKey(userId)
                                userUses = uses(userId);
                            end
                            userUses(end+1,:) = [startPos, endPos];
                            uses(userId) = userUses;
                        end
                    end
                    
                    % make recursive call to analyze all child ASTs.
                    childAsts = ast.children;
                    for jj=1:length(childAsts)
                        traverseAstForUse(userId, childAsts{jj});
                    end
                end
                
            end
            
            function refactorAtomicSubchartUses
                substateIds = sf('SubstatesIn', chartId);
                atomicSubchartIds = sf('find', substateIds, 'state.simulink.isComponent', 1);
                for i=1:length(atomicSubchartIds)
                    subchartMan = Stateflow.SLINSF.SubchartMan(atomicSubchartIds(i));
                    subchartMan.refactorDataBinding(refactorId, newName);
                end
            end
            
        end
        
    end
    
    %% Methods for menu items and menu actions.
    methods(Static)
        
        function schemas = getContextMenu
            if sf('feature', 'subchartComponents')
                schemas = {@Stateflow.SLINSF.SubchartMan.editBindingMenu, ...
                    @Stateflow.SLINSF.SubchartMan.checkSubchartRestrictionsMenu};
            else
                schemas = {};
            end
        end
        
        function schema = linkOptionsMenu(callbackinfo)
            selection = callbackinfo.getSelection;
            
            schema = sl_container_schema;
            schema.label = DAStudio.message('Stateflow:subchart:LinkOptionsMenuLabel');
            schema.childrenFcns = {@navigateToLinkMenu, ...
                @disableOrBreakLinkMenu, ...
                @resolveLinkMenu};
            
            if length(selection) == 1 && isa(selection, 'Stateflow.AtomicSubchart')
                
                subchartMan = Stateflow.SLINSF.SubchartMan(selection.Id);
                linkStatStr = get_param(subchartMan.subchartH, 'StaticLinkStatus');
                
                if ~isempty(linkStatStr) && ~strcmpi(linkStatStr, 'none') && ~strcmpi(linkStatStr, 'unresolved')
                    schema.state = 'Enabled';
                else
                    schema.state = 'Disabled';
                end
            else
                schema.state = 'Hidden';
            end
            
            function schema = navigateToLinkMenu(~)
                schema = sl_action_schema;
                schema.label = DAStudio.message('Stateflow:subchart:GotoLibraryBlockMenuLabel');
                schema.callback = @navigateToLinkAction;
            end
            
            function navigateToLinkAction(callbackinfo)
                sfH = callbackinfo.getSelection;
                subchartMan = Stateflow.SLINSF.SubchartMan(sfH.Id);
                Stateflow.SLUtils.gotoLibraryLink(subchartMan.subchartH);
            end
            
            function schema = disableOrBreakLinkMenu(~)
                schema = sl_action_schema;
                switch (linkStatStr)
                    case 'inactive'
                        schema.label = DAStudio.message('Stateflow:subchart:BreakLinkMenuLabel');
                    case 'resolved'
                        schema.label = DAStudio.message('Stateflow:subchart:DisableLinkMenuLabel');
                end
                schema.callback = @(cbInfo) Stateflow.SLINSF.SubchartMan.disableLinkAction(cbInfo.getSelection);
            end
            
            function schema = resolveLinkMenu(~)
                schema = sl_action_schema;
                schema.label = DAStudio.message('Stateflow:subchart:ResolveLinkMenuLabel');
                schema.callback = @(cbInfo) Stateflow.SLINSF.SubchartMan.resolveLinkAction(cbInfo.getSelection);
                if ~strcmpi(linkStatStr, 'inactive')
                    schema.state = 'Disabled';
                end
            end
            
        end
        
        % The various library link actions are exposed as static class
        % methods for testing purposes.
        function disableLinkAction(sfH)
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('MESleepEvent');
            
            subchartMan = Stateflow.SLINSF.SubchartMan(sfH.Id);
            linkStatStr = get_param(subchartMan.subchartH, 'StaticLinkStatus');
            
            switch (linkStatStr)
                case 'inactive'
                    set_param(subchartMan.subchartH, 'LinkStatus', 'none');
                case 'resolved'
                    set_param(subchartMan.subchartH, 'LinkStatus', 'inactive');
            end
            
            Stateflow.SLINSF.SubchartMan.refreshSubchartIcon(sfH);
            
            ed.broadcastEvent('MEWakeEvent');
        end
        
        function resolveLinkAction(sfH)
            subchartMan = Stateflow.SLINSF.SubchartMan(sfH.Id);
            
            subchartName = getfullname(subchartMan.subchartH);
            modelName = bdroot(subchartName);
            editedlinkstool('Create', modelName, subchartName);
        end
        
        function refreshSubchartIcon(sfH)
            sf('RefreshSubchartIcon', sfH.Id);
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent', sfH);
        end
        
        function schema = editBindingMenu(callbackinfo)
            selection = callbackinfo.getSelection;
            
            schema = sl_action_schema;
            schema.label = DAStudio.message('Stateflow:subchart:EditSubchartMappingsMenuLabel');
            schema.callback = @editBinding;
            if length(selection) == 1 && isa(selection, 'Stateflow.AtomicSubchart')
                schema.state = 'Enabled';
            else
                schema.state = 'Hidden';
            end
            
            function editBinding(callbackinfo)
                selection = callbackinfo.getSelection;
                Stateflow.SLINSF.SubchartMan.openProps(selection.Id);
            end
            
        end
        
        function schema = makeContentsSubchartMenu(cbInfo)
            selection = cbInfo.getSelection;
            
            schema = DAStudio.ToggleSchema;
            schema.label = DAStudio.message('Stateflow:subchart:AtomicSubchartedContextMenuOption');
            schema.callback = @(cbInfo) toggleAtomicness(selection);
            
            if length(selection) == 1 && sf('feature', 'subchartComponents')
                schema.state = 'Enabled';
                if isa(selection, 'Stateflow.State')
                    schema.checked = 'Unchecked';
                elseif isa(selection, 'Stateflow.AtomicSubchart')
                    schema.checked = 'Checked';
                else
                    schema.state = 'Hidden';
                end
            else
                schema.state = 'Hidden';
            end
            
            function toggleAtomicness(obj)
                if isa(obj, 'Stateflow.State')
                    Stateflow.SLINSF.SubchartMan.createSubchart(obj);
                else
                    Stateflow.SLINSF.SubchartMan.convertToNormalSubchart(obj);
                end
            end
        end
        
    end
    
    %% Methods for showing a cool binding editor table in the state dialog.
    methods(Static)
        
        function bindingTab = getBindingTabSchema(h)
            subchartMan = Stateflow.SLINSF.SubchartMan(h.Id);
            bindingTab = subchartMan.getBindingTabSchemaLocal;
        end
        
        function toggleScopeBindings(dialog, scope)
            tableTag = ['sfStatedlg_BindingTable_' scope];
            visible = dialog.isVisible(tableTag);
            dialog.setVisible(tableTag, ~visible);
            
            paddingTag = ['sfStatedlg_BindingTable_Padding_' scope];
            dialog.setVisible(paddingTag, ~visible);
            
            prefix = ['sfStatedlg_BindingExpandCollapse_' scope '_'];
            dialog.setVisible([prefix '1'], ~visible);
            dialog.setVisible([prefix '0'], visible);
        end
        
        function proposeBindings(dialog)
            stateUddH = dialog.getSource;
            bindingInfo = getappdata(stateUddH, 'StateflowSubchartBindingInfo');
            if isempty(bindingInfo)
                % g637388: This can happen if there was another dialog on
                % the same atomic subchart which got closed after this one
                % was open.
                dialog.refresh;
                bindingInfo = getappdata(stateUddH, 'StateflowSubchartBindingInfo');
            end
            
            proposeForScope('Input');
            proposeForScope('Output');
            proposeForScope('Data Store Memory');
            
            setappdata(stateUddH, 'StateflowSubchartBindingInfo', bindingInfo);
            dialog.refresh;
            
            function proposeForScope(scope)
                scopeMap = bindingInfo(scope);
                
                keys = scopeMap.keys;
                for i=1:length(keys)
                    ssid = keys{i};
                    if ~isempty(scopeMap(ssid).presentVal) && ~strcmp(scopeMap(ssid).presentVal,  ' ')
                        continue;
                    end
                    
                    info = scopeMap(ssid);
                    
                    name = info.Name;
                    allowedVals = info.allowedVals;
                    
                    dist = zeros(size(allowedVals));
                    dist(1) = Inf;
                    for jj=2:length(allowedVals)
                        dist(jj) = levDist(name, allowedVals{jj});
                    end
                    [~, idx] = sort(dist);
                    
                    info.presentVal = allowedVals{idx(1)};
                    scopeMap(ssid) = info;
                    
                    try
                        dialog.setTableItemValue(['sfStatedlg_BindingTable_' scope], i-1, 1, info.presentVal);
                        dialog.enableApplyButton(true);
                    catch ME %#ok<NASGU>
                    end
                    
                    try
                        dialog.setWidgetValue(['sfStatedlg_SubchartBinding_' num2str(ssid)], idx(1)-1);
                        dialog.enableApplyButton(true);
                    catch ME %#ok<NASGU>
                    end
                end
                
                bindingInfo(scope) = scopeMap;
            end
            
            function cost = levDist(s, t)
                m = length(s);
                n = length(t);
                
                d = zeros(m+1,n+1);
                d(:,1) = 0:m;
                d(1,:) = 0:n;
                for i=1:m
                    for j=1:n
                        cost = (s(i) ~= t(j));
                        d(i+1,j+1) = min([d(i,j+1)+1, d(i+1,j)+1, d(i,j)+cost]);
                    end
                    cost = d(m+1,n+1);
                end
            end
            
        end
        
        function applyBindings(stateId)
            rt = sfroot;
            stateUddH = rt.idToHandle(stateId);
            bindingInfo = getappdata(stateUddH, 'StateflowSubchartBindingInfo');
            
            bindingSpec = [bindingSpecForScope('Input'), ...
                bindingSpecForScope('Output'), ...
                bindingSpecForScope('Data Store Memory'), ...
                bindingSpecForScope('Parameter')];
            
            % Join all the strings.
            bindingSpec = horzcat(bindingSpec{:});
            
            if ~isempty(bindingSpec)
                stateUddH.Binding = bindingSpec;
            else
                stateUddH.Binding = '';
            end
            
            % setappdata(stateUddH, 'StateflowSubchartBindingInfo', []);
            
            function spec = bindingSpecForScope(scope)
                scopeMap = bindingInfo(scope);
                keys = scopeMap.keys;
                
                spec = cell([1 length(keys)]);
                for i=1:length(keys)
                    spec{i} = sprintf('%d %s\n', scopeMap(keys{i}).SSIdNumber, scopeMap(keys{i}).presentVal);
                end
            end
        end
        
        function onDialogClosed(stateId)
            stateUddH = idToHandle(sfroot, stateId);
            % remove this so that next time the dialog is opened, we do not
            % show stale info.
            setappdata(stateUddH, 'StateflowSubchartBindingInfo', []);
            sf('SetDynamicDialog', stateId, []);
        end
        
    end
    
    methods
        
        function bindingTab = getBindingTabSchemaLocal(self)
            bindingTab.Name = self.dxlate('MappingTabTitle');
            bindingTab.Tag = 'sfStatedlg_Binding';
            
            h = idToHandle(sfroot, self.stateId);
            bindingInfo = getappdata(h, 'StateflowSubchartBindingInfo');
            if isempty(bindingInfo)
                bindingInfo = self.getBindingInfo;
                setappdata(h, 'StateflowSubchartBindingInfo', bindingInfo);
            end
            if isempty(bindingInfo)
                return
            end
            
            stretch.Type = 'panel';
            bindingTab.Items = {...
                self.getBindingBoxSchema, ...
                self.getProposedBindingSchema, ...
                self.getBindingSectionSchema(bindingInfo, 'Input'), ...
                self.getBindingSectionSchema(bindingInfo, 'Output'), ...
                self.getBindingSectionSchema(bindingInfo, 'Data Store Memory'), ...
                self.getBindingSectionSchema(bindingInfo, 'Parameter'), ...
                stretch};
            
            idx = cellfun(@isempty, bindingTab.Items);
            bindingTab.Items(idx) = [];
            
            for i=1:length(bindingTab.Items)
                bindingTab.Items{i}.RowSpan = i*[1 1];
            end
            
            bindingTab.RowStretch = zeros([1 length(bindingTab.Items)]);
            bindingTab.RowStretch(end) = 1;
            bindingTab.LayoutGrid = [length(bindingTab.Items) 2];
            bindingTab.ColStretch = [0 1];
        end
        
        function bindingInfo = getBindingInfo(self)
            
            if self.subchartId == 0
                bindingInfo = [];
                return
            end
            
            outerChartUddH = idToHandle(sfroot, self.chartId);
            innerChartUddH = idToHandle(sfroot, self.subchartId);
            
            bindingMap = self.getBindingMap;
            
            bindingInfo = containers.Map;
            
            bindingInfo('Input') = getBindingInfoForScope('Input');
            bindingInfo('Output') = getBindingInfoForScope('Output');
            bindingInfo('Parameter') = getBindingInfoForParam;
            bindingInfo('Data Store Memory') = getBindingInfoForDSM;
            
            function bindingInfo = getBindingInfoForScope(scope, varargin)
                innerDataH = innerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', scope);
                outerDataH = outerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', scope);
                bindingInfo = getBindingInfoForData(innerDataH, outerDataH);
            end
            
            function bindingInfo = getBindingInfoForDSM
                innerDataH = innerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', 'Data Store Memory');
                outerDataH = [outerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', 'Data Store Memory');
                    outerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', 'Local')];
                bindingInfo = getBindingInfoForData(innerDataH, outerDataH);
            end
            
            function bindingInfo = getBindingInfoForData(innerDataH, outerDataH)
                outerDataNames = getDataNames(outerDataH);
                innerDataNames = getDataNames(innerDataH);
                
                bindingInfo = containers.Map(0, struct); % struct makes the 'ValueType' be any
                bindingInfo.remove(0);
                
                for i=1:length(innerDataNames)
                    dataH = innerDataH(i);
                    
                    dataInfo.Name = dataH.Name;
                    dataInfo.SSIdNumber = dataH.SSIdNumber;
                    dataInfo.allowedVals = [{' '}; outerDataNames];
                    if bindingMap.isKey(dataH.SSIdNumber)
                        dataInfo.presentVal = bindingMap(dataH.SSIdNumber);
                    else
                        dataInfo.presentVal = '';
                    end
                    dataInfo.editable = true;
                    
                    bindingInfo(dataInfo.SSIdNumber) = dataInfo;
                end
            end
            
            function bindingInfo = getBindingInfoForParam
                bindingInfo = containers.Map(0, struct); % struct makes the 'ValueType' be any
                bindingInfo.remove(0);
                
                innerDataH = innerChartUddH.find('-isa', 'Stateflow.Data', '-depth', 1, 'Scope', 'Parameter');
                innerDataNames = getDataNames(innerDataH);
                
                for i=1:length(innerDataNames)
                    dataH = innerDataH(i);
                    
                    dataInfo.Name = dataH.Name;
                    dataInfo.SSIdNumber = dataH.SSIdNumber;
                    if bindingMap.isKey(dataH.SSIdNumber)
                        dataInfo.presentVal = bindingMap(dataH.SSIdNumber);
                    else
                        dataInfo.presentVal = '';
                    end
                    dataInfo.allowedVals = {dataInfo.presentVal};
                    dataInfo.editable = true;
                    
                    bindingInfo(dataInfo.SSIdNumber) = dataInfo;
                end
            end
            
            function names = getDataNames(handles)
                names = cell(size(handles));
                for i=1:length(handles)
                    names{i} = handles(i).Name;
                end
            end
        end
        
        function binding = getBindingBoxSchema(self)
            bindingL.Name = DAStudio.message('Stateflow:subchart:BindingDialogExplanation');
            bindingL.Type = 'text';
            bindingL.WordWrap = true;
            bindingL.RowSpan = [1, 1];
            bindingL.ColSpan = [1, 1];
            
            binding.Name = self.dxlate('DescriptionTitle');
            binding.Type = 'group';
            binding.ColSpan = [1 2];
            binding.LayoutGrid = [1 1];
            binding.RowStretch = 0;
            binding.Items = {bindingL};
            binding.Tag = 'sfStatedlg_BindingExplanationBox';
        end
        
        function schema = getProposedBindingSchema(self)
            schema.Name = self.dxlate('ProposeBindings');
            schema.Type = 'hyperlink';
            schema.Tag = 'sfStatedlg_ProposeBindings';
            schema.ColSpan = [1 1];
            schema.MatlabMethod = 'sfprivate';
            schema.MatlabArgs = {'subchart_man', 'proposeBindings', '%dialog'};
        end
        
        function schema = getBindingSectionSchema(self, bindingInfo, scope)
            
            if strcmp(scope, 'Parameter')
                data = getTableForParams;
            else
                data = getTableForScope;
            end
            if isempty(data)
                schema = [];
                return
            end
            
            schema.Tag = ['sfStatedlg_BindingGroup_' scope];
            schema.ColSpan = [1 2];
            
            schema.Type = 'panel';
            schema.LayoutGrid = [2 2];
            schema.RowStretch = [0 1];
            schema.ColStretch = [0 1];
            schema.Items = {getExpandCollapseSchema(1), getExpandCollapseSchema(0), getTableHeadingSchema, getSpaceSchema, getTableSchema};
            
            function schema = getExpandCollapseSchema(visible)
                imagepath = fullfile(matlabroot,'toolbox/simulink/simulink/@Simulink/@DataTypePrmWidget/private');
                if visible
                    filePath = fullfile(imagepath, 'contract.png');
                else
                    filePath = fullfile(imagepath, 'expand.png');
                end
                
                schema.FilePath = filePath;
                schema.Type = 'image';
                schema.Tag = ['sfStatedlg_BindingExpandCollapse_' scope '_' num2str(visible)];
                schema.MatlabMethod = 'sfprivate';
                schema.MatlabArgs = {'subchart_man', 'toggleScopeBindings', '%dialog', scope};
                schema.Value = 1;
                schema.Graphical = 1;
                schema.Visible = visible;
                
                schema.RowSpan = [1 1];
                schema.ColSpan = [1 1];
                schema.FontFamily = get(0,'fixedWidthFontName');
            end
            
            function schema = getTableHeadingSchema
                schema.Name = [scope ' ' self.dxlate('MappingSectionTitle')];
                schema.Type = 'hyperlink';
                schema.RowSpan = [1 1];
                schema.ColSpan = [2 2];
                schema.Bold = 1;
                schema.MatlabMethod = 'sfprivate';
                schema.MatlabArgs = {'subchart_man', 'toggleScopeBindings', '%dialog', scope};
            end
            
            function schema = getSpaceSchema
                schema.Type = 'text';
                schema.Name = '     ';
                schema.ColSpan = [1 1];
                schema.RowSpan = [2 2];
                schema.Tag = ['sfStatedlg_BindingTable_Padding_' scope];
            end
            
            function schema = getTableSchema
                schema.Tag = ['sfStatedlg_BindingTable_' scope];
                schema.Type = 'table';
                schema.Size = size(data);
                schema.Grid = true;
                schema.HeaderVisibility = [0 1];
                schema.RowHeader = {'row 1', 'row 2'};
                schema.ColHeader = {self.dxlate('AtomicSubchartSymbol'), ...
                    self.dxlate('MainChartSymbol')};
                schema.Editable = true;
                schema.ColumnHeaderHeight = 1;
                
                schema.ColumnCharacterWidth = [20 20];
                schema.ReadOnlyColumns = 0; % zeroth column is read-only.
                
                schema.Data = data;
                schema.ValueChangedCallback = @(dialog, row, col, value) onTableItemChanged(dialog, data, row, col, value);
                
                schema.RowSpan = [2 2];
                schema.ColSpan = [2 2];
                schema.Visible = 1;
            end
            
            function data = getTableForScope
                scopeMap = bindingInfo(scope);
                keys = scopeMap.keys;
                
                data = cell([length(keys) 2]);
                for ii=1:length(keys)
                    ssid = keys{ii};
                    dataInfo = scopeMap(ssid);
                    
                    lhs.Type = 'edit';
                    lhs.Value = dataInfo.Name;
                    
                    rhs.Type = 'combobox';
                    rhs.Editable = true;
                    rhs.Entries = dataInfo.allowedVals;
                    
                    idx = strmatch(dataInfo.presentVal, rhs.Entries, 'exact');
                    if ~isempty(idx)
                        rhs.Value = idx-1;
                    else
                        rhs.Value = 0;
                    end
                    
                    rhs.UserData = {scope, ssid};
                    rhs.Tag = ['sfStatedlg_SubchartBinding_' scope num2str(ssid)];
                    
                    data{ii,1} = lhs;
                    data{ii,2} = rhs;
                end
            end
            
            function data = getTableForParams
                scope = 'Parameter';
                
                scopeMap = bindingInfo(scope);
                keys = scopeMap.keys;
                
                data = cell([length(keys) 2]);
                for ii=1:length(keys)
                    ssid = keys{ii};
                    dataInfo = scopeMap(ssid);
                    
                    lhs.Type = 'edit';
                    lhs.Value = dataInfo.Name;
                    
                    rhs.Type = 'edit';
                    if isempty(dataInfo.presentVal)
                        rhs.Value = '<Inherited>';
                    else
                        rhs.Value = dataInfo.presentVal;
                    end
                    
                    rhs.UserData = {scope, ssid};
                    rhs.Tag = ['sfStatedlg_SubchartBinding_' scope num2str(ssid)];
                    
                    data{ii,1} = lhs;
                    data{ii,2} = rhs;
                end
            end
            
            function onTableItemChanged(dialog, data, row, col, value)
                stateUddH = dialog.getSource;
                bindingInfo = getappdata(stateUddH, 'StateflowSubchartBindingInfo');
                
                item = data{row+1, col+1};
                scope = item.UserData{1};
                ssid = item.UserData{2};
                
                scopeMap = bindingInfo(scope);
                dataInfo = scopeMap(ssid);
                
                if strcmp(class(value), 'double')
                    allowedVals = item.Entries;
                    presentVal = allowedVals{value+1};
                else
                    if ~strcmpi(value, '<inherited>')
                        presentVal = value;
                    else
                        presentVal = '';
                    end
                end
                
                dataInfo.presentVal = presentVal;
                
                scopeMap(ssid) = dataInfo;
                bindingInfo(scope) = scopeMap;
                
                setappdata(stateUddH, 'StateflowSubchartBindingInfo', bindingInfo);
            end
        end
        
        function [proceed, msg] = preRevertCallbackFcn(self, dialog)
            proceed = true;
            msg = '';
            
            bindingInfo = self.getBindingInfo;
            if isempty(bindingInfo)
                return
            end
            
            scopes = bindingInfo.keys;
            for i=1:length(scopes)
                scope = scopes{i};
                dataInfo = bindingInfo(scope);
                ssids = dataInfo.keys;
                for j=1:length(ssids)
                    ssid = ssids{j};
                    
                    info = dataInfo(ssid);
                    dialog.setTableItemValue(['sfStatedlg_BindingTable_' scope], j-1, 1, info.presentVal);
                end
            end
            
            stateUddH = idToHandle(sfroot, self.stateId);
            setappdata(stateUddH, 'StateflowSubchartBindingInfo', bindingInfo);
        end
        
        function msg = dxlate(~, msgin, varargin)
            msg = DAStudio.message(sprintf('Stateflow:subchart:%s', msgin), varargin{:});
        end
        
    end
    
    % Methods for showing RTW options in the state dialog.
    methods(Static)
        
        function widgets = getRTWWidgets(stateUddH)
            subchartMan = Stateflow.SLINSF.SubchartMan(stateUddH.Id);
            widgets = subchartMan.getRTWWidgetsLocal;
        end
        
    end
    
    methods
        
        function widgets = getRTWWidgetsLocal(self)
            if self.subchartId == 0
                widgets = {};
                return;
            end
            
            if self.linkChartId > 0
                widgets = {{explainLink, 0}};
                return;
            end
            
            subchartUddH = idToHandle(sfroot, self.subchartId);
            subsysUddH = subchartUddH.up;
            
            enableSysCodeOpts = strcmpi(subsysUddH.TreatAsAtomicUnit, 'on');
            enableFileNameOpts = enableSysCodeOpts && ~isempty(regexpi(subsysUddH.RTWSystemCode, 'function', 'once'));
            enableFileName = enableFileNameOpts && ~isempty(regexpi(subsysUddH.RTWFileNameOpts, 'user', 'once'));
            
            widgets = {
                {rtwSystemCodeOptsUI, 0}, ...
                {rtwFileNameOptsUI, 0}, ...
                {rtwFileNameUI, 0}, ...
                {subchartPropsUI, 0}, ...
                };
            
            function widget = explainLink
                widgetL.Type = 'text';
                widgetL.Name = self.dxlate('ExplainLink');
                widgetL.WordWrap = true;
                
                widgetH.Type = 'hyperlink';
                widgetH.Name = self.dxlate('GotoLinkAction');
                widgetH.MatlabMethod = 'Stateflow.SLUtils.gotoLibraryLink';
                widgetH.MatlabArgs = {self.subchartH};
                
                widget.Name = self.dxlate('SubchartProps');
                widget.Type = 'group';
                widget.ColSpan = [1 4];
                widget.LayoutGrid = [2 1];
                widget.RowStretch = 0;
                widget.Items = {widgetL, widgetH};
                widget.Tag = 'sfStatedlg_RtwOptionsForLinkExplanation';
            end
            
            function widget = rtwSystemCodeOptsUI
                widget.Type = 'combobox';
                widget.Source = subsysUddH;
                widget.ObjectProperty = 'RTWSystemCode';
                widget.Name = self.dxlate(widget.ObjectProperty);
                widget.ColSpan = [1 4];
                widget.DialogRefresh = 1;
                widget.Mode = 1;
                widget.Entries = {'Auto', 'Inline', 'Reusable function'};
                widget.Visible = enableSysCodeOpts;
            end
            
            function widget = rtwFileNameOptsUI
                widget.Type = 'combobox';
                widget.Source = subsysUddH;
                widget.ObjectProperty = 'RTWFileNameOpts';
                widget.Name = self.dxlate(widget.ObjectProperty);
                widget.ColSpan = [1 4];
                widget.DialogRefresh = 1;
                widget.Mode = 1;
                widget.Visible = enableFileNameOpts;
            end
            
            function widget = rtwFileNameUI
                label.Type = 'text';
                label.Name = self.dxlate('RTWFileName');
                label.RowSpan = [1 1];
                label.ColSpan = [1 1];
                
                edit.Type = 'edit';
                edit.Source = subsysUddH;
                edit.ObjectProperty = 'RTWFileName';
                edit.RowSpan = [2 2];
                edit.ColSpan = [1 1];
                edit.DialogRefresh = 1;
                edit.Mode = 1;
                
                widget.Type = 'panel';
                widget.ColSpan = [1 4];
                widget.LayoutGrid = [2 1];
                widget.RowStretch = [0 1];
                widget.Items = {label, edit};
                widget.Visible = enableFileName;
            end
            
            function widget = subchartPropsUI
                chartUI = sfprivate('chartddg', subchartUddH);
                chartUI = chartUI.Items;
                
                widget.Name = self.dxlate('SubchartProps');
                widget.Type = 'group';
                widget.ColSpan = [1 4];
                widget.Items = {...
                    getSubchartWidget('Stateflow.Chart.EnableBitOps'), ...
                    getSubchartWidget('Stateflow.Chart.UserSpecifiedStateTransitionExecutionOrder'), ...
                    getSubchartWidget('Stateflow.Chart.ExportChartFunctions')};
                
                function widget = getSubchartWidget(widgetId)
                    widget = {};
                    for i=1:length(chartUI)
                        if isfield(chartUI{i}, 'WidgetId') && strcmp(chartUI{i}.WidgetId, widgetId)
                            widget = chartUI{i};
                            widget.Source = subchartUddH;
                            return;
                        end
                    end
                end
                
            end
        end
        
    end
    
    %% Private methods to aid in syncing
    methods(Access=protected)
        
        function ensureSubchartExists(self)
            %%% BEGIN Grandfathering Code
            if ~isempty(self.subsysH) && strcmpi(get_param(self.subsysH, 'BlockType'), 'Subsystem') && ~strcmpi(get_param(self.subsysH, 'MaskType'), 'Stateflow')
                % Need to transfer the inner subchart to the top-level
                
                % Need to relax permissions in order to deal with loading
                % legacy SF charts which lie in read-only subsystems.
                permQ = self.relaxPermissions;
                if ~isempty(self.subchartH)
                    self.subchartH = Stateflow.SLUtils.addBlock(self.chartBlockH, self.subchartH, ' ', 'MakeNameUnique', 'on');
                    newSubSysH = self.subchartH;
                else
                    assert(~isempty(self.brokenLinkH));
                    self.brokenLinkH = Stateflow.SLUtils.addBlock(self.chartBlockH, self.brokenLinkH, ' ', 'MakeNameUnique', 'on');
                    newSubSysH = self.brokenLinkH;
                end
                
                delete_block(self.subsysH);
                self.subsysH = newSubSysH;
                self.restorePermissions(permQ);
                
            end
            %%% END Grandfathering Code
            
            if isempty(self.subsysH)
                origBlock = sf('get', self.stateId, '.simulink.blockHandle');
                
                % Make sure we do not allow stupid users to create circular
                % links using linked atomic subcharts.
                if ishandle(origBlock)
                    try
                        % When we copy/paste an atomic subchart from SF
                        % into SF, the .simulink.blockHandle refers to a
                        % _valid_ block which is on the Simulink clipboard.
                        % Doing get_param on such blocks is not allowed.
                        % When copying from SL to SF, this works, because
                        % SL allows get_param for blocks on the clipboard
                        % when we are processing a callback.
                        refBlock = get_param(origBlock, 'ReferenceBlock');
                    catch ME
                        if strcmp(ME.identifier, 'Simulink:Commands:InvSimulinkObjHandle')
                            refBlock = '';
                        else
                            rethrow(ME);
                        end
                    end
                    if ~isempty(refBlock)
                        chartFullName = getfullname(self.chartBlockH);
                        dstInsideSrc = any(strfind([chartFullName '/'], [refBlock '/']) == 1);
                        if dstInsideSrc
                            DAStudio.warning('Stateflow:subchart:CircularLink', refBlock, chartFullName);
                            origBlock = -1;
                        end
                    end
                end
                
                if ~ishandle(origBlock)
                    load_system('sflib');
                    origBlock = 'sflib/Chart';
                end
                
                self.subsysH = Stateflow.SLUtils.addBlock(self.chartBlockH, origBlock, 'Chart', 'MakeNameUnique', 'on');
                if strcmpi(get_param(self.subsysH, 'BlockType'), 'Reference')
                    self.brokenLinkH = self.subsysH;
                else
                    assert(strcmpi(get_param(self.subsysH, 'BlockType'), 'Subsystem'));
                    self.subchartH = self.subsysH;
                    self.subchartId = sfprivate('block2chart', self.subchartH);
                    
                    % Only calculate default bindings when we are
                    % copy-pasting from Simulink into Stateflow.
                    if isempty(sf('get', self.stateId, '.simulink.binding'))
                        self.calculateDefaultBindings;
                    end
                end
            end
            
            Stateflow.SLUtils.setNameSafely(self.subsysH, self.getFullName);
            sf('set', self.stateId, '.simulink.blockHandle', self.subsysH);
            sf('set', self.stateId, '.simulink.blockName', get_param(self.subsysH, 'Name'));
        end
        
        function err = connectIOPorts(self, throwError)
            err = false;
            
            [~, subchartDataIds, subToMainNameMap, subToMainIdMap] = self.getBindingMap;
            
            % Ensure that no dynamic matrices are bound.
            if throwError
                for i=1:length(subchartDataIds)
                    dataId = subchartDataIds(i);
                    if sf('get', dataId, 'data.props.array.isDynamic')
                        rt = sfroot;
                        
                        dataH = rt.idToHandle(dataId);
                        msg = DAStudio.message('Stateflow:subchart:InvalidDynMatrixBinding', ...
                            dataH.Name, dataH.Id);
                        
                        sfprivate('construct_error', self.stateId, 'Interface', msg, 0);
                        err = true;
                    end
                end
            end
            
            % Ensure proper binding rules are followed.
            for i=1:length(subchartDataIds)
                dataId = subchartDataIds(i);
                
                scope = sf('get', dataId, '.scope');
                isParam = (scope == Stateflow.DataUtils.PARAMETER_DATA);
                if isParam
                    continue
                end
                
                if ~subToMainIdMap.isKey(dataId)
                    errThisTime = true;
                    err = err || errThisTime;
                    
                    if errThisTime && throwError
                        rt = sfroot;
                        outerChartUddH = rt.idToHandle(self.chartId);
                        innerDataUddH = rt.idToHandle(dataId);
                        compStateUddH = rt.idToHandle(self.stateId);
                        
                        msg = DAStudio.message('Stateflow:subchart:InvalidPortBinding', ...
                            innerDataUddH.Name, ...
                            compStateUddH.getFullName, ...
                            outerChartUddH.getFullName, ...
                            compStateUddH.Id, ...
                            compStateUddH.getFullName, ...
                            compStateUddH.Id);
                        
                        sfprivate('construct_error', self.stateId, 'Interface', msg, 0);
                    end
                end
                
            end
            
            ensureInputsAreSplit
            ensureOutputsAreMerged;
            err = self.autoBindParams(subToMainNameMap, throwError) || err;
            self.autoBindDSMs(subchartDataIds, subToMainNameMap, subToMainIdMap);
            
            function ensureInputsAreSplit
                ioPortBindingHelper('INPUT_DATA', @processInport);
                
                function processInport(portH, i)
                    Stateflow.SLUtils.ensureConnection(portH, 1, self.subsysH, i);
                end
            end
            
            function ensureOutputsAreMerged
                ioPortBindingHelper('OUTPUT_DATA', @processOutport);
                
                function processOutport(portH, i)
                    mergeH = ensureMergeBeforeOutport(self, portH);
                    ensureConnectionToMerge(self.subsysH, i, mergeH);
                end
                
                function mergeH = ensureMergeBeforeOutport(self, portH)
                    lineHandles = get_param(portH, 'LineHandles');
                    lineH = lineHandles.Inport;
                    
                    origPortH = -1; origBlockH = -1;
                    if ishandle(lineH)
                        origPortH = get_param(lineH, 'SrcPortHandle');
                        origBlockH = get_param(lineH, 'SrcBlockHandle');
                        
                        assert(ishandle(origPortH) && ishandle(origBlockH));
                    end
                    
                    % If the port is already connected to a merge block, we are done!
                    if ishandle(origBlockH) && strcmp(get_param(origBlockH, 'BlockType'), 'Merge')
                        mergeH = origBlockH;
                        return;
                    end
                    
                    % The port is either connected to a non-merge block or it is
                    % disconnected. If it is connected, then disconnect it from its
                    % original source.
                    if ishandle(origBlockH)
                        % origBlockH is NOT a merge otherwise we would have returned
                        % earlier.
                        delete_line(lineH);
                    end
                    
                    % Add a new merge block.
                    mergeH = Stateflow.SLUtils.addBlock(self.chartBlockH, 'built-in/Merge', ' Merge ', 'MakeNameUnique', 'on');
                    % Ensure its placed in line with the outport.
                    dstpos = get_param(portH, 'Position');
                    set_param(mergeH, 'Position', [dstpos(1)-100, dstpos(2), dstpos(3)-100, dstpos(4)]);
                    
                    Stateflow.SLUtils.addLine(mergeH, 1, portH, 1);
                    set_param(mergeH, 'Inputs', '2');
                    
                    % Connect the original source to the newly created merge.
                    if ishandle(origBlockH)
                        Stateflow.SLUtils.addLine(origBlockH, get_param(origPortH, 'PortNumber'), mergeH, 1);
                    end
                end
                
                function ensureConnectionToMerge(subchartH, portNum, mergeH)
                    dstBlockH = -1;
                    lineHandles = get_param(subchartH, 'LineHandles');
                    lineH = lineHandles.Outport(portNum);
                    if ishandle(lineH)
                        dstBlockH = get_param(lineH, 'DstBlockHandle');
                    end
                    
                    if mergeH == dstBlockH
                        return
                    end
                    
                    lineHandles = get_param(mergeH, 'LineHandles');
                    firstEmptyIdx = find(~ishandle(lineHandles.Inport), 1);
                    if isempty(firstEmptyIdx)
                        numInputs = str2double(get_param(mergeH, 'Inputs'));
                        set_param(mergeH, 'Inputs', num2str(numInputs+1));
                        firstEmptyIdx = numInputs + 1;
                    end
                    
                    if ishandle(dstBlockH) && strcmp(get_param(dstBlockH, 'BlockType'), 'Merge')
                        % since mergeH != dstBlockH by the time we are here, it
                        % means that we were connected to the wrong merge.
                        % Disconnect from that merge and compact it.
                        % g568874
                        delete_line(lineH);
                        % We cannot just simply reduce the number of input
                        % ports of the merge block. We first need to make sure
                        % all existing valid connections to the merge block
                        % connect to the first few input ports so that reducing
                        % the number of input ports will keep the existing
                        % connections alive.
                        % g592213
                        Stateflow.SLUtils.compactInputsToMerge(dstBlockH);
                    end
                    
                    Stateflow.SLUtils.addLine(subchartH, portNum, mergeH, firstEmptyIdx);
                end
            end
            
            function ioPortBindingHelper(scope, callback)
                if strcmpi(scope, 'INPUT_DATA')
                    portType = 'Inport';
                else
                    portType = 'Outport';
                end
                
                lInnerDataIds = sf('find', subchartDataIds, 'data.scope', scope);
                
                for ii=1:length(lInnerDataIds)
                    lInnerDataId = lInnerDataIds(ii);
                    if ~subToMainIdMap.isKey(lInnerDataId)
                        continue
                    end
                    
                    lOuterDataId = subToMainIdMap(lInnerDataId);
                    outerDataUddH = idToHandle(sfroot, lOuterDataId);
                    if isempty(outerDataUddH)
                        % When an output data is deleted and we get called
                        % as a result of update_instance_connections, the
                        % call-back happens at a strange time. The data is
                        % still part of the low level hierarchy but its uDD
                        % handle has been deleted.
                        continue
                    end
                    mainPortH = Stateflow.SLUtils.findSystem(self.chartBlockH, 'BlockType', portType, 'Port', num2str(outerDataUddH.Port));
                    if ~isempty(mainPortH)
                        callback(mainPortH, ii);
                    end
                end
            end
        end
        
        function adjustInstanceConnectionsAfterRemoval(~)
            % XXX: TEMPORARY till we get the synthesized Simulink function
            % call trigger port in place.
        end
        
        function [ssidToNameMap, subchartDataIds, subToMainNameMap, subToMainIdMap] = getBindingMap(self)
            
            bindingSpec = sf('get', self.stateId, '.simulink.binding');
            matches = regexp(bindingSpec, '^(?<ssid>\d+)[ ]*(?<value>[^\n]*)$', 'names', 'lineanchors');
            
            ssidToNameMap = containers.Map(0, 'double');
            ssidToNameMap.remove(0);
            
            for i=1:length(matches)
                ssidToNameMap(str2double(matches(i).ssid)) = matches(i).value;
            end
            
            subToMainNameMap = containers.Map('name', 'value');
            subToMainNameMap.remove('name');
            subToMainIdMap = containers.Map(0, 0);
            subToMainIdMap.remove(0);
            
            subchartDataIds = self.getSubchartBoundData;
            outerChartDataIds = sf('DataOf', self.chartId);            
            % Ensure proper binding rules are followed.
            for i=1:length(subchartDataIds)
                dataId = subchartDataIds(i);
                ssid = sf('get', dataId, '.ssIdNumber');
                scope = sf('get', dataId, '.scope');
                isDSM = (scope == Stateflow.DataUtils.DATA_STORE_MEMORY_DATA);
                
                innerDataName = sf('get', dataId, '.name');
                
                if ssidToNameMap.isKey(ssid) && ~isempty(ssidToNameMap(ssid))
                    outerDataName = ssidToNameMap(ssid);
                else
                    outerDataName = innerDataName;
                end
                
                subToMainNameMap(innerDataName) = outerDataName;

                outerDataId = sf('find', outerChartDataIds, '.name', outerDataName);
                
                % Ensure that the inner/outer data objects have compatible
                % scopes.
                if ~isempty(outerDataId)
                    outerScope = sf('get', outerDataId, '.scope');
                    if isDSM
                        if ~(outerScope == Stateflow.DataUtils.DATA_STORE_MEMORY_DATA || outerScope == Stateflow.DataUtils.LOCAL_DATA)
                            outerDataId = [];
                        end
                    else
                        if scope ~= outerScope
                            outerDataId = [];
                        end
                    end
                end
                
                if ~isempty(outerDataId)
                    subToMainIdMap(dataId) = outerDataId;
                end
            end
            
        end
        
        function boundData = getSubchartBoundData(self)
            innerData = sf('DataOf', self.subchartId);
            boundData = [sf('find', innerData, '.scope', 'INPUT_DATA'), ...
                sf('find', innerData, '.scope', 'OUTPUT_DATA'), ...
                sf('find', innerData, '.scope', 'PARAMETER_DATA'), ...
                sf('find', innerData, '.scope', 'DATA_STORE_MEMORY_DATA')];
        end
        
        function err = autoBindParams(self, subToMainNameMap, throwError)
            % Sets the following values on the subsystem mask:
            % 'MaskPrompts' : {'Prompt for ''P1''', 'Prompt for ''P2'''}
            % 'MaskValues'  : {'P1', 'P2'}
            % 'MaskVariables' : 'P1=@1;P2=@2;'
            
            % Unfortunately, the MaskVariables property is not a linked
            % instance property. Hence with linked atomic subcharts, the
            % first time a model is loaded, we are guaranteed that
            % 'MaskVariables' is empty. Hence it will dirty. The "proper"
            % way to fix that would be for all Stateflow charts to set the
            % 'MaskVariables' and 'MaskPrompts' property while the instance
            % sets the 'MaskValues' property. That seems to trigger a
            % Simulink bug.
            modelH = bdroot(self.subsysH);
            prevDirty = get_param(modelH, 'dirty');
            restoreDirty = onCleanup(@() set_param(modelH, 'dirty', prevDirty));

            [maskValues, err] = ...
                Stateflow.SLINSF.SubchartMan.updateMaskParams(...
                self.subchartId, self.subsysH, ...
                subToMainNameMap, throwError);

            
            stateUddH = idToHandle(sfroot, self.stateId);
            if ~isempty(stateUddH)
                setappdata(stateUddH, 'MaskValues', maskValues);
            end
        end
        
        function autoBindDSMs(self, subchartDataIds, subToMainNameMap, subToMainIdMap)
            % Sets the 'DSMNames' and 'DSMValues' properties on the
            % subsystem. This allows for an atomic subchart to bind to a
            % different named DSM in the containing chart.
            
            dsmDataIds = sf('find', subchartDataIds, '.scope', 'DATA_STORE_MEMORY_DATA');
            
            namesCell = cell(size(dsmDataIds));
            valuesCell = cell(size(dsmDataIds));
            for i=1:length(dsmDataIds)
                dataId = dsmDataIds(i);
                dataName = sf('get', dataId, '.name');
                mainName = subToMainNameMap(dataName);
                
                namesCell{i} = [dataName ','];
                if ~isempty(mainName)
                    valuesCell{i} = [mainName ','];
                else
                    valuesCell{i} = '';
                end
                
                if subToMainIdMap.isKey(dataId)
                    outerDataId = subToMainIdMap(dataId);
                    sf('set', outerDataId, '.subchart.isMappedToSubchart', 1);
                end
            end
            
            idx = cellfun(@isempty, valuesCell);
            namesCell(idx) = [];
            valuesCell(idx) = [];
            
            names = [namesCell{:}];
            values = [valuesCell{:}];
            
            if ~isempty(values)
                set_param(self.subsysH, 'DSMNames', names(1:end-1));
                set_param(self.subsysH, 'DSMValues', values(1:end-1));
            else
                set_param(self.subsysH, 'DSMNames', '');
                set_param(self.subsysH, 'DSMValues', '');
            end
        end
        
    end
    
    %% Syncing for parameters
    methods(Static)
        % In order to make parameter mapping work for atomic subcharts, we
        % have to set the following properties on the atomic subchart chart
        % block.
        %
        % 'MaskPrompts' : {'Prompt for ''P1''', 'Prompt for ''P2'''}
        % 'MaskValues'  : {'P1', 'P2'}
        % 'MaskVariables' : 'P1=@1;P2=@2;'
        %
        % Of these, 'MaskPrompts' and 'MaskVariables' should be set on a
        % "real" block, while 'MaskValues' should be set on an instance
        % block.
        %
        % 1. In pre_link_resolve pass 1, we set 'MaskPrompts', 'MaskValues'
        %    and 'MaskVariables' on all real blocks. We set
        %    'MaskValues' the same as 'MaskVariables' in this stage.
        % 
        % 2. In pre_link_resolve pass 2 (which happens after we have
        %    processed all library blocks), We then iterate over all link
        %    blocks in the main model and set the 'MaskVariables' to the
        %    same as the library block. This is necessary before the
        %    Simulink block copy phase.
        
        function preLinkResolvePass2(machineId)
            modelH = sf('get', machineId, '.simulinkModel');
            mainPrevDirty = get_param(modelH, 'Dirty');
            mainRestoreDirty = onCleanup(@() set_param(modelH, 'dirty', mainPrevDirty));
            
            sfBlocks = find_system(modelH,  'LookUnderMasks', 'on', ...
                'FollowLinks', 'on', ...
                'LookUnderReadProtectedSubsystems', 'on', ...
                'MaskType', 'Stateflow');
            
            % For every library block instantiated in the main model, we
            % remember whether that library block was used as an atomic
            % subchart or not.
            libBlockHandlesMap = containers.Map('KeyType', 'char', 'ValueType', 'logical');
            
            % Iterate in bottom up order so that in the presence of atomic
            % subcharts, the MaskValues set by the container takes
            % precedence over the MaskValues set by the subchart.
            for ii=length(sfBlocks):-1:1
                chartId = sfprivate('block2chart', sfBlocks(ii));
                
                % If its a library instance, we need to remember whether
                % any instance of it was used as an atomic subchart.
                usedAsAtomicSubchart = ...
                    Stateflow.SLINSF.SubchartMan.isUsedAsComponent(sfBlocks(ii));
                libBlockH = get_param(sfBlocks(ii), 'ReferenceBlock');
                if ~isempty(libBlockH)
                    if ~libBlockHandlesMap.isKey(libBlockH)
                        libBlockHandlesMap(libBlockH) = usedAsAtomicSubchart;
                    end
                    libBlockHandlesMap(libBlockH) = ...
                        libBlockHandlesMap(libBlockH) || usedAsAtomicSubchart;
                end
                
                if usedAsAtomicSubchart
                    % We need to also cleanup any 'MaskVariables' setting
                    % on an instance block because the instance and the
                    % real block need to have the same 'MaskVariables'
                    % setting (!) when Simulink does the block copy. If we
                    % do not do this, then if parameters are deleted on a
                    % library block and we press CTRL-d, we'll get an
                    % error.
                    Stateflow.SLINSF.SubchartMan.updateMaskParams(chartId, sfBlocks(ii));
                else
                    % Clear out the 'MaskVariables' etc on the instance
                    % block since PLC coder (and who know what else) breaks
                    % if the Stateflow mask has 'MaskVariables' set.
                    Stateflow.SLINSF.SubchartMan.clearMaskParams(sfBlocks(ii));
                end
                
                % This needs to happen for all blocks. With multi-hop
                % links, setting the 'MaskValues' on the intermediate
                % library does not seem to get transferred over to the
                % final chart.
                updateMaskValues(chartId, sfBlocks(ii));
            end
            
            % Now for every library block instantiated in the main model,
            % depending on whether any of its instances is an atomic
            % subchart or not, set or clear the 'MaskVariables' on the
            % library block.
            libBlockHandles = libBlockHandlesMap.keys;
            for ii=1:length(libBlockHandles)
                libBlockH = libBlockHandles{ii};
                chartId = sfprivate('block2chart', libBlockH);
                
                libModelH = bdroot(libBlockH);
                libDirty = get_param(libModelH, 'dirty');
                libLock = Stateflow.SLUtils.unlockModel(libModelH);
                libRestore = onCleanup(@() set_param(libModelH, 'dirty', libDirty, 'lock', libLock));
                
                if libBlockHandlesMap(libBlockH) == true
                    Stateflow.SLINSF.SubchartMan.updateMaskParams(chartId, libBlockH);
                else
                    Stateflow.SLINSF.SubchartMan.clearMaskParams(libBlockH);
                end
                
                delete(libRestore);
            end
            
            function updateMaskValues(chartId, chartBlockH)
                allStates = sf('SubstatesIn', chartId);
                atomicSubcharts = sf('find', allStates, 'state.simulink.isComponent', 1);
                for i = 1:length(atomicSubcharts)
                    stateId = atomicSubcharts(i);
                    blockName = sf('get', stateId, 'state.simulink.blockName');
                    stateUddH = idToHandle(sfroot, stateId);
                    
                    subsysH = Stateflow.SLUtils.findSystem(chartBlockH, 'Name', blockName);
                    set_param(subsysH, 'MaskValues', getappdata(stateUddH, 'MaskValues'));
                end
            end
        end
        
        function clearMaskParams(chartBlockH)
            set_param(chartBlockH, 'MaskPrompts', {});
            set_param(chartBlockH, 'MaskValues', {});
            set_param(chartBlockH, 'MaskVariables', '');              
        end
        
        function [maskValues, err] = updateMaskParams(chartId, chartBlockH, subToMainNameMap, throwError)
            if nargin < 3
                subToMainNameMap = [];
            end
            if nargin < 4
                throwError = false;
            end
            
            err = false;
            allData = sf('DataIn', chartId);
            paramDataIds = sf('find', allData, '.scope', 'PARAMETER_DATA');
            
            maskVarNames   = cell(length(paramDataIds), 1);
            maskPrompts    = cell(length(paramDataIds), 1);
            maskValues     = cell(length(paramDataIds), 1);
            idxToRemove    = false(size(paramDataIds));
            for i=1:length(paramDataIds)
                dataId = paramDataIds(i);
                dataName = sf('get', dataId, '.name');
                maskVarNames{i} = dataName;
                maskPrompts{i} = sprintf('Value for ''%s''', dataName);
                
                % Need to provide a "default" value so that charts at top-level
                % (non atomic subcharts) also work.
                if ~isempty(subToMainNameMap)
                    maskValues{i} = subToMainNameMap(dataName);
                else
                    maskValues{i} = dataName;
                end
                
                if Stateflow.SLUtils.isBuiltinParam(dataName)
                    % If its a builtin parameter, we better not have a
                    % mapping for it because Simulink doesn't let us set a
                    % 'MaskVariable' with the same name as a builtin
                    % parameter.
                    idxToRemove(i) = true;
                    if ~strcmp(dataName, maskValues{i}) && throwError
                        msg = DAStudio.message('Stateflow:subchart:ParameterNameClashHeader', ...
                            getfullname(chartBlockH), dataId, dataName, maskValues{i});
                        sfprivate('construct_error', chartId, 'Interface', msg, 0);
                        err = true;
                    end
                end
                
            end

            % Remove all mask variables whos names clash with builtin
            % Simulink subsystem parameter names.
            maskVarNames(idxToRemove) = [];
            maskPrompts(idxToRemove) = [];
            maskValues(idxToRemove) = [];
            
            % Do this as a separate pass because we want to the @1,@2 etc
            % to be contiguous and some of the params might have been
            % zapped from the middle.
            maskVarStrings = cell(size(maskVarNames));
            for i=1:length(maskVarNames)
                maskVarStrings{i} = sprintf('%s=@%d;', maskVarNames{i}, i);
            end
            
            % trailing '' to force it to be a character array
            maskVariables = [maskVarStrings{:} ''];            
            
            set_param(chartBlockH, 'MaskPrompts', maskPrompts);
            set_param(chartBlockH, 'MaskValues', maskValues);
            set_param(chartBlockH, 'MaskVariables', maskVariables);            
        end
    end
    
    %% Private methods to aid in unified SL/SF copy/paste
    methods(Access=protected)
        
        function doAdditionalCopyOperations(~, copiedBlockH)
            if ~sf('feature', 'SLSFUnifiedCopyBuffer')
                return
            end
            
            Stateflow.SLUtils.copyToCopyBuffer(copiedBlockH);
        end
        
    end
    
end

% LocalWords:  Dyn
