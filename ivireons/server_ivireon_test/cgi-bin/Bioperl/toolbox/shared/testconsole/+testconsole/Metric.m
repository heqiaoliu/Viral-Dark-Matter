classdef (Hidden, Sealed) Metric < handle
%Metric Compute metrics for test console
%
%   Metric methods:
%
%   clone                       - Clone the Metric object
%   compute                     - Compute metrics
%   aggregate                   - Aggregate metrics
%   reset                       - Reset the metric object
%   getMetricNames              - Get metric names
%   getMetric                   - Get the value of the metric
%   setMetric                   - Set the value of the metric
%   setComputeFunctions         - Set metric computation functions
%   setAggregateFunctions       - Set metric aggregation functions
%   setMetricCalculatorFunction - Set main metric calculator function
%   getMetricCalculatorFunction - Get main metric calculator function
%
%   See also testconsole

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:14 $

    %===========================================================================
    % Private Properties
    properties (Access = private)
        %Metrics
        Metrics
        %Metric names
        MetricNames
        %Initial values for metrics
        InitialValues
        %Metric indices
        %   Used to relate indices to names
        MetricIndices
        %Compute function handle(s)
        ComputeFunctions
        %Aggregate function handle(s)
        AggregateFunctions
        %Number of metric functions
        NumMetricFunctions
        %Main metric calculator function
        %   This function can be set by the user during run time and is intended
        %   to calculate all the metrics and return the results in the order
        %   determined by the specific test console.
        MetricCalculatorFunction
    end
    
    %===========================================================================
    % Public Methods
    methods
        function this = Metric(varargin)
            %METRIC Construct a metric object
            %   If input is not empty, then it should correspond to a structure
            %   with field names equal to metric names and field values equal to
            %   metric initial values.
            
            numMetrics = 0;
            if nargin > 0 
                if nargin > 1
                    error(generatemsgid('tooManyArgsInMetric'),...
                        (['Too many input arguments to the Metric ',...
                        'constructor.']));                    
                end                
                validateattributes(varargin{1},...
                    {'struct'},...
                    {}, ...
                    class(this),...
                    'Metric Constructor');                
                inputNames = fieldnames(varargin{1});
                inputValues = struct2cell(varargin{1});
                numMetrics = length(inputNames);
            end
            metricNames = {};
            metrics = cell(1, numMetrics);
            initValues = cell(1, numMetrics);
            this.MetricIndices = containers.Map;
            
            for p=1:numMetrics
                metricNames = [metricNames inputNames{p}]; %#ok<AGROW>
                metrics{p} = inputValues{p};
                initValues{p} = inputValues{p};
                this.MetricIndices(inputNames{p}) = p;
            end
            this.MetricNames = metricNames;
            this.Metrics = metrics;
            this.InitialValues = initValues;
        end
        %-----------------------------------------------------------------------
        function setComputeFunctions(this, funHandle)
            %setComputeFunctions Set the compute function handles
            
            this.ComputeFunctions = funHandle;
            this.NumMetricFunctions = length(funHandle);
        end
        %-----------------------------------------------------------------------
        function setAggregateFunctions(this, funHandle)
            %setAggregateFunctions Set the aggregate function handles

            this.AggregateFunctions = funHandle;
            this.NumMetricFunctions = length(funHandle);
        end
        %-----------------------------------------------------------------------
        function setMetricCalculatorFunction(this, funHandle)
            %setMetricCalculatorFunction Set the metric calculator function handle
            
            reset(this)
            if ~isempty(funHandle)
                validateattributes(funHandle, {'function_handle'}, {}, ...
                    class(this), ...
                    'Metric calculator function handle')
            end
            this.MetricCalculatorFunction = funHandle;
        end
        %-----------------------------------------------------------------------
        function funHandle = getMetricCalculatorFunction(this)
            %getMetricCalculatorFunction Get the metric calculator function handle

            funHandle = this.MetricCalculatorFunction;
        end
        %-----------------------------------------------------------------------
        function compute(this, testPoint)
            %COMPUTE Compute the metrics
            
            for p=1:this.NumMetricFunctions
                fun = this.ComputeFunctions{p};
                this.Metrics{p} = fun(testPoint);
            end
        end
        %-----------------------------------------------------------------------
        function aggregate(this, that)
            %AGGREGATE Aggregate the metrics
            
            for p=1:this.NumMetricFunctions
                fun = this.AggregateFunctions{p};
                this.Metrics{p} = fun(this, that);
            end
        end
        %-----------------------------------------------------------------------
        function names = getMetricNames(this)
            %getMetricNames Get metric names
            
            names = this.MetricNames;
        end
        %-----------------------------------------------------------------------
        function val = getMetric(this, metricName)
            %getMetric Get metric value
            
            if nargin == 1
                % No metric name is specified.  Return all metrics in a
                % structure.
                metricNames = keys(this.MetricIndices);
                for p=1:length(metricNames)
                    val.(metricNames{p}) = this.Metrics{...
                        this.MetricIndices(metricNames{p})};
                end
            else
                if isKey(this.MetricIndices, metricName)
                    val = this.Metrics{this.MetricIndices(metricName)};
                else
                    allMetricNames = this.MetricNames;
                    names = '';
                    for p=1:length(allMetricNames)
                        names = sprintf('%s\n%s', names, allMetricNames{p});
                    end
                    error(generatemsgid('InvalidMetricName'), ['Metric name '...
                        '%s is not recognized.  Available metrics are %s.'], ...
                        metricName, names);
                end
            end
        end
        %-----------------------------------------------------------------------
        function setMetric(this, metricName, val)
            %setMetric Set metric value
            
            if isKey(this.MetricIndices, metricName)
                this.Metrics{this.MetricIndices(metricName)} = val;
            else
                allMetricNames = this.MetricNames;
                names = '';
                for p=1:length(allMetricNames)
                    names = sprintf('%s\n%s', names, allMetricNames{p});
                end
                error(generatemsgid('InvalidMetricName'), ['Metric name '...
                    '%s is not recognized.  Available metrics are %s.'], ...
                    metricName, names);
            end
        end
        %-----------------------------------------------------------------------
        function reset(this)
            %RESET Reset the metric object
            
            this.Metrics = this.InitialValues;
        end
        %-----------------------------------------------------------------------
        function h = clone(this)
            %CLONE Clone the Metric object
            %   HCLONE = clone(H) creates clone, HCLONE, of Metric object, H.
            h = testconsole.Metric;
            h.Metrics = this.Metrics;
            h.MetricNames = this.MetricNames;
            h.InitialValues = this.InitialValues;
            h.MetricIndices = testconsole.copyContainer(this.MetricIndices);
            h.ComputeFunctions = this.ComputeFunctions;
            h.AggregateFunctions = this.AggregateFunctions;
            h.MetricCalculatorFunction = this.MetricCalculatorFunction;
            h.NumMetricFunctions = this.NumMetricFunctions;
        end
    end
end
