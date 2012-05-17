classdef SimStateContainer < Stateflow.SimState.SimStateObject & dynamicprops

    %   Copyright 2008-2009 The MathWorks, Inc.

    properties (Constant, Hidden)
        % Container types
        SFSS_UNKNOWN_CONTAINER = 0;
        SFSS_CHART = 1;
        SFSS_AND_STATE = 2;
        SFSS_OR_STATE = 3;
        SFSS_BOX = 4;
        SFSS_FUNCTION = 5;
        
        % State decomposition types
        SFSS_DECOMP_UNKNOWN = 0;
        SFSS_DECOMP_EXCLUSIVE_OR = 1;
        SFSS_DECOMP_PARALLEL_AND = 2;
        
        % State consistency error codes
        SFSS_SC_NO_ERROR = 0;
        SFSS_SC_ACTIVE_CLUSTER_STATE_HAS_NO_ACTIVE_SUBSTATES = 1;
        SFSS_SC_ACTIVE_CLUSTER_STATE_HAS_MULTIPLE_ACTIVE_SUBSTATES = 2;
        SFSS_SC_INACTIVE_CLUSTER_STATE_HAS_ACTIVE_SUBSTATES = 3;
        SFSS_SC_ACTIVE_SET_STATE_HAS_INACTIVE_SUBSTATES = 4;
        SFSS_SC_INACTIVE_SET_STATE_HAS_ACTIVE_SUBSTATES = 5;
    end
    
    properties (Hidden, SetAccess = private)
        IndexAmongSiblings = -1; % Cache codegen state active child enum value
        Decomposition = 0;
        Substates = [];
        Children = [];
        Data = [];
        StateOutputData = [];
        TemporalCounters = [];
        SubchartRoot = [];
    end
        
    methods (Static, Hidden, Access = private)

        function result = isMethodName(name)
            % WISH: ismethod(obj, name) should also detects hidden methods
            persistent methodNames
            if isempty(methodNames)
                mc = ?Stateflow.SimState.BlockSimState;
                numMethods = length(mc.Methods);
                methodNames = cell(1, numMethods);
                for i = 1 : numMethods
                    if ~mc.Methods{i}.Static
                        methodNames{i} = mc.Methods{i}.Name;
                    else
                        methodNames{i} = '';
                    end
                end
            end
            match = regexp(methodNames, sprintf('^%s$', name));
            result = ~isempty([match{:}]);
        end

    end
    
    methods

        function obj = SimStateContainer(name, type, source, decomp, idxsiblns)
            obj = obj@Stateflow.SimState.SimStateObject(name, type, source);
            obj.Decomposition = decomp;
            obj.IndexAmongSiblings = idxsiblns;
        end
        
        function setActive(obj)
            if obj.isLeafState
                obj.activate([]);
                obj.Root.highlightActiveStatesPassive;
            else
                error('Stateflow:SimStateError', '''setActive'' method can only be called from a leaf state.');
            end
        end
        
        function result = isActive(obj)
            switch obj.Type
                case {Stateflow.SimState.SimStateContainer.SFSS_CHART, ...
                      Stateflow.SimState.SimStateContainer.SFSS_AND_STATE}
                    result = (obj.('$isActive').Value ~= 0);
                case Stateflow.SimState.SimStateContainer.SFSS_OR_STATE
                    result = (obj.getActualParent.('$activeChild').Value == obj.IndexAmongSiblings);
                otherwise
                    % Box, Functions are never active
                    result = false;
            end
        end

        function prevActChild = getPrevActiveChild(obj)
            prevActChild = [];
            if ~isempty(obj.findprop('$prevActiveChild'))
                if obj.isActive
                    prevActChild = obj.getActiveChild;
                else
                    idx = obj.('$prevActiveChild').Value;
                    if idx > 0
                        prevActChild = obj.Substates(idx);
                    end
                end
            else
                error('Stateflow:SimStateError', 'Object does not have history.');
            end
        end
        
        function setPrevActiveChild(obj, newActiveChild)
            if isempty(obj.findprop('$prevActiveChild'))
                error('Stateflow:SimStateError', 'Object does not have history.');
            end
            
            if obj.isActive
                error('Stateflow:SimStateError', 'Cannot change history for an active state.');
            end
            
            if isempty(newActiveChild)
                obj.('$prevActiveChild').Value = 0;
            else
                isSubstate = false;
                for i = 1 : length(obj.Substates)
                    if isequal(newActiveChild, obj.Substates(i))
                        isSubstate = true;
                        break;
                    end
                    
                    if ischar(newActiveChild) && strcmp(newActiveChild, obj.Substates(i).Name)
                        isSubstate = true;
                        newActiveChild = obj.Substates(i);
                        break;
                    end
                end
                
                if isSubstate
                    obj.('$prevActiveChild').Value = newActiveChild.IndexAmongSiblings;
                else
                    error('Stateflow:SimStateError', 'Previous active child must be a substate of this parent state.');
                end
            end
        end
        
        function disp(obj)
            if length(obj) > 1
                for i = 1 : length(obj)
                    disp(obj(i));    
                end
                
                return;
            end

            dispStr = obj.getDescription;

            numChildren = length(obj.Children);
            numData = length(obj.Data);
            len = numChildren + numData;
            fPrefix = cell(len, 1);
            fName = cell(len, 1);
            fDesc = cell(len, 1);
            fMisc = cell(len, 1); % Class, Size, Active infos
            
            for i = 1 : numChildren
                fPrefix{i} = '+';
                fName{i} = obj.Children(i).getPropName;
                fDesc{i} = ['"' obj.Children(i).getShortDescription '"'];
                fMisc{i} = '';
                if obj.Children(i).isActive
                    fMisc{i} = '(active)';
                end
            end
            
            dataIdx = numChildren + 1;
            for i = 1 : numData
                if ~obj.Data(i).isHidden
                    fPrefix{dataIdx} = ' ';
                    fName{dataIdx} = obj.Data(i).getPropName;
                    fDesc{dataIdx} = ['"' obj.Data(i).Description '"'];                    
                    fMisc{dataIdx} = [obj.Data(i).DataType ' ' obj.Data(i).Size];
                    dataIdx = dataIdx + 1;
                end
            end
            
            fPrefix(dataIdx:end) = [];
            fName(dataIdx:end) = [];
            fDesc(dataIdx:end) = [];
            fMisc(dataIdx:end) = [];
            
            prefixStr = char(fPrefix);
            nameStr = char(fName);
            descStr = char(fDesc);
            miscStr = char(fMisc);
            
            contentStr = '';
            for i = 1 : length(fName)
                contentStr = sprintf('%s    %s %s         %s         %s\n', contentStr, ...
                    prefixStr(i,:), nameStr(i,:), descStr(i,:), miscStr(i,:));
            end
            
            if isempty(contentStr)
                contentStr = sprintf('    []\n');
            end
            
            dispStr = sprintf('%s\n  Contains:\n\n%s', dispStr, contentStr);

            disp(dispStr);
        end

    end
    
    methods (Hidden)
        
        function showHiddenData(obj, show)
            for i = 1 : length(obj.Data)
                thisData = obj.Data(i);
                if thisData.isHidden
                    thisProp = obj.findprop(thisData.getPropName);
                    thisProp.Hidden = ~show;
                end
            end
            
            for i = 1 : length(obj.Children)
                obj.Children(i).showHiddenData(show);
            end
        end
        
        function children = getChildren(obj)
            children = obj.Children;
        end
        
        function data = getData(obj)
            data = obj.Data;
        end

        function child = getActiveChild(obj)
            child = [];
            if obj.isStateLike && ~obj.isLeafState
                if obj.Decomposition == Stateflow.SimState.SimStateContainer.SFSS_DECOMP_EXCLUSIVE_OR
                    % OR decomposition states
                    activeChildIdx = obj.('$activeChild').Value;
                    if activeChildIdx > 0
                        child = obj.Substates(activeChildIdx);
                    end
                else
                    % Chart, AND decomposition states
                    for i = 1 : length(obj.Substates)
                        if obj.Substates(i).isActive
                            child = [child obj.Substates(i)]; %#ok<AGROW>
                        end
                    end
                end
            end            
        end
        
        function setContainerObject(obj, val) %#ok<INUSD,MANU>
            error('Stateflow:SimStateError', 'Property is read-only.');
        end

        % For debugging purpose
        function setActiveAnimation(obj, delay)
            if nargin < 2
                delay = 1;
            end
            
            if obj.isLeafState
                obj.doSetActiveAnimation(delay);                
                obj.activate([], delay);
            else
                error('Stateflow:SimStateError', '''setActiveAnimation'' method can only be called from a leaf state.');
            end
        end

    end
    
    methods (Hidden, Access = protected)
        
        function path = getEscapedPathWithHyperLink(obj)
            path = obj.getEscapedPath;
            
            if usejava('desktop')
                if obj.isChart
                    cbStr = sprintf('open_system(''%s''); open_system(''%s'');', obj.Root.RootSystem, obj.getEscapedPath(true));
                else
                    cbStr = sprintf('open_system(''%s''); h = sfprivate(''ssIdToHandle'', ''%s:%d''); sf(''Open'', h.Id);', ...
                        obj.Root.RootSystem, obj.Root.getEscapedPath(true), obj.Source);
                end
                path = sprintf('<a href="matlab:%s">%s</a>', cbStr, path);
            end
        end
        
        function desc = getDescription(obj)
            if obj.isChart
                title = 'Block:   ';
            elseif obj.isStateLike
                title = 'State:   ';
            elseif obj.isBox
                title = 'Box:     ';
            elseif obj.isFunction
                title = 'Function:';
            else
                title = 'Unknown: ';
            end
            
            desc = sprintf('  %s "%s"    (handle)', title, obj.getEscapedName);
            if obj.isActive
                desc = [desc '    (active)'];
            end

            desc = sprintf('%s\n  Path:     %s\n', desc, obj.getEscapedPathWithHyperLink);
        end

        function desc = getShortDescription(obj)
            if obj.isChart
                desc = 'Block';
            elseif obj.isOrState
                desc = 'State (OR)';
            elseif obj.isAndState
                desc = 'State (AND)';
            elseif obj.isBox
                desc = 'Box';
            elseif obj.isFunction
                desc = 'Function';
            else
                desc = 'Unknown';
            end
        end
        
        function result = isChart(obj)
            result = obj.Type == Stateflow.SimState.SimStateContainer.SFSS_CHART;
        end

        function result = isOrState(obj)
            result = obj.Type == Stateflow.SimState.SimStateContainer.SFSS_OR_STATE;
        end
        
        function result = isAndState(obj)
            result = obj.Type == Stateflow.SimState.SimStateContainer.SFSS_AND_STATE || ...
                     obj.Type == Stateflow.SimState.SimStateContainer.SFSS_CHART;
        end
        
        function result = isStateLike(obj)
            result = false;
            switch obj.Type
                case {Stateflow.SimState.SimStateContainer.SFSS_CHART, ...
                      Stateflow.SimState.SimStateContainer.SFSS_OR_STATE, ...
                      Stateflow.SimState.SimStateContainer.SFSS_AND_STATE}
                  result = true;
            end
        end
        
        function result = isLeafState(obj)
            result = obj.isStateLike && isempty(obj.Substates);
        end

        function result = isBox(obj)
            result = obj.Type == Stateflow.SimState.SimStateContainer.SFSS_BOX;
        end
        
        function result = isFunction(obj)
            result = obj.Type == Stateflow.SimState.SimStateContainer.SFSS_FUNCTION;
        end
        
        function result = isAndDecomposition(obj)
            result = obj.Decomposition == Stateflow.SimState.SimStateContainer.SFSS_DECOMP_PARALLEL_AND;
        end
        
        function result = isOrDecomposition(obj)
            result = obj.Decomposition == Stateflow.SimState.SimStateContainer.SFSS_DECOMP_EXCLUSIVE_OR;
        end
          
        function ap = getActualParent(obj)
            ap = obj.Parent;
            while ~isempty(ap) && ap.isBox
                ap = ap.Parent;
            end
        end
                
        function setStateOutputData(obj, val)
            if ~isempty(obj.StateOutputData)
                obj.StateOutputData.Value = {val};
            end
        end

        function doSetActiveAnimation(obj, animateDelay)
            if ~isempty(animateDelay)
                obj.Root.highlightActiveStates;
                pause(animateDelay);
            end
        end
                
        function activate(obj, via, animateDelay)
            if nargin < 3
                animateDelay = []; % No animation
            end
            
            if ~isequal(via, obj.getActualParent)
                % upstream
                if ~obj.isLeafState
                    if obj.isOrDecomposition
                        if obj.isActive
                            activeChild = obj.getActiveChild;
                            if ~isempty(activeChild)
                                activeChild.deactivate(animateDelay);
                            end
                        end
                        obj.('$activeChild').Value = via.IndexAmongSiblings;
                        obj.doSetActiveAnimation(animateDelay);
                    elseif obj.isAndDecomposition
                        for i = 1 : length(obj.Substates)
                            obj.Substates(i).activate(obj, animateDelay); % activate downstream
                        end
                    end
                end
                
                if ~obj.isActive
                    if obj.isAndState
                        obj.('$isActive').Value = 1;
                        obj.doSetActiveAnimation(animateDelay);
                    end
                    obj.setStateOutputData(1);
                    if ~isempty(obj.getActualParent) % otherwise, obj is the root chart
                        obj.getActualParent.activate(obj, animateDelay); % activate upstream
                    end
                end
            else
                % downstream. Only possible if parent is AND decomp
                if ~obj.isActive
                    obj.('$isActive').Value = 1;
                    obj.doSetActiveAnimation(animateDelay);
                    if obj.isAndDecomposition
                        for i = 1 : length(obj.Substates)
                            obj.Substates(i).activate(obj, animateDelay); % activate downstream
                        end
                    end
                    obj.setStateOutputData(1);
                end
            end
        end

        function deactivate(obj, animateDelay)
            % Deactivate can only be downstream
            if nargin < 2
                animateDelay = []; % No animation
            end

            if ~obj.isActive
                return;
            end
                        
            if ~obj.isLeafState
                if obj.isOrDecomposition
                    activeChild = obj.getActiveChild;
                    if ~isempty(activeChild)
                        activeChild.deactivate(animateDelay);
                    end
                elseif obj.isAndDecomposition
                    for i = 1 : length(obj.Substates)
                        obj.Substates(i).deactivate(animateDelay);
                    end
                end
            end
        
            if obj.isOrState
                obj.getActualParent.('$activeChild').Value = 0;
            else
                obj.('$isActive').Value = 0;
            end
            
            obj.doSetActiveAnimation(animateDelay);
            obj.setStateOutputData(0);
        end
                
        function uniqName = getUniqueName(obj, name)
            % Avoid collision of newly added property name with existing
            % prop names and method names
            uniqName = name;
            while ~isempty(obj.findprop(uniqName)) || ...
                  Stateflow.SimState.SimStateContainer.isMethodName(uniqName)
                uniqName = sprintf('%s_', uniqName);
            end
        end
        
        function appendData(obj, data)
            data.Parent = obj;
            obj.Data = [obj.Data data];
            
            uniqName = obj.getUniqueName(data.getPropName);
            data.setPropName(uniqName);
            p = addprop(obj, uniqName);
            p.Hidden = data.isHidden;
            obj.(uniqName) = data;
            p.SetMethod = @setContainerObject;
        end
        
        function appendChild(obj, child)
            child.Parent = obj;
            obj.Children = [obj.Children child];
            
            uniqName = obj.getUniqueName(child.getPropName);
            child.setPropName(uniqName);
            p = addprop(obj, uniqName);
            p.Hidden = false;
            obj.(uniqName) = child;
            p.SetMethod = @setContainerObject;
        end
        
        function appendSubstate(obj, substate)
            obj.Substates = [obj.Substates substate];
        end
        
        function attachStateOutputData(obj, data)
            obj.StateOutputData = data;
        end
        
        function appendTemporalCounter(obj, tc)
            obj.TemporalCounters = [obj.TemporalCounters tc];
        end
        
        function [result, code, msg] = isStateConsistentInternal(obj)
            result = true;
            code = Stateflow.SimState.SimStateContainer.SFSS_SC_NO_ERROR;
            msg = '';
            
            if ~isempty(obj.Substates)
                numActiveSubstates = 0;
                for i = 1 : length(obj.Substates)
                    if obj.Substates(i).isActive
                        numActiveSubstates = numActiveSubstates + 1;
                    end
                end
                
                switch obj.Decomposition
                    case Stateflow.SimState.SimStateContainer.SFSS_DECOMP_EXCLUSIVE_OR
                        if obj.isActive
                            if numActiveSubstates == 0
                                code = Stateflow.SimState.SimStateContainer.SFSS_SC_ACTIVE_CLUSTER_STATE_HAS_NO_ACTIVE_SUBSTATES;
                                msg = 'Active cluster state has no active substates';
                            elseif numActiveSubstates > 1
                                code = Stateflow.SimState.SimStateContainer.SFSS_SC_ACTIVE_CLUSTER_STATE_HAS_MULTIPLE_ACTIVE_SUBSTATES;
                                msg = 'Active cluster state has multiple active substates';
                            end
                        else
                            if numActiveSubstates > 0
                                code = Stateflow.SimState.SimStateContainer.SFSS_SC_INACTIVE_CLUSTER_STATE_HAS_ACTIVE_SUBSTATES;
                                msg = 'Inactive cluster state has active substates';
                            end
                        end
                    case Stateflow.SimState.SimStateContainer.SFSS_DECOMP_PARALLEL_AND
                        if obj.isActive
                            if numActiveSubstates < length(obj.Substates)
                                code = Stateflow.SimState.SimStateContainer.SFSS_SC_ACTIVE_SET_STATE_HAS_INACTIVE_SUBSTATES;
                                msg = 'Active set state has inactive substates';
                            end
                        else
                            if numActiveSubstates > 0
                                code = Stateflow.SimState.SimStateContainer.SFSS_SC_INACTIVE_SET_STATE_HAS_ACTIVE_SUBSTATES;
                                msg = 'Inactive set state has active substates';
                            end
                        end
                    otherwise
                        error('Stateflow:UnexpectedError', 'Unexpected state decomposition.');
                end
            end

            if code ~= Stateflow.SimState.SimStateContainer.SFSS_SC_NO_ERROR
                result = false;
                msg = sprintf('%s => %s', msg, obj.getEscapedPathWithHyperLink);
            end
        end
        
        function adoptSubchart(obj)
            subchartInfo = obj.('$subchartSimStateInfo').Value;
            subchartRoot = Stateflow.SimState.BlockSimState.constructHierarchicalContext(subchartInfo);
            
            obj.SubchartRoot = subchartRoot;
            
            for i=1:length(subchartRoot.Data)
                obj.appendData(subchartRoot.Data(i));
            end
            for i=1:length(subchartRoot.Children)
                obj.appendChild(subchartRoot.Children(i));
            end
            for i=1:length(subchartRoot.Substates)
                obj.appendSubstate(subchartRoot.Substates(i));
            end
            obj.Decomposition = subchartRoot.Decomposition;
        end
        
        function refreshSubchartInfo(obj)
            obj.('$subchartSimStateInfo').Value = obj.SubchartRoot.getSimStateInfo;
        end
        
        function states = getActiveSubchartStates(obj)
            states = obj.SubchartRoot.getActiveStates;
        end
        
        function yn = isAtomicSubchart(obj)
            yn = ~isempty(findprop(obj, '$subchartSimStateInfo'));
        end
    end
    
end
