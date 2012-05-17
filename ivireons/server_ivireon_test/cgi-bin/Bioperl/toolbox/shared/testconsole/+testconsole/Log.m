classdef (Hidden, Sealed) Log < handle
% Log  Log the test console results
% testconsole.Log returns a test console results logger that holds results for
% all the test points for each sweep point.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:13 $

    properties
        %FormatPlotFunction Handle to format plot function of the test console
        FormatPlotFunction
        %DefaultMetric Metric set as TestParameter1 by default
        DefaultMetric
    end
    %===========================================================================
    % Protected Properties
    properties (SetAccess = protected)
        %CurrentTestPoints Current Test points
        CurrentTestPoints
        %TestPoints Test points
        % A 2D matrix of TestPoints and sweep points
        TestPoints
        %TestPointIndices Container with indices to test point names
        TestPointIndices
    end
    properties (Access = private, Dependent, Hidden)        
        %TestPointNames
        %   TestPointNames property existed in R2009b and was removed from the
        %   R2010a Log class. We define a private, dependent and Hidden
        %   TestPointNames property so that, at load time of an R2009b object,
        %   we force the built-in load function to call the set method of
        %   TestPointNames. Inside this set method we will initialize properties
        %   created in R2010a that are empty in the loaded R2009b object. This
        %   technique will allow the loading of R2009b objects without the need
        %   to write a loadobj method.
        TestPointNames 
    end
    %===========================================================================
    % Protected Properties
    properties (Access = private)
        %State State of the test log
        %   Can be: 
        %   'Uninitialized': no sweep point set
        %   'CollectingData': sweep point set, but not all the data collected
        State = 'Uninitialized';
    end
    
    %===========================================================================
    % Static Methods
    methods (Static)
        function aggregate(thisTestPoints, thatTestPoints)
            %AGGREGATE Aggregate the results of two test points
            for p=1:length(thisTestPoints)
                aggregate(thisTestPoints(p), thatTestPoints(p));
            end
        end
    end
    
    %===========================================================================
    % Public Methods
    methods
        function set.FormatPlotFunction(this,value)
            if ~isempty(value)
                propName = 'FormatPlotFunction';
                validateattributes(value,...
                    {'function_handle'},...
                    {'scalar'}, ...
                    [class(this) '.' propName],...
                    propName);
            end
            this.FormatPlotFunction = value;
        end  
        %-----------------------------------------------------------------------
        function set.DefaultMetric(this,value)
            propName = 'DefaultMetric';
            validateattributes(value,...
                {'char'},...
                {'vector'}, ...
                [class(this) '.' propName],...
                propName);
            
            this.DefaultMetric = value;
        end
        %-----------------------------------------------------------------------        
        function set.TestPointNames(this,value)
            %Set TestPointNames dependent property
            %   TestPointNames was renamed as TestPointIndices in R2010a. When
            %   loading an R2009b test console, the set method of TestPointNames
            %   will be called and we will initialize TestPointIndices with the
            %   TestPointNames value. At this same call, we will also initialize
            %   the FormatPlotFunction property which did not exist in R2009b.            
            warning(generatemsgid('R2009bLogLoad'), ...
                ['Loading of commtest.ErrorRate objects ',....
                'created with Communications Toolbox Version 4.4 ',...
                'will not be supported in the future. We recommend ',...
                'that you re-save the object.'])            
            this.TestPointIndices = value;
            this.FormatPlotFunction = @commtest.errorRateTestConsoleFormatPlot;
        end
    end
    %===========================================================================    
    % Public Hidden Methods
    methods (Hidden = true)
        function h = clone(this)
            %CLONE Clone the log
            %   HCLONE = clone(H) clones Log object, H, and returns as HCLONE.
            %
            %   See also testconsole.Log
            
            h = testconsole.Log;
            h.FormatPlotFunction = this.FormatPlotFunction;
            h.DefaultMetric = this.DefaultMetric;
            
            if ~isempty(this.TestPoints)
                [numRows numCols] = size(this.TestPoints);
                testPoints(numRows, numCols) = testconsole.TestPoint;
                for p=1:numRows
                    for q=1:numCols
                        testPoints(p,q) = clone(this.TestPoints(p,q));
                    end
                end
                h.TestPoints = testPoints;
            end
            if ~isempty(this.CurrentTestPoints)
                [numRows numCols] = size(this.CurrentTestPoints);
                clear testPoints
                testPoints(numRows, numCols) = testconsole.TestPoint;
                for p=1:numRows
                    for q=1:numCols
                        testPoints(p,q) = clone(this.CurrentTestPoints(p,q));
                    end
                end
                h.CurrentTestPoints = testPoints;
            end
            h.TestPointIndices = testconsole.copyContainer(this.TestPointIndices);
            h.State = this.State ;
        end
        %-----------------------------------------------------------------------
        function initialize(this, testPoints)
            %INITIALIZE Initialize the log for given test points
            %   INITIALIZE(H, TESTPOINT) Initializes the log object, H, and sets
            %   up the log for test points, TESTPOINT.
            %
            % See also testconsole.Log
                        
            % Create a container to map index to test point names
            this.TestPointIndices = containers.Map;
            names = keys(testPoints);
            for p=1:length(names)
                this.TestPointIndices(names{p}) = p;
            end            
        end        
        %-----------------------------------------------------------------------
        function reset(this, testPoints)
            %RESET Reset the log for given test points
            %   RESET(H, TESTPOINT) resets the log object, H, and sets up the
            %   log for test points, TESTPOINT.
            %
            % See also testconsole.Log
            
            this.TestPoints = [];            
            initialize(this,testPoints);            
            this.State = 'Uninitialized';
        end
        %-----------------------------------------------------------------------
        function startNewLogPoint(this, sweepPoint, testPoints)
            %startNewLogPoint Start a new log point
            %   startNewLogPoint(H, SWEEPPOINT, TESTPOINTs) starts a new log
            %   point for log, H, with sweep point, SWEEPPOINT, and test points,
            %   TESTPOINTS)
            %
            %   See also testconsole.Log
            
            % Start a new test log
            if strcmp(this.State, 'Uninitialized')
                % Make a copy of input test points and set the CurrentTestPoint
                % property
                validateattributes(testPoints, {'containers.Map'}, {}, ...
                    'testconsole.Log', 'testPoints');
                
                names = keys(testPoints);
                for p = 1:length(names)
                    if isa(testPoints(names{p}), 'testconsole.TestPoint')
                        testPoint = clone(testPoints(names{p}));
                        % Set sweep point of all test points
                        setSweepPoint(testPoint, sweepPoint);
                        temp(this.TestPointIndices(names{p})) = testPoint; %#ok<AGROW>
                    else
                        error(generatemsgid('NotTestPoint'), ...
                            ['''testPoints'' must be a container of '...
                            'test points.'])
                    end
                end
                this.CurrentTestPoints = temp;
            else
                error(generatemsgid('CollectingData'), ...
                    'Test log ''%s'' Already collecting data', this.Name);
            end
            this.State = 'CollectingData';
        end
        %-----------------------------------------------------------------------
        function processCurrentTestPointsData(this)
            %processCurrentTestPointsData Process current test points' data
            %
            % See also testconsole.Log
            
            for p=1:length(this.CurrentTestPoints)
                processData(this.CurrentTestPoints(p))
            end
         end
        %-----------------------------------------------------------------------
        function endLogPoint(this, currentTestPoint)
            %endLogPoint End the test log point
            %   endLogPoint(H, TESTPOINT) ends the log point for log, H, with
            %   current test point data, TESTPOINT.
            %
            % See also testconsole.Log

            if strcmp(this.State, 'CollectingData')
                % Add current test point to the TestPoints log
                this.TestPoints = [this.TestPoints; currentTestPoint];
            else
                error(generatemsgid('WrongState'), ...
                    'Test log is not collecting data');
            end
            this.State = 'Uninitialized';
        end
        %-----------------------------------------------------------------------
        function testPoint = getCurrentTestPoint(this, testPointName)
            %getCurrentTestPoint Get current test point
            %
            % See also testconsole.Log
            
            testPoint = this.CurrentTestPoints(...
                this.TestPointIndices(testPointName));
        end
        %-----------------------------------------------------------------------
        function metricNames = getMetricNames(this)
            %getMetricNames Return metric names
            
            % We assume that all the test points have the same metrics
            metricNames = getMetricNames(this.TestPoints(1,1));
        end
        %-----------------------------------------------------------------------
        function paramNames = getTestParameterNames(this)
            %getTestParameterNames Get test parameter names
            
            % We assume that all the test points have the same parameters
            sweepPoint = this.TestPoints(1,1).SweepPoint;
            paramNames = keys(sweepPoint);
        end
        %-----------------------------------------------------------------------
        function sweepVector = getTestParameterSweepRange(this, paramName)
            %getTestParameterSweepRange Get test parameter sweep range
            
            % We assume that all the test points have the same parameters
            sweepVector = this.TestPoints(1,1).SweepPoint(paramName).SweepVector;
        end
        %-----------------------------------------------------------------------
        function sweepPoints = getTestSweepPoints(this, testPointName, paramName)
            %getTestSweepPoints Get sweep points for given test point
            
            testPoints = this.TestPoints(:, this.TestPointIndices(testPointName));
            numTestPoints = length(testPoints);
            sweepPoint = testPoints(1).SweepPoint;
            temp = sweepPoint(paramName).CurrentValue;
            if ischar(temp)
                sweepPoints = cell(numTestPoints,1);
            else
                sweepPoints = zeros(numTestPoints,1);
            end
            for p=1:numTestPoints
                sweepPoint = testPoints(p).SweepPoint;
                temp = sweepPoint(paramName).CurrentValue;
                if ischar(temp)
                    sweepPoints{p} = sweepPoint(paramName).CurrentValue;
                else
                    sweepPoints(p) = sweepPoint(paramName).CurrentValue;
                end
            end
        end
        %-----------------------------------------------------------------------
        function metricData = getTestMetricData(this, testPointName, metricName)
            %getTestMetricData Get test metric data
            
            testPoints = this.TestPoints(:, this.TestPointIndices(testPointName));
            numTestPoints = length(testPoints);
            metricData = zeros(numTestPoints,1);
            for p=1:numTestPoints
                metricData(p) = getMetric(testPoints(p), metricName);
            end
        end
        %-----------------------------------------------------------------------
        function names = getTestPointNames(this)
            %getTestPointNames Get test point names
            
            names = keys(this.TestPointIndices);
        end
    end
end
