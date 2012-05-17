classdef PlaybackControlsTimer < uiscopes.AbstractPlaybackControls
    % Constructor for PlaybackControlsTimer
    
    % Copyright 2004-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.21 $ $Date: 2010/05/20 03:07:36 $
    
    properties
        
        CurrentFrame = 1;     % uint32
        Repeat       = false; % bool
        AutoReverse  = 1;     % 1 = fwd, 2 = bk, 3 = fwd->bk
        StepSize     = 10;    % uint32
    end
    
    properties (SetAccess = protected)
        NextFrame = 1;  % uint32
    end
    
    % These properties should be protected, but tests need to query them.
    properties (Hidden)
        DrawnowTimer = [];
        Timer     = []; % timer
        JumpTo    = []; % scopeextensions.JumpTo
        FrameRate = []; % scopeextensions.FrameRate
        
        % Requested playback modes
        %
        % these do not necessarily indicate that timer/etc
        % has actually achieved a certain state (e.g., we could
        % be in stop mode, but the timer hasn't yet stopped)
        
        PauseRequested = false;
        StopRequested  = true;
        PlayRequested  = false;
    end
    
    properties (Access = protected)
        FrameRateChangedListener = []; % handle.listener
        
        ReversePlay = false; % bool
        
        % Internal semaphore flags indicating that the object is attempting
        % one of these actions.
        IsPausing  = false;
        IsStarting = false;
        IsStopping = false;
    end
    
    methods
        function this = PlaybackControlsTimer(hScope, hSource)
            
            % mlock keeps the instantiation of this class from throwing a
            % warning when the clear classes command is issued.
            mlock;

            this@uiscopes.AbstractPlaybackControls(hScope, hSource);
            
            % Jump To manager object
            this.JumpTo = scopeextensions.JumpTo(hScope);
            
            % FrameRate manager object
            this.FrameRate = scopeextensions.FrameRate(hScope);
            
            % Initialize
            %timer
            setStopState(this);   % set internal state bits to default
            
            % Cache UI plug-in's (don't add/render, just build/cache)
            % Create base UI buttons, menus, statusbar, etc
            createGUI(this);
            
            % Listen for the event FrameRateChanged which notifies us that
            % changes are needed to the Playback Schedule.  This event is
            % sent from the FrameRate object when the DesiredFPS,
            % SchedRateMin, SchedRateMax or SchedEnable properties change.
            this.FrameRateChangedListener = handle.listener(this.FrameRate, ...
                'FrameRateChanged', @(hco, ev) this.changeFrameRate);
        end
        
        % -----------------------------------------------------------------
        function delete(this)
            
            % Clean up the objects that we contain.
            if isTimerRunning(this)
                stop(this.Timer);
                stop(this.DrawnowTimer);
            end
            if ~isempty(this.Timer), delete(this.Timer); this.Timer=[];end
            if ~isempty(this.DrawnowTimer), delete(this.DrawnowTimer); this.DrawnowTimer=[];end
            if ~isempty(this.JumpTo), delete(this.JumpTo); this.JumpTo=[];end
            if ~isempty(this.FrameRate), delete(this.FrameRate); this.FrameRate=[];end
        end
        
        % -----------------------------------------------------------------
        function fFwd(this,stepsize)
            %FFwd Fast-forward by skipping N frames
            
            if nargin<2
                stepsize = this.StepSize;
            end
            srcObj    = this.Source;
            numFrames = srcObj.data.NumFrames;
            cmd_mode  = getPlaybackCmdMode(srcObj.Application);
            repeat    = this.Repeat && cmd_mode;
            if (this.AutoReverse==3) && cmd_mode
                % Forward/backward ("yo-yo") playback
                if this.ReversePlay
                    % Decrement frame number
                    if this.CurrentFrame - stepsize > 1
                        this.CurrentFrame = this.CurrentFrame - stepsize;
                    else
                        % Decrement to frame 1, go to fwd mode only if repeat
                        this.CurrentFrame = 1;
                        this.ReversePlay = ~repeat;
                    end
                else  % Forward dir
                    % Increment frame number
                    if this.CurrentFrame + stepsize < numFrames
                        this.CurrentFrame = this.CurrentFrame + stepsize;
                    else
                        % increment to last frame, go to reverse mode
                        this.CurrentFrame = numFrames;
                        this.ReversePlay = true;
                    end
                end
            elseif (this.AutoReverse==2) && cmd_mode
                % Backward playback
                if this.CurrentFrame==1
                    % Since we always "powerup" on frame 1, we ignore
                    % the repeat flag and cycle back to frame N
                    % if ~repeat, return; end % CurrentFrame is at start of video
                    this.CurrentFrame = numFrames; % repeat mode: wrap back to end
                elseif this.CurrentFrame - stepsize > 1
                    this.CurrentFrame = this.CurrentFrame-stepsize;
                else
                    this.CurrentFrame = 1;
                end
            else
                % Forward playback
                if this.CurrentFrame==numFrames
                    if ~repeat, return; end % CurrentFrame is at end of video
                    this.CurrentFrame = 1; % repeat mode: wrap back to start
                elseif this.CurrentFrame + stepsize < numFrames
                    this.CurrentFrame = this.CurrentFrame + stepsize;
                else
                    this.CurrentFrame = numFrames;
                end
            end
            % Force an update by pausing or stoping the playback which will call
            % showMovieFrame.  We call pause when we are not "at the end" of the movie
            % so that the play button because "continue" instead of play, which would
            % cause the viewer to start over again.  We call stop at the end so that
            % the button will revert from continue back to play so that when the button
            % is pressed it will immediately play from the beginning again.
            try
                
                if this.CurrentFrame ~= numFrames || ...
                        this.Repeat || ...
                        this.AutoReverse ~= 1
                    pause(this, true);
                else
                    this.StopRequested = false;
                    stop(this);
                end
                
                updateVCRControls(this);
            catch e
                this.frameReadErrorHandling(e);
            end
        end
        
        % -----------------------------------------------------------------
        function frameReadErrorHandling(this, varargin)
            %FRAMEREADERRORHANDLING Handle frame read errors.
            
            srcObj = this.Source;
            srcObj.Controls.enable('off');
            srcObj.clearDisplay;
            
            if nargin > 1
                srcObj.Application.screenMsg(uiservices.cleanErrorMessage(varargin{:}));
            end
            eventData = uiservices.EventData(srcObj.Application, 'DataLoadedEvent', false);
            send(srcObj.Application,'DataLoadedEvent', eventData);
        end
        
        % -----------------------------------------------------------------
        function updateVCRControls(this)
            % Update stop and all "step" buttons and menu enables/states
            % and status bar text
            
            hUIMgr = this.UIMgr;
            
            % Enable step controls (sync'd menus and buttons)
            % (enable all but stop/play, includes jump)
            hb = hUIMgr.findchild( ...
                {'Toolbars','Playback','PlaybackTimerButtons'});
            hm = hUIMgr.findchild(...
                'MPlay/Menus/Playback/PlaybackTimerMenus');
            enab = spcwidgets.logical2onoff( ...
                this.PauseRequested || this.StopRequested);
            hb.Enable = enab;
            hm.Enable = enab;
            
            hbVCR = hb.findchild('VCR');
            hmVCR = hm.findchild('VCR');
            
            % Fixup - stop and play were included in the group above
            hb2 = hbVCR.findchild('Play');
            hb2.Enable = 'on';
            hb2 = hbVCR.findchild('Stop');
            hb2.Enable = spcwidgets.logical2onoff( ...
                this.PauseRequested || this.PlayRequested);
            
            hm2 = hmVCR.findchild('Play');
            hm2.Enable = 'on';
            hm2 = hmVCR.findchild('Stop');
            hm2.Enable = spcwidgets.logical2onoff( ...
                this.PauseRequested || this.PlayRequested);
            
            % Setup status bar text, indicating
            % current scope state, for file/variable connection
            %
            hsb = hUIMgr.findwidget('StatusBar');
            if ~shouldShowControls(this.Source, 'Base')
                % If we're not showing controls, do not show any status
                % because we can not play/pause/stop/etc.
                hsb.Text = '';
            elseif this.StopRequested,
                hsb.Text = 'Stopped';
            elseif this.PauseRequested,
                hsb.Text = 'Paused';
            else
                hsb.Text = 'Playing';
            end
            
            % If we are on the first frame disable the "GoToStart" button.  If we are
            % not in a repeat mode and autoreverse is off, disable the rest of the
            % "backwards" buttons.
            startEnab     = enab;
            gotoStartEnab = enab;
            if this.CurrentFrame == 1
                gotoStartEnab = 'off';
                if ~this.ReversePlay && ...
                        ~this.Repeat && ...
                        this.AutoReverse == 1
                    startEnab = 'off';
                end
            end
            
            %set buttons
            set([hbVCR.findchild('Rewind') hbVCR.findchild('StepBack')], 'Enable', startEnab);
            set(hbVCR.findchild('GotoStart'), 'Enable', gotoStartEnab);
            
            %set menus
            set([hmVCR.findchild('Rewind') hmVCR.findchild('StepBack')], 'Enable', startEnab);
            set(hmVCR.findchild('GotoStart'), 'Enable', gotoStartEnab);
            
            % If we are on the last frame disable the "GoToEnd" button.  If
            % we are not in a repeat mode and autoreverse is off, disable
            % the rest of the "forward" buttons.
            endEnab     = enab;
            gotoEndEnab = enab;
            if this.CurrentFrame == this.Source.Data.NumFrames
                gotoEndEnab = 'off';
                if ~this.Repeat && ...
                        this.AutoReverse == 1
                    endEnab = 'off';
                end
            end
            set([hbVCR.findchild('StepFwd') hbVCR.findchild('FFwd')], 'Enable', endEnab);
            set(hbVCR.findchild('GotoEnd'), 'Enable', gotoEndEnab);
            
            set([hmVCR.findchild('StepFwd') hmVCR.findchild('FFwd')], 'Enable', endEnab);
            set(hmVCR.findchild('GotoEnd'), 'Enable', gotoEndEnab);
        end
        
        % -----------------------------------------------------------------
        function jumpTo(this,newFrame)
            %JumpTo Jump to new frame number.
            % Called from listener on JumpTo object's frame property (init)
            % Called from external API
            
            % Set curr/next frame # for movie playback
            % based on current JumpTo dialog property
            %
            % object checks for legal frame number in set-function
            if nargin>1
                try
                    % Set the new frame number:
                    this.JumpTo.Frame = newFrame;
                catch e
                    uiscopes.errorHandler(uiservices.cleanErrorMessage(e));
                    return
                end
            end
            
            % Note:
            %   need to copy frame into both .CurrentFrame *and* .NextFrame here
            %   this is because the timer could be running, and we want to "interfere"
            %   with the normal frame sequence progression deriving from .NextFrame:
            %
            % there is *some* chance we will fail here, since we're not stopping the
            % timer --- we could get halfway through these changes and the timer tick
            % could go off.
            this.CurrentFrame = this.JumpTo.Frame;
            this.NextFrame    = this.JumpTo.Frame;
            
            % jump puts player in pause mode if change is due to:
            %   frame dialog interaction (not datasource change), and
            %   player is currently stopped
            try
                if this.StopRequested
                    % If we are stopped, we want to go to the new frame and
                    % put ourselves into a paused state so tht the next
                    % time the user hits play, we start playing fromt his
                    % point, not from the beginning.
                    pause(this, true);
                else
                    updateFrameData(this.Source);
                end
                
                updateVCRControls(this);
            catch e
                frameReadErrorHandling(this, e);
            end
        end
        
        % -----------------------------------------------------------------
        function play(this)
            %PLAY Play movie, regardless of current state
            %   Sends PlayEvent, even if MPlay is already playing.
            %
            %   This is the default installed playback toolbar for use with timers
            %   and file/variable data sources
            
            % Prevent re-entry: empty means a thread can enter
            if ~this.IsStarting
                this.IsStarting = true;
                srcObj = this.Source;
                
                if ~this.PlayRequested
                    if this.PauseRequested
                        % Paused - move to play
                        % Must setup .NextFrame field before starting timer
                        this.NextFrame = this.CurrentFrame;
                    else
                        % Stopped - move to play
                        if this.AutoReverse==2
                            % Backward playback mode
                            % Start from last frame when stopped
                            this.ReversePlay = true;  % Set to reverse play
                            this.NextFrame = srcObj.data.NumFrames;
                        else
                            % Forward or Fwd/Bk mode
                            this.ReversePlay = false;  % Reset autoreverse to fwd play
                            this.NextFrame = 1;  % Start from 1st frame when stopped
                        end
                    end
                    
                    % Set state flags after using "old" state values above
                    setPlayState(this);   % set state bits
                    
                    % xxx Move this into UpdateVCRControls() ?
                    %
                    % Update Play buttons/menus
                    % On play event, set pause mode in button
                    %   Button sequence: 1=Play, 2=Pause, 3=Resume
                    hUIMgr = getGUI(srcObj.Application);
                    hPlay = hUIMgr.findwidget('Toolbars','Playback','PlaybackTimerButtons','VCR','Play');
                    hPlay.Selection = 2;
                    hPlay = hUIMgr.findwidget('Menus','Playback','PlaybackTimerMenus','VCR','Play');
                    set(hPlay,'label','Pause');
                    
                    % Only need to update "VCR controls", and not *all* of
                    % the controls - otherwise we'd call update(this)
                    updateVCRControls(this);
                    
                    send(srcObj.Application,'PlayEvent');  % Last step: send event
                    this.IsStarting = false;
                    % We don't want to get a timer tick without the proper state-bits
                    % set to represent the mode (which is now "play" mode)
                    
                    %Listen to timer start and stop events
                    this.Source.State.attachToTimer(this.Timer,'stopped',...
                        @(h, ev) this.onStateEventHandler(ev));
                    start(this.Timer); % Start the timer
                end
            end
        end
        
        % ------------------------------------------------------------
        function pause(this, force)
            %PAUSE Put player into pause mode
            %   Sends PauseEvent, even if the scope is already paused.
            
            if nargin < 2
                force = false;
            end
            
            if this.PauseRequested
                % need very fast processing here, especially for keyboard
                % frame control (step fwd/back, etc).  In this case, skip
                % all processing and exit quickly.  We also wish to skip
                % any send-events for this as well.
                %
                % To do "proper" job, we must handles flow control, events, etc,
                % by calling the following:
                pauseContinue(this);
            elseif this.StopRequested && ~force
                % If we are stopped or stopping, don't bother with an
                % actual pause, just send the event.
                send(this.Source.Application, 'PauseEvent');
            elseif ~this.IsPausing  % do a SemTake, prevent reentrant flow
                this.IsPausing = true;
                % Timer-based
                %
                if this.StopRequested
                    % Already stopped - events will not fire
                    pauseContinue(this);
                else
                    % Playing (timer is running)
                    % Special call to Stop, so Stop doesn't perform any GUI
                    % changes or fire events - scaled-down just for Pause:
                    stop(this,true)
                end
            end
        end
        
        % -----------------------------------------------------------------
        function stop(this, forPause)
            % Stop movie playback; does not close/shutdown data source
            % Sends StopEvent when stop completes.  If already in
            % stop state, event fires immediately.
            
            if this.StopRequested
                % If already stopped, send event and skip out
                % (minimize repeated keypresses)
                hScope = this.Source.Application;
                send(hScope,'StopEvent');  % Must send event
            else
                
                % Not stopped - prevent re-entry via semaphore
                if ~this.IsStopping
                    this.IsStopping = true;
                    % Pause calls stop, but doesn't want the GUI to change
                    % Allow for this special-case call
                    if nargin<2, forPause=false; end
                    
                    if isTimerRunning(this)
                        % stops timer object and then calls
                        % stop_playback_general
                        this.Source.State.setPause(forPause);
                        stop(this.Timer);
                    else
                        % Allow stop even when movie not running
                        % We could have been paused
                        if (forPause)
                            pauseContinue(this);
                        else
                            stopContinue(this);
                        end
                    end
                end
            end
        end
        
        % ------------------------------------------------
        function onStateEventHandler(this, event)
            %ONSTATEEVENTHANDLER React to Event from timer
            % Call subclassed handlers if any
            
            switch event.Type
                case 'sourceStop'
                    stopContinue(this);
                case 'sourcePause'
                    pauseContinue(this);
                    %   this.Source.State.setPause(false);
                case 'sourceHalt'
                    localChangeFPS(this,true);
                    this.Source.State.setHalt(false);
                case {'sourceRun','sourceContinue'}
                    this.Source.State.setPause(false);
                    if strcmp(this.DrawnowTimer.Running, 'off')   
                        start(this.DrawnowTimer);
                    end
                otherwise
            end
            
            % rebroadcast for others (on application)
            % caution, objects may already be deleted on close
            if ~isempty(this.Source) && ~isempty(this.Timer)
                send(this.Source.Application, event.Type);
            end
        end
        
        % -----------------------------------------------------------------
        function rewind(this,stepsize)
            %Rewind Rewinds data source by N frames
            
            if nargin<2
                stepsize = this.StepSize;
            end
            srcObj    = this.Source;
            numFrames = srcObj.data.NumFrames;
            cmd_mode  = getPlaybackCmdMode(srcObj.Application);
            repeat    = this.Repeat && cmd_mode;
            if (this.AutoReverse==3) && cmd_mode
                % Forward/backward ("yo-yo") playback
                if this.ReversePlay
                    % Increment frame number
                    if this.CurrentFrame + stepsize < numFrames
                        this.CurrentFrame = this.CurrentFrame + stepsize;
                    else
                        % Increment to last frame, go to forward mode
                        this.CurrentFrame = numFrames;
                        this.ReversePlay = false;
                    end
                else  % Forward dir
                    % Decrement frame number
                    if this.CurrentFrame - stepsize > 1
                        this.CurrentFrame = this.CurrentFrame - stepsize;
                    else
                        % Decrement to frame 1, go to fwd mode only if repeat
                        this.CurrentFrame = 1;
                        this.ReversePlay = repeat;
                    end
                end
            elseif (this.AutoReverse==2) && cmd_mode
                % Backward playback
                if this.CurrentFrame==numFrames
                    % if ~repeat, return; end % CurrentFrame is at end of video
                    this.CurrentFrame = 1; % repeat mode: wrap back to start
                elseif this.CurrentFrame + stepsize < numFrames
                    this.CurrentFrame = this.CurrentFrame + stepsize;
                else
                    this.CurrentFrame = numFrames;
                end
            else
                % Forward playback
                if this.CurrentFrame == 1
                    if ~repeat, return; end % CurrentFrame is at start of video
                    this.CurrentFrame = numFrames; % repeat mode: wrap
                elseif this.CurrentFrame - stepsize > 1
                    this.CurrentFrame = this.CurrentFrame - stepsize;
                else
                    this.CurrentFrame = 1;
                end
            end
            pause(this, true);  % Forces an update
            
            updateVCRControls(this);
        end
        
        % -----------------------------------------------------------------
        function timerTick(this)
            %TimerTick Timer tick function, for file playback
            
            % Increment frame or stop playback if finished or error
            %
            shouldStop = false;  % Assume no stopping
            
            % Get the Timer Handle here, because it is possible to be in
            % this method and have "this" be deleted" in a callback.
            hTimer = this.Timer;
            
            try
                % Cache # of frames
                srcObj = this.Source;
                N = srcObj.data.NumFrames;
                
                % We're going to display .NextFrame
                % First, we update .currentframe to be .NextFrame
                this.CurrentFrame = this.NextFrame;
                
                % Respect framerateObj frame playback schedule
                thisIncr = nextSchedIncr(this.FrameRate);
                
                % Show the video frame
                %
                % Update the frame number readout if:
                %   - this is the 1st or a multiple of 10 frames, or -
                %   frame rate is "slow" (<= 10 fps) - any of the next
                %   "thisIncr" frame numbers passes through a multiple of
                %   ~0.5 seconds
                %
                % Timer-based: twice per second, to nearest 5-frame boundary
                %
                % xxx compute readout display interval
                %
                interval = max(1, 5*round(this.FrameRate.Desiredfps/10));
                readout_cnt = rem(this.CurrentFrame + [0 thisIncr-1], interval);
                frame_motion = (readout_cnt(2) < readout_cnt(1)) || any(readout_cnt==0);
                doReadoutUpdate = frame_motion || (this.CurrentFrame == 1);
                
                % Show new movie frame, and conditionally update
                % current frame number (the "readout")
                updateFrameData(srcObj, doReadoutUpdate);

                % Provide feedback on measured rate, only when timer
                % is running (e.g., this is not part of ShowMovieFrame)
                if doReadoutUpdate
                    updateActualRate(this);
                    
                    % Flush all the events through the queue.
                    drawnow;
                end
                
                if this.CurrentFrame == N
                    % Last frame of movie just displayed
                    %
                    switch this.AutoReverse
                        case 3  % FwdBk playback mode
                            if this.ReversePlay
                                % only occurs for single-frame video
                                shouldStop = ~this.Repeat;
                            else % ~this.ReversePlay
                                % the usual case for multi-frame video
                                this.ReversePlay = true;  % going into reverse playback mode
                                this.NextFrame = N-thisIncr;
                            end
                            
                        case 2 % Backward playback mode
                            % first displayed frame for reverse play!
                            this.NextFrame = N-thisIncr;
                            this.ReversePlay = true;  % should be in reverse playback mode
                            
                        case 1 % Fwd playback mode
                            this.NextFrame = 1;  % loop back to beginning
                            this.ReversePlay = false;
                            shouldStop = ~this.Repeat;
                    end
                    % If we hit this point, the timer ran us to the end of the movie
                    % or we started on the last frame.
                    
                elseif this.CurrentFrame == 1
                    % First frame of movie just displayed
                    %
                    switch this.AutoReverse
                        case 3  % FwdBk playback mode
                            this.NextFrame = 1+thisIncr;
                            if this.ReversePlay
                                this.ReversePlay = false;  % going into fwd playback mode
                                shouldStop = ~this.Repeat; % to handle repeat mode
                            end
                            
                        case 2 % Backward playback mode
                            % This is the last displayed frame (in reverse sequence)
                            this.NextFrame = N;
                            this.ReversePlay = true;
                            shouldStop = ~this.Repeat;
                            
                        case 1 % Fwd playback mode
                            this.NextFrame = 1+thisIncr;
                            this.ReversePlay = false;
                    end
                else
                    % Not first or last frame:
                    %
                    if this.ReversePlay
                        % next frame, reverse play
                        this.NextFrame = this.NextFrame - thisIncr;
                    else
                        % next frame, fwd play
                        this.NextFrame = this.NextFrame + thisIncr;
                    end
                end
                
                % Clip frame count, due to nonunity stride by thisFrameSkip
                % Need to check always, in case of degenerate 1-frame movie
                %
                if this.NextFrame < 1
                    this.NextFrame = 1;
                elseif this.NextFrame > N
                    this.NextFrame = N;
                end
            catch e
                
                % Return early when we hit "noSuchMethodOrField" because the object has
                % been deleted.
                if any(strcmp(e.identifier, ...
                        {'MATLAB:noSuchMethodOrField', ...
                        'MATLAB:class:InvalidHandle'}))
                    
                    % If the timer is still running, but "this" has been deleted, stop
                    % the timer.
                    if strcmpi(hTimer.Running, 'on')
                        stop(hTimer);
                    end
                    return;
                end
                shouldStop = true;
            end
            
            % Stop playback if we're at end of movie, etc:
            %
            if shouldStop
                stop(this);
            end
        end
        
        % -----------------------------------------------------------------
        function enable(this, value)
            
            if shouldShowControls(this.Source, 'Base')
                controlVis(this, value);
            else
                controlVis(this, false);
            end

            set(this.FrameRateChangedListener,'Enable',value);
            
            if isempty(this.Timer)
                
                % Create Timer object
                this.Timer = timer( ...
                    'ExecutionMode','fixedRate', ...
                    'TimerFcn', @(hco,ev) timerTick(this), ...
                    'BusyMode', 'drop', ...
                    'TasksToExecute', inf);
                this.DrawnowTimer = timer( ...
                    'Period', .25, ...
                    'ExecutionMode', 'fixedRate', ...
                    'TimerFcn', @(hco, ev) drawnow, ...
                    'BusyMode', 'drop', ...
                    'TasksToExecute', inf);
            end
            
        end
        
        
        % -----------------------------------------------------------------
        function close(this)
            %CLOSE Cleanup playback object
            
            % Delete timer object
            if ~isempty(this.Timer) && ~strcmp(this.Timer.Running, 'off')
                stop(this.Timer);
                stop(this.DrawnowTimer);
            end
            if ~isempty(this.Timer), delete(this.Timer); this.Timer = [];end
            if ~isempty(this.DrawnowTimer), delete(this.DrawnowTimer);this.DrawnowTimer = [];end
           
            
            % Delete buttons/menus, if needed
            %  (done automatically when GUI closes)
            install(this, false);
            set(this.FrameRateChangedListener,'Enable','off');
        end
        
        % -----------------------------------------------------------------
        function frameRateDlg(this)
            %FrameRateDlg Show frame rate dialog
            
            this.FrameRate.show(true);
        end
        
        % -----------------------------------------------------------------
        function jumpToDlg(this)
            %JumpToDlg Show "jump to" dialog
            
            this.JumpTo.show(true);  % allow dialog creation
            
            % Set focus to the OK button:
            this.JumpTo.dialog.setFocus('pushOK');
        end
        
        % -----------------------------------------------------------------
        function resetToStart(this)
            %RESETTOSTART Reset internal indices to frame 1.
            %   For timer-based playback
            
            this.CurrentFrame = 1;
        end
        
        % -----------------------------------------------------------------
        function stepBack(this)
            %STEPBACK Step one frame backward
            
            rewind(this, 1);
        end
        
        % -----------------------------------------------------------------
        function stepFwd(this)
            %STEPFWD Step one frame forward
            
            fFwd(this, 1);
        end
        
        % -----------------------------------------
        function updateActualRate(this)
            %UpdateActualRate Update measured frame-rate in frame rate dialog.
            
            % Only update the display if the frame rate dialog is open
            if ~isempty(this.FrameRate.dialog)
                % Get average rate from timer
                % By setting the .measuredRate value, the dialog readout
                % will be automatically updated
                this.FrameRate.measuredRate = ...
                    1 ./ get(this.Timer,'AveragePeriod');
            end
        end
        % ------------------------------------------------------------
        function playPause(this)
            %PlayPause Toggles between pause and play modes
            
            if this.PlayRequested
                pause(this);
            else
                play(this);
            end
        end
        
        % -----------------------------------------------------------------
        function setAutoReverse(this,sel)
            %AutoReverse React to autoreverse (forward/backward play) mode
            % If no mode passed in, get mode stored in state
            %   sel: 1=fwd, 2=bk, 3=fwdbk
            
            % SEL:
            %       -3=use widget state (menu click callback)
            %       -2=use this.AutoReverse state (update call)
            %       -1=manually cycle choice
            %       (0=unused to better align with Repeat(), which uses this state)
            %        1=set fwd
            %        2=set backward state
            %        3=set fwdbk state
            
            hUIMgr = this.UIMgr;
            h = hUIMgr.findwidget('Toolbars','Playback','PlaybackModeButtons','AutoReverse');
            
            if sel==-3
                % This is the menu callback
                % Get the current choice, based on button/menu state
                % Remaps SEL to 1,2,3
                %
                % NOTE: Cannot use .autorev state, since it hasn't
                % been updated yet ... we're about to do that!
                sel = get(h,'Selection');
                
            elseif sel==-1
                % Cycle current choice, based on either BUTTON state or .autorev
                % Remaps SEL to 1,2,3
                sel = 1+rem(this.AutoReverse,3);
                
            elseif sel==-2
                % Get current .autorev state
                sel = this.AutoReverse;
            end
            
            if ~(sel==-2)
                % When setting a NEW value for .AutoReverse, update
                % the current playback direction (.ReversePlay).
                %
                % Note: Do NOT do this in the case of KEEPING the
                % current mode, since this will change the playback
                % dir, say, when pausing playback
                %
                % True if we're in backward playback mode
                this.ReversePlay = (this.AutoReverse==2);
                
                % Record new state
                this.AutoReverse = sel;
            end
            
            if (sel~=-3)
                % Update menu/button state (sync'd)
                h.Selection = sel;
            end
            
            % Update frame readout and tooltip
            updateFrameReadout(this);
            local_UpdateFrameReadoutTooltip(this);
            
            updateVCRControls(this);
        end
        
        % ---------------------------------------------------------------
        function setRepeat(this, sel)
            %SETREPEAT React to the (new) repeat mode
            % If no mode passed in, get mode from internal state
            % SEL:
            %       -3=use widget state (menu click callback)
            %       -2=use this.repeatMode state (update call)
            %       -1=manually cycle choice
            %        0=turn off
            %        1=turn on
            
            h = this.UIMgr.findwidget('Menus','Playback','PlaybackModeMenus','Repeat');
            
            if sel==-3
                % This is the menu widget callback
                % Get the current choice, based on widget state
                % Remaps SEL to 0,1
                %
                % NOTE: Cannot use .repeatMode state, since it hasn't
                % been updated yet ... we're about to do that!
                sel = spcwidgets.onoff2logical(get(h,'Checked'));
                
            elseif sel==-1
                % Cycle current choice, based on either widget state or .autorev
                % Remaps SEL to 0,1
                sel = 1-this.Repeat;
                
            elseif sel==-2
                % Get current .autorev state
                sel = this.Repeat;
            end
            
            if ~(sel==-2)
                % Record new state
                this.Repeat = logical(sel);
            end
            
            if (sel~=-3)
                % Update menu state (sync'd to button)
                set(h,'Checked',spcwidgets.logical2onoff(sel));
            end
            
            updateVCRControls(this);
            
        end
        
        % -----------------------------------------------------------------
        function gotoStart(this)
            %GotoStart Jump to the first movie frame
            %   Puts player into forward-play mode, in case of autoreverse operation
            
            if ~this.StopRequested
                % Stop() is not really needed, as things work fine either
                % way. It's just consistency with the gotoEnd method, which
                % does a Stop().
                stop(this);
            end
            
            % If we're in autoreverse mode and hit "go to start", we want
            % to pick things up in the fwd direction - even if we were in
            % reverse mode when we hit it.  Change fwd/bkwd state to
            % reflect this expectation.  If we're in backward mode,
            % vice-versa:
            %
            % That is, only if we're in backward playback mode, set reverse play
            this.ReversePlay = (this.AutoReverse==2);
            
            % If we're not at first frame, go there now:
            srcObj = this.Source;
            if this.CurrentFrame ~= 1,  % prevent repeats
                this.CurrentFrame = 1;
                updateFrameData(srcObj);
            end
            
            updateVCRControls(this);
        end
        
        % -----------------------------------------------------------------
        function gotoEnd(this)
            %GotoEnd Goto end button callback
            
            % NOTE: For fwd/bkwd mode, goes to last frame as usual,
            % and enters bkwd playback.  No special override needed.
            %
            % Cannot hit this while player is running - it's disabled
            %
            % Put player into Stop mode
            % Could have been in Pause mode
            %
            % The reason is that if we goto last frame and remain in pause,
            % a subsequent "play" action (with repeat turned off)
            % immediately stops the play, and it feels wrong.  Also,
            % there's no benefit to remaining in "pause" mode since on the
            % next play we start at frame 1 (just like playback from
            % stopped mode)
            if ~this.StopRequested
                stop(this);
            end
            
            % If we're in autoreverse mode and hit "go to start", we want
            % to pick things up in the fwd direction - even if we were in
            % reverse mode when we hit it.
            %
            % That is, only if we're in backward playback mode, set reverse play
            this.ReversePlay = (this.AutoReverse==2);
            
            srcObj = this.Source;
            numFrames = srcObj.data.NumFrames;
            try
                
                if this.CurrentFrame ~= numFrames,  % prevent repeats
                    this.CurrentFrame = numFrames;
                    updateFrameData(srcObj);
                end
                
                updateVCRControls(this);
            catch e
                this.frameReadErrorHandling(e);
            end
            
        end
        
        % -----------------------------------------------------------------
        function createGUI(this)
            %CreateGUI Build and cache GUI menus and buttons for timer-based playback.
            %   Create the PlaybackControlsTimer GUI.
            %   Don't add/render, just build and cache.
            
            % Create plug-in GUI trees
            [mVCR, bVCR] = createVCR(this);
            [mPlayMode, bPlayMode] = createPlaybackModes(this);
            [hKeyPlayback, hFrameRate] = createKeyBinding(this);
            mFrameRate = createFrameRate(this);
            
            % Create plug-in installer
            plan = { mVCR,'Base/Menus/Playback';
                bVCR,'Base/Toolbars/Playback';
                mPlayMode,'Base/Menus/Playback';
                bPlayMode,'Base/Toolbars/Playback';
                mFrameRate,'Base/Menus/Playback';
                hKeyPlayback, 'Base/KeyMgr';
                hFrameRate, 'Base/KeyMgr'};
            this.PlugInGUI = uimgr.uiinstaller(plan);
        end
        
        % -----------------------------------------------------------------
        function changeFrameRate(this, newFPS)
            %ChangeRate Change playback frame rate for timer use
            
            framerateObj = this.FrameRate;
            
            % Set new frames/sec for movie playback
            %
            if nargin>1
                % One of two ways to get here:
                %
                % 1. External API to change frame rate
                %    user calls ChangeFrameRate, passing numeric value as newFPS
                %
                % 2. "Preset" frame rate change from keyboard
                %    newFPS is '+', '-', or '0'
                %
                if ischar(newFPS) && strmatch(newFPS,{'+','-','0'},'exact')
                    % Compute new frame rate from preset increment/decrement
                    newFPS = speedPreset(framerateObj,newFPS);
                else
                    % "Arbitrary" rate entered by user
                    speedReset(framerateObj);
                end
                [success,err] = checkFPS(framerateObj,newFPS);
                if ~success
                    uiscopes.errorHandler(err);
                    return
                end
                % Disable listener before manually changing value
                % NOTE: This is a vector of handles
                set(this.FrameRateChangedListener,'Enabled','off');
                framerateObj.Desiredfps = newFPS;
                set(this.FrameRateChangedListener,'Enabled','on');
            else
                % Arbitrary rate entered via frame dialog
                % (which sets the desired_fps automagically itself - hence no input arg)
                
                % "Arbitrary" rate entered by user
                speedReset(framerateObj);
            end
            
            % Update GUI status line
            %
            % approx fps for display
            fracRate = framerateObj.Desiredfps / framerateObj.Sourcefps;
            pctRate = round(100 * fracRate);
            rndRate = round(framerateObj.Desiredfps);
            txtStr = sprintf('%.0f%% (%d fps)', pctRate, rndRate);
            tipStr = sprintf('Relative frame rate (Absolute frame rate)');
            
            % Set info into status bar
            %
            % Status: 1:size, 2:rate, 3:num
            % Status: 1:size, 2:rate, 3:num+
            if ~isempty(this.Source) && isa(this.Source, 'extmgr.AbstractExtension')
                
                % Set up the rate widget.  Also grow the width based on the
                % size of the text.  Do not shrink though, this will reduce
                % flicker and take less processing time. g461864
                hRate = getStatusControl(this.Source.Application, 'Rate');
                set(hRate, ...
                    'Text',     txtStr, ...
                    'Tooltip',  tipStr, ...
                    'Width',    max(hRate.Width, largestuiwidth({txtStr})+5), ...
                    'Callback', @(h,ev) frameRateDlg(this));
            end
            
            % Determine playback schedule to use, impacting both
            % timer rate and frame show/skip factors
            %
            createPlaybackSchedule(framerateObj);
            
            % Reset timer avg-rate measurement
            framerateObj.measuredRate = 0;
            
            % Force manual refresh of dialog info, if open
            if ~isempty(framerateObj.dialog)
                refresh(framerateObj.dialog);
            end
            
            % Cannot change period while movie is running
            % Must stop timer, change frame rate, then restart timer
            %
            if isTimerRunning(this)
                % "Temporary" timer halt - not a full Pause() or Stop()
                % Force Halt callback on timer stop
                this.Source.State.setHalt(true);
                stop(this.Timer);
            else
                % timer wasn't running - proceed with change:
                localChangeFPS(this,false);
            end
        end
        
        % -----------------------------------------------------------------
        function update(this)
            %Update timer-based playback controls
            
            updateVCRControls(this);
            updateJumpLoopControls(this);
        end
        
        % -----------------------------------------------------------------
        function updateFrameReadout(this)
            %UpdateFrameReadout Update current frame number readout in status bar
            %   for timer-based playback
            
            % If fwd/bkwd mode not on,
            %    show "current frame : total frames"
            % If on,
            %    show "+/- current frame : total frames"
            %  where + means fwd play, - means bkwd play
            %
            % If on-demand source is installed, show 'N/A'
            % since frame number is not known/relevant
            
            srcObj = this.Source;
            dataSrc = srcObj.data;
            
            % File or variable playback
            %
            % Create text display of current frame and direction
            str = sprintf('%d / %d', this.CurrentFrame, dataSrc.NumFrames);
            
            if this.AutoReverse > 1  % Playback mode is FwdBk or Bk (not Fwd)
                % Option 2
                if this.ReversePlay, str = ['-' str];
                else                        str = ['+' str];
                end
                
                % Option 2 xxx autoreverse display in statusbar
                %     if this.ReversePlay, str = ['< ' str];
                %     else                        str = [str ' >'];
                %     end
            end
            
            % Show text in status bar
            % Status: 1:size, 2:rate, 3:num
            hFrame = srcObj.Application.getStatusControl('Frame');
            hFrame.Width = max(hFrame.Width, largestuiwidth({str})+2);
            hFrame.Text = str;
        end
        
        % -----------------------------------------------------------------
        function dataInfo = getDataInfo(this)
            data = this.Source.data;
            
            dataInfo.Title = 'Timer';
            dataInfo.Widgets = { ...
                'Source rate', sprintf('%g fps', data.FrameRate); ...
                'Frame count', sprintf('%d',     data.NumFrames)};
        end
    end
    
    % ---------------------------------------------------------------------
    methods (Access = protected)
        
        function local_UpdateFrameReadoutTooltip(this)
            %local_UpdateFrameReadoutTooltip Update the tooltip to define
            %   +/- symbols when in autoreverse mode
            
            tStr = 'Current Frame / Total Frames';
            if (this.AutoReverse > 1)  % fwdbk or bk mode
                % Append additional information for fwdbk and bk playback mode
                tStr = [tStr sprintf('\n') '+Fwd dir, -Bkwd dir'];
            end
            hFrame = this.Source.Application.getStatusControl('Frame');
            hFrame.Tooltip = tStr;
            
        end
        
        % -----------------------------------------------------------------
        function updateJumpLoopControls(this)
            % Update jump/repeat/autoreverse buttons and menu enables/states
            
            %htoolbar = this.parent_toolbar;
            %hmenu    = this.parent_menu;
            
            setRepeat(this, -2);      % update button state
            setAutoReverse(this, -2); % update button state
        end
        
        % -----------------------------------------------------------------
        function localChangeFPS(this,wasRunning)
            % Wait until timer is stopped before proceeding with
            % change to frame rate
            
            % Install new timer period
            %
            % Note: timer only allows nearest-millisecond accuracy,
            %       and warns otherwise
            %
            timerObj = this.Timer;
            set(timerObj,'Period', ...
                round_to_millisec(1 ./ this.FrameRate.Schedfps));
            
            if wasRunning
                % timer resume, not a full Play(mplayObj)
                start(timerObj);
            end
        end
        
        % -----------------------------------------------------------------
        function isRunning = isTimerRunning(this)
            %IsTimerRunning Return logical flag indicating whether timer object is running
            
            if isempty(this.Timer)
                isRunning = false;
            else
                isRunning = strcmpi(this.Timer.running,'on');
            end
        end
        
        % -----------------------------------------------------------------
        function s = getTimerState(this)
            % Returns state for timer-based playback
            
            s.isPlaying = this.PlayRequested;
            s.isStopped = this.StopRequested;
            s.isPaused  = this.PauseRequested;
        end
        
        function setPauseState(this)
            %SETPAUSESTATE Set pause state
            
            this.PauseRequested = true;
            this.PlayRequested  = false;
            this.StopRequested  = false;
        end
        
        % -----------------------------------------------------------------
        function setPlayState(this)
            %SETPLAYSTATE Set play state
            
            this.PauseRequested = false;
            this.PlayRequested  = true;
            this.StopRequested  = false;
        end
        
        % -----------------------------------------------------------------
        function setStopState(this)
            %SETSTOPSTATE Set stop state
            
            this.PauseRequested = false;
            this.PlayRequested  = false;
            this.StopRequested  = true;
        end
        
        % -----------------------------------------------------------------
        function [hKeyPlayback, hKeyFrameRate]= createKeyBinding(this)
            
            hKeyPlayback = uimgr.spckeygroup('Playback');
            hKeyPlayback.add(...
                uimgr.spckeybinding('playpause',{'P', 'Space'},...
                @(h,ev)playPause(this), 'Play/pause video'),...
                uimgr.spckeybinding('stopvideo','S',...
                @(h,ev)stop(this), 'Stop video'),...
                uimgr.spckeybinding('gobegin',{'F','Home'},...
                @(h,ev)gotoStart(this), 'Go to first frame'),...
                uimgr.spckeybinding('goend',{'L', 'End'},...
                @(h,ev)gotoEnd(this), 'Go to last frame'),...
                uimgr.spckeybinding('stepfwd',{'rightarrow', 'pagedown'},...
                @(h,ev)stepFwd(this), 'Step forward','Right Arrow, Page Down'),...
                uimgr.spckeybinding('stepback',{'leftarrow', 'pageup'},...
                @(h,ev)stepBack(this), 'Step back','Left Arrow, Page Up' ),...
                uimgr.spckeybinding('jumpfwd','downarrow',...
                @(h,ev)fFwd(this), 'Jump forward','Down Arrow'),...
                uimgr.spckeybinding('jumpback','uparrow',...
                @(h,ev)rewind(this), 'Jump back', 'Up Arrow'),...
                uimgr.spckeybinding('jumpframe','J',...
                @(h,ev)jumpToDlg(this), 'Jump to frame','J'),...
                uimgr.spckeybinding('repeat','R',...
                @(h,ev) setRepeat(this, ~this.Repeat), 'Repeat'),...
                uimgr.spckeybinding('autorev','A',...
                @(h,ev) setAutoReverse(this, rem(this.AutoReverse, 3)+1), 'Autoreverse'));
            
            hKeyFrameRate = uimgr.spckeygroup('Frame Rate');
            hKeyFrameRate.add(...
                uimgr.spckeybinding('change','T',...
                @(h,ev)frameRateDlg(this), 'Change rate'),...
                uimgr.spckeybinding('inc',{'equal','add'},...
                @(h,ev)changeFrameRate(this, '+'), 'Increase rate','+'),...
                uimgr.spckeybinding('dec',{'hyphen','subtract'},...
                @(h,ev)changeFrameRate(this, '-'), 'Decrease rate','-'),...
                uimgr.spckeybinding('restore',{'0','numpad0'},...
                @(h,ev)changeFrameRate(this, '0'), 'Reset rate','0 (zero)'));
        end
        
        % -----------------------------------------------------------------
        function [hMenus,hButtons] = createPlaybackModes(this)
            % Controls for playback modes (fwd/bkwd/autorev, repeat)
            
            % MENUS:
            %   Playback Modes ->
            %       Repeat
            %       ---
            %       Forward play
            %       Backward play
            %       Autoreverse play
            
            mRpt = uimgr.spctogglemenu('Repeat', '&Repeat');
            mRpt.WidgetProperties = {...
                'callback',@(hco,ev)setRepeat(this,-3)};
            m1 = uimgr.spctogglemenu('Forward', 'Forward &play');
            m1.WidgetProperties = {...
                'callback',@(hco,ev) setAutoReverse(this,1)};
            m2 = uimgr.spctogglemenu('Backward', 'Backward pl&ay');
            m2.WidgetProperties = {...
                'callback',@(hco,ev) setAutoReverse(this,2)};
            m3 = uimgr.spctogglemenu('AutoReverse', 'AutoReverse pla&y');
            m3.WidgetProperties = {...
                'callback',@(hco,ev) setAutoReverse(this,3)};
            mgDir = uimgr.uimenugroup('PlaybackDir', m1,m2,m3);
            mgDir.SelectionConstraint = 'SelectOne';
            
            % Main playback modes menu
            hMenus = uimgr.uimenugroup('PlaybackModeMenus', ...
                'Playback &Modes', mRpt,mgDir);
            
            % BUTTONS
            %
            % Fwd/Bkwd buttons
            % init=bkwd (1=fwd,2=bkwd,3=autorev)
            bRpt = uimgr.spctoggletool('Repeat');
            bRpt.IconAppData = {'repeat_on', 'repeat_off'};
            bRpt.WidgetProperties = {...
                'Tooltips', {'Repeat: On','Repeat: Off'}, ...
                'oncall',  @(hco,ev) setRepeat(this,1), ...
                'offcall', @(hco,ev) setRepeat(this,0)};
            
            bRev = uimgr.spcpushtool('AutoReverse');
            bRev.IconAppData = {...
                'playback_dir_fwd',...
                'playback_dir_bk', ...
                'playback_dir_fwdbk'};
            bRev.WidgetProperties = {...
                'Tooltips', {'Forward playback','Backward playback','AutoReverse playback'}, ...
                'Selection',1, ...
                'AutoCycle','on', ...
                'click',  @(hco,ev) setAutoReverse(this,-3)};
            bRev.StateName = 'Selection';
            
            hButtons = uimgr.uibuttongroup('PlaybackModeButtons',bRpt,bRev);
            
            % SYNC
            % Note: the autoreverse button is a 3-state button
            %       it links to 3 menu items in the PlaybackDir menu group
            %       but in practice, just the first of the 3 menus ('forward')
            %       is tied to it.  So when the 3-state button changes,
            %       the sync callback on the 1st menu fires ... it gets the
            %       full src group handle.  This is good, because just one
            %       sync callback fires (autorevButtonToMenu); we must
            %       consider all 3 menus in the group, however.
            %
            % Sync repeat
            sync2way(bRpt, mRpt);
            % Sync playback dir
            sync(bRev, mgDir, @autorevMenuToButton);
            sync(mgDir, bRev, @autorevButtonToMenu);
        end
        
        % -----------------------------------------------------------------
        function [hMenus,hButtons] = createVCR(this)
            % Controls for timer-based VCR playback
            
            % VCR menus
            m1 = uimgr.uimenu('GotoStart', 'Go to Firs&t');
            m1.WidgetProperties = {...
                'callback',@(hco,ev) gotoStart(this)};
            m2 = uimgr.uimenu('StepBack',  'Step &Back');
            m2.WidgetProperties = {...
                'callback',@(hco,ev) stepBack(this)};
            m3 = uimgr.uimenu('Play', '&Play');
            m3.WidgetProperties = {...
                'callback',@(hco,ev) playPause(this)};
            m4 = uimgr.uimenu('Stop', '&Stop');
            m4.WidgetProperties = {...
                'callback',@(hco,ev) stop(this)};
            m5 = uimgr.uimenu('Rewind', 'Re&wind');
            m5.WidgetProperties = {...
                'callback',@(hco,ev) rewind(this)};
            m6 = uimgr.uimenu('FFwd', 'Fast Fo&rward');
            m6.WidgetProperties = {...
                'callback',@(hco,ev) fFwd(this)};
            m7 = uimgr.uimenu('StepFwd', 'Step &Forward');
            m7.WidgetProperties = {...
                'callback',@(hco,ev) stepFwd(this)};
            m8 = uimgr.uimenu('GotoEnd', 'Go to &Last');
            m8.WidgetProperties = {...
                'callback',@(hco,ev) gotoEnd(this)};
            mgVCR = uimgr.uimenugroup('VCR',m3,m4,m5,m6,m2,m7,m1,m8);
            %mgVCR = uimgr.uimenugroup('VCR',m1,m2,m3,m4,m5,m6,m7,m8);
            mJump = uimgr.uimenu('JumpTo', '&Jump to ...');
            mJump.WidgetProperties = {...
                'callback',@(hco,ev) jumpToDlg(this)};
            hMenus = uimgr.uimenugroup('PlaybackTimerMenus',mgVCR,mJump);
            
            % VCR buttons
            b1 = uimgr.spcpushtool('GotoStart');
            b1.IconAppData = 'goto_start_default';
            b1.WidgetProperties = {...
                'tooltip','Go to first', ...
                'click', @(hco,ev) gotoStart(this)};
            b2 = uimgr.uipushtool('StepBack');
            b2.IconAppData = 'step_back';
            b2.WidgetProperties = {...
                'Interruptible', 'off', ...
                'Busyaction', 'cancel', ...
                'tooltip','Step back', ...
                'click', @(hco,ev) stepBack(this)};
            b3 = uimgr.spcpushtool('Rewind');
            b3.IconAppData = 'rewind_default';
            b3.WidgetProperties = {...
                'tooltip','Jump back', ...
                'click', @(hco,ev) rewind(this)};
            b4 = uimgr.spcpushtool('Stop');
            b4.IconAppData = 'stop_default';
            b4.WidgetProperties = {...
                'tooltip','Stop', ...
                'click', @(hco,ev) stop(this)};
            b5 = uimgr.spcpushtool('Play');
            b5.IconAppData = {'play_on','pause_default','play_off'};
            b5.WidgetProperties = {...
                'BusyAction', 'cancel', ...
                'Tooltips', {'Play', 'Pause', 'Resume'}, ...
                'Clicked', @(hco,ev) playPause(this)};
            b6 = uimgr.spcpushtool('FFwd');
            b6.IconAppData = 'ffwd_default';
            b6.WidgetProperties = {...
                'tooltip','Jump forward', ...
                'click', @(hco,ev) fFwd(this)};
            b7 = uimgr.spcpushtool('StepFwd');
            b7.IconAppData = 'step_fwd';
            b7.WidgetProperties = {...
                'Interruptible', 'off', ...
                'Busyaction', 'cancel', ...
                'tooltip','Step forward', ...
                'click', @(hco,ev) stepFwd(this)};
            b8 = uimgr.uipushtool('GotoEnd');
            b8.IconAppData = 'goto_end_default';
            b8.WidgetProperties = {...
                'tooltip','Go to last', ...
                'click', @(hco,ev) gotoEnd(this)};
            bgVCR = uimgr.uibuttongroup('VCR',b1,b3,b2,b4,b5,b7,b6,b8);
            bJump = uimgr.spcpushtool('JumpTo');
            bJump.IconAppData = 'jump_to';
            bJump.WidgetProperties = {...
                'tooltip','Jump to', ...
                'click', @(hco,ev) jumpToDlg(this)};
            hButtons = uimgr.uibuttongroup('PlaybackTimerButtons',bgVCR,bJump);
        end
        
        % -----------------------------------------------------------------
        function hMenus = createFrameRate(this)
            % Controls for frame rate
            
            
            mFR = uimgr.uimenu('FrameRate', 'Fr&ame Rate...');
            mFR.WidgetProperties = { ...
                'callback',@(hco,ev) frameRateDlg(this)};
            hMenus = uimgr.uimenugroup('FrameRate', mFR);
        end
    end
end


% ------------------------------------------------
function stopContinue(this)
% Continue processing after timer has stopped
% Handles both timer control and single/on-demand control.
% Resets internal and GUI/button state.

try
    
    % Stop the timer that runs the 1/4s drawnow.  It does not need to tick
    % if the playback timer has stopped.
    stop(this.DrawnowTimer);
    srcObj = this.Source;
        setStopState(this);  % set state bits
        
        % On stop event, set Play mode in button
        % Button sequence: 1=Play, 2=Pause, 3=Resume
        bPlay = this.UIMgr.findwidget('Toolbars','Playback','PlaybackTimerButtons','VCR','Play');
        bPlay.Selection = 1;
        mPlay = this.UIMgr.findwidget('Menus','Playback','PlaybackTimerMenus','VCR','Play');
        set(mPlay, 'label', 'Play');
        
        updateVCRControls(this);
        
        try
            updateFrameData(srcObj);  % Flush changes
        catch e
            frameReadErrorHandling(this, e);
        end
	
    this.IsStopping = false;
    send(srcObj.Application,'StopEvent');  % Last step: send event
catch e %#ok
    % This can error when deleting the object.
end
end

% -------------------------------------------------------------
function pauseContinue(this)
% for synchronization with time stop

srcObj = this.Source;
hScope = srcObj.Application;

% Set state flags - do this AFTER call to Stop,
% since that sets up "Stop" states
setPauseState(this);  % set state bits

% On pause event, set Resume mode in button
%   Button sequence: 1=Play, 2=Pause, 3=Resume
bPlay = this.UIMgr.findwidget('Toolbars','Playback','PlaybackTimerButtons','VCR','Play');
bPlay.Selection = 3;
mPlay = this.UIMgr.findwidget('Menus','Playback','PlaybackTimerMenus','VCR','Play');
set(mPlay, 'label','Resume')
this.IsPausing = false;
this.IsStopping = false;

updateVCRControls(this);
updateFrameData(srcObj); % Flush changes

send(hScope,'PauseEvent');  % Last step: send event

end

% -------------------------------------------------------------------------
function autorevMenuToButton(dst,dstIdx,src,srcIdx,ev) %#ok
% One of 3 different autoreverse-related menu items has changed
% Update the single button accordingly
% Note that during rendering, there are 1, 2, then 3 menu items
% and v will contain empties for non-rendered items
if uimgr.isHandle(dst.hWidget) 
    if isa(ev, 'event.PropertyEvent')
        srcValue = ev.AffectedObject.(ev.Source.Name);
    else
        srcValue = ev.NewValue;
    end
    
    if isempty(srcValue)
        % Initialization call
        % Could be 1, 2, or 3 rendered items in group as rendering proceeds
        % We only want to initialize once all 3 src menus have rendered
        [sel,val] = src.findOnItems;
        if ~any(cellfun('isempty',val)) % full set of menus?
            if isempty(sel), sel=1; end
            dst.hWidget.Selection = sel(1); % in case multiple are on
        end
    else
        dst.hWidget.Selection = srcIdx;
    end
end
end

% -------------------------------------------------------------------------
function autorevButtonToMenu(dst,dstIdx,src,srcIdx,ev) %#ok
% The single autoreverse-related button was changed,
% or initialization is occurring (i.e., ev.NewValue=[]).
% Update one of the 3 related (dst) menu items accordingly.
% The SelectionConstraint on the dst group will take
% care of un-setting the other menus.

% By definition, srcWidget is present because this is a listener callback
% This is the fwd/rev playback button, clicked or initialized
% If the dst (menu) widget is available, sync to the button
% Note: SelectionConstraint is set, so we can just turn on what we need

srcProp = ev.Source.Name;
if any(strcmpi(srcProp,{'visible','enable'}))
    % Enable and Visible propagate to the parent (uimgr) item
    if isa(ev, 'event.PropertyEvent')
        dst.(srcProp) = ev.AffectedObject.(ev.Source.Name);
    else
        dst.(srcProp) = ev.NewValue;
    end
    
else
    % Find current selection of 3-state src button
    % This tells us which of the 3 dst menu items should be 'on'
    if isempty(src.hWidget) || ~uimgr.isHandle(src.hWidget)
        return
    end
    selIdx = src.hWidget.Selection;
    
    % Find the selIdx'th dst menu
    dst=dst.down; % get first child
    for i=2:selIdx
        dst=dst.right; % get next child
    end
    % Turn on this dst menu - others will turn off via selection constraint
    dstWidget = dst.hWidget;
    if uimgr.isHandle(dstWidget)
        dstWidget.Checked = 'on';
    end
end
end

% -------------------------------------------------------------------------
function y = round_to_millisec(p)

%Round to nearest millisecond
y = round(p*1000)./1000;
end

% -------------------------------------------------------------------------
function mode = getPlaybackCmdMode(hApp)

mode = hApp.getExtInst('Core', 'Source UI').findProp('PlaybackCmdMode').Value;

end

% [EOF]
