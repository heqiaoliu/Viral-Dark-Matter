classdef (Hidden) System < handle & sigutils.sorteddisp & sigutils.pvpairs
    %SYSTEM Define the System abstract class
    %   Template to define a system under test that may be attached to a test
    %   console for analysis.    
    
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:47:18 $
    
    %===========================================================================
    % Define Protected Properties
    %=========================================================================== 
    properties (Access = protected) 
        %MyParentTestConsole Parent test console handle
        %   Handle to the test console object that holds the system under test.
        MyParentTestConsole = [];
    end
    %===========================================================================
    % Define Private Properties
    %===========================================================================     
    properties (Access = private)
        %AttachedToConsole Attached to console flag
        %   If system is attached to a console, this flag will be true.
        AttachedToConsole = false;
        
        %AttachFlag Attach flag
        %   This flag is true when the system is in the process of being
        %   attached to a test console
        AttachFlag = false;
    end
    %=========================================================================== 
    % Define Hidden Public Methods
    %=========================================================================== 
    methods (Hidden)
        function registerSystem(obj,consoleObj)
            %registerSystem Register system
            %   When the user connects the system under test to a given test
            %   console, the test console will call this method to pass its
            %   handle to the system under test object and to obtain registered
            %   properties.
            
            
            %See if this method has been called by the test console object
            if ~acknowledgeSystemAttach(consoleObj);
                error(generatemsgid('invalidRegistration'),...
                    (['The registerSystem method may only be called by the ',...
                      'test console when a system under test ',...
                      'is in the process of being attached to it. If you ',...
                      'want to attach a system to ',...
                      'a test console, you must call the test ',...
                      'console''s attachSystem method.']));
            end                                    
            
            if ~isempty(obj.MyParentTestConsole)
                warning(generatemsgid('attachedToATestConsole'),...
                    (['The system of the type %s is detaching from ',...
                     'another test console and attaching to the ',...
                     'test console for which the constructor or the ',...
                     'attachSystem method was called.']),class(obj));
                
                % Set AttachFlag to true. The test console will ask for
                % acknowledgement of the detach console operation to the system.
                % The answer to that acknowledgement will be the value in
                % AttachFlag. This ensures that the detachTestConsole can only
                % be called by a system when in the process of detaching from a
                % current test console to be attached to a new one.
                obj.AttachFlag = true;
                detachTestConsole(obj.MyParentTestConsole);
                obj.AttachFlag = false;
            end     
                        
            %Attach the test console object to MyParentTestConsole property
            obj.MyParentTestConsole = consoleObj;
            
            %Register simulation parameters             
            try
                register(obj); 
                obj.AttachedToConsole = true;
                
            catch ME
                obj.MyParentTestConsole = [];  
                obj.AttachFlag = false;
                rethrow(ME)                
            end            
        end
        %=======================================================================        
        function unRegisterSystem(obj)
            %unRegisterSystem Un-register system
            %   The test console will call this method to detach the system from
            %   it.             
            if ~acknowledgeSystemAttach(obj.MyParentTestConsole );
                error(generatemsgid('invalidUnRegistration'),...
                    (['The unregisterSystem method may only be called by the ',...
                      'test console when a system under test ',...
                      'is in the process of being detached from it. If you ',...
                      'want to detach a system from ',...
                      'a test console, you must call the test ',...
                      'console''s detachSystem method.']));
            end                                                
            obj.MyParentTestConsole = [];
        end
        %=======================================================================        
        function ack = acknowledgeTestConsoleDetach(obj)
            %acknowledgeTestConsoleDetach Acknowledge detach test console
            %   Return the value in the AttachFlag property. If AttachFlag is
            %   true then it means that the system is in the process of
            %   detaching from a current test console to attach to a new one. 
            %   The current test console will call this method to verify that it
            %   is indeed a system under test that is calling its
            %   detachTestConsole method.
            ack = obj.AttachFlag;
        end
    end 
    %=========================================================================== 
    % Define Protected Methods - only system under test objects will have
    % access to these methods
    %=========================================================================== 
    methods (Access = protected)
        function input = getInput(obj,inputName)
            %getInput Request a test input to the test console                
            %   Call the getInput test console method
            if obj.AttachedToConsole                            
                input = getInput(obj.MyParentTestConsole,inputName);
            else
                %In debug mode the system can use a default input generator if
                %needed. The system must override the generateDefaultInput
                %method to be able to call getInput without an error in debug
                %mode. 
                input = generateDefaultInput(obj);
            end
        end
        %=======================================================================  
        function testerDescription = getTestConsoleDescription(obj)
            %getTestConsoleDescription Get the test console description           
            %   Call the getTestConsoleDescription test console method to find
            %   out to which test console is the system under test currently
            %   attached to.
            
            if obj.AttachedToConsole 
                testerDescription = ...
                    getTestConsoleDescription(obj.MyParentTestConsole);
            else
                % Return 'Not attached to a test console' in debug mode
                testerDescription = 'Not attached to a test console';
            end
        end            
        %=======================================================================  
        function registerTestParameter(obj,name,default,varargin)
            %registerTestParameter Register test parameter
            %   Instantiate a test parameter object and register it to the
            %   parent test console.  
            
            % Force the system to have properties with same names as the test
            % parameters that it registers.
            p = findprop(obj,name);
            if isempty(p) || ~strcmpi(p.GetAccess,'public')
                error(generatemsgid('regParamIsNotAProperty'), ...
                    ['A public property with name ''%s'' must exist in the ',...
                    'system under test object to be able to register ',...
                    'a test parameter with the same name.'],name);                
            end
            if nargin < 3
                error(generatemsgid('defaultNotDefined'), ...
                    ['The system under test did not specify a default value ',...
                    'when registering test parameter ''%s'' to the test ',...
                    'console.'],name);                                
            end
            param = testconsole.Parameter(name,default,varargin{:});
            registerTestParameter(obj.MyParentTestConsole, param);
        end
        %=======================================================================  
        function value = getTestParameter(obj,name)
            %getTestParameter Get test parameter
            %   Get current value of the test parameter named 'name' from the
            %   test console.
            
           if obj.AttachedToConsole           
                p = getTestParameter(obj.MyParentTestConsole,name);
                value = p.CurrentValue;
           else
               % Check that the system has the desired property
               p = findprop(obj,name);
               if isempty(p) || ~strcmpi(p.GetAccess,'public')
                   error(generatemsgid('regParamIsNotAProperty'), ...
                       ['A public property with name ''%s'' must exist in ',...
                       'the system under test object to be able to call ',...
                       'the getTestParameter method in debug mode.'],name);
               end                               
                value = obj.(name);
            end                
        end        
        %=======================================================================  
        function registerTestProbe(obj,name,description)
            %registerTestProbe Register a test probe
            %   Instantiate a test probe object and register it in the parent
            %   test console. Set the name and the description properties of the
            %   probe object. 
            if nargin == 1
                error(generatemsgid('notEnoughArgumentsForProbe'), ...
                    ['The system under test is attempting to register a probe ',...
                    'without providing a probe name.']);
            end
            if nargin == 2
                probe = testconsole.Probe(name);
            elseif nargin == 3                        
                probe = testconsole.Probe(name,description);
            end
            registerTestProbe(obj.MyParentTestConsole, probe);
        end   
        %=======================================================================  
        function setTestProbeData(obj,name,data)
            %setTestProbeData Set test probe data
            %   Set log data into the 'name' test probe registered in the test
            %   console object.  
            
            %If connected to a test console, log the data, otherwise, in debug
            %mode do nothing.
             if obj.AttachedToConsole     
                setTestProbeData(obj.MyParentTestConsole,name,data);
             end
        end    
        %=======================================================================  
        function setUserData(obj,data)
            %setUserData Set user data
            %   Pass any user data to the test console. The test console will
            %   pass this data (can be a cell array, or a structure for
            %   example.) as an input to the metric calculator functions defined
            %   by the user.
            
            %If connected to a test console, log the data, otherwise, in debug
            %mode do nothing.
            if obj.AttachedToConsole              
               setUserData(obj.MyParentTestConsole,data);
            end
        end            
        %=======================================================================  
        function registerTestInput(obj,inputName)
            %registerTestInput Register test input
            %   Register the type of input that will be fed by the test console
            %   to the system under test. This method is called by the system
            %   under test at registration time.                                  
            registerTestInput(obj.MyParentTestConsole,inputName)
        end           
        %=======================================================================  
        function register(obj) %#ok<MANU>
        %REGISTER Register the system under test
        %   Register test inputs, test parameters, and test probes, that the
        %   system under test will use to define input signal sources, sweep
        %   parameters, and data probes. The concrete system class may override
        %   this method to register any of the aforementioned elements.
        
        % NO OP   
        end
        %=======================================================================  
        function input = generateDefaultInput(obj) %#ok<MANU,STOUT>
            %generateDefaultInput Generate default input 
            %   Calling the getInput method in debug mode will in turn call this
            %   method. 
            %   The concrete system class must override this method and
            %   implement a specific input generator. An error will occur if the
            %   system calls getInput and does not override the
            %   generateDefaultInput method. 
            
            error(generatemsgid('noDefaultInput'),...
                (['The system under test must implement a ',...
                'generateDefaultInput method to be able to call the ',...
                'getInput method when running in debug mode.']));
        end
    end
end %classdef









