classdef (Hidden, Sealed) TestPoint < handle
%TestPoint Class to define a test point
%   A test point object contains probes and metrics.
%
%   TestPoint methods:
%
%   clone              - Clone the test point
%   reset              - Reset the test point
%   setValue           - Set the data value for a probe
%   setUserData        - Set the user data
%   processData        - Process the data and calculate metrics
%   getMetricNames     - Get metric names
%   getMetric          - Get the metric value
%   aggregateTestPoint - Aggregate test points from two objects
%   registerProbe      - Register a probe
%
%   TestPoint properties:
%   DataStorage
%

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:19 $

    %===========================================================================
    % Public Properties
    properties
        %DataStorage
        %   Internal data storage to pass information from one metric compute
        %   function to the next one
        DataStorage
        %UserData
        %   If user needs extra information to calculate the metric
        UserData        
    end
    
    %===========================================================================
    % Protected Properties
    properties (SetAccess = protected)
        %Name of the test point
        Name
        %Sweep point
        %   Container that holds parameter objects. The values in the
        %   CurrentValue property of these parameter objects define the current
        %   sweep point.
        SweepPoint
        %Probes
        %   Holds a containers.Map
        Probes
        %Metric processor (testconcole.Metric object)
        Metric
    end
    
    %===========================================================================
    % Public Methods
    methods
        function this = TestPoint(testPointName)
            %TestPoint Construct a test point
            
            if nargin > 0
                this.Name = testPointName;
            end
            this.Probes = containers.Map;
            this.SweepPoint = containers.Map;
        end
        %-----------------------------------------------------------------------
        function h = clone(this)
            %CLONE  Clone the test point 
            
            h = testconsole.TestPoint;
            h.Name = this.Name;
            h.SweepPoint = testconsole.cloneContainer(this.SweepPoint);
            
            % We want to use the same probe for multiple test points.  So, copy
            % instead of clone
            h.Probes = testconsole.copyContainer(this.Probes);
            
            h.Metric = clone(this.Metric);
            h.UserData = this.UserData;
            h.DataStorage = this.DataStorage;
        end
        %-----------------------------------------------------------------------
        function reset(this)
            %RESET  Reset the test point
            
            this.SweepPoint = [];
            probeNames = keys(this.Probes);
            for p=1:length(probeNames);
                reset(this.Probes(probeNames{p}))
            end
            this.UserData = [];
            reset(this.Metric);
        end
        %-----------------------------------------------------------------------
        function setSweepPoint(this, sweepPoint)
            %setSweepPoint Set the sweep point of the test point
            
            this.SweepPoint = testconsole.cloneContainer(sweepPoint);
        end
        %-----------------------------------------------------------------------
        function processData(this)
            %processData Process the test point data
            
            notSetProbes = getNotSetProbes(this);
            if ~isempty(notSetProbes)
                compute(this.Metric, this);
            else
                error(generatemsgid('NotReady'), ...
                    ['Probes %s are not set.  Set all the probes '...
                    'before processing the data.'], notSetProbes{:});
            end
        end
        %-----------------------------------------------------------------------
        function metricFun = getMetricCalculatorFunction(this)
            %getMetricCalculatorFunction Get the metric calculator function handle

            metricFun = getMetricCalculatorFunction(this.Metric);
        end
        %-----------------------------------------------------------------------
        function metrics = getMetric(this, varargin)
            %getMetric Get the metric value(s)
            
            metrics = getMetric(this.Metric, varargin{:});
        end
        %-----------------------------------------------------------------------
        function setMetric(this, metricName, val)
            %setMetric Set the metric value
            
            setMetric(this.Metric, metricName, val);
        end
        %-----------------------------------------------------------------------
        function names = getMetricNames(this)
            %getMetricNames Get the metric names
            
            if ~isempty(this.Metric)
                names = getMetricNames(this.Metric);
            else
                names = {};
            end
        end
        %-----------------------------------------------------------------------
        function names = getProbeNames(this)
            %getProbeNames Get the probe names
            
            names = keys(this.Probes);
        end
        %-----------------------------------------------------------------------
        function data = getProbeData(this, probeName)
            %getProbeData Get the probe data
            
            probe = this.Probes(probeName);
            data = probe.Data;
        end
        %-----------------------------------------------------------------------
        function aggregate(this, that)
            %AGGREGATE Aggregate the test point data
            
            aggregate(this.Metric, that.Metric);
        end
        %-----------------------------------------------------------------------
        function registerProbe(this, probeName, probe)
            %registerProbe Register a test probe to the test point
            %   registerProbe(HTP, NAME, HPROBE) adds the test probe, HPROBE,
            %   with name, NAME, to the probe list of test point, HTP.
            %
            % See also testconsole.TestPoint
            
            validateattributes(probeName, {'char'}, {}, ...
                'testconsole.TestPoint.registerProbe', 'NAME');
            
            validateattributes(probe, {'testconsole.Probe'}, {}, ...
                'testconsole.TestPoint.registerProbe', 'HPROBE');
            
            this.Probes(probeName) = probe;
        end
        %-----------------------------------------------------------------------
        function registerMetric(this, metric)
            %registerMetric Register a test metric to the test point
            %   registerMetric(HTP, HMETRIC) registers the test metric, HMETRIC,
            %   to the test point, HTP. 
            %
            % See also testconsole.TestPoint

            validateattributes(metric, {'testconsole.Metric'}, {}, ...
                'testconsole.TestPoint.registerMetric', 'metric');
            
            this.Metric = metric;
        end
    end
    
    %======================================================================
    % Protected Methods
    methods (Access = protected)
        function notSetProbes = getNotSetProbes(this)
            %getNotSetProbes Get the probes that have not received data yet

            probeNames = keys(this.Probes);
            numProbes = length(probeNames);
            notSetProbes = cell(1,numProbes);
            for p=1:numProbes
                if ~this.Probes(probeNames{p}).IsSet
                    notSetProbes{p} = probeNames{p};
                end
            end
        end
    end

    %===========================================================================
    % Set/Get methods
    methods
        function set.Name(this, val)
            validateattributes(val, {'char'}, {}, ...
                'testconsole.TestPoint.Name', 'Name')
            this.Name = val;
        end
    end
end
