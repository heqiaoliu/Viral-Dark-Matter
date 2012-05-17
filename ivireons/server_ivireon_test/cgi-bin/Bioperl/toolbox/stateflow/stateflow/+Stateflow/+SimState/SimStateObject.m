classdef SimStateObject < hgsetget
        
    properties (SetAccess = protected, GetAccess = protected, Hidden)
        Name = '';
        Type = 0;
        Source = 0;  % Source ID relative to root chart
        
        PropName = ''; % Property name as added to dynamic props parent container
                       % In most case, it's the same as "Name". If there is
                       % a collision with pre-existing props/methods names,
                       % the PropName is uniquified.
        
        Root = [];   % Pointer to root chart node
        Parent = []; % Pointer to parent container node
    end
    
    methods (Access = protected, Static, Hidden)

        function h = getHandleBySource(chartPath, source)
            % This method relies on model being open
            if isequal(source, 0) || isequal(chartPath, source)
                chartId = sf('Private', 'block2chart', chartPath);
                h = idToHandle(sfroot, chartId);
            else
                ssId = sprintf('%s:%d', chartPath, source);
                h = sf('Private', 'ssIdToHandle', ssId);
            end
        end

        function str = escapeSimulinkName(str, escapeSingleQuote)
            str = regexprep(str, '\n', ' ');
            if escapeSingleQuote
                str = regexprep(str, '''', '''''');
            end
        end
        
    end
    
    methods (Hidden, Access = protected)
        
        function result = isRootSystemOpen(obj)
            m = find(slroot, '-isa', 'Stateflow.Machine', 'Name', obj.Root.RootSystem); %#ok<GTARG>
            result = ~isempty(m);
        end
        
        function openRootSystem(obj)
            if ~obj.isRootSystemOpen
                if exist(obj.Root.RootSystem, 'file') == 4 % "4" for MDL-file
                    open_system(obj.Root.RootSystem);
                else
                    error('Stateflow:SimStateError', 'Unable to open model file named ''%s''.', obj.Root.RootSystem);
                end
            end
        end
        
        function h = getSourceHandle(obj)
            % This method relies on model being open
            h = Stateflow.SimState.SimStateObject.getHandleBySource(obj.Root.Source, obj.Source);
        end

    end

    methods (Hidden)

        function path = getPath(obj)
            if ~isempty(obj.Parent)
                path = sprintf('%s/%s', obj.Parent.getPath, obj.Name);
            else
                path = obj.Source;
            end
        end

        function name = getName(obj)
            name = obj.Name;
        end

        function path = getEscapedPath(obj, escapeSingleQuote)
            if nargin < 2
                escapeSingleQuote = false;
            end
            path = Stateflow.SimState.SimStateObject.escapeSimulinkName(obj.getPath, escapeSingleQuote);
        end
        
        function name = getEscapedName(obj, escapeSingleQuote)
            if nargin < 2
                escapeSingleQuote = false;
            end
            name = Stateflow.SimState.SimStateObject.escapeSimulinkName(obj.getName, escapeSingleQuote);
        end
        
        function name = getPropName(obj)
            name = obj.PropName;
        end
        
        function setPropName(obj, name)
            obj.PropName = name;
        end

    end
    
    methods
        
        function obj = SimStateObject(name, type, source)
            obj.Name = name;
            obj.Type = type;
            obj.Source = source;
            obj.PropName = name;
        end

        function open(obj)
            obj.openRootSystem;
            h = obj.getSourceHandle;
            sf('Open', h.Id);
        end
                                
    end
        
end
