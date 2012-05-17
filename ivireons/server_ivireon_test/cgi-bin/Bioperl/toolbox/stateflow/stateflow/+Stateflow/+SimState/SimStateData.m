classdef SimStateData < Stateflow.SimState.SimStateObject

    %   Copyright 2008-2009 The MathWorks, Inc.

    properties (Constant, Hidden)
        % IMPORTANT: This ordered list of sim state data types must match
        % that defined in cdr_simulation_save_restore.cpp
        SFSS_NOT_A_STATE = 0;
        SFSS_CHART_OUTPUT = 1;
        SFSS_STATE_OUTPUT_DATA = 2;
        SFSS_CHART_LOCAL = 3;
        SFSS_EML_PERSISTENT = 4;
        SFSS_CT_DATA = 5;
        SFSS_OUTPUT_EVENT_DATA = 6;        
        SFSS_OUTPUT_EVENT_COUNTER = 7;
        SFSS_STATE_IS_ACTIVE = 8;
        SFSS_STATE_ACTIVE_CHILD = 9;
        SFSS_STATE_PREV_ACTIVE_CHILD = 10;
        SFSS_TEMPORAL_COUNTER = 11;
        SFSS_CHANGE_DETECTION_START_BUFFER = 12;
        SFSS_PREVIOUS_COUNT = 13;
        SFSS_SUBCHART_SIMSTATE_INFO = 14;
    end

    properties (SetAccess = private, Hidden)
        Index = -1;
        AuxInfo = [];
    end

    properties (SetAccess = private)
        Description = '';
        DataType = '';
        Size = '';
        Range = struct('Minimum', [], 'Maximum', []);
        InitialValue = [];
    end

    properties
        Value = [];
    end
        
    methods (Static, Hidden, Access = private)
        
        function result = isCastableClass(className)
            switch className
                case {'double', 'single', 'logical', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64'}
                    result = true;
                otherwise
                    result = false;
            end
        end
        
        function newVal = checkValueCompatibility(newVal, oldVal, subfield)
            ctxstr = '';
            if nargin > 2 && ~isempty(subfield)
                ctxstr = sprintf(' for value subfield ''%s''', subfield);
            end
            
            if isstruct(oldVal) && isstruct(newVal)
                % Check size matches
                if ~isequal(size(newVal), size(oldVal))
                    error('Stateflow:SimStateError', 'Can''t change sim state data size%s.', ctxstr);
                end
                
                % Check field names
                oldValFN = fieldnames(oldVal);
                newValFN = fieldnames(newVal);
                if ~isequal(sort(oldValFN), sort(newValFN))
                    error('Stateflow:SimStateError', 'Can''t add, delete, or change sim state data struct fields%s.', ctxstr);
                elseif ~isequal(oldValFN, newValFN)
                    newVal = orderfields(newVal, oldVal);
                end
                
                for k = 1:numel(oldVal)
                    % Recursively check each field values
                    for i = 1:length(oldValFN)
                        fn = oldValFN{i};
                        subfld = sprintf('%s.%s', subfield, fn);
                        newVal(k).(fn) = Stateflow.SimState.SimStateData.checkValueCompatibility(newVal(k).(fn), oldVal(k).(fn), subfld);
                    end
                end
            else
                % Check types are compatible
                oldCls = class(oldVal);
                newCls = class(newVal);
                
                if ~isequal(newCls, oldCls) && ...
                        ~(Stateflow.SimState.SimStateData.isCastableClass(oldCls) && Stateflow.SimState.SimStateData.isCastableClass(newCls))
                    error('Stateflow:SimStateError', 'Can''t change sim state data class from ''%s'' to ''%s''%s.', oldCls, newCls, ctxstr);
                elseif ~isequal(newCls, oldCls)
                    newVal = cast(newVal, oldCls);
                end
            end
            
            % Check size matches
            if ~isequal(size(newVal), size(oldVal))
                error('Stateflow:SimStateError', 'Can''t change sim state data size%s.', ctxstr);
            end
        end
        
    end
    
    methods

        function obj = SimStateData(name, type, source, index, value, desc, range, initVal, dtype, size, auxinfo)
            obj = obj@Stateflow.SimState.SimStateObject(name, type, source);
            obj.Index = index;
            obj.Value = value;
            obj.Description = desc;
            obj.DataType = dtype;
            obj.Size = size;
            obj.Range = range;
            obj.InitialValue = initVal;
            obj.AuxInfo = auxinfo;
        end
        
        function disp(obj)
            obj.getdisp;
        end

        function open(obj)
            if obj.Type == Stateflow.SimState.SimStateData.SFSS_EML_PERSISTENT && ~isempty(obj.AuxInfo)
                if ~isempty(obj.AuxInfo.p)
                    sfObjId = sf('Private', 'eml_man', 'open_mfile', obj.AuxInfo.p);
                else
                    obj.openRootSystem;
                    h = obj.getSourceHandle;
                    sfObjId = h.Id;
                end
                sf('Open', sfObjId, obj.AuxInfo.l(1), obj.AuxInfo.l(2));
            else
                open@Stateflow.SimState.SimStateObject(obj);
            end
        end

        function set.Value(obj, newVal)
            if ~isempty(obj.Root)
                % Plant model states are read-only
                if obj.Root.SimStateInfo.chartIsPlantModel
                    error('Stateflow:SimStateError', 'Changing simulation state for continuous time chart is not allowed.');
                end
                
                % State output data are read-only
                if obj.Type == Stateflow.SimState.SimStateData.SFSS_STATE_OUTPUT_DATA
                    if iscell(newVal)
                        % This is internal assignment.
                        newVal = newVal{1};
                    else
                        error('Stateflow:SimStateError', 'State output data value is read-only.');
                    end
                end
                
                % Check new value
                if ~strcmp(obj.DataType, 'ml') % Stateflow "ml" type data can be assigned to ANY value.
                    % Check type/size compatibility
                    newVal = Stateflow.SimState.SimStateData.checkValueCompatibility(newVal, obj.Value, '');
                                        
                    % Check min/max
                    if (~isempty(obj.Range.Minimum) && isfinite(obj.Range.Minimum) && any(newVal(:) < obj.Range.Minimum)) || ...
                            (~isempty(obj.Range.Maximum) && isfinite(obj.Range.Maximum) && any(newVal(:) > obj.Range.Maximum))
                        error('Stateflow:SimStateError', 'New value is out of range.');
                    end
                end
            end

            obj.Value = newVal;
        end
        
    end
    
    methods (Hidden)
        
        function result = isHidden(obj)
            switch obj.Type
                case {Stateflow.SimState.SimStateData.SFSS_CHART_OUTPUT, ...
                      Stateflow.SimState.SimStateData.SFSS_STATE_OUTPUT_DATA, ...
                      Stateflow.SimState.SimStateData.SFSS_CHART_LOCAL, ...
                      Stateflow.SimState.SimStateData.SFSS_CT_DATA}
                    result = false;
                case Stateflow.SimState.SimStateData.SFSS_EML_PERSISTENT
                    if false && ~isempty(obj.AuxInfo) && obj.AuxInfo.i ~= 0
                        % Persistent var from eml internal functions
                        % Branch disabled as M files on path are marked as
                        % internal as well for now.
                        result = true;
                    else
                        result = false;
                    end
                otherwise
                    result = true;
            end
        end
        
    end
end
