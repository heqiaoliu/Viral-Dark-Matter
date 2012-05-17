classdef (Sealed) Results < handle & sigutils.sorteddisp 
%Results Results of the test console run
%   H = testconsole.Results creates a simulation results object, H.  
%
%   testconsole.Results methods:
%       getData                      - Get results data
%       plot                         - Plot results data
%       semilogy                     - Plot results data in a semi-log scale
%       surf                         - Generate surface plots of results data
%       setParsingValues             - Set parsing values
%       getParsingValues             - Get parsing values
%
%   testconsole.Results properties:
%       TestConsoleName              - Test console name. Read-only
%       SystemUnderTestName          - System under test name. Read-only
%       IterationMode                - Iteration mode. Read-only
%       Testpoint                    - Test point name
%       Metric                       - Metric name 
%       TestParameter1               - Test parameter 1 name
%       TestParameter2               - Test parameter 2 name

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:17 $
    
    %===========================================================================
    % Dependent Public Properties
    properties (Dependent)
        %TestPoint Test point name
        %   Specify the name of the test point for which results will be parsed.
        %   The getData and plot methods of the results object will return data
        %   and create a plot for the specified test point name in the TestPoint
        %   property.
        %   You obtain a list of available test points using the info method of
        %   the test console.
        %
        %   See also testconsole.Results.
        TestPoint
        %Metric Test metric name
        %   Specify the name of the test metric for which results will be
        %   parsed. The getData and plot methods of the results object return
        %   data and create a plot for the specified metric in the Metric
        %   property. 
        %   You obtain a list of available test metrics using the info method of
        %   the test console.
        %
        % See also testconsole.Results.
        Metric
        %TestParameter1 Test parameter name for first independent variable
        %   Specify the name of the first independent variable for which results
        %   will be parsed. This property is only relevant when IterationMode is
        %   'Combinatorial' and at least one test parameter was registered to
        %   the test console by the system under test. In this scenario, the
        %   getData method of the results object returns a matrix with rows
        %   containing results for all the sweep values of the test parameter 
        %   specified in the TestParameter1 property and columns containing
        %   results for all the sweep values of the test parameter specified in
        %   the TestParameter2 property. The plot and semilogy methods of
        %   the results object create a plot with the x-axis controlled by the
        %   test parameter specified in the TestParameter1 property. The plot
        %   has as many curves as sweep values are available in the test
        %   parameter specified in the TestParameter2 property. The surf method
        %   of the results object will create a surface plot with the x-axis
        %   controlled by TestParameter1 and the y-axis controlled by
        %   TestParameter2.
        %   For all other test parameters (different than those specified in
        %   TestParameter1 and TestParameter2) you can choose single sweep
        %   values for which results data and plots are obtained by calling the
        %   setParsingValues method of the results object. 
        %   You obtain a list of registered test parameters using the info
        %   method of the test console. You obtain the current parsing values by
        %   calling the getParsingValues method of the results object. 
        %
        % See also testconsole.Results,
        % testconsole.Results/setParsingValues.      
        TestParameter1
        %TestParameter2 Test parameter name for second independent variable
        %   Specify the name of the second independent variable for which
        %   results will be parsed. This property is only relevant when
        %   IterationMode is 'Combinatorial' and at least two test parameters
        %   were registered to the test console by the system under test. In
        %   this scenario, the getData method of the results object will return
        %   a matrix with columns containing results for all the sweep values of
        %   the test parameter specified in the TestParameter2 property. The
        %   plot and semilogy methods of the results object create a plot with
        %   the x-axis controlled by the test parameter specified in the
        %   TestParameter1 property. The plot has as many curves as sweep values
        %   are available in the test parameter specified in the TestParameter2
        %   property. The surf method of the results object will create a
        %   surface plot with the x-axis controlled by TestParameter1 and the
        %   y-axis controlled by TestParameter2.
        %   For all other test parameters (different than those specified in
        %   TestParameter1 and TestParameter2) you can choose single sweep
        %   values for which results data and plots are obtained by calling the
        %   setParsingValues method of the results object. 
        %   You obtain a list of registered test parameters using the info
        %   method of the test console. You obtain the current parsing values by
        %   calling the getParsingValues method of the results object. 
        %
        % See also testconsole.Results,
        % testconsole.Results/setParsingValues.      
        TestParameter2
    end
    
    %===========================================================================
    % Read Only Properties
    properties (SetAccess = private)
        %TestConsoleName Name of the test console (read-only)
        %   Name of the test console that was used to obtain results. 
        %
        %   See also testconsole.Results.
        TestConsoleName
        %SystemUnderTestName Name of the system under test (read-only)
        %   Name of the system under test for which results were obtained. 
        %
        %   See also testconsole.Results.        
        SystemUnderTestName
        %IterationMode Iteration mode (read-only)
        %   Iteration mode that was used to obtain results.    
        %
        %   See also testconsole.Results.        
        IterationMode
    end
    
    %===========================================================================
    % Private Properties
    properties (Access = private)
        TestPoints ={};
        TestPointIndices
        Parameters ={};
        ParameterIndices
        Metrics = {};
        ParameterValues
        ParsingValues
        TestResultsSweep = struct;
        TestResultsMetric = struct;
        FormatPlotFunction      
        PrivTestParameter1 = 'None';
        PrivTestParameter2 = 'None';
        PrivTestPoint
        PrivMetric 
        Version = [];
    end
    %===========================================================================
    % Public Methods
    methods
        function this = Results(testConsole, systemUnderTest, testLog, iterationMode)
            % RESULTS Construct a testconsole.Results object 
                                    
            this.Version.('number') = 1.1;
            this.Version.('description') = 'R2010a';

            if nargin > 0
                
                validateattributes(testConsole,...
                    {'char'},...
                    {'row', 'vector'}, class(this), ...
                    ['tescConsole input to the testconsole.Results ',...
                    'class constructor']);
                
                validateattributes(systemUnderTest,...
                    {'char'},...
                    {'row', 'vector'}, class(this), ...
                    ['systemUnderTest input to the testconsole.Results ',...
                    'class constructor']);
                
                validateattributes(iterationMode,...
                    {'char'},...
                    {'row', 'vector'}, class(this), ...
                    ['iterationMode input to the testconsole.Results ',...
                    'class constructor']);
            
                if ~isa(testLog,'testconsole.Log')
                    error(generatemsgid('invalidLogInput'),...
                        (['Invalid testLog input to the testconsole.Results ',...
                        'class constructor. Expected an instance of a ',...
                        'testconsole.Log class.']));
                end                
                    
                this.SystemUnderTestName = systemUnderTest;
                this.TestConsoleName = testConsole;
                this.IterationMode = iterationMode;
                this.ParsingValues = struct;
                
                % Get the test point names and index them
                this.TestPoints = getTestPointNames(testLog);
                this.TestPointIndices = containers.Map;
                for p=1:length(this.TestPoints)
                    this.TestPointIndices(this.TestPoints{p}) = p;
                end
                
                % Set the first test point as the default
                this.TestPoint = this.TestPoints{1};
                
                % Set the metric names.
                this.Metrics = getMetricNames(testLog);
                this.Metric = testLog.DefaultMetric;
                
                % Set parameter information
                this.Parameters = getTestParameterNames(testLog);
                
                % Set parameter information. We assume that all the test points have
                % the same parameters.
                numParameters = length(this.Parameters);
                this.ParameterIndices = containers.Map;
                foundSweepParam = false;
                for p=1:numParameters
                    paramName = this.Parameters{p};
                    this.ParameterValues{p} = ...
                        getTestParameterSweepRange(testLog, paramName);
                    this.ParameterIndices(paramName) = p;
                    if ~foundSweepParam && (length(this.ParameterValues{p}) > 1)
                        % Current parameter has more than one sweep value.  Assign
                        % it as TestParameter1.
                        this.PrivTestParameter1 = paramName;
                        foundSweepParam = true;
                    end
                end
                
                % Initialize ParsingValues
                initParsingValues(this)
                
                if ~foundSweepParam &&  ~isempty(this.Parameters)
                    % There are no parameters that had more than one sweep
                    % value. Choose the first parameter as the TestParameter1
                    this.PrivTestParameter1 = this.Parameters{1};
                end
                
                % Prepare to parse
                dummySweepData = struct;
                for testPointCount=1:length(this.TestPoints)
                    for paramCount = 1:length(this.Parameters)
                        paramName = this.Parameters{paramCount};
                        sweepData = getTestSweepPoints(testLog, ...
                            this.TestPoints{testPointCount}, paramName);
                        dummySweepData.(paramName)(:,testPointCount) = sweepData;
                    end
                    for metricCount = 1:length(this.Metrics)
                        metricName = this.Metrics{metricCount};
                        metricData = getTestMetricData(testLog, ...
                            this.TestPoints{testPointCount}, metricName);
                        dummyMetricData.(metricName)(:,testPointCount) = metricData;
                    end
                end
                % All pre-parsed sweep points are kept in TestResultsSweep
                % property
                this.TestResultsSweep = dummySweepData;
                % All pre-parsed sweep points are kept in TestResultsMetric
                % property
                this.TestResultsMetric = dummyMetricData;
                
                % Set the format plot function
                this.FormatPlotFunction = testLog.FormatPlotFunction;                
            end
        end
        %-----------------------------------------------------------------------
        function val = getData(this)
            %getData Get results data 
            %   D = getData(R) returns results data matrix, D, available in the
            %   results object R. The returned results correspond to the test
            %   point specified in the TestPoint property of R, and to the test
            %   metric specified in the Metric property of R.
            %   If IterationMode is 'Combinatorial' then D is a matrix
            %   containing results for all the sweep values available in the
            %   test parameters specified in the TestParameter1 and
            %   TestParameter2 properties. The rows of the matrix correspond to
            %   results for all the sweep values available in TestParameter1.
            %   The columns of the matrix correspond to results for all sweep
            %   values available in TestParameter2. For each of the remaining
            %   test parameters (if more than two test parameters were
            %   registered by the system under test, or if two test parameters
            %   are available and TestParameter2 is set to 'None') you can
            %   specify a single value for which results will be returned using
            %   the setParsingValues method of the results object. 
            %   To see the current parsing values call the getParsingValues
            %   method of the results object. By default, the parsing values are
            %   set to the first value in the sweep vector of each test
            %   parameter. The parsing values for parameters currently set as
            %   TestParameter1 or TestParameter2 will be ignored by the getData
            %   method. 
            %                        
            %   If IterationMode is 'Indexed', then D is a vector of results
            %   corresponding to each indexed combination of all the test
            %   parameter values registered to the test console. You view a list
            %   of registered test parameters, registered test points, and
            %   available test metrics using the info method of the test
            %   console. 
            %
            %   See also testconsole.Results, testconsole.Results/plot,
            %   testconsole.Results/setParsingValues,
            %   testconsole.Results/getParsingValues.
            
            testPointIdx = this.TestPointIndices(this.TestPoint);
            
            if strcmp(this.IterationMode,'Indexed')
                % Indexed mode yields just a single column matrix of results
                val = this.TestResultsMetric.(this.Metric)(:, testPointIdx);
            else
                if isempty(this.Parameters)
                    % No registered test parameters, just give result from the
                    % single simulation point. 
                    val = this.TestResultsMetric.(this.Metric)(:, testPointIdx);
                else 
                    if strcmpi(this.PrivTestParameter1 ,'none') && ...
                            ~strcmpi(this.IterationMode,'indexed')
                        error(generatemsgid('param1None'), ...
                            '''TestParameter1'' must not be set to ''None''.');
                    end                    
                    if length(this.Parameters) >1
                        if strcmp(this.PrivTestParameter1, ...
                                this.PrivTestParameter2)
                            error(generatemsgid('SameParameter'), ...
                                ['''TestParameter1'' and '...
                                '''TestParameter2'' must be different.'])
                        end
                    end
                    
                    % Prepare to parse
                    params = this.Parameters;
                    numParams = length(params);
                    requestedRange = cell(1,numParams);
                    
                    if isempty(this.Parameters)
                        idxOut = 1;
                        m = 1;
                        n = 1;
                    else
                        paramValues = ...
                            this.TestResultsSweep.(this.Parameters{1})(:, testPointIdx);
                        idxOut = ones(size(paramValues));
                        for p=1:numParams
                            paramValues = this.TestResultsSweep.(...
                                this.Parameters{p})(:, testPointIdx);
                            if strcmp(params{p}, this.TestParameter1) ...
                                    || strcmp(params{p}, this.TestParameter2)
                                requestedRange{p} = this.ParameterValues{p};
                            else
                                v = this.ParsingValues.(this.Parameters{p});
                                if ischar(v)
                                    % If value is char
                                    % testconsole.Results.getIndices requires
                                    % the value to be inside a cell
                                    v = {v};
                                end
                                requestedRange{p} = v;
                            end
                            idxIn = zeros(size(paramValues));
                            for q=1:length(requestedRange{p})
                                idxIn = idxIn ...
                                    | testconsole.Results.getIndices(...
                                    requestedRange{p}(q), paramValues);
                            end
                            idxOut = idxOut & idxIn;
                        end
                    
                        [param1 param2] = getOutputParameterIndices(this);
                        if param1 > 0
                            m = length(requestedRange{param1});
                        else
                            m = 1;
                        end
                        if param2 > 0
                            n = length(requestedRange{param2});
                        else
                            n = 1;
                        end
                    end
                    
                    results = ...
                        this.TestResultsMetric.(this.Metric)(idxOut, testPointIdx);
                    if param1 < param2
                        val = reshape(results,m,n);
                    else
                        val = reshape(results,n,m)';
                    end                        
                end
            end
        end
        %-----------------------------------------------------------------------
        function varargout = plot(this, varargin)
            %PLOT   Plot results 
            %   PLOT(R) creates a plot for results available in the results
            %   object R. The plot corresponds to the test point currently
            %   specified in the TestPoint property of R, and to the test metric
            %   currently specified in the Metric property of R.
            %
            %   If IterationMode is 'Combinatorial' then the plot contains a set
            %   of curves with the x-axis controlled by the sweep values
            %   available in the test parameter specified in the TestParameter1
            %   and with as many curves as the number of sweep values available
            %   in the test parameter specified in the TestParameter2 property.
            %   If more than two test parameters are registered to the test
            %   console or if two parameters are registered but TestParameter2
            %   is set to 'None', the aforementioned curves will correspond to
            %   results obtained with parameter sweep values previously
            %   specified with the setParsingValues method of the results
            %   object. You see the current parsing values by calling the
            %   getParsingValues method of the results object. By default, the
            %   parsing values are set to the first value in the sweep vector of
            %   each test parameter. The plot method ignores the parsing values
            %   for parameters currently set as TestParameter1 or
            %   TestParameter2. 
            %
            %   You obtain a list of registered test parameters, registered test
            %   points, and available test metrics using the info method of the
            %   test console.                
            %
            %   No plots are available when IterationMode is 'Indexed'.
            %
            %   The R input can be followed by parameter/value pairs to specify
            %   additional properties of the curves. For instance,
            %   PLOT(R,'LineWidth',2) creates curves with line widths of 2
            %   points.
            %
            %   See also testconsole.Results, testconsole.Results/getData,
            %   testconsole.Results/semilogy, testconsole.Results/surf,
            %   testconsole.Results/setParsingValues,
            %   testconsole.Results/getParsingValues.
            
            plotHandle = actualPlot(this,'plot',nargout,varargin{:});                        
            if nargout > 0
                varargout{1} = plotHandle;
            end
        end   
        %-----------------------------------------------------------------------
        function varargout = semilogy(this, varargin)
            %SEMILOGY   Create semi-log scale plot of results 
            %   SEMILOGY(R) is the same as PLOT(R) except that a logarithmic
            %   (base 10) scale is used for the Y-axis.            
            %
            %   See also testconsole.Results, testconsole.Results/getData,
            %   testconsole.Results/plot, testconsole.Results/surf.
            
            plotHandle = actualPlot(this,'semilogy',nargout,varargin{:});                        
            if nargout > 0
                varargout{1} = plotHandle;
            end
        end
        %-----------------------------------------------------------------------
        function varargout = surf(this, varargin)
            %SURF 3-D colored surface plot of results
            %   SURF(R) creates a 3-D colored surface plot for results available
            %   in the results object R. The surface plot corresponds to the
            %   test point currently specified in the TestPoint property of R,
            %   and to the test metric currently specified in the Metric
            %   property of R.
            %
            %   If IterationMode is 'Combinatorial' then the x-axis of the
            %   surface plot is controlled by the sweep values available in the
            %   test parameter specified in the TestParameter1 property and the
            %   y-axis is controlled by the sweep values available in the test
            %   parameter specified in the TestParameter2 property. If more than
            %   two test parameters are registered to the test console, the
            %   aforementioned surface plot will correspond to results obtained
            %   with the parameter sweep values previously specified with the
            %   setParsingValues method of the results object. You see the
            %   current parsing values by calling the getParsingValues method of
            %   the results object. By default, the parsing values are set to
            %   the first value in the sweep vector of each test parameter. The
            %   parsing values for parameters currently set as TestParameter1 or
            %   TestParameter2 are ignored by the surf method. 
            %
            %   No surface plots are available when IterationMode is 'Indexed',
            %   when there exist less than two registered test parameters, or
            %   when there exist two or more test parameters but TestParameter2
            %   is set to 'None'.
            %
            %   The R input can be followed by parameter/value pairs to specify
            %   additional properties of the surface plot.
            %
            %   See also testconsole.Results, testconsole.Results/getData,
            %   testconsole.Results/plot, testconsole.Results/semilogy,
            %   testconsole.Results/setParsingValues,
            %   testconsole.Results/getParsingValues.

            
            plotHandle = actualPlot(this,'surf',nargout,varargin{:});                        
            if nargout > 0
                varargout{1} = plotHandle;
            end
        end   
        %-----------------------------------------------------------------------        
        function setParsingValues(this,varargin)
            %setParsingValues Set parsing values
            %   Specify single sweep values for test parameters that are
            %   different from the ones in TestParameter1 and TestParameter2.
            %   The results object returns data values or plots that correspond
            %   to the sweep values defined with the setParsingValues method.
            %   The parsing values default to the first value in the sweep
            %   vector of each test parameter.
            %
            %   setParsingValues(R,'ParameterName1', 'Value1', ...
            %   'ParameterName2', 'Value2', ...) sets the parsing values to the
            %   values specified in the parameter-value pairs. Parameter name
            %   inputs must correspond to names of registered test parameters,
            %   and value inputs must correspond to a valid test parameter sweep
            %   value. 
            %  
            %   You see the current parsing values by calling the 
            %   getParsingValues of the results object. You may set parsing
            %   values for parameters in TestParameter1 and TestParameter2, but
            %   the results object ignores the values when getting data or
            %   returning plots. 
            %
            %   Parsing values are irrelevant when IterationMode is 'Indexed'.
            %
            %   See also testconsole.Results, 
            %   testconsole.Results/getParsingValues.

            if strcmp(this.IterationMode,'Indexed')
                warning(generatemsgid('IrrelevantParsingValuesSet'), ...
                    ['Parsing values are irrelevant when IterationMode ',...
                    'is ''Indexed''.'])                                
            end
            
            if nargin < 2
                error(generatemsgid('notEnoughParsingValuesArguments'), ...
                    ['Not enough input arguments. The setParsingValues ',...
                    'method expects at least one test parameter name ',...
                    'and its corresponding value as an input.'])                
            end
            %varargin should contain pv-pairs
            if ~isequal(mod((nargin-1),2),0)
                error(generatemsgid('oddParsingValuesArguments'), ...
                    ['The setParsingValues method expects inputs in the ',...
                    'form of parameter-value pairs.'])                                
            end
            
            %parameter names should be valid registered parameter names
            for idx = 1:length(varargin)/2
                unmatchedValueFlag = false;
                inputParamName = varargin{idx*2-1};
                inputParamValue = varargin{idx*2};
                
                if ischar(inputParamName)
                    if ~any(strcmp(inputParamName, this.Parameters))
                        error(generatemsgid('invalidParsingValuesParamName'), ...
                            ['Parameter ''%s'' is not a registered parameter. ',...
                            'Call the info method of the test console to ',...
                            'see the registered parameter names'],inputParamName)
                    end                        
                else
                    error(generatemsgid('invalidParsingValuesParamNameType'), ...
                        'Expected input parameter name to be a char.')
                end
                
                %input values should match values in the parameter sweep value
                %vector
                p = this.ParameterIndices(inputParamName);
                paramRange = this.ParameterValues{p};
                
                validateattributes(inputParamValue,...
                    {'numeric', 'char'},...
                    {}, [class(this) '.setParsingValues'], ...
                    sprintf('parsing value for parameter ''%s''',...
                    inputParamName));
                                
                if iscell(paramRange) 
                    %Make sure inputParamValue is a char
                    validateattributes(inputParamValue,...
                        {'char'},...
                        {'row','vector'}, [class(this) '.setParsingValues'], ...
                        sprintf('parsing value for parameter ''%s''',...
                        inputParamName));
                    
                    if ~any(strcmp(inputParamValue,paramRange))
                        unmatchedValueFlag = true;
                    end                    
                else
                    %Make sure inputParamValue is a numeric scalar
                    validateattributes(inputParamValue,...
                        {'numeric'},...
                        {'scalar'}, [class(this) '.setParsingValues'], ...
                        sprintf('parsing value for parameter ''%s''',...
                        inputParamName));
                    
                    findIdx = find(paramRange == inputParamValue, 1);
                    if isempty(findIdx)
                        unmatchedValueFlag = true;
                    end
                end  
                if unmatchedValueFlag 
                    error(generatemsgid('invalidParsingValuesParamValue'), ...
                        ['The parsing value specified for parameter %s does ',...
                         'not match any of the specified test parameter ',...
                         'sweep values. Call the ',...
                         'getTestParameterSweepValues method of the test ',...
                         'console to get the valid sweep values.'],...
                         inputParamName)                    
                end                
                this.ParsingValues.(inputParamName) = inputParamValue;
            end
        end
        %-----------------------------------------------------------------------        
        function struct = getParsingValues(this)
            %getParsingValues Get the current parsing values
            %   S = getParsingValues(R) returns a structure, S, with field names
            %   equal to the registered test parameter names and with values
            %   that correspond to the current parsing values.            
            %
            %   Parsing values are irrelevant when IterationMode is 'Indexed'.
            %
            %   See also testconsole.Results, 
            %   testconsole.Results/setParsingValues.

            if strcmp(this.IterationMode,'Indexed')
                warning(generatemsgid('IrrelevantParsingValuesGet'), ...
                    ['Parsing values are irrelevant when IterationMode ',...
                    'is ''Indexed''.'])                                
            end
            
            struct = this.ParsingValues;
        end        
    end    
    %===========================================================================
    % Public Hidden Methods
    methods (Hidden)
        function paramNames = getParameterNames(this)
            %getParameterNames Get parameter names
            paramNames = this.Parameters;
        end
        %-----------------------------------------------------------------------        
        function paramRange = getParameterRange(this, paramName)
            %getParameterRange Get parameter range
            paramIdx = this.ParameterIndices(paramName);
            paramRange = this.ParameterValues{paramIdx};
        end
    end
    
    %===========================================================================
    % Private Methods
    methods (Access=private)
        function [param1 param2] = getOutputParameterIndices(this)
            %getOutputParameterIndices Get output parameter indices
            param1 = 0;
            param2 = 0;                
            if ~strcmp(this.PrivTestParameter1, 'None')
                param1 = this.ParameterIndices(this.PrivTestParameter1);
            end
            if ~strcmp(this.PrivTestParameter2, 'None')
                param2 = this.ParameterIndices(this.PrivTestParameter2);
            end
        end
    %===========================================================================        
        function initParsingValues(this)
            %initParsingValues initialize parsing values
            %   Set ParsingValues field names to the parameter names and set
            %   values to the first value in the sweep vector of each parameter.
            
            numParameters = length(this.Parameters);
            for p=1:numParameters                
                if iscell(this.ParameterValues{p})
                    this.ParsingValues.(this.Parameters{p}) = ...
                        this.ParameterValues{p}{1};
                else
                    this.ParsingValues.(this.Parameters{p}) = ...
                        this.ParameterValues{p}(1);
                end
            end            
        end
    %===========================================================================        
        function isPlotValid(this,type,numArgsOut)
            %isPlotValid Check conditions before plotting
            %   type may be set to 'plot', or 'semilogy'
            
            if numArgsOut > 1
                error(generatemsgid('tooManyPlotOutputArgs'),...
                    'Too many output arguments.');
            end            
            if strcmp(this.IterationMode,'Indexed')
                error(generatemsgid('Indexed'), ['Cannot plot indexed '...
                    'simulation results.'])
            elseif isempty(this.Parameters)
                error(generatemsgid('noTestParamsToPlot'), ...
                    'Cannot plot results. No test parameters were registered.')
            end            
            
            if strcmp(type,'surf') && ...
                (length(this.Parameters) < 2 ||...
                strcmp(this.TestParameter2, 'None'))
                error(generatemsgid('InvalidSurfPlot'), ...
                    ['To obtain a surface plot, there must be at least two ',...
                    'registered test parameters and/or the TestParameter2 ',...
                    'property must not be set to ''None''.'])            
            end
                        
        end
    %===========================================================================                
        function plotHandle = actualPlot(this,type,nargout,varargin)
            %actualPlot Plot curves using type format
            %   type may be set to 'plot', or 'semilogy'
            
            % Validate plotting
            isPlotValid(this,type,nargout)
            
            % Render the plot
            data = getData(this);
            param1Range = getParameterRange(this, this.TestParameter1);
            param1Len = length(param1Range);
            if ~strcmp(type,'surf')               
                if iscell(param1Range)                    
                    if strcmp(type,'plot')
                        plotHandle = plot(1:param1Len, data, varargin{:});
                    elseif strcmp(type,'semilogy')
                        plotHandle = semilogy(1:param1Len, data, varargin{:});
                    end
                    
                    hAxes = get(plotHandle(1),'Parent');
                    testconsole.Results.formatAxes('x',...
                        hAxes,param1Len, param1Range)                                        
                else
                    if strcmp(type,'plot')
                        plotHandle = plot(param1Range, data, varargin{:});
                    elseif strcmp(type,'semilogy')
                        plotHandle = semilogy(param1Range, data, varargin{:});
                    end
                end
            else % surface plot
                if isequal(size(data,1),1) || isequal(size(data,2),1)
                    error(generatemsgid('invalid3DPlot'), ...
                        ['To obtain a surface plot of the results, the ',...
                        'parameters in TestParameter1 and/or TestParameter2 ',...
                        'must have more than one sweep value.']);
                end
                data = data.';
                param2Range = getParameterRange(this, this.TestParameter2);
                param2Len = length(param2Range);
                if iscell(param1Range) && ~iscell(param2Range)
                     plotHandle = surf(1:param1Len, param2Range, data, ...
                         varargin{:});
                     hAxes = get(plotHandle(1),'Parent');
                     testconsole.Results.formatAxes('x',...
                         hAxes,param1Len, param1Range)                     
                elseif ~iscell(param1Range) && iscell(param2Range)
                     plotHandle = surf(param1Range, 1:param2Len, data, ...
                         varargin{:});
                     hAxes = get(plotHandle(1),'Parent');
                     testconsole.Results.formatAxes('y',...
                         hAxes,param2Len, param2Range)                                         
                elseif ~iscell(param1Range) && ~iscell(param2Range)
                    plotHandle = surf(param1Range, param2Range, data, varargin{:});
                else %both are cells
                     plotHandle = surf(1:param1Len, 1:param2Len, data, ...
                         varargin{:});
                     hAxes = get(plotHandle(1),'Parent');
                     testconsole.Results.formatAxes('x',...
                         hAxes,param1Len, param1Range)                                                                                  
                     testconsole.Results.formatAxes('y',...
                         hAxes,param2Len, param2Range)                                                             
                end
            end
            % call the format plot function of the test console
            if ~isempty(this.FormatPlotFunction)
                this.FormatPlotFunction(this,type)
            end
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.TestPoint(this, val)
            val = validatestring(val, this.TestPoints, ...
                'testconsole.Results.TestPoint', 'TestPoint');

            this.PrivTestPoint = val;
        end
        %-----------------------------------------------------------------------
        function val = get.TestPoint(this)
            val = this.PrivTestPoint;
        end
        %-----------------------------------------------------------------------
        function set.TestParameter1(this, val)
            if strcmpi(this.IterationMode,'indexed')
                warning(generatemsgid('irrelevantTestParam1'), ...
                    ['''TestParameter1'' is irrelevant when ',...
                    '''IterationMode'' is ''Indexed''.'])
            elseif isempty(this.Parameters)
                    warning(generatemsgid('noParams'), ...
                        ['The system under test did not register any test ',...
                        'parameters so ''TestParameter1'' is irrelevant.'])                    
            else
                val = validatestring(val, [this.Parameters {'None'}], ...
                    'testconsole.Results.TestParameter1', 'TestParameter1'); %#ok<*MCSUP>
                
                this.PrivTestParameter1 = val;
            end
        end
        %-----------------------------------------------------------------------
        function val = get.TestParameter1(this)
            if strcmpi(this.IterationMode,'indexed')
                val = 'None';
            else
                val = this.PrivTestParameter1;
            end
        end
        %-----------------------------------------------------------------------
        function set.TestParameter2(this, val)
            if strcmpi(this.IterationMode,'indexed')
                warning(generatemsgid('irrelevantTestParam2'), ...
                    ['''TestParameter2'' is irrelevant when ',...
                    '''IterationMode'' is ''Indexed''.'])
            elseif length(this.Parameters) < 2
                    warning(generatemsgid('noSecondParam'), ...
                        ['The system under test registered less than two test ',...
                        'parameters so ''TestParameter2'' is irrelevant.'])
            else
                val = validatestring(val, [this.Parameters {'None'}], ...
                    'testconsole.Results.TestParameter2', 'TestParameter2');
                this.PrivTestParameter2 = val;
            end
        end
        %-----------------------------------------------------------------------
        function val = get.TestParameter2(this)
            % GET TestParameter2
            if strcmpi(this.IterationMode,'indexed')
                val = 'None';
            else
                val = this.PrivTestParameter2;
            end
        end        
        %-----------------------------------------------------------------------
        function set.Metric(this, val)
            val = validatestring(val, this.Metrics, ...
                'commtest.Results.Metric', 'Metric');
            this.PrivMetric = val;
        end
        %-----------------------------------------------------------------------
        function val = get.Metric(this)
            val = this.PrivMetric;
        end
    end
    
    %===========================================================================
    % Protected Methods
    methods (Access = protected)
        function sortedList = getSortedPropDispList(this)
            %getSortedPropDispList 
            %   Get the sorted list of the properties to be displayed. Overwrite
            %   this method in the subclass to customize.
            
            sortedList = {...
                'TestConsoleName', ...
                'SystemUnderTestName', ...
                'IterationMode', ...
                'TestPoint', ...
                'Metric'};                        
                       
            if ~isempty(this.Parameters)
                if ~strcmpi(this.IterationMode,'indexed')                    
                    sortedList = [sortedList {'TestParameter1'}];
                    if length(this.Parameters) > 1
                        sortedList = [sortedList {'TestParameter2'}];
                    end
                end
                
            end
        end    
    end
    %===========================================================================
    % Static Public Methods
    methods (Static)
        function this = loadobj(s)
            %loadobj Load object                        
            if isstruct(s)
                warning(generatemsgid('R2009bResultsLoad'), ...
                    ['Loading of testconsole.Results objects ',....
                    'created with Communications Toolbox Version 4.4 ',...
                    'will not be supported in the future. We recommend ',...
                    'that you re-save the object.'])

                % A structure will be returned in R2009b loaded objects since
                % they do not have ParsingValues, FormatPlotFunction, and
                % Version properties. 
                this = testconsole.Results;
                                
                % Set all the properties
                this.TestConsoleName     = s.TestConsoleName;
                this.SystemUnderTestName = s.SystemUnderTestName;
                this.IterationMode       = s.IterationMode;
                this.TestPoints          = s.TestPoints;
                this.TestPointIndices    = s.TestPointIndices;
                this.Parameters          = s.Parameters;
                this.ParameterIndices    = s.ParameterIndices;
                this.Metrics             = s.Metrics;
                this.ParameterValues     = s.ParameterValues;
                this.TestResultsSweep    = s.TestResultsSweep;
                this.TestResultsMetric   = s.TestResultsMetric;
                this.PrivTestParameter1  = s.PrivTestParameter1;
                this.PrivTestParameter2  = s.PrivTestParameter2;
                this.PrivTestPoint       = s.PrivTestPoint;
                this.PrivMetric          = s.PrivMetric;
                
                % In R2009b only Error Rate consoles exist so we set the format
                % plot function to that of the Error Rate Test Console.
                this.FormatPlotFunction = ...
                    @commtest.errorRateTestConsoleFormatPlot;
                
                % Set ParsingValues field names to the parameter names and set
                % values to the first value in the sweep vector of each
                % parameter.
                initParsingValues(this)                       
            else
                % The load operation was successful so just return the loaded
                % object s
                this = s;
            end
        end
    end
    %===========================================================================
    % Static Private Methods
    methods (Static, Access = private)
        function idx = getIndices(requestedValues, simulatedValues)
			%getIndices Get indices of matching values
			%   I = getIndices(A, B) returns indices, I, of elements of B that
			%   match the elements of A.
            if iscell(simulatedValues)
                idx = strcmp(requestedValues,simulatedValues);
            else
                idx = (requestedValues==simulatedValues);
            end
        end
        %-----------------------------------------------------------------------
        function formatAxes(axis, hAxes,paramLen, paramRange)
            %formatAxes Format plot axes
            if strcmp(axis,'x')
                tick = 'XTick';
                tickLabel = 'XTickLabel';
            else
                tick = 'YTick';
                tickLabel = 'YTickLabel';                
            end
            set(hAxes, tick, 0:paramLen)
            set(hAxes, tickLabel, [{''} paramRange])
        end

    end
end
