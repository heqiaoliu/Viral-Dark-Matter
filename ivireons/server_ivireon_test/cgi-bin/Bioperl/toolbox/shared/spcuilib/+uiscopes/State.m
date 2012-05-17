classdef State < handle
    %STATE Holds and broadcasts state of  simulation for scopes
    % A simulation can be driven by Simulink or by a timer
    % Listen to events from Simulink or timer, and transmits to listener
    % as 'sourceRun', 'sourceContinue', 'sourcePause', 'sourceStop', 'sourceClose'
    % Caches simulation state
    % as 'running','stopped','paused','unknown'.
    
    % Author(s): J. Schickler, H. Dannelongue
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.6.4 $ $Date: 2010/03/31 18:40:57 $
    
    properties (SetAccess = protected)
        CurrentState = 'unknown';
        Callback = [];
        CallbackInProgress = false;
        % Caller managed flag to differentiate between
        % Stop and Halt. Halt is a system action, a brief
        % stop to set parameters
        Halt = false;
        % Caller managed flag to differentiate between
        % Stop and Pause. Pause is a user action.
        Pause = false;
        Listeners = [];
    end
    
    
    methods
        function this = State
            %STATE Constructor
        end
        
        function success = attachToModel(this, hroot, initialGivenState, listener )
            %ATTACHTOMODEL Attach to Simulink model
            % initialGivenState is one of 'running','stopped',...
            %    'paused', 'unknown'
            % Implements basic callback mechanism:
            %    callback_fcn(hco,eventStruct,userArgs)
            % for each possible callback:
            %     stopped, running, closed
            % - hroot : model to attach to
            % - initialGivenState: initialState of model,to trigger proper callback
            % - listener : object on which onStateEventHandler will be called
            % eventType is the name of a Simulink event
            %
            
            % store passed-in callback
            if ~isempty(listener)
                this.Callback  = listener; 
            end
            
            % Note that we attempt to pair-up simulation status flags
            % (here, 'stopped','running', etc) to match the conditions
            % under which the corresponding events (such as StopEvent,
            % StartEvent, etc) are sent.  This may not be 1-to-1.
            % In particular, the StartEvent is paired with no less than
            % 3 distinct simulation flags (run/pause/init).  We cross
            % our fingers... it's the idea of events vs. static status.
            %
            switch initialGivenState
                case 'stopped'
                    this.CurrentState = 'stopped'; % to record initial system state
                    eventType = 'StopEvent';  % for initial callbacks to fire
                case {'running','external'}
                    this.CurrentState = 'running';
                    % Earliest safe event for getting run-time objects
                    % appears to be 'StartEvent'
                    eventType = 'StartEvent';
                case 'initializing'
                    
                    % If we are in rapid-accelerator, we will not get a
                    % StartEvent when the model starts due to g585051.
                    % Setup the scope now.
                    if any(strcmp(get(hroot, 'SimulationMode'), ...
                            {'external', 'rapid-accelerator'}))
                        
                        this.CurrentState = 'running';
                        eventType = 'StartEvent';
                    else
                        % no data available yet
                        this.CurrentState = 'stopped';
                        eventType = '';
                    end
                case 'paused'
                    this.CurrentState = 'paused';
                    eventType = 'PauseEvent';
                otherwise
                    this.CurrentState = 'unknown';
                    eventType = '';
            end
           
            
            % Add listeners to Simulink
            lis = [handle.listener(hroot,'StopEvent',@TrapEvents); ...
                handle.listener(hroot,'StartEvent',@TrapEvents); ...
                handle.listener(hroot,'CloseEvent',@TrapEvents); ...
                handle.listener(hroot,'PauseEvent',@TrapEvents); ...
                handle.listener(hroot,'ContinueEvent',@TrapEvents)];
            set(lis, 'CallbackTarget', this);          
            this.Listeners = lis; 
            
            % Force callback based on initial simulation state
            if ~isempty(eventType)
            evStruct.Type = eventType;
            TrapEvents(this,evStruct);         
            end
            
            success = this.isAttached(); 
        end
        
        function success = attachToTimer(this, timer, initialGivenState, listener)
            %ATTACH Attach to timer
            % attach to a system timer 
            % initialGivenState is one of 'running','stopped','unknown'
            % Implements basic callback mechanism
            % for each possible callback:
            %     startFcn, stopFcn
            %
            
            % store passed-in callback
            if ~isempty(listener)
                this.Callback  = listener; %@(h, ev) onStateEventHandler(listener, ev);
            end
            
            switch initialGivenState
                case 'stopped'
                    initialState = 'stopped'; % to record initial system state
                case 'running'
                    initialState = 'running';
                otherwise
                    initialState = 'unknown';
            end
            this.CurrentState = initialState;
            
            % Add listeners to timer
            set(timer, 'StopFcn', @(h,ev) TrapEvents(this,ev));
            set(timer, 'StartFcn', @(h,ev) TrapEvents(this,ev));
            lis ={timer.StartFcn;timer.StopFcn};
            this.Listeners = lis;
            % Do not force callback based on initial simulation state   
            success = this.isAttached(); 
        end
        
        % -----------------------------------------
        function TrapEvents(this,ev)
            % Execute callbacks, constructing appropriate argument list
            
            % Callback is re-entrant when aborting data connection
            % Ideally, it should not be. 
            % if this.CallbackInProgress, exit quickly

            this.CallbackInProgress = true;
            % Pre-callback processing
            %
            % Set new state in this, based on event type,
            % then broadcast events with generic names
            % (not Simulink or timer specific)
            % Some minor events are not resent
            rebroadcastEv.Type = 'unknown';
            switch ev.Type  % the event received
                case {'StopEvent','StopFcn'}
                    this.CurrentState = 'stopped';
                    if this.Halt
                        % short pause, do not broadcast
                        this.CurrentState = 'halted';
                        rebroadcastEv.Type = 'sourceHalt';
                    elseif this.Pause
                        % fake a "pause" for timers
                        this.CurrentState = 'paused';
                        rebroadcastEv.Type = 'sourcePause';
                    else
                        % plain stop
                        rebroadcastEv.Type = 'sourceStop';
                    end
                case {'StartEvent','StartFcn'}
                    this.CurrentState = 'running';
                    if this.Halt
                        rebroadcastEv.Type = 'unknown';
                    elseif this.Pause
                        % fake a "continue" for timers
                        rebroadcastEv.Type = 'sourceContinue';
                    else
                        rebroadcastEv.Type = 'sourceRun';
                    end
                case 'CloseEvent'
                    this.CurrentState = 'closed';
                    rebroadcastEv.Type = 'sourceClose';
                case 'PauseEvent'
                    this.CurrentState = 'paused';
                    rebroadcastEv.Type = 'sourcePause';
                case 'ContinueEvent'
                    this.CurrentState = 'running';
                    rebroadcastEv.Type = 'sourceContinue';
                case ''
                    % empty is due to a manual call from reconnect,
                    % where the model is neither running nor stopped
                    % (perhaps it's paused?)  in any case, do nothing:
                    warning(generatemsgid('UnknownState'), ...
                        'uiscopes.State: unknown state of model during TrapEvents');
                    return 
                otherwise
                    error(generatemsgid('UnsupportedEvent'), ...
                        'Unsupported event type: %s', ev.Type);
            end
            
            
            % Callback processing
            if ~isempty(this.Callback) && ~strcmp(rebroadcastEv.Type,'unknown')
                this.Callback(this, rebroadcastEv);
            end
            
            % Post-callback processing
            %
            if strcmp(this.CurrentState,'closed'),
                this.closeTasks;
            end
            
            %reset semaphore
            this.CallbackInProgress = false;
        end
        
        % -----------------------------------------------------------------
        function close(this)
            % CLOSE
            this.Listeners = [];  % clear listeners
            this.CurrentState = 'unknown';
            detach(this);
            
        end
% %         
        function closeTasks(this)
            %CLOSETASKS Called when system closes
            % Differs from disconnect in the following regards:
            %   - clears system handle
            %   - leaves current state alone (as 'closed')
            this.Listeners = []; 

        end
        
        function detach(this)
            % Detach from  model      
            %  do all the work in close
            this.Callback = [];
        end
        
        function b = isAttached(this)
            %ISATTACHED  Return TRUE as long as we're not in the UNKNOWN state
            b = ~strcmp(this.CurrentState,'unknown');
        end
        
        function b = isRunning(this)
            %ISRUNNING   Returns true if running.
            b = any(strcmpi(this.CurrentState,{'running','initializing'}));
        end
        
        function b = isStopped(this)
            %ISSTOPPED   Returns true if stopped.
            b = any(strcmpi(this.CurrentState,{'stopped','terminating'}));
        end
        
        function b = isPaused(this)
            %ISPAUSED   Returns true if paused.
            b = strcmp(this.CurrentState,'paused');
        end
        
        function b = isHalted(this)
            %ISPAUSED   Returns true if paused.
            b = strcmp(this.CurrentState,'halted');
        end
        function b = isDisconnected(this)
            %ISDISCONNECT   Returns true if disconnected
            b = strcmp(this.CurrentState,'unknown');
        end
        
        function setCallback(this, cb)
            %SETCALLBACK Stores the function to be used as event callback
            % backdoor for testing
           this.Callback = cb; 
           
        end
        
        function setHalt(this,tf)
            this.Halt = tf;       
        end
        
        function setPause(this,tf)
            this.Pause = tf;
        end

     end %methods
end
% [EOF]
