classdef (Sealed) ErrorRate < testconsole.Harness
%ErrorRate Error Rate Test Console
%   H = commtest.ErrorRate returns an Error Rate Test Console, H. The Error Rate
%   Test Console runs simulations of a system under test to obtain error rates.
%
%   H = commtest.ErrorRate(SYS) returns an Error Rate Test Console,
%   H, with an attached system under test, SYS. 
%
%   H = commtest.ErrorRate(SYS,'PropertyName',PropertyValue,...) returns an
%   Error Rate Test Console, H, with an attached system under test, SYS, and
%   with each specified property, 'PropertyName', set to the specified value,
%   PropertyValue. 
%
%   H = commtest.ErrorRate('PropertyName',PropertyValue,...) returns an Error
%   Rate Test Console, H, with each specified property, 'PropertyName', set to
%   the specified value, PropertyValue. 
%
%   commtest.ErrorRate methods:
%       run                          - Run error rate simulations
%       getResults                   - Get simulation results
%       info                         - Get a report of test console settings 
%       reset                        - Reset the Error Rate Test Console
%       attachSystem                 - Attach a system to test console
%       detachSystem                 - Detach the system from the test console
%       setTestParameterSweepValues  - Set test parameter sweep values
%       getTestParameterSweepValues  - Get test parameter sweep values
%       getTestParameterValidRanges  - Get test parameter valid ranges
%       getTestProbeDescription      - Get test probe description
%       registerTestPoint            - Register a test point
%       helpRegisterTestPoint        - Get help to register a test point
%       unregisterTestPoint          - Unregister a test point
%
%   commtest.ErrorRate properties:
%       Description                  - 'Error Rate Test Console'. Read-only
%       SystemUnderTestName          - System under test name. Read-only
%       FrameLength                  - Frame length
%       IterationMode                - Iteration mode
%       SystemResetMode              - System reset mode
%       SimulationLimitOption        - Simulation limit option
%       MaxNumTransmissions          - Maximum number of transmissions
%       MinNumTransmissions          - Minimum number of transmissions
%       MinNumErrors                 - Minimum number of errors
%       TransmissionCountTestPoint   - Test point to get transmission count
%       ErrorCountTestPoint          - Test point to get error count
%
%    Example:
%      % Obtain bit error rate and  symbol error rate of an M-PSK system
%      % for different modulation orders and EbNo values. 
% 
%      % Instantiate an Error Rate Test Console. The default Error Rate
%      % Test Console has an M-PSK system attached. 
%      h = commtest.ErrorRate; 
% 
%      % Set sweep values for simulation test parameters
%      setTestParameterSweepValues(h,'M',2.^[1 2 3 4],'EbNo',(-5:5))
%   
%      % Register a test point
%      registerTestPoint(h,'BitErrorRate','TxInputBits','RxOutputBits')
%      
%      % Get information about the simulation settings
%      info(h)
%
%      % Run the M-PSK simulations 
%      run(h)
% 
%      % Get the results
%      mpskResults = getResults(h);
%      
%      % Get a semi-log scale plot of EbNo versus bit error rate for different
%      % values of modulation order M
%      mpskResults.TestParameter2 = 'M';
%      semilogy(mpskResults)
%
%   See also testconsole.Results.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/08/11 15:38:10 $

    %===========================================================================
    % Define Public Properties
    %===========================================================================
    properties
        %SimulationLimitOption Simulation limit option
        %   Specify how to stop the simulation for each sweep parameter point as
        %   one of [{'Number of transmissions'} | 'Number of errors' | 'Number
        %   of errors or transmissions' | 'Number of errors and transmissions'].
        %   When this property is set to 'Number of transmissions' the
        %   simulation for a sweep parameter point stops when the number of
        %   transmissions specified in the MaxNumTransmissions property are
        %   completed. The TransmissionCountTestPoint property should be set to
        %   the name of the registered test point that contains the transmission
        %   count that will be compared to the MaxNumTransmissions property to
        %   control the simulation length. 
        %   When this property is set to 'Number of errors' the simulation for a
        %   sweep parameter point stops when the number of errors specified in
        %   the MinNumErrors property has been counted. The ErrorCountTestPoint
        %   property should be set to the name of the registered test point that
        %   contains the error count that will be compared to the MinNumErrors
        %   property to control the simulation length. 
        %   When this property is set to 'Number of errors or transmissions' the
        %   simulation for a sweep parameter point stops when the number of
        %   transmissions specified in the MaxNumTransmissions property has been
        %   completed, or when the number of errors specified in the
        %   MinNumErrors property has been obtained, whichever happens first.
        %   The TransmissionCountTestPoint property should be set to the name of
        %   the registered test point that contains the transmission count that
        %   will be compared to the MaxNumTransmissions property, and the
        %   ErrorCountTestPoint property should be set to the name of the
        %   registered test point that contains the error count that will be
        %   compared to the MinNumErrors property to control the simulation
        %   length.
        %   When this property is set to 'Number of errors and transmissions'
        %   the simulation for a sweep parameter point will stop when both
        %   specified number of transmissions and errors have at least reached
        %   the values in MinNumTransmissions and MinNumErrors respectively. The
        %   TransmissionCountTestPoint property should be set to the name of the
        %   registered test point that contains the transmission count that will
        %   be compared to the MinNumTransmissions property, and the
        %   ErrorCountTestPoint property should be set to the name of the
        %   registered test point that contains the error count that will be
        %   compared to the MinNumErrors property to control the simulation
        %   length.       
        %   Call the info method of the Error Rate Test Console to see the valid
        %   registered test point names.
        %
        %   See also commtest.ErrorRate, commtest.ErrorRate/Info.
        SimulationLimitOption = 'Number of transmissions';
    end
    %=========================================================================== 
    % Define Public Dependent Properties
    %=========================================================================== 
    properties (Dependent)
        %FrameLength Frame length
        %   Specify the length of the transmission frame at each iteration. This
        %   property is only relevant when the system under test has registered
        %   a valid test input. If the system under test has registered a
        %   'NumTransmissions' test input and calls its getInput method, then
        %   the Error Rate Test Console will simply return the value stored in
        %   the FrameLength property. The system under test can use this value
        %   to generate a transmission frame of the specified length using an
        %   internal data source. If the system under test has registered a
        %   'DiscreteRandomSource' test input and calls its getInput method,
        %   then the Error Rate Test Console will generate and return a frame of
        %   symbols of length specified in the FrameLength property.
        %   Default value is 500.
        %
        %   See also commtest.ErrorRate.        
        FrameLength      
        %MaxNumTransmissions Maximum number of transmissions
        %   Specify the maximum number of transmissions that must be counted
        %   before stopping the simulation for a sweep parameter point. This
        %   property is relevant only when 'SimulationLimitOption' is set to
        %   'Number of transmissions', or 'Number of errors or transmissions'.
        %   When the SimulationLimitOption property is set to 'Number of
        %   transmissions' the simulation for each sweep parameter point will
        %   stop when the number of transmissions specified in the
        %   MaxNumTransmissions property has been counted. When the
        %   SimulationLimitOption property is set to 'Number of errors or
        %   transmissions' the simulation for each sweep parameter point will
        %   stop when the number of transmissions specified in the
        %   MaxNumTransmissions property has been completed, or when the number
        %   of errors specified in the MinNumErrors property has been obtained,
        %   whichever happens first. 
        %   The type of transmissions used in the transmission count is
        %   user-specific and is defined by setting the
        %   TransmissionCountTestPoint property to the name of a registered test
        %   point that contains that count. 
        %   Call the info method of the Error Rate Test Console to see the valid
        %   registered test point names. 
        %   If no test points have been registered to the test console, then the
        %   Error Rate Test Console will run, for each sweep parameter point, a
        %   number of iterations equal to the value stored in the
        %   MaxNumTransmissions property regardless of this property being
        %   relevant or not. If there are no registered test parameters either,
        %   then the Error Rate Test Console will run a number of iterations
        %   equal to the value stored in the MaxNumTransmissions property and
        %   stop.
        %   Default value is 1000.
        %
        %   See also commtest.ErrorRate, commtest.ErrorRate/Info.       
        MaxNumTransmissions
        %MinNumTransmissions Minimum number of transmissions
        %   Specify the minimum number of transmissions that must be counted
        %   before stopping the simulation for a sweep parameter point. This
        %   property is relevant only when 'SimulationLimitOption' is set to
        %   'Number of errors and transmissions'. In this scenario the
        %   simulation for a sweep parameter point will stop when both
        %   number of transmissions and errors have at least reached the values
        %   specified in the MinNumTransmissions and MinNumErrors properties.
        %   The type of transmissions used in the transmission count is
        %   user-specific and is defined by setting the
        %   TransmissionCountTestPoint property to the name of a registered test
        %   point that contains that count. 
        %   Call the info method of the Error Rate Test Console to see the valid
        %   registered test point names. 
        %   Default value is 1000.
        %
        %   See also commtest.ErrorRate, commtest.ErrorRate/Info.       
        MinNumTransmissions
        %MinNumErrors Minimum number of errors
        %   Specify the minimum number of errors that must be counted before
        %   stopping the simulation for a sweep parameter point. This property
        %   is relevant only when the SimulationLimitOption property is set to
        %   'Number of errors', 'Number of errors or transmissions', or 'Number
        %   of errors and transmissions'. When the SimulationLimitOption
        %   property is set to 'Number of errors' the simulation for each
        %   parameter point will stop when the number of errors specified in the
        %   MinNumErrors property has been reached. When the
        %   SimulationLimitOption property is set to 'Number of errors or
        %   transmissions' the simulation for each sweep parameter point will
        %   stop when the number of transmissions specified in the
        %   MaxNumTransmissions property has been completed, or when the number
        %   of errors specified in the MinNumErrors property has been reached,
        %   whichever happens first. When the SimulationLimitOption property is
        %   set to 'Number of errors and transmissions' the simulation for a
        %   sweep parameter point will stop when both number of transmissions
        %   and errors have at least reached the values specified in the
        %   MinNumTransmissions and MinNumErrors properties.                             
        %   The type of errors used in the error count is user-specific and is
        %   defined by setting the ErrorCountTestPoint property to the name of a
        %   registered test point that contains that count. 
        %   Call the info method of the Error Rate Test Console to see the valid
        %   registered test point names. 
        %   Default value is 100.
        %
        %   See also commtest.ErrorRate, commtest.ErrorRate/Info.        
        MinNumErrors        
        %TransmissionCountTestPoint Transmission count test point
        %   Specify the name of a registered test point that contains the
        %   transmission count that will control the simulation stop mechanism.
        %   This property is only relevant when the SimulationLimitOption
        %   property is set to 'Number of transmissions', 'Number of errors or
        %   transmissions', or 'Number of errors and transmissions'. In this
        %   scenario, when you register a test point, and
        %   TransmissionCountTestPoint equals 'Not set', the value of the
        %   property will be automatically updated to that of the registered
        %   test point name. 
        %   Call the info method of the Error Rate Test Console to see the valid
        %   registered test point names.    
        %
        %   See also commtest.ErrorRate, commtest.ErrorRate/Info.        
        TransmissionCountTestPoint        
        %ErrorCountTestPoint Error count test point
        %   Specify the name of a registered test point that contains the error
        %   count that will control the simulation stop mechanism. 
        %   This property is only relevant when the SimulationLimitOption
        %   property is set to 'Number of errors', 'Number of errors or
        %   transmissions', or 'Number of errors and transmissions'. In this
        %   scenario, when you register a test point, and ErrorCountTestPoint
        %   equals 'Not set', the value of the property will be automatically
        %   updated to that of the registered test point name. 
        %   Call the info method of the Error Rate Test Console to see the valid
        %   registered test point names. 
        %
        %   See also commtest.ErrorRate, commtest.ErrorRate/Info.     
        ErrorCountTestPoint
    end
    %=========================================================================== 
    % Define Private Properties
    %=========================================================================== 
    properties (Access = private)             
        % Private counterparts to dependent properties
        PrivFrameLength = 500;
        PrivMaxNumTransmissions = 1000;
        PrivMinNumTransmissions = 1000;
        PrivMinNumErrors = 100;
        PrivErrorCountTestPoint = 'Not set';
        PrivTransmissionCountTestPoint =  'Not set';
    end
    %=========================================================================== 
    % Define Public Methods
    %=========================================================================== 
    methods
        function obj = ErrorRate(varargin) %#ok<*STOUT>
            %ErrorRate Construct a commtest.ErrorRate object                        
            obj = obj@testconsole.Harness(varargin{:});
            obj.Description = 'Error Rate Test Console';
        end        
        %=======================================================================               
        function  helpRegisterTestPoint(obj)
            %helpRegisterTestPoint Display help for registerTestPoint method
            %   Display help for the registerTestPoint method of the Error Rate
            %   Test Console.
            
              fprintf(['registerTestPoint Register a new test point\n',...
              '   registerTestPoint(H, NAME, ACTPROBE,EXPPROBE) registers a new \n',...
              '   test point with name NAME to the Error Rate Test Console, H. \n',...
              '   The test point must contain a pair of registered test probes \n',...
              '   ACTPROBE and EXPPROBE whose data will be compared to obtain \n',...
              '   error rate values. ACTPROBE contains actual data, and EXPPROBE \n',...   
              '   contains expected data. Error rates will be calculated using \n',...   
              '   a default error rate calculator function that simply performs \n',...   
              '   one-to-one comparisons of the data vectors available in the \n',... 
              '   probes.\n\n',...
              '   registerTestPoint(H, NAME, ACTPROBE,EXPPROBE, HANDLE) adds a \n',...   
              '   handle, HANDLE, that points to a user-defined error calculator \n',...   
              '   function that will be used to compare the data in probes \n',...   
              '   ACTPROBE and EXPPROBE, to obtain error rate results. The \n',...   
              '   user-defined error calculator function must comply with the \n',...   
              '   following syntax:\n\n',...
              '   [ECNT TCNT] = functionName(ACT, EXP, UDATA) where ECNT output \n',...   
              '   corresponds to the error count, and TCNT output is the number \n',...
              '   of transmissions used to obtain the error count. Inputs ACT, \n',...
              '   and EXP correspond to actual and expected data. The Error \n',...
              '   Rate Test Console will set these inputs to the data available \n',...
              '   in the pair of test point probes ACTPROBE, and EXPPROBE \n',...
              '   respectively.\n',...
              '   UDATA is a user data input that the system under test may \n',...
              '   pass to the test console at run time using the setUserData \n',...
              '   method. UDATA may contain data necessary to compute errors \n',...
              '   such as delays, data buffers, and so on. The Error Rate Test \n',...
              '   Console will pass the same user data logged by the system \n',...
              '   under test to the error calculator functions of all the \n',... 
              '   registered test points.\n\n',...
              '   Call the info method to see the names of the registered test \n',...
              '   points and the error rate calculator functions associated \n',...                  
              '   with them, and to see the names of the  registered test probes.\n']);
        end
    %=========================================================================== 
    % SET/GET Methods
    %=========================================================================== 
        function  set.FrameLength(obj,value)
            %SET FrameLength property
            
            %Check data type 
            propName = 'FrameLength';
            validateattributes(value,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                [class(obj) '.' propName],...
                propName);
            
            %Set property
            obj.PrivFrameLength = value; 
            
            %Warn if property is currently irrelevant
            if isempty(obj.RegisteredInputs)
                    warning(generatemsgid('irrelevantFrameLength'),...
                        (['The system that you have attached to ',...
                        'the Error Rate Test Console does not contain any ',...
                        'registered test inputs so setting the FrameLength ',...
                        'property is irrelevant.']));
            else
                %Setting this property causes a reset
                checkResetFlagAndReset(obj);
            end               
        end
        %=======================================================================               
        function  value = get.FrameLength(obj)
            %GET FrameLength property
            value = obj.PrivFrameLength;
        end        
        %=======================================================================               
        function  set.SimulationLimitOption(obj,value)
            %SET SimulationLimitOption property
            
            %Check data type (enum)
            propName = 'SimulationLimitOption';
            validCell = { 'Number of transmissions',...                          
                          'Number of errors',...
                          'Number of errors or transmissions',...
                          'Number of errors and transmissions'};
            value = validatestring(value, validCell, ...
                [class(obj) '.' propName], propName);
            
            %Set property
            obj.SimulationLimitOption = value;    
            
            %Setting this property causes a reset
            checkResetFlagAndReset(obj);            
        end
        %=======================================================================                
        function  set.MaxNumTransmissions(obj,value)
            %SET MaxNumTransmissions property
            
            %Check data type 
            propName = 'MaxNumTransmissions';
            validateattributes(value,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                [class(obj) '.' propName],...
                propName);
            
            %Set private property (MaxNumTransmissions is dependent)
            obj.PrivMaxNumTransmissions = value;
            
            %Warn if property is currently irrelevant
            if strcmp(obj.SimulationLimitOption,'Number of errors') || ...
                    strcmp(obj.SimulationLimitOption, ...
                    'Number of errors and transmissions')
                warnAboutIrrelevantSet(obj,'MaxNumTransmissions',...
                    class(obj));
            else
                %Setting this property causes a reset
                checkResetFlagAndReset(obj);
            end
        end      
        %=======================================================================                
        function  value = get.MaxNumTransmissions(obj)
            %GET MaxNumTransmissions property
            value = obj.PrivMaxNumTransmissions;
        end        
        %=======================================================================                
        function  set.MinNumTransmissions(obj,value)
            %SET MinNumTransmissions property
            
            %Check data type 
            propName = 'MinNumTransmissions';
            validateattributes(value,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                [class(obj) '.' propName],...
                propName);
            
            %Set private property (MinNumTransmissions is dependent)
            obj.PrivMinNumTransmissions = value;
            
            %Warn if property is currently irrelevant
            if ~strcmp(obj.SimulationLimitOption, ...
                    'Number of errors and transmissions')
                warnAboutIrrelevantSet(obj,'MinNumTransmissions',...
                    class(obj));
            else
                %Setting this property causes a reset
                checkResetFlagAndReset(obj);
            end
        end      
        %=======================================================================                
        function  value = get.MinNumTransmissions(obj)
            %GET MinNumTransmissions property
            value = obj.PrivMinNumTransmissions;
        end                
        %=======================================================================                
        function  set.MinNumErrors(obj,value)
            %SET MinNumErrors property
            
            %Check data type 
            propName = 'MinNumErrors';
            validateattributes(value,...
                {'numeric'},...
                {'finite','positive','scalar','integer'}, ...
                [class(obj) '.' propName],...
                propName);
            
            %Set private property (MinNumErrors is dependent)
            obj.PrivMinNumErrors = value;
            
            %Warn if property is currently irrelevant
            if strcmp(obj.SimulationLimitOption,'Number of transmissions')
                warnAboutIrrelevantSet(obj,'MinNumErrors',...
                    class(obj));
            else
                %Setting this property causes a reset
                checkResetFlagAndReset(obj);
            end
        end    
        %=======================================================================                
        function  value = get.MinNumErrors(obj)
            %GET MinNumErrors property
            value = obj.PrivMinNumErrors;
        end                
        %=======================================================================                
        function  set.ErrorCountTestPoint(obj,value)
            %SET ErrorCountTestPoint property
            
            %Check data type 
            propName = 'ErrorCountTestPoint';
            validateattributes(value,...
                {'char'},...  
                {'vector'},...
                [class(obj) '.' propName],...
                propName);
            
            % If TestProbeRegisteredObjects is not empty, check if name
            % is valid
            validateCountOutput(obj, value,'error');
                            
            %Set private property (ErrorCountTestPoint is dependent)
            obj.PrivErrorCountTestPoint = value;
            
            %Warn if property is currently irrelevant
            if strcmp(obj.SimulationLimitOption,'Number of transmissions')
                warnAboutIrrelevantSet(obj,'ErrorCountTestPoint',class(obj));
            else
                %Setting this property causes a reset
                checkResetFlagAndReset(obj);
            end
        end     
        %=======================================================================                
        function  value = get.ErrorCountTestPoint(obj)
            %GET ErrorCountTestPoint property
            value = obj.PrivErrorCountTestPoint;
        end     
        %=======================================================================                
        function  set.TransmissionCountTestPoint(obj,value)
            %SET TransmissionCountTestPoint property
            
            %Check data type 
            propName = 'TransmissionCountTestPoint';
            validateattributes(value,...
                {'char'},...   
                {'vector'},...
                [class(obj) '.' propName],...
                propName);
            
            validateCountOutput(obj, value,'transmission');
            
            %Set private property (ErrorCountTestPoint is dependent)
            obj.PrivTransmissionCountTestPoint = value;
            
            %Warn if property is currently irrelevant
            if strcmp(obj.SimulationLimitOption,'Number of errors')
                warnAboutIrrelevantSet(obj,'TransmissionCountTestPoint',class(obj));
            else
                %Setting this property causes a reset
                checkResetFlagAndReset(obj);
            end
        end     
        %=======================================================================                
        function  value = get.TransmissionCountTestPoint(obj)
            %GET TransmissionCountTestPoint property
            value = obj.PrivTransmissionCountTestPoint;
        end     
    end%Set/Get methods    
    %=========================================================================== 
    % Define Hidden Public Methods
    %=========================================================================== 
    methods (Hidden)
        function input = getInput(obj,inputName)
            %getInput Provide test input to the system under test
            %   Feed the system under test with an input named 'inputName' when
            %   requested.
            %   getInput(H, 'NumTransmissions') returns the number of requested
            %   source transmissions which is equal to the value set in the
            %   FrameLength property of the Error Rate Test Console. The system
            %   under test must provide this number of transmissions using its
            %   own implemented data source. Whether transmissions are bits, or
            %   symbols of any order, is irrelevant to the Error Rate Test
            %   Console. 
            %   getInput(H, 'RandomIntegerSource') will return a FrameLength
            %   length stream of symbols with an alphabet order equal to the
            %   current value of registered test parameter named 'M'. If the
            %   system under test did not register a test parameter called 'M'
            %   an error will occur at run time. 
            %   This method implements the super class abstract method.
            
            switch(inputName)
                case 'NumTransmissions'
                    if any(strcmp(obj.RegisteredInputs,'NumTransmissions'))
                        input = obj.PrivFrameLength;
                    else
                        error(generatemsgid('noRegInput'), ...
                            ['The system under test may not request a ',...
                            '''NumTransmissions'' test input since it ',...
                            'did not register one.']);
                    end
                case 'RandomIntegerSource'
                    if any(strcmp(obj.RegisteredInputs,'RandomIntegerSource'))
                        % If the system under test registered this input source
                        % then it is required that a test parameter M has been
                        % registered as well. Perform check for existing M
                        % parameter in run to avoid slowing down the simulations
                        % since getInput will be called inside the parfor loop.
                        M = getCurrentValue(obj.TestParamRegisteredObjects('M'));
                        input = randi([0 M-1], obj.PrivFrameLength,1);
                    else
                        error(generatemsgid('noRegInput'), ...
                            ['The system under test may not request a ',...
                            '''RandomIntegerSource'' test input since it ',...
                            'did not register one.']);
                    end
                    
                otherwise
                    error(generatemsgid('invalidInputRequest'),...
                        (['Requested input type ''%s'' is not ',...
                        'available in the Error Rate Test Console. ',...
                        'use the info method to see the available ',...
                        'test inputs.']),...
                        inputName);
            end
        end
    end
    %=========================================================================== 
    % Define Protected Methods
    %=========================================================================== 
    methods (Access = protected)
        function stopCondition = isEndOfSimulation(obj)
            %isEndOfSimulation
            %   Check conditions to end simulation for each simulation parameter
            %   point. This method is called by the run method at every frame
            %   iteration. 
            
            stopCondition = false;
            
            if strcmp(obj.SimulationLimitOption,'Number of transmissions')
                %Stop simulation when total number of target transmissions
                %is reached.
                % Get the current transmission count from the probe of
                % interest. 
                currentNumTransmissions = getTransmissionCounts(obj);
                % Get the actual target number of transmissions according
                % to the available number of workers. 
                targetTransmissions = getActualTarget(obj,obj.MaxNumTransmissions); 
                % Check if current count has reached the target. 
                if currentNumTransmissions >= targetTransmissions;
                    stopCondition = true;
                end
            elseif strcmp(obj.SimulationLimitOption,'Number of errors')
                %Stop simulation when at least the required min number
                %of errors is reached.
                % Get the current error count from the probe of
                % interest.
                currentNumErrors = getErrorCounts(obj);
                % Get the actual target number of errors according
                % to the available number of workers.                 
                targetErrors = getActualTarget(obj,obj.MinNumErrors);
                % Check if current count has reached the target.
                if currentNumErrors >= targetErrors
                    stopCondition = true;
                end
            else
                % Get the current transmission and error counts from the
                % probes of interest.
                currentNumTransmissions = getTransmissionCounts(obj);
                currentNumErrors = getErrorCounts(obj);
                % Get the actual target number of transmissions and errors
                % according to the available number of workers.     
                targetErrors = getActualTarget(obj,obj.MinNumErrors);              
                if strcmp(obj.SimulationLimitOption,'Number of errors or transmissions')
                    targetTransmissions = getActualTarget(obj,obj.MaxNumTransmissions);
                    %Stop simulation when at least the required min number of
                    %errors is reached, OR when the required number of frames is
                    %reached
                    if (currentNumErrors >= targetErrors) || ...
                            (currentNumTransmissions >= targetTransmissions)
                        stopCondition = true;
                    end
                else % 'Number of errors and transmissions'
                    targetTransmissions = getActualTarget(obj,obj.MinNumTransmissions);
                    %Stop simulation when at least the required min number of
                    %errors is reached, AND at least the required number of
                    %frames is reached
                    if (currentNumErrors >= targetErrors) && ...
                            (currentNumTransmissions >= targetTransmissions)
                        stopCondition = true;
                    end
                end
                
            end
        end
        %=======================================================================               
       function checkEndOfSimulationCriteria(obj)
           %checkEndOfSimulationCriteria           
           %   Check that test points have been registered and that names
           %   specified in TransmissionCountTestPoint, or ErrorCountTestPoint
           %   agree with the names of the registered test point objects.
           
           if strcmp(obj.SimulationLimitOption,'Number of transmissions')
               validateCountOutput(obj, ...
                   obj.TransmissionCountTestPoint,'transmission');
           elseif strcmp(obj.SimulationLimitOption,'Number of errors')
               validateCountOutput(obj, obj.ErrorCountTestPoint,'error');
           else
               validateCountOutput(obj, ...
                   obj.TransmissionCountTestPoint,'transmission');
               validateCountOutput(obj, obj.ErrorCountTestPoint,'error');
           end
       end
        %=======================================================================               
       function isValidInputRegistration(obj)
           %isValidInputRegistration
           %   This method, called at run time, checks if necessary test
           %   parameters are available when certain type of inputs have been
           %   registered to the test console by the system under test.
           
           if any(strcmp(obj.RegisteredInputs,'RandomIntegerSource')) && ...
                   ~isKey(obj.TestParamRegisteredObjects,'M')
               error(generatemsgid('requiredMParameter'),...
                   (['No modulation order test parameter ''M'' has been ',...
                     'registered by the system under test. A modulation '....
                     'order test parameter named ''M'' must be ',...
                     'registered when the system under test has ',...
                     'registered a ''RandomIntegerSource'' test ',...
                     'input.']));                                     
           end               
       end
        %=======================================================================                
        function  maxNumIters = getDefaultMaxNumIterations(obj)
            %getDefaultMaxNumIterations
            %   If no test points are registered, we stop the simulation
            %   according to the value in MaxNumTransmissions property,
            %   regardless of the property being relevant or irrelevant.
            
            % The Harness super class will call this method at run time if no
            % test points were registered to the test console.
            maxNumIters = obj.MaxNumTransmissions;
        end
        %=======================================================================   
        function numProbes = getNumTestPointProbes(obj)
            %getNumTestPointProbes 
            %   Specify the number of probes that are grouped in a test point of
            %   the Error Rate Test Console.
            
            % The Error Rate Test Console groups two probes per test point
            numProbes = 2;
        end
        %=======================================================================
        function probeIdentifiers = getTestPointProbeIdentifiers(obj)
            %getTestPointProbeIdentifiers
            %    Specify the probe identifier names used by Error Rate Test
            %    Console test points. 
             probeIdentifiers = {'ActualValue','ExpectedValue'};
        end
        %=======================================================================        
        function option = getMetricCalcFcnOption(obj)
            %getMetricCalcFcnOption Get metric calculator function option
            %    Specify if the super class registerTestPoint method should
            %    expect a user-defined metric calculator function handle as an
            %    input.
            
            % In an Error Rate Test Console, it is optional for the user to
            % specify a user-defined error calculator function when registering
            % a test point. If the user does not specify a metric calculator
            % function, a default function is used instead.
            option = 'Optional';
        end
        %=======================================================================                        
        function fcnHandle = getDefaultMetricCalculatorFunction(obj)
            %getDefaultMetricCalculatorFunction
            %    Specify the default metric calculator function handle. 
            fcnHandle = @commtest.ErrorRate.defaultErrorCalculator;               
        end
        %=======================================================================                                
        function metricStruct = getAvailableMetrics(obj)
            %getAvailableMetrics Specify available metrics
            %   Return available metrics for the Error Rate Test Console and
            %   their initial values. Must return in the form of a structure. 
            metricStruct.ErrorCount = 0;
            metricStruct.TransmissionCount = 0;
            metricStruct.ErrorRate = NaN;
                    end
        %=======================================================================                        
        function name = getDefaultMetricName(obj)
            %getDefaultMetricName
            %   Return the default metric name for the Error Rate Test Console
            name = 'ErrorRate';
        end
        %=======================================================================                                
        function computeFunctions = getComputeFunctionHandles(obj)
            %getComputeFunctionHandles Specify compute functions
            %   Return the compute function handles for the Error Rate Test
            %   Console
            computeFunctions = {@calculateNumErrors @calculateNumTransmissions};
        end
        %=======================================================================                                
        function  aggregateFunctions = getAggregateFunctionHandles(obj)
            %getComputeFunctionHandles Specify aggregate functions
            %   Return the aggregate function handles for the Error Rate Test
            %   Console            
            aggregateFunctions = {@aggregateNumErrors  ...
                @aggregateNumTransmissions};
        end        
        %=======================================================================                                
        function handle = getFormatPlotFunction(obj)
            %getFormatPlotFunction            
            %   Return a function handle for the plot formatting function that
            %   will be used by the Error Rate Test Console
            handle = @commtest.errorRateTestConsoleFormatPlot;           
        end        
        %=======================================================================                                
        function inputNames = getTestInputNames(obj)
            %getTestInputs
            %   Get test input names available in the Error Rate Test Console
            
            %Return the names of the inputs available in the Error Rate Test
            %Console in a cell array.
            inputNames = {'NumTransmissions','RandomIntegerSource'}';                        
        end    
        %=======================================================================                                
        function defaultSys = getDefaultSystem(obj)
            %getDefaultSystem
            %   Get the default system that will be attached to the Error Rate
            %   Test Console by default (when a user does not specify a system
            %   as an input at construction time)
            defaultSys = commtest.MPSKSystem;
        end        
        %=======================================================================                        
        function postProcessMetric(obj)
            %postProcessMetric
            %   This method is called by the main test console run at the end of
            %   the entire simulation. It calculates the error rate values based
            %   on the collected error and transmission counts.   
            
            % Compute error rates if there are any registered test points
            if obj.RegisteredTestPointsFlag
                computeErrorRates(obj);
            end
        end
        %=======================================================================                                
        function postProcessRegisterTestPoint(obj, testPointName)
            %postProcessRegisterTestPoint
            %   We override this super class hook method to set the
            %   TransmissionCountTestPoint and/or ErrorCountTestPoint to the
            %   newly registered test point name. This is done only if the
            %   TransmissionCountTestPoint and/or ErrorCountTestPoint properties
            %   are set to 'Not set', and are relevant.
            if strcmp(obj.SimulationLimitOption,'Number of transmissions')
                if strcmp(obj.PrivTransmissionCountTestPoint,'Not set')
                    obj.TransmissionCountTestPoint = testPointName;
                end                
            elseif strcmp(obj.SimulationLimitOption,'Number of errors')
                if strcmp(obj.PrivErrorCountTestPoint,'Not set')
                    obj.ErrorCountTestPoint = testPointName;
                end
            else
                if strcmp(obj.PrivTransmissionCountTestPoint,'Not set')
                    obj.TransmissionCountTestPoint = testPointName;
                end
                if  strcmp(obj.PrivErrorCountTestPoint,'Not set')
                    obj.ErrorCountTestPoint = testPointName;
                end
            end
        end
        %=======================================================================                
        function warnIfNoRegisteredTestParameters(obj)
            %warnIfNoRegisteredTestParameters
            %   Warn if the system under test did not register any test
            %   parameters. The Error Rate Test Console will still run however.             
            warning(generatemsgid('noParamsRegistered'),...
                (['The system that you have attached to ',...
                  'the test console does not contain any registered test ',...
                  'parameters.']));
        end              
        %=======================================================================                
        function sortedList = getSortedPropDispList(obj) %#ok<*MANU>
            %getSortedPropDispList
            %   Get the sorted list of the properties to be displayed. Do not
            %   display irrelevant properties.
            sortedList = {...
                'Description', ...
                'SystemUnderTestName', ...
                'FrameLength', ...
                'IterationMode', ...
                'SystemResetMode', ...
                'SimulationLimitOption', ...
                'TransmissionCountTestPoint',...
                'MaxNumTransmissions', ...
                'MinNumTransmissions', ...
                'ErrorCountTestPoint', ...
                'MinNumErrors'};
                        
            idx = [];
            %Do not display MinNumErrors, and ErrorCountTestPoint if
            %SimulationLimitOption is 'Number of transmissions'. Do not display
            %MaxNumTransmissions, MaxNumTransmissions, and
            %TransmissionCountTestPoint if SimulationLimitOption is 'Number of
            %errors'. Do not display MaxNumTransmissions if
            %SimulationLimitOption is 'Number of errors and transmissions',
            %instead, display MinNumTransmissions.
            if strcmp(obj.SimulationLimitOption,'Number of transmissions')
                idx = [idx strmatch('MinNumErrors',sortedList,'exact')];
                idx = [idx strmatch('ErrorCountTestPoint',sortedList,'exact')];
                idx = [idx strmatch('MinNumTransmissions',sortedList,'exact')];
            elseif strcmp(obj.SimulationLimitOption,'Number of errors')
                idx = [idx strmatch('MaxNumTransmissions',sortedList,'exact')];
                idx = [idx strmatch('MinNumTransmissions',sortedList,'exact')];
                idx = [idx strmatch('TransmissionCountTestPoint',...
                    sortedList,'exact')];
            elseif strcmp(obj.SimulationLimitOption, ...
                    'Number of errors or transmissions')
                idx = [idx strmatch('MinNumTransmissions',sortedList,'exact')];
            else %'Number of errors and transmissions'
                idx = [idx strmatch('MaxNumTransmissions',sortedList,'exact')];
            end
            if isempty(obj.RegisteredInputs)
                idx = [idx strmatch('FrameLength',sortedList,'exact')];
            end
            sortedList(idx) = [];
        end
        %=======================================================================
        function sortedList = getSortedPropInitList(obj) %#ok<MANU>
            %getSortedPropInitList 
            %   Returns a list of properties in the order in which the
            %   properties must be initialized.  If order is not important,
            %   returns an empty cell array.
            
            %Give priority to option properties to avoid warnings at
            %construction time when setting values to the properties they
            %enable.
            sortedList = {'SimulationLimitOption'};
        end
    end %protected methods
    %=========================================================================== 
    % Define Private Methods
    %=========================================================================== 
    methods (Access = private)
        %=======================================================================                
        function count = getTransmissionCounts(obj)
            %getTransmissionCounts
            %   Get current transmission count from the test point of interest
            %   whose name has been registered in the TransmissionCountTestPoint
            %   property. 
            currentTestPoint = getCurrentTestPoint(obj.TestLog, ...
                obj.TransmissionCountTestPoint);
            count = getMetric(currentTestPoint, 'TransmissionCount');
        end
        %=======================================================================                
        function validateCountOutput(obj, inputName,type)
            %validateCountOutput
            %   Check that test points have been registered and that names
            %   specified in TransmissionCountTestPoint, or ErrorCountTestPoint
            %   agree with the names of the registered test point objects.
            
           if strcmp(type,'transmission')
               errorLabel1 = 'invalidTxCountProbe';
               errorLabel2 = 'unsetTxCountProbe';
               propName = 'TransmissionCountTestPoint';
           else
               errorLabel1 = 'invalidErrorCountProbe';
               errorLabel2 = 'unsetErrorCountProbe';
               propName = 'ErrorCountTestPoint';
           end               
               
           if ~isempty(obj.TestPointRegisteredObjects) 
               if strcmp(inputName,'Not set')
                   error(generatemsgid(errorLabel2),...
                       ['%s must be set to a registered test point name. ',...
                        'Use the info method of the Error Rate ',...
                        'Test Console to see valid test point names.'],...
                       propName);                   
               elseif ~isKey(obj.TestPointRegisteredObjects,inputName) 
                   error(generatemsgid(errorLabel1),...
                       ['Expected %s to be equal to the ',...
                        'name of a registered test point. Use ',...
                        'the info method of the Error Rate ',...
                        'Test Console to see valid test point names.'],...
                       propName);
               end
           else
               error(generatemsgid('NoTestPoint'),...
                   ['No test point has been registered. First register '...
                    'test points using the registerTestPoint method ',...
                    'of the Error Rate Test Console.']);
           end
        end
        %=======================================================================
        function count = getErrorCounts(obj)
            %getErrorCounts
            %   Get current error count from the probe of interest whose name
            %   has been registered in the 'ErrorCountTestPoint' property.

            currentTestPoint = getCurrentTestPoint(obj.TestLog, ...
                obj.ErrorCountTestPoint);
            count = getMetric(currentTestPoint, 'ErrorCount');
        end       
        %=======================================================================               
        function computeErrorRates(obj)
            %computeErrorRates
            %   Compute error rates in test log objects
            testPoints = obj.TestLog.TestPoints;
            [numSweep numTestPoint] = size(testPoints);
            for p=1:numSweep
                for q=1:numTestPoint
                    metrics = getMetric(testPoints(p,q));
                    if metrics.TransmissionCount ~= 0
                        errorRate = metrics.ErrorCount ...
                            / metrics.TransmissionCount;
                    else
                        errorRate = NaN;
                    end
                    setMetric(testPoints(p,q), 'ErrorRate', errorRate);
                end
            end
        end  
    end% private methods
    %=========================================================================== 
    % Define Hidden Static Methods
    %=========================================================================== 
    methods (Hidden, Static)
        %=======================================================================               
        function [errorCnt transCnt] = defaultErrorCalculator(actVal, ...
                expVal, varargin)
            %defaultErrorCalculator Default error calculator function
			%   [ECNT TCNT] = defaultErrorCalculator(ACT, EXP) returns the error
			%   count, ECNT, which is the number of mismatched values in ACT and
			%   EXP. TCNT is the length of ACT, which should be equal to the
			%   length of EXP.

            if ~isequal(size(actVal),size(expVal))
                error(generatemsgid('invalidDimensions'),...
                    ('ActualVal and expVal inputs must be of equal dimensions.'));
            end
            errorCnt = sum(actVal ~= expVal);
            transCnt = length(actVal);
        end
        %=======================================================================               
        function calculateErrorRate(metric)
            %calculateErrorRate Calculate the error rate

            setMetric(metric, 'ErrorRate', ...
                getMetric(metric, 'ErrorCount') ...
                / getMetric(metric, 'TransmissionCount'));
        end
    end
end %classdef

%===============================================================================
% Helper functions
function errorCnt = calculateNumErrors(testPoint)
%calculateNumErrors Calculate number of errors
%   calculateNumErrors calls the error calculator function, which returns both 
%   number of errors and number of transmissions.  This function returns the 
%   accumulated number of errors (from iterations for the current sweep point)
%   and logs the number of transmissions in the DataStorage property of the
%   testPoint.

%   Get data from the probes in the test point and call the user functions to
%   compute error count and transmission count.  Return the error count and
%   store transmission count in user data for calculateNumTransmissions

% Get data from probes
actValue = getProbeData(testPoint, 'ActualValue');
expValue = getProbeData(testPoint, 'ExpectedValue');

% Call user function to calculate error count and transmission count in
% this data block
errorCalculatorFun = getMetricCalculatorFunction(testPoint);
[errorCnt transCnt] = ...
    errorCalculatorFun(actValue, expValue, testPoint.UserData);

% Aggregate the error count
errorCnt = errorCnt + testPoint.getMetric('ErrorCount');

% Store data for the calculateNumTransmissions function
testPoint.DataStorage = transCnt;
end
%-------------------------------------------------------------------------------
function txCnt = calculateNumTransmissions(testPoint)
%calculateNumTransmissions Calculate number of transmissions
%   calculateNumTransmissions returns the accumulated number of transmissions
%   (from iterations for the current sweep point). The current number of
%   transmissions is stored in DataStorage property of the testPoint.

% Get transmission count from user data
txCnt = testPoint.DataStorage + testPoint.getMetric('TransmissionCount');

% Prepare user data for the next use
testPoint.DataStorage = [];
end
%-------------------------------------------------------------------------------
function errorCnt = aggregateNumErrors(metric1, metric2)
%aggregateNumErrors Aggregate the number of errors

errorCnt =  getMetric(metric1, 'ErrorCount')...
    + getMetric(metric2, 'ErrorCount');
end
%-------------------------------------------------------------------------------
function txCnt = aggregateNumTransmissions(metric1, metric2)
%aggregateNumTransmissions Aggregate the number of transmissions

txCnt = getMetric(metric1, 'TransmissionCount')...
    + getMetric(metric2, 'TransmissionCount');
end

