classdef timer
%MATLAB Timer Object Properties and Methods.
%
% Timer properties.
%   AveragePeriod    - Average number of seconds between TimerFcn executions.
%   BusyMode         - Action taken when TimerFcn executions are in progress.
%   ErrorFcn         - Callback function executed when an error occurs.
%   ExecutionMode    - Mode used to schedule timer events.
%   InstantPeriod    - Elapsed time between the last two TimerFcn executions. 
%   Name             - Descriptive name of the timer object.
%   Period           - Seconds between TimerFcn executions.
%   Running          - Timer object running status.
%   StartDelay       - Delay between START and the first scheduled TimerFcn execution.
%   StartFcn         - Callback function executed when timer object starts.
%   StopFcn          - Callback function executed after timer object stops.
%   Tag              - Label for object.
%   TasksExecuted    - Number of TimerFcn executions that have occurred.
%   TasksToExecute   - Number of times to execute the TimerFcn callback.
%   TimerFcn         - Callback function executed when a timer event occurs.
%   Type             - Object type.
%   UserData         - User data for timer object.
%
% timer methods:
% Timer object construction:
%   @timer/timer            - Construct timer object.
%
% Getting and setting parameters:
%   get              - Get value of timer object property.
%   set              - Set value of timer object property.
%
% General:
%   delete           - Remove timer object from memory.
%   display          - Display method for timer objects.
%   inspect          - Open the inspector and inspect timer object properties.
%   isvalid          - True for valid timer objects.
%   length           - Determine length of timer object array.
%   size             - Determine size of timer object array.
%   timerfind        - Find visible timer objects with specified property values.
%   timerfindall     - Find all timer objects with specified property values.
%
% Execution:
%   start            - Start timer object running.
%   startat          - Start timer object running at a specified time.
%   stop             - Stop timer object running.
%   waitfor          - Wait for timer object to stop running.
%

% Copyright 2002-2008 The MathWorks, Inc.

    properties
        ud = {};
        jobject;
    end

    methods
        function obj = timer(varargin)
        %TIMER Construct timer object.
        %
        %    T = TIMER constructs a timer object with default attributes.
        %
        %    T = TIMER('PropertyName1',PropertyValue1, 'PropertyName2', PropertyValue2,...)
        %    constructs a timer object in which the given Property name/value pairs are
        %    set on the object.
        %
        %    Note that the property value pairs can be in any format supported by
        %    the SET function, i.e., param-value string pairs, structures, and
        %    param-value cell array pairs.
        %
        %    Example:
        %       % To construct a timer object with a timer callback mycallback and a 10s interval:
        %         t = timer('TimerFcn',@mycallback, 'Period', 10.0);
        %
        %    See also TIMER/SET, TIMER/TIMERFIND, TIMER/START, TIMER/STARTAT.

            % Create the default class.
            if (nargin>0) && all(ishandle(varargin{1})) && all(isJavaTimer(varargin{1})) % java handle given, just wrap in OOPS
                % this flavor of the constructor is not intended to be for the end-user
                if sum(gt(size(varargin{1}),1)) > 1 % not a vector, sorry.
                    error('MATLAB:timer:creatematrix',timererror('matlab:timer:creatematrix'));
                end
                obj.jobject = varargin{1}; % make a MATLAB timer object from a java timer object
            elseif nargin>0 && (isa(varargin{1},'timer') || ...
                    (isstruct(varargin{1}) && isfield(varargin{1}, 'jobject'))) %support for old style timer object
                % duplicate a timer object
                % e.g., q = timer(t), where t is a timer array.
                orig = varargin{1};
                len = length(orig.jobject);
                obj.jobject = orig.jobject;
                % foreach valid object in the original timer object array...
                for lcv=1:len
                    if isJavaTimer(orig.jobject(lcv))
                        % for valid java timers found, make new java timer object,...
                        obj.jobject(lcv) = handle(com.mathworks.timer.TimerTask);
                        obj.jobject(lcv).MakeDeleteFcn(@deleteAsync);
                        % duplicate copy of settable properties from the old object to the new object,and ...
                        propnames = fieldnames(set(orig.jobject(lcv)));
                        propvals = get(orig.jobject(lcv),propnames);
                        set(obj.jobject(lcv),propnames,propvals);
                        mltimerpackage('Add', obj.jobject(lcv));
                    end
                end                
            else
                % e.g., t=timer or t=timer('pn',pv,...)
                % set a default name to a unique identifier, i.e., an object 'serial number'
                obj.jobject = handle(com.mathworks.timer.TimerTask);
                obj.jobject.setName(['timer-' num2str(mltimerpackage('Count'))]);
                obj.jobject.timerFcn = '';
                obj.jobject.errorFcn = '';
                obj.jobject.stopFcn = '';
                obj.jobject.startFcn = '';
                obj.jobject.MakeDeleteFcn(@deleteAsync);
                if (nargin>0)
                    % user gave PV pairs, so process them by calling set.
                    try
                        set(obj, varargin{:});
                    catch exception
                        throw(fixexception(exception));
                    end
                end
                % register the new object so timerfind can find it later,
                mltimerpackage('Add', obj.jobject);
            end
        end

        function delete(obj)
        %DELETE Remove timer object from memory.
        %
        %    DELETE(OBJ) removes timer object, OBJ, from memory. If OBJ
        %    is an array of timer objects, DELETE removes all the objects
        %    from memory.
        %
        %    When a timer object is deleted, it becomes invalid and cannot
        %    be reused. Use the CLEAR command to remove invalid timer
        %    objects from the workspace.
        %
        %    If multiple references to a timer object exist in the workspace,
        %    deleting the timer object invalidates the remaining
        %    references. Use the CLEAR command to remove the remaining
        %    references to the object from the workspace.
        %
        %    See also CLEAR, TIMER, TIMER/ISVALID.

            len = length(obj);

            stopWarn = false;

            for lcv=1:len
                try
                    if obj.jobject(lcv).isRunning == 1
                        stopWarn = true;
                        obj.jobject(lcv).stop;
                    end
                    %Call the Java method, to trigger an asynchronous delete call.
                    obj.jobject(lcv).Asyncdelete;
                catch exception  %#ok<NASGU>
                end
            end

            if stopWarn == true
                state = warning('backtrace','off');
                warning('MATLAB:timer:deleterunning',timererror('matlab:timer:deleterunning'));
                warning(state);
            end
        end
    end
    
    methods ( Static=true, Hidden=true ) 
        obj = loadobj(B)
        
        %The empty static method is implemented by MATLAB for all objects
        %and needs to be oveloaded here for the correct timer object
        %behavior.  
        function obj = empty(varargin)
            if nargin > 0
                indices = [varargin{:}];
                if ~isequal(indices, [1 0]) && ~isequal(indices, [0 0])
                    error('MATLAB:timer:empty', 'Only 1-by-0 empty timers can be created.')
                end
            end
            tempObj = timer;
            subs =  {{zeros(1,0)}};
            obj = subsref(tempObj, struct('type', '()', 'subs', subs));
            delete(tempObj);
        end
        
    end
    methods ( Hidden=true ) 
        B = saveobj(obj)
    end
end