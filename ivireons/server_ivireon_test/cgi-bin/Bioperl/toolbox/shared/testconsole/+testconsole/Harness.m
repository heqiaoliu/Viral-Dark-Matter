classdef Harness < handle & sigutils.pvpairs & sigutils.sorteddisp
    %Harness Define Harness Abstract Class
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:12 $
    
    %===========================================================================
    % Define Read-Only Properties
    %===========================================================================
    properties (SetAccess = protected)
        %Description Test console description
        %
        %   See also testconsole.Harness.                
        Description
    end
    properties (SetAccess = protected, Dependent)
        %SystemUnderTestName System under test name
        %
        %   See also testconsole.Harness.                
        SystemUnderTestName
    end
    %===========================================================================
    % Define Public Properties
    %===========================================================================
    properties
        %IterationMode Iteration mode
        %   Specify how simulation points are determined as one of
        %   [{'Combinatorial'} | 'Indexed'].  When this property is set to
        %   'Combinatorial', simulations are performed for all possible
        %   combinations of registered test parameter sweep values. 
        %   When this property is set to 'Indexed', simulations are performed
        %   for all indexed sweep value sets.  The ith sweep value set consists
        %   of the ith element of every sweep value vector of each registered
        %   test parameter. All sweep value vectors must be of equal length with
        %   the exception of those that are unit length. 
        %
        %   See also testconsole.Harness.        
        IterationMode = 'Combinatorial';
        %SystemResetMode System reset mode
        %   Specify at what stage of a simulation run a system is reset as
        %   one of [{'Reset at new simulation point'} | 'Reset at every
        %   iteration']. When this property is set to 'Reset at new simulation
        %   point' the system under test will be reset only at the beginning of
        %   a new simulation point. 
        %   When this property is set to 'Reset at every iteration' the system
        %   under test will be reset at every iteration.
        %
        %   See also testconsole.Harness.                
        SystemResetMode = 'Reset at new simulation point';
    end
    %===========================================================================
    % Define Protected Properties
    %===========================================================================
    properties (Access = protected)
        %TotalIterations
        %   Keep a vector of number of iterations per simulation point.
        TotalIterations = [];
        %ResetFlag
        %   Flag used to avoid calling the reset method more than once before
        %   the run method is called.
        ResetFlag
        %TestParamRegisteredObjects
        %   Container that keeps the test parameter objects registered by the
        %   system under test currently attached to the test console.
        TestParamRegisteredObjects = containers.Map;        
        %TestProbeRegisteredObjects
        %   The system under test logs data using test probe objects that it
        %   registers when attaching to the test console.
        %   TestProbeRegisteredObjects is a container.Map that contains
        %   registered test probe objects.
        TestProbeRegisteredObjects = containers.Map;
        %TestPointRegisteredObjects
        %   The test console groups test objects (test probes, and test metrics)
        %   in test point objects that are kept in a containers.Map.
        TestPointRegisteredObjects = containers.Map;
        %TestLog
        %   Results for each simulation sweep point are kept in a test log
        %   object. 
        TestLog
        %AttachSystemFlag
        %   True if in the process of attaching a system under test. False if
        %   not in the process of attaching a system under test.
        AttachSystemFlag = false;
        %TestConsoleState
        %   State of the test console. May be set to:
        %   'uninitialized' - no system has been attached to the test console
        %   'initialized'   - a system has been attached to the test console 
        %                     but no simulations have been run. 
        %   'testing'       - the test console is currently running simulations 
        %                     for the system under test. No results are
        %                     available yet. 
        %   'finished'      - the test console finished simulating and results 
        %                     are ready to be analyzed. Simulations may be
        %                     ran again at any time.
        TestConsoleState = 'uninitialized';
        %NumWorkers - Number of workers
        %   Available number of workers for parallel computations.
        NumWorkers        
        %SystemUnderTest - System under test object
        %   Handle to the system under test.
        SystemUnderTest = [];
        %RegisteredTestPointsFlag
        %   True if test points have been registered
        %   False if no test points have been registered
        RegisteredTestPointsFlag
        %SystemInputs
        %   Must be a cell array with names of input types available in the
        %   concrete test console implementation.
        SystemInputs = {};
        %RegisteredInputs 
        %   Cell array with names of the registered inputs. 
        RegisteredInputs ={};
        %Version - Test console version
        Version
    end
    %===========================================================================
    % Define Public Methods
    %===========================================================================
    methods
        function obj = Harness(varargin)
            %HARNESS Construct a testconsole.Harness object
            
            obj.Version.('number') = 1.1;
            obj.Version.('description') = 'R2010a';
            
            %Don't reset when setting properties at construction time            
            obj.ResetFlag = false;
                        
            % Instantiate a test log object
            obj.TestLog = testconsole.Log;   
            
            % Set available system inputs
            setTestInputs(obj,getTestInputNames(obj))
            % Set the default metric of the test log, this method is
            % implemented in a concrete subclass
            setDefaultMetric(obj,getDefaultMetricName(obj)) 
            % Set the format plot function for the test log
            setFormatPlotFunction(obj,getFormatPlotFunction(obj))
                        
            %Set TestProbeRegisteredObjects, TestParamRegisteredObjects, and
            %TestPointRegisteredObjects to containers. Need to do this in the
            %constructor or two test console instances will have connected
            %containers.
            obj.TestProbeRegisteredObjects = containers.Map;
            obj.TestParamRegisteredObjects = containers.Map; 
            obj.TestPointRegisteredObjects = containers.Map; 
            
            parseInputs(obj,varargin{:});
        end
        %=======================================================================        
        function run(obj)
            %RUN    Run simulations
            %   RUN(H) runs a specified number of iterations of an attached
            %   system under test for a specified set of parameter values. If a
            %   Parallel Computing Toolbox license is available and a matlabpool
            %   is open, then the iterations will be distributed among the
            %   available number of workers.
            %
            %   See also testconsole.Harness.
            
            % Perform checks before starting simulations
            isSystemIsAttached(obj);                        
            isValidIndexedIteration(obj);            
            isValidInputRegistration(obj);
            setEndOfSimulationCriteria(obj);            
            
            %Reset all test parameters and probes
            resetAllParameters(obj);
            resetAllProbes(obj);
            resetLog(obj);
            
            % Allow a reset if a property is set after run time
            obj.ResetFlag = true;
            
            % See if a matlabpool is open and get number of workers
            obj.NumWorkers = testconsole.Harness.getNumWorkers;
            
            obj.TestConsoleState = 'testing';
            
            % Loop over simulation parameter points -----------------------                 
            % Stop iterations when we have gone through all the possible
            % combinations of simulation parameters (the way parameters are
            % combined depends on the Iteration mode property value).
            endOfSimulation = false;
            cnt = 0;
            fprintf('Running simulations...\n')
            while ~endOfSimulation
                totalIterations = 0;                
                % Begin settings for a new sweep parameter point and add a
                % new element to the data buffer vectors in the registered
                % probe objects. The added value is equal to zero so that we
                % can use it as a counter.
                sweepPoint = getCurrentSweepPoint(obj);
                
                % Start a sweep point and call the setup method of the
                % system under test. 
                startSweepPoint(obj,sweepPoint);
                
                % parfor loop - distribute total number of iterations per
                % simulation point among workers.
                parfor wIdx = 1:obj.NumWorkers
                    % Call system run
                    iterations  = runIterations(obj);
                    % Aggregate results from all workers
                    totalIterations = totalIterations +  iterations;
                    if obj.RegisteredTestPointsFlag
                        copyObj{wIdx} = obj.TestLog.CurrentTestPoints;
                    end
                end %parfor
                
                % Final aggregation
                if obj.RegisteredTestPointsFlag
                    currentTestPoints = copyObj{1};
                    for p=2:obj.NumWorkers
                    	testconsole.Log.aggregate(currentTestPoints,...
                            copyObj{p});
                    end
                    % Log sweep point data
                	endSweepPoint(obj, currentTestPoints);
                    
                    % Register number of iterations per simulation point
                    cnt = cnt + 1;
                    obj.TotalIterations(cnt)= totalIterations;                    
                end
                % Step to next simulation sweep point and check if we
                % are done. If no test parameters have been registered by
                % the system under test, stop after one set of iterations.
                if ~isempty(obj.TestParamRegisteredObjects)
                    endOfSimulation = stepIntoNextSimulationPoint(obj);                
                else
                    endOfSimulation = true;
                end
            end %main simulation loop                
            obj.TestConsoleState = 'finished';
            % Let the test console perform post-iteration calculations to wrap
            % up the metric calculations.
            postProcessMetric(obj);            
        end%run method
        %=======================================================================        
        function results = getResults(obj)
            %getResults Get the simulation results
            %   R = getResults(H) returns the simulation results, R, for the
            %   test console, H. R is an object of type testconsole.Results
            %   and contains all the simulation data for all the registered
            %   test points.  
            %
            %   See also testconsole.Results, testconsole.Harness.
        
            % Perform checks
            isSystemIsAttached(obj);                        
            isResultsAvailable(obj);
            
            % Instantiate a results object
            results = testconsole.Results(class(obj), obj.SystemUnderTestName, ...
                obj.TestLog, obj.IterationMode);
        end
        %=======================================================================        
        function attachSystem(obj,system)
            %attachSystem Attach a system to the test console
            %   attachSystem(H,SYS) attaches a user-defined system, SYS, to the
            %   test console, H.            
            %   If system, SYS, was attached to another test console, it will be
            %   detached from it to be attached to the new test console H.   
            %
            %   See also testconsole.Harness, testconsole.Harness/detachSystem.
            
            %Check data type and that object is not empty
            if nargin < 2
                error(generatemsgid('noSystemInput'),...
                    (['A system object must be provided as an input to the ',...
                    'attachSystem method']));
            end
            
            if ~isa(system,'testconsole.System') || isempty(system)
                error(generatemsgid('invalidSystemClass'),...
                    (['Invalid system object class. The ',...
                    'system object must extend the ',...
                    'testconsole.System class']));
            end
                        
            try                                               
                %Detach existing system
                oldSystem = obj.SystemUnderTest;
                if ~strcmpi(obj.TestConsoleState,'uninitialized')                    
                    detachSystem(obj);      
                end
                
                % Set SystemUnderTest property to the input system
                obj.SystemUnderTest = system;                                
                
                %Pass handle to the system under test and let this system
                %register the simulation parameters. The system under test will
                %validate the registerSystem operation by asking the test
                %console if a system attachment operation is currently in place.
                %So we set the corresponding flag to true.
                obj.AttachSystemFlag = true;                
                registerSystem(obj.SystemUnderTest,obj);
                obj.AttachSystemFlag = false;
                
                %Reset after attaching
                reset(obj);

                if isempty(obj.TestParamRegisteredObjects)
                    warnIfNoRegisteredTestParameters(obj);
                end
                if isempty(obj.TestProbeRegisteredObjects)
                    warning(generatemsgid('noProbesRegistered'),...
                        (['The system, SYS, does not contain any ',...
                        'registered test probes.']));
                end
                
                obj.TestConsoleState = 'initialized';
            catch ME
                cleanUpTestConsole(obj);
                obj.AttachSystemFlag = false;
                if ~isempty(oldSystem)
                    attachSystem(obj,oldSystem)
                end
                rethrow(ME)
            end
        end
        %=======================================================================        
        function detachSystem(obj)
            %detachSystem Detach the system under test from the test console
            %   detachSystem(H) detaches the currently attached system from the
            %   test console, H.  This method also clears the registered test
            %   inputs, test parameters, test probes, and test points.
            %
            %   See also testconsole.Harness, testconsole.Harness/attachSystem.
            
            %The system under test will validate the detachSystem operation by
            %asking the test console if a system detachment operation is
            %currently in place. So we set the corresponding flag to true.
            obj.AttachSystemFlag = true;
            
            if isempty(obj.SystemUnderTest)
                warning(generatemsgid('invalidDetach'),...
                    (['No system is currently attached to the test ',...
                    'console.']));
            else
                %Let the system delete the handle to the test console
                unRegisterSystem(obj.SystemUnderTest)                
                cleanUpTestConsole(obj);
            end
            obj.AttachSystemFlag = false;
        end
        %=======================================================================        
        function reset(obj)
            %RESET  Reset the test console
            %   RESET(H) resets test parameters and test probes, and
            %   clears all simulation results of test console, H.
            %
            %   See also testconsole.Harness.
                        
            obj.TotalIterations = [];            
            % Reset registered test parameter objects
            resetAllParameters(obj);            
            % Reset registered test probe objects
            resetAllProbes(obj);            
            % Reset log
            resetLog(obj);
            
            % Reset state of the test console
            if ~strcmpi(obj.TestConsoleState,'uninitialized')
                obj.TestConsoleState = 'initialized';
            end
        end
        %=======================================================================        
        function setTestParameterSweepValues(obj,varargin)
            %setTestParameterSweepValues Set test parameter sweep values
            %   setTestParameterSweepValues(H,NAME,SWEEP) specifies a set of
            %   sweep values, SWEEP, for the registered test parameter named
            %   NAME in the test console, H. Sweep values may only be specified
            %   for registered test parameters. 
            %   SWEEP can be a row vector of numeric values, or a cell array of
            %   char values. 
            %   SWEEP must have values within the specified range of the test
            %   parameter. Use the getTestParameterValidRanges method to get the
            %   valid ranges.
            %
            %   setTestParameterSweepValues(H,NAME1,SWEEP1,NAME2,SWEEP2,...)
            %   allows the simultaneous specification of sweep values for
            %   multiple registered test parameters. 
            %
            %   See also testconsole.Harness,
            %   testconsole.Harness/getTestParameterSweepValues,
            %   testconsole.Harness/getTestParameterValidRanges. 

            isSystemIsAttached(obj);
            
            if nargin == 1
                error(generatemsgid('noInputSweepValues'),...
                    (['You must specify at least one test parameter name ',...
                    'and the corresponding vector of sweep values.']));                
            end
            
            if ~isequal(mod(nargin-1,2),0)
                error(generatemsgid('noInputSweepValues'),...
                    (['You must specify a vector of sweep values for each ',...
                    'test parameter name.']));                
            end                
            
            for idx = 1 : (nargin-1)/2
                name = varargin{2*idx-1};
                value = varargin{2*idx};
                testParamObj = isValidKeyName(obj,name,'parameter');
                
                %The test parameter objects have a SweepVector property where we
                %can save the sweep parameter vector input. We can only set the
                %private SweepVector property using the setSweepVector method of
                %the test parameter object.
                setSweepVector(testParamObj,value)
            end
            
            %Reset test console object after setting a sweep parameter.
            checkResetFlagAndReset(obj)
        end
        %=======================================================================        
        function value = getTestParameterSweepValues(obj,name)
            %getTestParameterSweepValues Get test parameter sweep values
            %   getTestParameterSweepValues(H,NAME) gets the sweep values
            %   currently specified for the registered test parameter named NAME
            %   in the test console, H.
            %
            %   See also testconsole.Harness,
            %   testconsole.Harness/setTestParameterSweepValues,
            %   testconsole.Harness/getTestParameterValidRanges. 
            
            isSystemIsAttached(obj);
            
            testParamObj = isValidKeyName(obj,name,'parameter');
            value = testParamObj.SweepVector;
        end
        %=======================================================================        
        function value = getTestParameterValidRanges(obj,name)
            %getTestParameterValidRanges Get test parameter valid ranges
            %   getTestParameterValidRanges(H,NAME) gets the valid ranges for a
            %   registered test parameter named NAME in the test console, H. 
            %
            %   See also testconsole.Harness,
            %   testconsole.Harness/setTestParameterSweepValues,
            %   testconsole.Harness/getTestParameterSweepValues. 
            
            isSystemIsAttached(obj);
            
            testParamObj = isValidKeyName(obj,name,'parameter');
            value = testParamObj.ValueRange;
        end
        %=======================================================================                 
        function  registerTestPoint(obj, testPointName, varargin)
            %registerTestPoint Register test point to the test console.
            %   A test point groups a set of probes and, possibly, a
            %   user-defined metric calculator function handle. The data in the
            %   probes along with the metric calculator function will be used to
            %   compute the simulation metrics. To get specific help call the
            %   helpRegisterTestPoint method of the test console you are using.
            %
            %   Example:
            %     h = commtest.ErrorRate;   %create an error rate test console
            %     helpRegisterTestPoint(h); % call the register test point help
            %
            %   See also testconsole.Harness,
            %   testconsole.Harness/unregisterTestPoint.
            
            
            % The registerTestPoint method will parse inputs and generate test
            % points according to values returned by the getNumTestPointProbes
            % and getMetricCalcFcnOption methods implemented by the concrete
            % test console. These methods are called inside the
            % getRegisterTestPointSpecs method. The API for the
            % registerTestPoint method varies for each test console but it has
            % one of the following general forms:
            % registerTestPoint(obj, testPointName)
            % registerTestPoint(obj, testPointName, probeName1, ... ProbeNameN)
            % registerTestPoint(obj, testPointName, probeName1, ... ProbeNameN, fcnHandle)
            % registerTestPoint(obj, testPointName, fcnHandle)
            
            
            %Check if a system is currently attached to the test console
            isSystemIsAttached(obj); 
            %Check that a name was input
            if nargin < 2
               error(generatemsgid('noInputNameInTestPoint'),...
                   ['You must specify a test point name when registering ',...
                   'a test point. Call the helpRegisterTestPoint method ',...
                   'of the test console for more information.']);
            end                
            %Check if a test point with the input name already exists
            isDuplicateRegistration(obj, testPointName, 'testpoint');
                        
            % Get specs to parse inputs
            [numProbes probeIdentifiers metricCalcFcnOption] = ...
                getRegisterTestPointSpecs(obj);
            
            L = length(varargin);
            
            if L < numProbes
                error(generatemsgid('notEnoughInputProbes'),...
                    ['The registerTestPoint method expects ',...
                    '%g test probe names as inputs. Call the ',...
                    'helpRegisterTestPoint method of the test console ',...
                    'for more information.'],numProbes);
            end
            %Instantiate a test point object
            testPoint = testconsole.TestPoint(testPointName);
 
           % Check that the input probe names are valid registered
           % probe names and register the probes to the test point.
           if numProbes > 0
               probeNames = varargin(1:numProbes);
               for idx = 1:length(probeNames)
                   % Check valid probe name
                   if ~ischar(probeNames{idx})
                       error(generatemsgid('ProbeNameIsNotChar'), ...
                           ['You must specify %g probe names to register a ',...
                           'test point. Test probe names should be ',...
                           'character arrays. Call the ',...
                           'helpRegisterTestPoint method of the test ',...
                           'console for more information.'],numProbes)
                   end                   
                   try
                      probeObj = obj.TestProbeRegisteredObjects(probeNames{idx});
                   catch me
                       error(generatemsgid('ProbeDoesNotExist'), ...
                           ['Specified test probe ''%s'' is not ',...
                           'registered. Use the info method of the test ',...
                           'console to see valid registered probe names.'],...
                           probeNames{idx});
                   end
                   % Set probes
                   try
                       registerProbe(testPoint, probeIdentifiers{idx}, probeObj)
                   catch me
                       error(generatemsgid('WrongProbeType'), ['Error rate '...
                           'test point ''%s'' requires a test probe of type '...
                           '''testconsole.Probe'''], testPointName)
                   end
               end
           end
           
           % Parse metric calculator function
           % 1) No function handle is input
           if  L < numProbes + 1
               if strcmp(metricCalcFcnOption,'Mandatory')
                   error(generatemsgid('MandatoryFcnHandle'), ...
                       ['You must specify a metric calculator function ',...
                       'handle when registering a test point. Call the ',...
                       'helpRegisterTestPoint method of the test console ',...
                       'for more information.'])
               elseif strcmp(metricCalcFcnOption,'Optional')
                   fcnHandle = getDefaultMetricCalculatorFunction(obj);
               else % metricCalcFcnOption = 'None'
                   fcnHandle = [];
               end
           else
           % 2) A function handle was input    
                if strcmp(metricCalcFcnOption,'None') || L > numProbes + 1
                    error(generatemsgid('tooManyInputsToRegisterTestPoint'), ...
                     ['Too many input arguments to the registerTestPoint ',...
                   'method. Call the helpRegisterTestPoint method ',...
                   'of the test console for more information.'])
                end
               fcnHandle = varargin{numProbes+1};
           end
        
           registerMetric(testPoint,createMetric(obj,fcnHandle));
           
           % Register the test point
           obj.TestPointRegisteredObjects(testPointName) = testPoint;
           
           postProcessRegisterTestPoint(obj,testPointName);
        end        
        %=======================================================================                 
        function  unregisterTestPoint(obj, testPointName)
            %unregisterTestPoint Unregister test point
            %   unregisterTestPoint(H,NAME) removes the test point named NAME
            %   from the test console, H.  
            %   The test console is reset after a call to the
            %   unregisterTestPoint method. 
            %
            %   See also testconsole.Harness,
            %   testconsole.Harness/registerTestPoint.
            
            isSystemIsAttached(obj);
            
            % See if test point exists
           if ~isKey(obj.TestPointRegisteredObjects,testPointName)
               error(generatemsgid('TestPointNotExist'), ...
                   ['Specified test point %s does not exist. ',...
                    'Use the info method to see the registered ',...
                    'test point names.'], testPointName);
           end 
           % Remove the registered test point
           remove(obj.TestPointRegisteredObjects,{testPointName});
           
           reset(obj);
           
           postProcessUnregisterTestPoint(obj, testPointName);
        end       
        %=======================================================================        
        function description = getTestProbeDescription(obj,name)
            %getTestProbeDescription Get test probe description
            %   getTestProbeDescription(H,NAME) gets the description of the
            %   registered test probe named NAME in the test console, H. 
            %
            %   See also testconsole.Harness
            
            isSystemIsAttached(obj);
            
            testProbeObj = isValidKeyName(obj,name,'probe');
            description = testProbeObj.getDescription;
        end                        
        %=======================================================================        
        function info(obj)
            %INFO   Get a report of current test console settings
            %   INFO(H) will display a report with current test console settings
            %   such as registered test parameters and registered test points.
            %
            %   See also testconsole.Harness.
            
            % Get the left line text and names            
            idx = 1;
            outCell{idx,1} = showTestConsoleName(obj); idx = idx+1;
            outCell{idx,1} = showAttachedSystemName(obj); idx = idx+1;
            outCell{idx,1} = showAvailableTestInputs(obj); idx = idx+1;
            outCell{idx,1} = showRegisteredTestInputs(obj); idx = idx+1;           
            outCell{idx,1} = showRegisteredTestParameterNames(obj); idx = idx+1;
            outCell{idx,1} = showRegisteredTestProbeNames(obj); idx = idx+1;
            outCell{idx,1} = showRegisteredTestPointNames(obj); idx = idx+1;
            outCell{idx,1} = showMetricCalculatorFunctions(obj); idx = idx+1;  
            outCell{idx,1} = showTestMetrics(obj);   
            
            % Print on screen
            maxLen = -inf;
            for idx = 1:length(outCell)
                maxLen = max(maxLen,length(outCell{idx}{1}));
            end
            for idx = 1:length(outCell)
                extraLength = maxLen - length(outCell{idx}{1}) + 1;
                fprintf([outCell{idx}{1} char(32*ones(1,extraLength))]);
                testconsole.Harness.dispNames(outCell{idx}{2},maxLen+1)
            end
            
        end
        %=======================================================================        
        % SET/GET Methods
        %=======================================================================        
        function  set.SystemResetMode(obj,value)
            %SET SystemResetMode property
            
            %Check data type (enum)
            propName = 'SystemResetMode';
            validCell = { 'Reset at new simulation point',...
                          'Reset at every iteration'};
            value = validatestring(value, validCell, ...
                [class(obj) '.' propName], propName);
            
            %Set property
            obj.SystemResetMode = value;
            
            %Setting this property causes a test console reset
            checkResetFlagAndReset(obj);
        end
        %=======================================================================        
        function  set.IterationMode(obj,value)
            %SET IterationMode property
            
            %Check data type (enum)
            propName = 'IterationMode';
            validCell = { 'Combinatorial',...
                          'Indexed'};
            value = validatestring(value, validCell, ...
                [class(obj) '.' propName], propName);
            
            %Set property
            obj.IterationMode = value;
            
            %Setting this property causes a test console reset
            checkResetFlagAndReset(obj);
        end
        %=======================================================================         
        function sys = get.SystemUnderTestName(obj)
            %GET SystemUnderTestName property
            if isempty(obj.SystemUnderTest)
                sys = 'No system attached'; 
            else
                sys = class(obj.SystemUnderTest);
            end
        end
    end%Public methods   
    %===========================================================================
    % Service methods to be called by the attached system under test to
    % get test console information. Public but hidden.
    %===========================================================================
    methods (Hidden)
        function  description = getTestConsoleDescription(obj)
            %getTestConsoleDescription
            %   Get the Description property of the test console.
            description = obj.Description;
        end
        %=======================================================================        
        function answer = acknowledgeSystemAttach(obj)
            %acknowledgeSystemAttach
            %   If we are truly in an attach/detach system process, answer with
            %   a true value. Otherwise, do not acknowledge the operation.
            answer = obj.AttachSystemFlag;
        end
        %=======================================================================        
        function detachTestConsole(obj)
            %detachTestConsole
            %   Detach the test console from a system under test.
            %   The system under test calls this method when it wants to leave
            %   this test console to be attached to a new test console.
            
            if acknowledgeTestConsoleDetach(obj.SystemUnderTest)
                cleanUpTestConsole(obj);
            else
                error(generatemsgid('invalidTestConsoleDetach'),...
                    (['The detachTestConsole method can only be called by ',...
                      'a system under test at the time it is detaching ',...
                      'from a test console.']));                                
            end                
        end
        
        %=======================================================================        
        function registerTestParameter(obj,param)
            %registerTestParameter Register a test parameter
            %   The attached system under test will use this method to register
            %   specified test parameter objects. 
            
            %    Add test parameter object to the
            %    TestParamRegisteredObjects property            
            isValidOperation(obj,'registerTestParameter');
            isDuplicateRegistration(obj,param.Name,'parameter');            
            obj.TestParamRegisteredObjects(param.Name) = param;
        end
        %=======================================================================        
        function testParamObj = getTestParameter(obj,name)
            %getTestParameter Get the test parameter object called 'name'
            
            % Registered test parameter objects are kept in
            % TestParamRegisteredObjects property.            
            testParamObj = isValidKeyName(obj,name,'parameter');
        end
        %=======================================================================        
        function registerTestProbe(obj,probe)
            %registerTestProbe Register a test probe object
            
            %Add test probe object to the TestProbeRegisteredObjects property
            isValidOperation(obj,'registerTestProbe');
            isDuplicateRegistration(obj,probe.Name,'probe');
            obj.TestProbeRegisteredObjects(probe.Name) = probe;
        end
        %=======================================================================        
        function setTestProbeData(obj,name,value)
            %setTestProbeData Set test probe data
            %   Log data to test probe called 'name'.
            
            % Registered test probe objects are kept in PrivProbeCopies
            % property.            
            testProbeObj = isValidKeyName(obj,name,'probe');
            setData(testProbeObj, value);
        end
        %=======================================================================        
        function setUserData(obj,value)
            %setUserData Set user data
            %   The same user data is kept in all test point objects. This data
            %   is then passed to each of the metric calculator functions
            %   specified for each test point object.
            
            % set user data to each current test point
            len = length(obj.TestLog.CurrentTestPoints);
            for idx = 1:len                        
                testPoint =obj.TestLog.CurrentTestPoints(idx);
                testPoint.UserData = value;
            end                        
        end        
        %=======================================================================        
        function registerTestInput(obj,inputName)
            %registerTestInput Register a test input
            
            isValidOperation(obj,'registerTestInput');
            if nargin < 2
                error(generatemsgid('noInputName'),...
                    (['A test input name must be provided when ',...
                      'registering an input.']));
            end            
            if ~any(strcmp(inputName,obj.SystemInputs))
                error(generatemsgid('invalidInputType'),...
                    (['Test input ''%s'' is not available in this ',...
                     'test console.']),inputName)
            end          
            if any(strcmp(inputName,obj.RegisteredInputs))
                error(generatemsgid('duplicatedInput'),...
                    (['A test input with name ''%s'' has already been ',...
                      'registered. You may not register the same ',...
                      'test input twice.']),inputName);
            end
            obj.RegisteredInputs = [obj.RegisteredInputs {inputName}];            
        end
    end
    %===========================================================================
    % Define Public Abstract Methods
    %===========================================================================
    methods (Abstract)
        helpRegisterTestPoint(obj)
        %helpRegisterTestPoint Help for registering a test point
        %   The API for registering test points will vary depending on the
        %   concrete test console implementation. Each test console must provide
        %   help to define the API of the registerTestPoint method.          
    end   
    %===========================================================================
    % Define Public Hidden Abstract Methods
    %===========================================================================
    methods (Hidden, Abstract)
        input = getInput(obj,inputName)
            %getInput Get input
            %   Feed the system under test with an input when requested. 
            %   Let the subclass implement this method since inputs will be
            %   different for different testers.
    end                       
    %===========================================================================
    % Define Protected Abstract Methods
    %===========================================================================
    methods (Access = protected, Abstract)
        stopCondition = isEndOfSimulation(obj)
        %isEndOfSimulation Is end of simulation
        %   A test console implementation must define the conditions to end the
        %   simulation for each sweep parameter point.         
        checkEndOfSimulationCriteria(obj)
        %checkEndOfSimulationCriteria Check end of simulation criteria
        %   Check if a valid end of simulation criteria is set.
        name = getDefaultMetricName(obj)
        %getDefaultMetricName Get default metric name
        %   Get default metric name. This metric name is dependent of the type
        %   of test console so the subclass must implement it. 
        numProbes = getNumTestPointProbes(obj)
        %getNumTestPointProbes Get number of probes per test point
        %   The registerTestPoint method of the super class test console will
        %   parse inputs according to values returned by the
        %   getNumTestPointProbes and getMetricCalcFcnOption methods implemented
        %   by the concrete test console.         
        %   Depending on the concrete test console implementation, test points
        %   will contain different number of probes. The concrete test console
        %   must implement this method to specify the number of probes it
        %   expects as inputs to the registerTestPoint method.        
        probeIdentifiers = getTestPointProbeIdentifiers(obj)
        %getTestPointProbeIdentifiers Get test point probe identifier names
        %   This method is called by the registerTestPoint method to get probe
        %   identifier names that will be used by the test point.          
        %   The probeIdentifiers output is a cell array containing generic names
        %   that will be used internally by the test point to identify the
        %   probes it contains. For instance, in an error rate test console we
        %   could have a test point with two probes with user-defined names
        %   'inputSymbols' and 'outputSymbols'. Inside the test point, however,
        %   the probes will be renamed in a more generic way as 'ExpectedValue',
        %   and 'ActualValue'. Probes are kept in a container inside the test
        %   point and their data is accessed using the probe identifier names. 
        option = getMetricCalcFcnOption(obj)
        %getMetricCalcFcnOption
        %   The registerTestPoint method of the super class test console will
        %   parse inputs and generate test points according to values returned
        %   by the getNumTestPointProbes and getMetricCalcFcnOption methods
        %   implemented by the concrete test console. getMetricCalcFcnOption
        %   should return any of the following strings: 'Mandatory, 'None',
        %   'Optional'.
        %   If getMetricCalcFcnOption returns a 'Mandatory' option, the
        %   registerTestPoint method will error out if the user does not input a
        %   metric calculator function handle. 
        %   If getMetricCalcFcnOption returns a 'None' option, the
        %   registerTestPoint method will not expect a user-defined metric
        %   calculator function as an input. The registerTestPoint method will
        %   call the getDefaultMetricCalculatorFunction method and pass the
        %   returned value to the Metric object of the new test point. 
        %   If getMetricCalcFcnOption returns an 'Optional' option, the
        %   registerTestPoint method will look for a user-defined metric
        %   calculator function input. If it does not find a handle input, it
        %   will call the getDefaultMetricCalculatorFunction method to get a
        %   handle. The registerTestPoint will pass either the input handle or
        %   the handle returned by getDefaultMetricCalculatorFunction to the
        %   Metric object of the new test point.         
        metricStruct = getAvailableMetrics(obj)
        %getAvailableMetrics Get the metrics from the concrete test console
        %   The concrete test console must implement this method to specify the
        %   available metric names and their initial values. The output to this
        %   method, metricStruct, must be a structure containing field names
        %   equal to the metric names and field values equal to the initial
        %   value of the metrics e.g.:
        %   metricStruct.MetricName1 = initValue1
        %   metricStruct.MetricNameN = initValueN         
        computeFunctions = getComputeFunctionHandles(obj)
        %getComputeFunctionHandles Get compute function handles
        %   The concrete test console must implement this method to specify the
        %   compute functions it will use to compute metrics. The
        %   computeFunctions output must be a cell array of function handles.
        %   The number of compute functions will vary for each test console.    
        aggregateFunctions = getAggregateFunctionHandles(obj)
        %getAggregateFunctionHandles Get aggregate function handles
        %   The concrete test console must implement this method to specify the
        %   aggregate functions it will use to aggregate metrics calculated at
        %   each worker in a parfor loop. The aggregateFunctions output must be
        %   a cell array of function handles. The number of aggregate functions
        %   will vary for each test console.             
    end    
    %===========================================================================
    % Define Protected Methods
    %===========================================================================
    methods (Access = protected)
        function totalIters = runIterations(obj)
            %runIterations Run iterations
            %   This method calls the reset, and run methods of the system under
            %   test. Several iterations for a given sweep point are performed
            %   in here. Iterations end when output to isEndOfSimulation method
            %   is true. This method is called in the parfor loop.
            
            resetAtEveryIteration = ...
                strcmp(obj.SystemResetMode,'Reset at every iteration');
            
            if strcmp(obj.SystemResetMode,'Reset at new simulation point')
                reset(obj.SystemUnderTest)
            end
            
            %initialize counters and conditions
            totalIters = 0;                                              
            stopCondition = false;            
            while ~stopCondition
                                
                %Reset the system under test
                if resetAtEveryIteration
                    reset(obj.SystemUnderTest);                   
                end
                
                % Run the system under test
                run(obj.SystemUnderTest);
                
                if obj.RegisteredTestPointsFlag
                    processTestLogData(obj)
                else
                    resetAllProbes(obj);
                end
                
                % Count number of iterations
                totalIters = totalIters + 1;
                
                % Check if simulation is done
                if obj.RegisteredTestPointsFlag
                    stopCondition = isEndOfSimulation(obj);
                else                   
                    maxIters = getDefaultMaxNumIterations(obj);
                    if totalIters == ...
                            ceil(maxIters/obj.NumWorkers)
                        stopCondition = true;
                    end
                end                
            end %while            
        end        
        %=======================================================================        
        function endOfSimulation = stepIntoNextSimulationPoint(obj)
            %stepIntoNextSimulationPoint
            %   Increment SweepIndex of test parameter objects and actualize
            %   their current parameter value according to the SweepIndex. All
            %   this happens internally in the test parameter object when
            %   calling the object's increment method. Set endOfSimulation to
            %   true when we have gone through all the desired combinations of
            %   parameters (the type of sweep parameter combinations is
            %   controlled by the IterationMode property). 
            
            paramObjs = obj.TestParamRegisteredObjects;
            params = keys(paramObjs);
            len = length(params);
            
            if strcmp(obj.IterationMode,'Combinatorial')
                % All possible combinations of sweep parameters
                idx = 1;
                while idx <= len
                    endOfSimulation = increment(paramObjs(params{idx}));
                    if ~endOfSimulation
                        return
                    else
                        idx = idx + 1;
                    end
                end               
            else % Indexed iteration mode
                % same index combinations only
                endOfSimulation = false;
                endOfSweepVector = zeros(1,len);
                for idx = 1:len
                    endOfSweepVector(idx) = ...
                        increment(paramObjs(params{idx}));
                end
                if all(endOfSweepVector == true)
                    endOfSimulation = true;
                end
            end
        end
        %=======================================================================         
        function resetAllParameters(obj)
            %resetAllParameters Reset registered test parameter objects
            
            names = keys(obj.TestParamRegisteredObjects);
            for idx = 1:length(names)
                reset(obj.TestParamRegisteredObjects(names{idx}));
            end
        end      
        %=======================================================================                 
        function parseInputs(obj,varargin)
            %parseInputs Parse inputs to the constructor of a test console
            
            %Attach a system if it has been specified in the input pv-pairs
            systemHasBeenAttached = false;
            if nargin > 1
                if isa(varargin{1},'testconsole.System')                     
                    attachSystem(obj,varargin{1});
                    varargin(1) = [];
                    systemHasBeenAttached = true;
                elseif ~ischar(varargin{1})
                    error(generatemsgid('invalidFirstInput'),...
                        ['Expected first input to be an object that extends ',...
                        'the testconsole.System class, or a character array ',...
                        'containing a valid property name of the ',...
                        'test console class.']);                    
                end                
            end              
            %Attach default system if no system was specified in the input
            %pv-pairs.
            if  ~systemHasBeenAttached           
                %Set default communications system
                defaultSystem = getDefaultSystem(obj);
                if ~isempty(defaultSystem) && ...
                        isa(defaultSystem,'testconsole.System')
                    attachSystem(obj,defaultSystem);
                end
            end
            % If there are pv-pairs, set them now that a system has been
            % attached. 
            if ~isempty(varargin)
                % There are input arguments, so initialize with
                % property-value pairs.
                initPropValuePairs(obj, varargin{:});
            end                                    
        end
        %=======================================================================        
        function sweepPoint = getCurrentSweepPoint(obj)
            % getCurrentSweepPoint Get current sweep point
            %   Output is set in a structure containing the test parameter names
            %   and current values.
            
            names = keys(obj.TestParamRegisteredObjects);
            
            sweepPoint = containers.Map;
            for idx = 1:length(names)
                p = obj.TestParamRegisteredObjects(names{idx});
                sweepPoint(names{idx}) = p;
            end
        end
        %=======================================================================        
        function startSweepPoint(obj,sweepPoint)
            %startSweepPoint Start a sweep point
            %   Create a new test log object, and call the setup method of the
            %   attached system under test
                        
            %Call system under test setup method
            setup(obj.SystemUnderTest);
            
            %Continue only if at least one test point has been registered
            if obj.RegisteredTestPointsFlag
       		% Start a new log point for the new sweep point. The new log point
            % will hold the test points for the new sweep point.           
            	startNewLogPoint(obj.TestLog, sweepPoint, ...
                	obj.TestPointRegisteredObjects);
            end
        end
        %=======================================================================        
        function processTestLogData(obj) 
            %processTestLogData Process the test log data
            %   Calculate test metrics with data collected in the probes
            
            % Process data of the current test point
            processCurrentTestPointsData(obj.TestLog);
            
            % Reset all the probes
            resetAllProbes(obj);
        end
        %=======================================================================        
        function endSweepPoint(obj,currentTestPoint)
			%endSweepPoint End a sweep point
            %   Finish the current sweep point simulation

           endLogPoint(obj.TestLog, currentTestPoint);
        end
        %=======================================================================         
        function postProcessMetric(obj) %#ok<MANU>
            %postProcessMetric Post process metric
            %   Let the test console perform post-iteration calculations to wrap
            %   up the metric calculations. Each concrete subclass will have its
            %   specific way of wrapping up metric calculations so this is a
            %   hook method that the subclass may override. 
            
            % NO OP
        end
        %=======================================================================                         
        function postProcessRegisterTestPoint(obj,testPointName) %#ok<MANU,INUSD>
            %postProcessRegisterTestInput 
            %   Post process after registering a test point. The concrete test
            %   console can override this NO OP method to perform extra tasks
            %   right after a test point has been registered. E.g. the error
            %   rate test console will set some properties (not available in the
            %   super class) to the first registered test point name. Input
            %   testPointName is the name of the test point that has been
            %   registered. The postProcessRegisterTestPoint method is called by
            %   the test console super class at the end of the registerTestPoint
            %   method.

            % NO OP
        end
        %=======================================================================                         
        function postProcessUnregisterTestPoint(obj, testPointName) %#ok<INUSD,MANU>
            %postProcessUnregisterTestPoint 
            %   Post process after unregistering a test point. The concrete test
            %   console can override this NO OP method to perform extra tasks
            %   right after a test point has been unregistered. Input
            %   testPointName is the name of the test point that has been
            %   unregistered. The postProcessUnregisterTestPoint method is
            %   called by the test console super class at the end of the
            %   unregisterTestPoint method.
            
            % NO OP    
        end
        %=======================================================================                 
        function numIters = getDefaultMaxNumIterations(obj)  %#ok<MANU>
            %getDefaultMaxNumIterations Get the default max number of iterations
            %   Define a stop criteria at run time when no test points have been
            %   registered to the test console. The subclass test console may
            %   override this method to specify a value different than the
            %   default 500 iterations.            
            numIters = 500;
        end
        %=======================================================================                         
        function metricCalcFcn = getDefaultMetricCalculatorFunction(obj) %#ok<MANU>
            %getDefaultMetricCalculatorFunction Get default metric calculator
            %   function.
            %   A test point may contain a metric calculator function that will
            %   be used to compute metrics. If a default metric calculator
            %   function is available in a concrete test console class, then
            %   this class can override this method to specify the handle to the
            %   function. This method is called by the registerTestPoint method
            %   to obtain a default metric calculator function handle, if one is
            %   available. 
            metricCalcFcn = [];
        end
        %=======================================================================         
        function resetAllProbes(obj)
            %resetAllProbes Reset registered test probe objects
            
            names = keys(obj.TestProbeRegisteredObjects);
            for idx = 1:length(names)
                reset(obj.TestProbeRegisteredObjects(names{idx}));
            end                
        end
        %=======================================================================         
        function resetLog(obj)
            %resetLog Reset the test log
            
            reset(obj.TestLog, obj.TestPointRegisteredObjects);
        end        
        %=======================================================================        
        function actualTarget = getActualTarget(obj,userTarget)
            %getActualTarget Get actual target
            %   Get actual stop-simulation-criteria target. Actual target
            %   differs from the user specified target in that it is divided by
            %   the number of available workers (since the iterations to
            %   accomplish this target are distributed among the available
            %   number of workers). 
            actualTarget = ceil(userTarget/obj.NumWorkers);        
        end
        %=======================================================================        
        function testObj = isValidKeyName(obj,name,type)
            %isValidKeyName Is valid key name
            %   Checks if key is valid, then it outputs the object corresponding
            %   to that key name.
            
            if strcmp(type,'probe')
                regTestObjs = obj.TestProbeRegisteredObjects;
            elseif strcmp(type,'parameter')
                regTestObjs = obj.TestParamRegisteredObjects;
            elseif strcmp(type,'testpoint')
                regTestObjs = obj.TestPointRegisteredObjects;
            else
                error(generatemsgid('invalidTypeToKeyChecker'),...
                    ('Invalid type input to isValidKeyName method.'));
            end
            
            % Check if name is a registered test object
            if ~isKey(regTestObjs,name)
                error(generatemsgid('invalidTestObjName'),...
                    (['Test %s ''%s'' name is not ',...
                      'registered.']),type,name);
            end
            
            % Return the valid test object
            testObj = regTestObjs(name);
        end
        %=======================================================================        
        function isValidIndexedIteration(obj)
            %isValidIndexedIteration Is valid indexed iteration
            %  When user chooses indexed iteration mode, check that sweep
            %  parameter vectors are all of the same length or unity length. 
            
            if strcmp(obj.IterationMode,'Indexed') &&...
                    ~isempty(obj.TestParamRegisteredObjects)
                
                names = keys(obj.TestParamRegisteredObjects);
                lCheck = zeros(size(names));
                for idx = 1:length(names)
                    p = obj.TestParamRegisteredObjects(names{idx});
                    lCheck(idx) = length(p.SweepVector);
                end
                lCheck(lCheck == 1) = [];
                if any(lCheck(1)~=lCheck)
                    error(generatemsgid('invalidRun'),...
                        (['When the IterationMode property is set to ',...
                          '''Indexed'', the length of a sweep ',...
                          'vector of a registered test parameter must ',...
                          'be unity or equal to the length of the sweep ',...
                          'vectors of all the other registered test ' ,...
                          'parameters.']));
                end
            end
        end
        %=======================================================================        
        function isValidInputRegistration(obj) %#ok<MANU>
            %isValidInputRegistration Is valid input registration
            %   Check conditions for registered inputs to work correctly. Check
            %   if we have correct registered input - parameter pairs.
            %   The concrete subclass may override this method if it needs to
            %   check necessary conditions that will make registered inputs work
            %   correctly. Each subclass will have different conditions. 
            
            % NO OP
        end        
        %=======================================================================         
        function namesCell = getTestInputNames(obj) %#ok<MANU>
            %getTestInputNames
            %   Get available test inputs. The concrete subclass may override
            %   this method if it has available test inputs. The
            %   getTestInputNames method should return a cell with test input
            %   names available in the test console.             
            namesCell = {};
        end
        %=======================================================================         
        function isSystemIsAttached(obj)
            % isSystemIsAttached Is system attached
            %   Check if a system is currently attached to the test console. 
            
            if strcmpi(obj.TestConsoleState,'uninitialized')                
                error(generatemsgid('systemNotAttached'),...
                    (['The test console does not have an attached system. ',...
                      'Use the attachSystem method to ',...
                      'attach a system.']));
            end        
        end
        %=======================================================================                 
        function  isValidOperation(obj,method)
            %isValidOperation Is valid operation
            %   Check if a public hidden method is not called at the wrong time
            %   or from the wrong place by the user. 
            if ~obj.AttachSystemFlag
                error(generatemsgid('invalidOperation'),...
                    (['The %s method may only be called by the ',...
                    'system under test at registration time ',...
                    'when attaching to a test console.']),method);
            end
        end
        %=======================================================================         
        function isResultsAvailable(obj)
            %isResultsAvailable Check if results are available
            
            if ~strcmpi(obj.TestConsoleState,'finished')                
                error(generatemsgid('resultsNotAvailableNoRun'),...
                    (['No results are available at this time. You must ',...
                      'call the run method of the test console to ',...
                      'generate results.']));
            elseif ~obj.RegisteredTestPointsFlag   
                error(generatemsgid('resultsNotAvailableNoTestPointReg'),...
                    (['No results are available since no ',...
                      'test points have been registered to the ',...
                      'test console.']));
            end                                
        end
        %=======================================================================                 
        function isDuplicateRegistration(obj,name,type)
            %isDuplicateRegistration Check if test object name already exists
            
            if strcmp(type,'parameter')
                container = obj.TestParamRegisteredObjects;
            elseif strcmp(type,'probe')
                container = obj.TestProbeRegisteredObjects;
            elseif strcmp(type,'testpoint')
                container = obj.TestPointRegisteredObjects;
            else
                error(generatemsgid('UnrecognizedType'), ...
                    ['Test object type '...
                     '%s is not recognized.  Use ''parameter'', ',...
                     '''probe'', or ''testpoint''.'], type);
            end
            if isKey(container,name)
                error(generatemsgid('duplicatedParameter'),...
                    (['A test %s with name ''%s'' has already been ',...
                      'registered.']),type,name);                
            end
        end
        %=======================================================================        
        function checkResetFlagAndReset(obj)
            %checkResetFlagAndReset Call reset if ResetFlag is true
            if obj.ResetFlag
                reset(obj);
                %Avoid resetting when more properties are changed until run
                %is called again
                obj.ResetFlag = false;
            end
        end
        %=======================================================================        
        function setEndOfSimulationCriteria(obj)
            %setEndOfSimulationCriteria Set end of simulation criteria
            %   Check if any test points have been registered, and if so, check
            %   if a valid end of simulation criteria is specified.
            
            if ~isempty(obj.TestPointRegisteredObjects)
                %test points have been specified
                checkEndOfSimulationCriteria(obj);
                obj.RegisteredTestPointsFlag = true;
            else           
                %no test points have been registered
                obj.RegisteredTestPointsFlag = false;
                warning(generatemsgid('noRegistration'), ...
                    (['No test points have been registered to ',...
                      'the test console. The test console will ',...
                      'run %g iterations per sweep parameter ',...
                      'point and stop.']),getDefaultMaxNumIterations(obj));                
            end    
        end
        %=======================================================================         
        function warnIfNoRegisteredTestParameters(obj) %#ok<MANU>
            %warnIfNoRegisteredTestParameters Warn if no registered parameters
            %   Override this method if a test console usually requires
            %   registered test parameters and the system under test has not
            %   provided any. This is a hook method since not all test consoles
            %   will necessarily require registered test parameters. 
            
            % NO OP
        end
        %=======================================================================        
        function warnAboutIrrelevantSet(obj,propertyName,class) %#ok<MANU>
            %warnAboutIrrelevantSet Warn about irrelevant set
            %   Warn when the user attempts to set an irrelevant property.
            id = [propertyName ':irrelevantPropertySet'];
            warning(generatemsgid(id),['The %s property is not relevant ',...
                'in this configuration of %s.'],propertyName,class);
        end
        %=======================================================================        
        function names = getMetricNames(obj, testPointName)
            %getMetricNames Get metric names
            testPointObj = isValidKeyName(obj, testPointName, 'testpoint');
            names = getMetricNames(testPointObj);
        end
        %=======================================================================        
        function  defaultSys = getDefaultSystem(obj) %#ok<MANU>
            %getDefaultSystem get default system
            %    The concrete test console can override this method if it wants
            %    to attach a default system when the user does not specify a
            %    system as an input at construction time. 
            defaultSys = [];
        end
        %=======================================================================          
        function handle = getFormatPlotFunction(obj) %#ok<MANU>
            %getFormatPlotFunction Get format plot function handle
            %   Get the function handle of the function that will be used to
            %   format plots. The results object will generate plots and then
            %   call the format plot function so that the concrete test console
            %   implementation can add titles, labels, legends, and so on to the
            %   figure. 
            handle = [];
        end
    end %protected methods
    %===========================================================================
    % Define private methods 
    %===========================================================================
    methods (Access = private)
        function setTestInputs(obj,inputNames)
            %setTestInputs
            %   Set the SystemInputs property to the available test input names.
            %   
            %   The input names are returned by the concrete console class using
            %   the getTestInputNames method. 
            if ~isempty(inputNames)
                if ~iscell(inputNames)
                    error(generatemsgid('inputNamesMustBeCell'),...
                        (['Expected input names to be a cell array in the ' ,...
                        'setTestInputs method']));
                else
                    for idx = 1:length(inputNames)
                        if ~ischar(inputNames{idx})
                            error(generatemsgid('inputNamesMustBeChar'),...
                                (['Expected elements of input names cell ',...
                                'array to be character arrays in the ',...
                                'setTestInputs method.']));
                        end
                    end
                end      
                obj.SystemInputs = inputNames;
            end                                        
        end
        %=======================================================================        
        function setDefaultMetric(obj,name)                        
            %setDefaultMetric
            obj.TestLog.DefaultMetric = name;
        end
        %=======================================================================        
        function setFormatPlotFunction(obj,handle)
            %setFormatPlotFunction
            obj.TestLog.FormatPlotFunction = handle;
        end
        %=======================================================================        
        function cleanUpTestConsole(obj)
            %cleanUpTestConsole Clean up the test console
            
            obj.TestParamRegisteredObjects = containers.Map;
            obj.TestProbeRegisteredObjects = containers.Map;
            obj.TestPointRegisteredObjects = containers.Map;
            obj.SystemUnderTest = [];
            obj.RegisteredInputs = [];
            obj.TestConsoleState = 'uninitialized';
            reset(obj);
        end
        %=======================================================================                
        function [numProbes probeIdentifiers fcnOption] = getRegisterTestPointSpecs(obj)
            %getRegisterTestPointSpecs 
            %   Get specifications to create a test point an to parse inputs to
            %   the registerTestPoint super class method.
            
            numProbes = getNumTestPointProbes(obj);
            validateattributes(numProbes,...
                {'numeric'},...
                {'finite','nonnegative','scalar','integer'}, ...
                class(obj),...
                'getNumTestPointProbes method');
            
            probeIdentifiers = getTestPointProbeIdentifiers(obj);
            validateattributes(probeIdentifiers,...
                {'cell'},...
                {}, ...
                class(obj),...
                'getTestPointProbeIdentifiers method');
            
            fcnOption = getMetricCalcFcnOption(obj);
            validCell = { 'Mandatory' 'None' 'Optional'};
            fcnOption = validatestring(fcnOption, validCell, ...
                class(obj), 'getMetricCalcFcnOption method');
            
            if ~isequal(numProbes,length(probeIdentifiers))
                error(generatemsgid('invalidNumProbes'), ...
                    ['The specified number of probes per test point ',...
                    'returned by the getNumTestPointProbes method and the ',...
                    'length of the probe identifier names cell returned by ',...
                    'the getTestPointProbeIdentifiers method must be the ',...
                    'same.']);
            end
        end
        %=======================================================================               
        function metric = createMetric(obj,metricCalcFcn)
            %createMetric
            %   Create a metric object and set its metric calculator function,
            %   compute functions and aggregate functions. 
            
            metricStruct = getAvailableMetrics(obj);                        
            metric = testconsole.Metric(metricStruct);
            
            % Set error calculator function
            setComputeFunctions(metric,getComputeFunctionHandles(obj));
            
            % Set aggregate error and transmission counts function
            setAggregateFunctions(metric,getAggregateFunctionHandles(obj));
            
            % Set the metric calculator function 
            setMetricCalculatorFunction(metric, metricCalcFcn)                        
        end                        
        %=======================================================================        
        % Show Methods
        %=======================================================================        
        function outCell = showTestConsoleName(obj)
            %showTestConsoleName Show the test console class name                                
            outCell{1} = 'Test console name:';
            outCell{2} = {class(obj)};                                              
        end
        %=======================================================================         
        function outCell = showAttachedSystemName(obj)
            %showAttachedSystemName Show the attached system class name
            %   showAttachedSystemName(H) shows the class name of the system
            %   that is currently attached to the test console object H.   
            
            outCell{1} = 'System under test name:';
            if strcmpi(obj.TestConsoleState,'uninitialized')
                outCell{2} = {'None'};
            else
                outCell{2} = {class(obj.SystemUnderTest)};
            end
        end
        %=======================================================================         
        function outCell = showAvailableTestInputs(obj) 
            %showAvailableTestInputs Show available test inputs
            
            outCell{1} = 'Available test inputs:';
            outCell{2} = obj.SystemInputs; 
            if isempty(outCell{2})
                outCell{2} = {'None'};
            end
        end
        %=======================================================================         
        function outCell = showRegisteredTestInputs(obj) 
            %showRegisteredTestInputs Show registered test inputs
            
            outCell{1} = 'Registered test inputs:';
            
            outCell{2} = obj.RegisteredInputs; 
            if isempty(outCell{2})
                outCell{2} = {'None'};
            end            
                                             
        end 
        %=======================================================================         
        function outCell = showRegisteredTestPointNames(obj)
            %showRegisteredTestPointNames Show registered test point names
            %   showRegisteredTestPointNames(H) shows the names of the test
            %   points currently registered to the console object H.
            
            outCell{1} = 'Registered test points:';            
            outCell{2} = keys(obj.TestPointRegisteredObjects);
            if isempty(outCell{2})
                outCell{2} = {'None'};
            end            
        end 
        %=======================================================================         
        function outCell = showMetricCalculatorFunctions(obj)
            %showMetricCalculatorFunction Show metric calculator function
            
            outCell{1} = 'Metric calculator functions:';
            outCell{2} = {};
            testPointNames = keys(obj.TestPointRegisteredObjects);
            if ~isempty(testPointNames)
                metricFunNames = cell(size(testPointNames));
                for idx = 1: length(testPointNames)
                    metric = ...
                        obj.TestPointRegisteredObjects(testPointNames{idx}).Metric;
                    metricFunNames{idx} = ...
                        ['@' char(getMetricCalculatorFunction(metric))];
                end
                outCell{2} = metricFunNames;
            end
            if isempty(outCell{2})
                outCell{2} = {'None'};
            end                            
        end                            
        %=======================================================================         
        function outCell = showRegisteredTestProbeNames(obj)
            %showRegisteredTestProbeNames Show registered test probe names
            %   showRegisteredTestProbeNames(H) returns a cell array with the
            %   names of the test probes currently registered to the test
            %   console object H.  
            
            outCell{1} = 'Registered test probes:';
            outCell{2} = keys(obj.TestProbeRegisteredObjects);
            if isempty(outCell{2})
                outCell{2} = {'None'};
            end            
        end      
        %=======================================================================         
        function outCell = showRegisteredTestParameterNames(obj)
            %showRegisteredTestParameterNames Show registered test parameter names
            %   showRegisteredTestParameterNames(H) returns a cell array with
            %   the names of the test parameters currently registered to the
            %   test console object H.
            
            outCell{1} = 'Registered test parameters:';
            outCell{2} = keys(obj.TestParamRegisteredObjects);
            if isempty(outCell{2})
                outCell{2} = {'None'};
            end            
        end    
        %=======================================================================         
        function outCell = showTestMetrics(obj)
            %showTestMetrics Show test metrics
            
            outCell{1} = 'Test metrics:';
            outCell{2} = {};
            testPointNames = keys(obj.TestPointRegisteredObjects);
            if ~isempty(testPointNames)
                metric = obj.TestPointRegisteredObjects(testPointNames{1}).Metric;
                outCell{2} = getMetricNames(metric);            
            end
            if isempty(outCell{2})
                outCell{2} = {'None'};
            end            
        end                    
    end%private methods 
    %===========================================================================
    % Define Public Hidden Static methods
    %===========================================================================
    methods (Static, Hidden)
        function numWorkers = getNumWorkers
            %getNumWorkers Get number of workers
            %   Find out if user has a PCT license and get the number of workers
            %   available in the matlabpool.
            
            %See if a matlabpool is open and how many workers are available
            if testconsole.Harness.isPCTInstalled
                numWorkers = matlabpool('size');
                if numWorkers == 0
                    numWorkers = 1;
                else
                    fprintf(['%g workers available for parallel computing. ',...
                        'Simulations will be distributed among these ',...
                        'workers. \n'],...
                        numWorkers);
                end
            else
                numWorkers = 1;
            end
        end  
    end    
    %===========================================================================
    % Define Private Static methods
    %===========================================================================
    methods (Access = private, Static)
        function value = isPCTInstalled
            %isPCTInstalled Is PCT installed
            %   Returns true if PCT toolbox is installed.
            
            value = false;            
            % This is for the compiler - LICENSE and VER do not work for
            % compiled applications so we need to check for the presence of the
            % PCT directory in the CTF root (compiled archived root)
            if isdeployed
                dir_present = ...
                    exist(fullfile(ctfroot,'toolbox','distcomp'),'dir');
                if (dir_present==7) %exist returns a 7 if it finds a directory
                    value = true; 
                end
            else                                
                value = license('test', 'MATLAB_Distrib_Comp_Engine') && ...
                    ~isempty(ver('distcomp'));                
            end
        end
        %=======================================================================
        function dispNames(names,maxLen)
            %dispNames Display method for the info method
            
            totalLength = maxLen;
            len = length(names);
            for idx = 1:len
                totalLength = totalLength + length(names{idx});
                fprintf('%s',names{idx})
                if idx < len
                    fprintf(', ')
                    if totalLength > 70
                        fprintf('\n')
                        fprintf(char(32*ones(1,maxLen)))
                        totalLength = maxLen;
                    end
                end
            end
            fprintf('\n')
        end
    end
end %classdef

