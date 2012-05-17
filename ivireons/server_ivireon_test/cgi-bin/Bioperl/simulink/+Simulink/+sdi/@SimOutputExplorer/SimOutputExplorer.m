classdef SimOutputExplorer < handle

    % Copyright 2009-2010 The MathWorks, Inc.

    properties (Access = 'public')
        Outputs;
    end

    methods (Access = 'public')

        function this = SimOutputExplorer()
            this.ClearOutputs();
        end

        function ClearOutputs(this)
            this.Outputs = [];
        end

        function AddOutput(this, NewOutput)
            this.Outputs = [this.Outputs NewOutput];
        end

        function ExploreBaseWorkspace(this)
            % Get base workspace vars
            WhosOut = evalin('base', 'whos');

            % Initialize outputs
            this.ClearOutputs();

            for i = 1 : length(WhosOut)
                % Cache i'th variable
                IthVarName  = WhosOut(i).name;
                IthVarValue = evalin('base', IthVarName);

                % Explore i'th variable
                this.ExploreVariable(IthVarName, IthVarValue);
            end % for
        end

        function ExploreMATFile(this, filename)
            % Get MAT file vars
            WhosOut = whos('-file', filename);

            % Initialize outputs
            this.ClearOutputs();

            for i = 1 : length(WhosOut)
                % Cache i'th variable name
                IthVarName = WhosOut(i).name;

                % Cache i'th variable value.  Account for
                % "load" packing variables into a structure
                IthVarValue = load(filename, IthVarName);
                IthVarValue = IthVarValue.(IthVarName);

                % Explore i'th variable
                this.ExploreVariable(IthVarName, IthVarValue);
            end % for
        end

        function ExploreVariables(this, VarNames, VarValues)
            len = length(VarNames);
            for i = 1 : len
                if Simulink.sdi.Util.IsStructureWithoutTime(VarValues{i})
                    if (isnumeric(i+1) && isvector(VarValues{i+1}) && ...
                            isnumeric(VarValues{i+1}))
                        VarValues{i}.time = VarValues{i+1};
                    end
                end
                this.ExploreVariable(VarNames{i}, VarValues{i});
            end
        end

    end % methods - public

    methods (Access = 'private')

        function ExploreVariable(this, VarName, VarValue)
            % MATLAB timeseries
            if Simulink.sdi.Util.IsMATLABTimeseries(VarValue)
                this.AddMATLABTimeseries(VarName, VarValue);

            % Simulink.Timeseries
            elseif Simulink.sdi.Util.IsSimulinkTimeseries(VarValue)
                this.AddSimulinkTimeseries(VarName, VarValue);

            % Simulink simulation output
            elseif Simulink.sdi.Util.IsSimulationOutput(VarValue)
                this.AddSimulationOutput(VarName, VarValue);

            % Simulink structure with time
            elseif Simulink.sdi.Util.IsStructureWithTime(VarValue)
                this.AddStructureWithTime(VarName, VarValue);
                
            elseif Simulink.sdi.Util.isSimulationDataSet(VarValue)
                this.addSimulationDataSet(VarName, VarValue);

            % Simulink.ModelDataLogs and all supporting structures
            elseif Simulink.sdi.Util.IsModelDataLogs(VarValue)      ...
                    || Simulink.sdi.Util.IsSubsysDataLogs(VarValue) ...
                    || Simulink.sdi.Util.IsScopeDataLogs(VarValue)  ...
                    || Simulink.sdi.Util.IsTSArray(VarValue)        ...
                    || Simulink.sdi.Util.IsStateflowDataLogs(VarValue)
                this.AddGenericDataLogs(VarName, VarValue);
                
            end
                       
        end


        function AddMATLABTimeseries(this, VarName, VarValue)
            % Allocate new output
            NewOutput = Simulink.sdi.SimOutputExplorerOutput;

            % Parse dimensions
            [TimeDim, SampleDims] = this.GetTSDims(VarValue);

            % Populate data - no links back to Simulink
            NewOutput.RootSource  = VarName;
            NewOutput.TimeSource  = [VarName '.Time'];
            NewOutput.DataSource  = [VarName '.Data'];
            NewOutput.TimeValues  = VarValue.Time;
            NewOutput.DataValues  = VarValue.Data;
            NewOutput.BlockSource = ' ';
            NewOutput.ModelSource = ' ';
            NewOutput.SignalLabel = ' ';
            NewOutput.TimeDim     = TimeDim;
            NewOutput.SampleDims  = SampleDims;
            try
                NewOutput.SID     = Simulink.ID.getSID(NewOutput.BlockSource);
            catch ME%#ok
                NewOutput.SID = [];
            end
            
            % Add output
            this.AddOutput(NewOutput);
        end % AddMATLABTimeseries

        function AddSimulinkTimeseries(this, VarName, VarValue) 
            % Allocate new output
            NewOutput = Simulink.sdi.SimOutputExplorerOutput;

            % Parse dimensions
            [TimeDim, SampleDims] = this.GetTSDims(VarValue);

            % Populate data - no links back to Simulink
            NewOutput.RootSource  = VarName;
            NewOutput.TimeSource  = [VarName '.Time'];
            NewOutput.DataSource  = [VarName '.Data'];
            NewOutput.TimeValues  = VarValue.Time;
            NewOutput.DataValues  = VarValue.Data;
            NewOutput.BlockSource = VarValue.BlockPath;
            NewOutput.ModelSource = strtok(VarValue.BlockPath, '/');
            NewOutput.SignalLabel = VarValue.Name;
            NewOutput.TimeDim     = TimeDim;
            NewOutput.SampleDims  = SampleDims;
            NewOutput.PortIndex   = VarValue.PortIndex;
            try
                NewOutput.SID     = Simulink.ID.getSID(NewOutput.BlockSource);
            catch ME%#ok
                NewOutput.SID = [];
            end
            
            % Add output
            this.AddOutput(NewOutput);
        end % AddSimulinkTimeseries
        
        function addSimulationDataSet(this, varName, varValue)

            % find the number of elements
            count = varValue.getLength;
            
            % loop through each element and get relevant data
            for i = 1:count                
                % get element at index i
                elem = varValue.getElement(i);
                % check if the element is of type Simulink.SimulationData.DataStoreMemory
                if ~isa(elem, 'Simulink.SimulationData.DataStoreMemory')
                    continue;
                else
                    % Allocate new output
                    newOutput = Simulink.sdi.SimOutputExplorerOutput;
                    newOutput.TimeValues = elem.Values.Time;
                    newOutput.DataValues = elem.Values.Data;
                    newOutput.RootSource = varName;
                    newOutput.TimeSource = [varName 'getElement(' num2str(i)...
                                            ').Values.Time'];
                    newOutput.DataSource = [varName 'getElement(' num2str(i)...
                                            ').Values.Data'];
                    len = elem.BlockPath.getLength;
                    if (len > 0)
                        newOutput.BlockSource = elem.BlockPath.getBlock(len);
                    else
                        newOutput.BlockSource = ' ';
                    end
                        
                    newOutput.ModelSource = strtok(newOutput.BlockSource, '/');
                    newOutput.SignalLabel = elem.Name;
                    % Parse dimensions
                    [timeDim, sampleDims] = this.GetTSDims(elem.Values);
                    newOutput.TimeDim     = timeDim;
                    newOutput.SampleDims  = sampleDims;
                    newOutput.PortIndex   = [];
                    try
                        newOutput.SID     = Simulink.ID.getSID(newOutput.BlockSource);
                    catch ME%#ok
                        newOutput.SID = [];
                    end
                    
                    % Add output
                    this.AddOutput(newOutput);
                end
            end % for
        end

        function AddStructureWithTime(this, VarName, VarValue) 
            for i = 1 : length(VarValue.signals)
                % Cache ith signal
                IthIndexStr     = sprintf('%d', i);
                IthSignalSource = [VarName '.signals(' IthIndexStr ')'];
                IthSignalValue  = VarValue.signals(i);
                
                if (isfield(IthSignalValue, 'valueDimensions')...
                    && (~isempty(IthSignalValue.valueDimensions)))
                    continue;
                end

                % Parse dimensions
                [TimeDim, SampleDims] = this.GetStructWTimeDims(IthSignalValue);

                % Allocate new output
                NewOutput = Simulink.sdi.SimOutputExplorerOutput;

                % Populate data
                NewOutput.RootSource  = VarName;
                NewOutput.TimeSource  = [VarName '.time'];
                NewOutput.DataSource  = [IthSignalSource '.values'];
                NewOutput.TimeValues  = VarValue.time;
                NewOutput.DataValues  = IthSignalValue.values;
                
                % Check if blockName exists on the structure
                if isfield(IthSignalValue, 'blockName')
                    NewOutput.BlockSource = IthSignalValue.blockName;
                    % fromWorkspace block case
                elseif isfield(VarValue, 'blockName') 
                    NewOutput.BlockSource = VarValue.blockName;
                end
                    
                NewOutput.ModelSource = strtok(NewOutput.BlockSource, '/');
                NewOutput.SignalLabel = IthSignalValue.label;
                NewOutput.TimeDim     = TimeDim;
                NewOutput.SampleDims  = SampleDims;
                NewOutput.PortIndex   = [];
                
                try
                    NewOutput.SID     = Simulink.ID.getSID(NewOutput.BlockSource);
                catch ME%#ok
                    NewOutput.SID = [];
                end
                % Add output
                this.AddOutput(NewOutput);
            end % for
        end 

        function AddGenericDataLogs(this, VarName, VarValue)
            % Cache fields
            VarList = whos(VarValue);

            for i = 1 : length(VarList)
                % Cache i'th variable
                IthScopeVar = VarList(i);

                % Accommodate carriage returns in block names
                SafeVarName = this.SafeLogFieldName(IthScopeVar.name);

                % Form name and value
                IthScopeVarName  = [VarName '.' SafeVarName];
                IthScopeVarValue = eval(['VarValue.', SafeVarName]);

                % Explore i'th variable
                this.ExploreVariable(IthScopeVarName, IthScopeVarValue);
            end % for
        end 

        function AddSimulationOutput(this, VarName, VarValue)
            % Get vars from object
            SimOutVars = VarValue.who;

            for i = 1 : length(SimOutVars)
                % Cache i'th variable details
                IthVarName   = SimOutVars(i);
                IthVarSource = [VarName '.find(''' char(IthVarName) ''')'];
                IthVarValue  = VarValue.find(char(IthVarName));

                % Explore i'th variabls
                this.ExploreVariable(IthVarSource, IthVarValue);
            end % for
        end 

    end % methods - private

    methods (Access = 'private', Static = true)

        function [TimeDim, SampleDims] = GetTSDims(ts)
            % Cache size of data
            tssize = size(ts.Data);

            % Is time first dimension
            if ts.IsTimeFirst
                TimeDim    = 1;
                SampleDims = tssize(2:end);
            % Only 1 data point - Time is not represented
            elseif length(ts.Time) == 1
                TimeDim    = []; 
                SampleDims = tssize;
            else
                % Last dimension
                TimeDim    = ndims(ts.Data);
                SampleDims = tssize(1:end-1);
            end
        end

        function [TimeDim, SampleDims] = GetStructWTimeDims(ts)
            SampleDims = ts.dimensions;
            if isscalar(SampleDims)
                TimeDim = 1;
            else
                TimeDim = ndims(ts.values);
            end
        end

        function result = SafeLogFieldName(LogFieldName)
            % Default to input
            result = LogFieldName;
            
            % Cache length of field name
            NameLength = length(result);
            
            % Are we working with a dynamic field name?
            IsDynamicField =    (NameLength >= 2)  ...
                             && (result(1) == '(') ...
                             && (result(2) == '''');

            if IsDynamicField
                % Carriage return
                CR = char(10);

                % Attempt to replace carriage return with
                % a \n.  This may be a no-op.
                result = strrep(LogFieldName, CR, '\n');

                % Since we are replace a substring of
                % length 1 with one of length 2, it's
                % fast to compare lengths to see if
                % any replacement was done.  If it
                % was then wrap with sprintf.
                if length(LogFieldName) ~= length(result)
                    result = ['(sprintf' result ')'];
                end
            end
        end

    end % methods - private, static

end % classdef
