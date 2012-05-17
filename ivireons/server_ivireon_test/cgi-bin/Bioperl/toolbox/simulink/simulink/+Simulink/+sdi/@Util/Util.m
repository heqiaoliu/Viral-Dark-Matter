classdef Util
    % Utility functions used in the SDI API
    % 
    % Copyright 2009-2010 The MathWorks, Inc.
    
    properties (Constant = true)
        % Synchronization options for SyncOpts class.
        Interp = {'zoh','linear'};
        Sync   = {'union','intersection','uniform'};
    end
    
    methods (Static = true)
    
        function result = IsMATLABTimeseries(var)
            result = isa(var, 'timeseries');
        end

        function result = IsSimulinkTimeseries(var)
            result = isa(var, 'Simulink.Timeseries');
        end

        function result = IsModelDataLogs(var)
            result = isa(var, 'Simulink.ModelDataLogs');
        end

        function result = IsSubsysDataLogs(var)
            result = isa(var, 'Simulink.SubsysDataLogs');
        end

        function result = IsScopeDataLogs(var)
            result = isa(var, 'Simulink.ScopeDataLogs');
        end

        function result = IsStateflowDataLogs(var)
            result = isa(var, 'Simulink.StateflowDataLogs');
        end
        
        function result = IsTSArray(var)
            result = isa(var, 'Simulink.TsArray');
        end

        function result = IsSimulationOutput(var)
            result = isa(var, 'Simulink.SimulationOutput');
        end
        
        function result = IsStructureWithTime(var)
            result = isstruct(var)                       ...
                     && isfield(var, 'time')             ...
                     && isfield(var, 'signals')          ...
                     && ~isempty(var.time);
        end
        
        function result = IsStructureWithoutTime(var)
            result = isstruct(var)                       ...
                     && isfield(var, 'time')             ...
                     && isfield(var, 'signals')          ...
                     && isfield(var.signals, 'blockName')...
                     && isempty(var.time);
        end
        
        function result = isSimulationDataSet(var)
            result = isa(var, 'Simulink.SimulationData.Dataset');
        end
        
        function result = IsSDISupportedType(var)
            % Cache Util class
            UC = Simulink.sdi.Util;

            % "or" supported types
            result =    UC.IsMATLABTimeseries(var)    ...
                     || UC.IsSimulinkTimeseries(var)  ...
                     || UC.IsModelDataLogs(var)       ...
                     || UC.IsSubsysDataLogs(var)      ...
                     || UC.IsScopeDataLogs(var)       ...
                     || UC.IsTSArray(var)             ...
                     || UC.IsSimulationOutput(var)    ...
                     || UC.IsStructureWithTime(var)   ...
                     || UC.IsStructureWithoutTime(var)...
                     || UC.isSimulationDataSet(var);
        end

        function VarNameList = GetLogVarNamesFromModel(ModelName)

            % Initialize list of variables
            VarNameList = {};

            % Get model Configset
            Configset = getActiveConfigSet(ModelName);
            
            % Cache Util class
            UC = Simulink.sdi.Util;
            
            isSignalLogging = get_param(ModelName, 'ModelSignalLogs');
            
            VarNameList = UC.SafeAddCSParam(VarNameList,              ...
                                            Configset,                ...
                                            'ReturnWorkspaceOutputs', ...
                                            'ReturnWorkspaceOutputsName');
            VarNameList = UC.SafeAddCSParam(VarNameList, ...
                                            Configset,   ...
                                            'SaveState', ...
                                            'StateSaveName');
            VarNameList = UC.SafeAddCSParam(VarNameList,  ...
                                            Configset,    ...
                                            'SaveOutput', ...
                                            'OutputSaveName');
            VarNameList = UC.SafeAddCSParam(VarNameList,      ...
                                            Configset,        ...
                                            'SaveFinalState', ...
                                            'FinalStateName');
                                        
            if ~isempty(isSignalLogging)
                VarNameList = UC.SafeAddCSParam(VarNameList,     ...
                                                Configset,       ...
                                                'SignalLogging', ...
                                                'SignalLoggingName');
            end
            
            VarNameList = UC.SafeAddCSParam(VarNameList,     ...
                                            Configset,       ...
                                            'DSMLogging', ...
                                            'DSMLoggingName');                          
          
                                        
            if isequal(get_param(Configset, 'SaveFormat'), 'Structure') ...
               VarNameList = UC.SafeAddCSParam(VarNameList,     ...
                                               Configset,       ...
                                              'SaveTime',       ...
                                              'TimeSaveName');
            end
        end

        function VarNameList = SafeAddCSParam(VarNameList, ...
                                              Configset,   ...
                                              EnableParam, ...
                                              NameParam)

            % if the logging setting is on, add variable to list
            if isequal(get_param(Configset, EnableParam), 'on')
                VarNameList{end + 1} = get_param(Configset, NameParam);
            end
        end
        
        function VarValues = BaseWorkspaceValuesForNames(VarNames)
            % Cache number of variables to add
            VarCount = length(VarNames);

            % Get values for names
            VarValues = cell(1, VarCount);
            for i = 1 : VarCount
                try
                    VarValues{i} = evalin('base', VarNames{i});
                catch %#ok
                    VarValues{i} = [];
                end
            end
        end

        % Helper function to validate data type. Used in VaryingTol, diffRuns,
        % Tolerance, Criterion, SyncOpts, Basic Tol, Data classes.
        function result = validateType(value, type)
            result = isa(value, type);
        end
                
        function validatedValue = validateTolerance(value)
            validatedValue = Simulink.sdi.Util.validateScalarNumericValue(value);
        end
        
        function validatedValue = validateScalarNumericValue(value)
            
            % Initialize outputs
            validatedValue = 0;%#ok<NASGU>
            
            if(isempty(value))
                DAStudio.error('SDI:sdi:EmptyValue');
            end
            
            % Check that values are real, not complex.
            % Note: Not using insumeric because isnumeric(complexVal)
            % returns true.  isnumeric(fi) returns true.
            if(ischar(value) || ~isscalar(value) || ~isreal(value))
                DAStudio.error('SDI:sdi:ValidateDataType', ...
                    'scalar numeric', 'real');
            end
            
            % Check that values are not NaN.
            if(isnan(value))
                DAStudio.error('SDI:sdi:ValAreNaNs');
            end
            
            % Check that the values are not inf
            if isinf(value)
                DAStudio.error('SDI:sdi:ValAreInf');
            end
            
            % Check that values are not embedded.fi
            if(isa(value,'embedded.fi'))
                DAStudio.error('SDI:sdi:ValAreFi');
            end
            
            % Check that the value is not smaller than eps and grater than zero.
            if( value > 0 && value < eps )
                DAStudio.error('SDI:sdi:ValAreSmallerEpsGraterZero');
            end
            
            validatedValue = value;
        end 
        
        function validatedInterpMtd = validateInterpMethod(value)
            
            validatedInterpMtd = []; %#ok<NASGU>
            
            if(~ischar(value))
                DAStudio.error('SDI:sdi:ValidateDataType',...
                               'interp method','char');
            end
            
            value = lower(value);
            
            if( ~( strcmp(value, 'linear') || strcmp(value, 'zoh') ) )
                DAStudio.error('SDI:sdi:ValidateInterpOpts', value);
            end
            
            validatedInterpMtd = value;
            
        end

        function validatedSyncMtd = validateSyncMethod(value)
            
            validatedSyncMtd = []; %#ok<NASGU>
            
            if(~ischar(value))
                DAStudio.error('SDI:sdi:ValidateDataType',...
                               'sync method', 'char');
            end
            
            value = lower(value);
            
            if( ~(strcmp(value, 'union') || ...
                    strcmp(value, 'intersection') || ...
                    strcmp(value, 'uniform') ) )
                DAStudio.error('SDI:sdi:ValidateSyncOpts', value);
            end
            
            validatedSyncMtd = value;
            
        end

        function validatedInterval = validateInterval(value)
            validatedInterval = Simulink.sdi.Util.validateScalarNumericValue(value);
        end

        function OnOff = BoolToOnOff(bool)
            if bool, OnOff = 'on'; 
            else     OnOff = 'off';
            end
        end
        
    end % methods - static
    
end % classdef