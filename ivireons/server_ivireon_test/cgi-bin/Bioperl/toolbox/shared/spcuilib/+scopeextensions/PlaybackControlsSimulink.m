classdef PlaybackControlsSimulink <  uiscopes.AbstractPlaybackControls
    %PLAYBACKCONTROLSSIMULINK Define the playback controls for Simulink.

    % Copyright 2004-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.8.2.1 $ $Date: 2010/07/06 14:42:01 $

    properties
        StatusBar = []; % uimgr.uistatusbar

        FrameCount = uint32(0);

        TimeOfDisplayData     = -1;
        PendingSimTimeReadout = false;
    end

    methods
        function this = PlaybackControlsSimulink(hScope, hSource)

            this@uiscopes.AbstractPlaybackControls(hScope, hSource);

            % Cache status option regions
            this.StatusBar = this.UIMgr.findchild('StatusBar');

            % Cache GUI plug-in's (don't add/render, just build/cache)
            createGUI(this);
        end

        % -----------------------------------------------------------------
        function enable(this,varargin)
            %Disable Enable or disable Simulink playback control
            %buttons/menus
            %Enable the playback menu if the controls are supposed to be
            %visible.
            enable = varargin{1};
            if shouldShowControls(this.Source,'Base')
                controlVis(this, enable);
            else
                controlVis(this, false);
            end
            enableSimControls(this, varargin{:});
            enableSnapshotPlaybackMode(this, enable);
            if shouldShowControls(this.Source,'Floating')
                enableFloatingControls(this,enable);
            end
        end

        % -----------------------------------------------------------------
        function pause(this)
            %PAUSE Force Simulink into pause mode.
            %   Assumes simulink connection

            srcObj = this.Source;

            if isRunning(srcObj)

                % Default call is from play/pause button,
                % We reset the stepFwd flag whenever the user directly
                % presses the play button.  But, this function is also
                % called by slStepFwd, and in that case we don't want
                % to touch the flag.  So we distinguish this by an
                % optional input:
                %
                srcObj.StepFwd = false;

                % Pass flag to asynchronous event handlers that play/pause button
                % was pressed in MPlay GUI ... as opposed to the Simulink simulation
                % button itself:
                %
                srcObj.PlayPauseButton = true;
                %
                % Execute simulation command:
                sendSimulationCommand(srcObj, 'pause');
                %
                % Clean up flag:
                srcObj.PlayPauseButton = false;

            end

            send(srcObj.Application, 'PauseEvent');  % Last step: send event
        end

        % -----------------------------------------------------------------
        function resetToStart(this)
            % ResetToStart Reset internal indices to frame 1.
            %   For Simulink-based playback

            this.FrameCount        =  0;
            this.TimeOfDisplayData = -1;
        end
        
        % -----------------------------------------------------------------
        function enableStep(this, enabState)
            %enableStep Enable the step menu/button.
            
            if nargin < 2
                enabState = true;
            end
            enabState = uiservices.logicalToOnOff(enabState);
            set(getStepMenu(this), 'Enable', enabState);
            set(getStepButton(this), 'Enable', enabState);
        end
        
        % -----------------------------------------------------------------
        function slPlayPause(this,stepFwd)
            %slPlayPause Play or pause Simulink simulator.
            %   Assumes simulink connection
            %  'start','pause','continue'

            if nargin<2
                stepFwd = false;
            end

            % We reset the stepFwd flag whenever the user directly
            % presses the play button.  But, this function is also
            % called by slStepFwd, and in that case we don't want
            % to touch the flag.  So we distinguish this by an
            % optional input:
            %
            srcObj = this.Source;
            srcObj.stepFwd = stepFwd;

            % Get current sim status, it has not been updated yet
            %
            if srcObj.isRunning
                    cmd='pause';
            elseif srcObj.isPaused
                    cmd='continue';
            elseif srcObj.isStopped
                    cmd='start';
            else
                % 'initializing', others?
                    return
            end

            % Pass flag to asynchronous event handlers that play/pause
            % button was pressed in MPlay GUI ... as opposed to the
            % Simulink simulation button itself:
            %
            srcObj.playPauseButton = true;
            
            % Execute simulation command:
            try
                sendSimulationCommand(srcObj, cmd);
                drawnow; %g387730, sometimes the pause keeps HG from updating icons.
            catch me
                msg = uiservices.cleanErrorMessage(me.message);
                uiscopes.errorHandler(msg);
            end
               
            
            % Clean up flag:
            srcObj.playPauseButton = false;
            

        end

        % -----------------------------------------------------------------
        function createGUI(this)
            %CreateGUI Build and cache UI menus and buttons for Simulink-based playback.
            %   Create the PlaybackControlsSimulink UI.
            %   Don't add/render, just build and cache.

            % Note that the "Connect to simulink" source button/menu
            % are always shown in the GUI, as long as the Simulink
            % source plug-in is enabled.  However, the other GUI elements
            % are only to appear when the Simulink connection has been made.
            %
            % To achieve this, we have TWO separate install objects,
            % one for the connection widgets, and the other for the rest
            % of the simulator/playback widgets.

            [mSimControls, bSimControls]     = createSimControls(this);
            [mPlaybackModes, bPlaybackModes] = createSnapshotPlaybackMode(this);
            
            % append floating button to playback mode for floating source
            if this.Source.shouldShowControls('Floating')
                createFloatingControls(this,mPlaybackModes,bPlaybackModes);
            end

            hMenus   = uimgr.uimenugroup('SimMenus',     mSimControls, mPlaybackModes);
            hButtons = uimgr.uibuttongroup('SimButtons', bSimControls, bPlaybackModes);
            hButtons.Placement = 0;
            hKeys    = createKeyBindings(this);

            mHighlight = uimgr.uimenu('Hilite', getHighlightString(this.Source));
            mHighlight.WidgetProperties = {...
                'accel','L', ...
                'callback',@(hco,ev)flash(this.Source)};

            % Create plug-in installer
            plan = {...
                mHighlight, 'Base/Menus/View';
                hMenus,   'Base/Menus/Playback';
                hButtons, 'Base/Toolbars/Playback';
                hKeys,    'Base/KeyMgr'};
            this.PlugInGUI = uimgr.uiinstaller(plan);
        end

        % -----------------------------------------------------------------
        function slStepFwd(this)
            %slStepFwd Step Simulink simulator forward one time step.

            % Set the .stepFwd flag when calling play/pause
            % (but do make sure the simulation is running).
            %
            % Update of time readout handled by slPlayPause

            slPlayPause(this,true);
            
            %pause if the connection failed and left the simulation running
            if strcmp(this.Source.ErrorStatus,'cancel') && ...
                    isRunning(this.Source)
                pause(this);
            end
        end

        % -----------------------------------------------------------------
        function slStop(this)
            %slStop Stop Simulink simulator.

            % Could be disconnected, in which case slSD is empty:
            srcObj = this.Source;

            % Stop the Simulink simulation
            sendSimulationCommand(srcObj, 'stop');

            % We reset the "step forward" flag whenever play, pause,
            % or stop are pressed.  Not absolutely essential here, in
            % stop method, since the next action (play, step, etc) will
            % do the right thing.  But it seems reasonable to put ourselves
            % into a definite, known state when stop is pressed:
            srcObj.stepFwd = false;

        end

        % -----------------------------------------------------------------
        function stop(this, forPause) %#ok
            %Stop Simulink control stop

            % We leave the Simulink model alone!
            send(this.Source.Application,'StopEvent');  % Must send event
        end

        % -----------------------------------------------------------------
        function update(this)
            %Update Simulink-based playback controls

            updateSimControls(this);
            updateSnapshotPlaybackMode(this);
            updateAttributeReadouts(this);
        end
    end

    methods (Access = protected)
        
        function label = getMenuLabel(~)
            label = uiscopes.message('SimulationMenuLabel');
        end
        
        function renderWidgets(this)
            hUI = this.UIMgr;
            render(hUI.findchild('Menus','Playback'));
            render(hUI.findchild('Menus','View'));
            render(hUI.findchild('Toolbars','Playback'));
        end
        
        % -----------------------------------------------------------------
        function [hMenus,hButtons] = createSimControls(this)
            % CreateSimControls
            % Controls for Simulink simulator controls

            % menus
            m1 = uimgr.uimenu('Play', '&Start');
            m1.WidgetProperties = {...
                'callback',@(hco,ev)slPlayPause(this)};
            m2 = uimgr.uimenu('Stop', 'S&top');
            m2.WidgetProperties = {...
                'callback',@(hco,ev)slStop(this)};
            m3 = uimgr.uimenu('StepFwd', 'Step &Forward');
            m3.WidgetProperties = {...
                'callback',@(hco,ev)slStepFwd(this)};
            hMenus = uimgr.uimenugroup('SimControls',m1,m2,m3);

            % buttons
            b1 = uimgr.spcpushtool('Play');
            b1.IconAppData = {'play_on','pause_default','play_off'};
            b1.WidgetProperties = {...
                'Tooltips', {'Start simulation','Pause simulation','Continue simulation'}, ...
                'Clicked',@(hco,ev)slPlayPause(this)};

            b2 = uimgr.spcpushtool('Stop');
            b2.IconAppData = 'stop_default';
            b2.WidgetProperties = {...
                'tooltip','Stop simulation', ...
                'click',@(hco,ev)slStop(this)};

            b3 = uimgr.spcpushtool('StepFwd');
            b3.IconAppData = 'step_fwd';
            b3.WidgetProperties = {...
                'tooltip','Simulate one step', ...
                'click',@(hco,ev)slStepFwd(this)};
            hButtons = uimgr.uibuttongroup('SimControls',b2,b1,b3);
        end

        % -----------------------------------------------------------------
        function [hMenus,hButtons] = createSnapshotPlaybackMode(this)
            %CREATESNAPSHOTPLAYBACKMODE Simulator modes widgets

            % menus
            m1 = uimgr.uimenu('Snapshot', 'Simulink S&napshot');
            m1.WidgetProperties = {...
                'checked','off', ...
                'callback',@(hco,ev)setSnapShotMode(this.Source,'menu')};
            hMenus = uimgr.uimenugroup('PlaybackModes',m1);

            % buttons
            b1 = uimgr.spctoggletool('Snapshot');
            b1.IconAppData = 'snapshot';
            b1.WidgetProperties = {...
                'state','off', ...
                'separator','on', ...
                'tooltip','Snapshot (freeze display)', ...
                'click', @(hco,ev)setSnapShotMode(this.Source,'button')};

            b2 = uimgr.spcpushtool('Hilite');
            b2.IconAppData = 'signal_highlight';
            b2.WidgetProperties = {...
                'tooltip', getHighlightString(this.Source, 'tooltip'), ...
                'click', @(hco,ev)flash(this.Source)};

            hButtons = uimgr.uibuttongroup('PlaybackModes',b1,b2);

            %sync2way(hMenus,hButtons);
        end

        % -----------------------------------------------------------------
        function hKeyPlayback = createKeyBindings(this)

            hKeyPlayback = uimgr.spckeygroup('Simulation');
            hKeyPlayback.add(...
                uimgr.spckeybinding('playpause',{'P', 'Space'},...
                @(h,ev)slPlayPause(this), 'Play/pause simulation'),...
                uimgr.spckeybinding('stopvideo','S',...
                @(h,ev)slStop(this), 'Stop simulation'),...
                uimgr.spckeybinding('stepfwd',{'rightarrow', 'pagedown'},...
                @(h,ev)slStepFwd(this), 'Step forward'));
        end

        function enableSnapshotPlaybackMode(this,ena)
            %Disable Enable or disable Simulink playback options control buttons/menus
            
            if nargin<2, ena=true; end
            
            h1 = {getSnapshotButton(this) getHiliteButton(this) ...
                getSnapshotMenu(this) getHiliteMenu(this)};
            setEnable(h1,ena);
        end

        % -----------------------------------------------------------------
        function enableFloatingControls(this,ena)

            if ena, s='on'; else s='off'; end
            set(this.UIMgr.findwidget(...
                'Toolbars','Playback','SimButtons','PlaybackModes','Floating'), ...
                'Enable', s);
            set(this.UIMgr.findwidget(...
                'Menus','Playback','SimMenus','PlaybackModes','Floating'), ...
                'Enable', s);
            
        end
        
        % -----------------------------------------------------------------
        function createFloatingControls(this,hMenus,hButtons)
            % menus
            m3 = uimgr.uimenu('Floating', 'Floating Simulink &Connection');
            m3.WidgetProperties = {...
                'checked','off', ...
                'callback',@(hco,ev)setConnectionMode(this.Source,'menu')};
            hMenus.add(m3);
            
            % buttons
            b3 = uimgr.spctoggletool('Floating');
            b3.IconAppData = {'signal_locked', 'signal_unlocked'};
            b3.WidgetProperties = {...
                'Tooltips', {'Persistent Simulink connection',...
                'Floating Simulink connection'}, ...
                'State','on', ...
                'click', @(hco,ev)setConnectionMode(this.Source,'button')};
            hButtons.add(b3);
        end

        % -----------------------------------------------------------------
        function enableSimControls(this,ena)
            %Disable Enable or disable Simulink simulator playback control buttons/menus

            h = {getStopButton(this) getPlayButton(this) getStepButton(this) ...
                getStopMenu(this) getPlayMenu(this) getStepMenu(this)};

            if nargin<2, ena=true; end
            if ena, s='on'; else s='off'; end
            for i=1:numel(h)
                set(h{i},'enable',s);
            end
        end

        % -----------------------------------------------------------------
        function updateAttributeReadouts(this)
            % Update status bar readouts with Simulink compile-time attributes

            % Status: 1:size, 2:rate, 3:num
            hFrame = this.StatusBar.findwidget('StdOpts','Frame');
            hFrame.Tooltip = getTimeStatusTooltip(this.Source);
            hFrame.Callback('');
        end
        
        % -----------------------------------------------------------------
        function updateSnapshotPlaybackMode(this)
            % Update options buttons/menus
            %   - snapshot, finder, and persistent/floating buttons

            % Set the snapshot button state
            if this.Source.SnapShotMode, s='on'; else s='off'; end
            set(getSnapshotButton(this), 'state', s);
            set(getSnapshotMenu(this), 'checked', s);
        end

        % -----------------------------------------------------------------
        function updateSimControls(this)
            % Update stop and all "step" buttons and menu enables/states
            % and status bar text

            % Update enable states of Simulink playback buttons/menus
            % and the status bar text readout
            %
            %   Stop, Play/Pause, Step Fwd
            %   Snapshot toggle updates as well

            % Update the Stop menu accelerator key.  ctrl-T switches
            % between Play and Stop to mirror the behavior of Simulink's
            % menu items.
            if this.Source.isStopped 
                accel=''; 
            else 
                accel='T'; 
            end 
            set(getStopMenu(this), 'accel', accel); 
            
            % Set Pause/Play icon as appropriate
            if this.Source.isRunning
                % show pause icon if we are running
                button_select = 2;
                mlabel  = '&Pause';
                accel = '';
            elseif this.Source.isStopped
                % show play icon
                button_select = 1;
                mlabel  = '&Start';
                accel = 'T';
            else
                % We are either paused or running in stepfwd mode.  We want
                % to show "continue" button in both cases.
                button_select = 3;
                mlabel  = '&Continue';
                accel = '';
            end
            set(getPlayButton(this), 'Selection', button_select);
            set(getPlayMenu(this), 'label', mlabel, 'accel', accel);

            % Enable stop controls if model is not stopped
            if this.Source.isStopped, s = 'off'; else s = 'on'; end
            set(getStopButton(this), 'enable', s);
            set(getStopMenu(this), 'enable', s);

            % Update status bar text for Simulink connection
            if this.Source.SnapShotMode
                str = 'Frozen';
            elseif this.Source.isDisconnected
                str = 'Disconnected';
            elseif this.Source.isStopped
                str = 'Ready';
            elseif this.Source.isPaused
                str = 'Paused';
            else
                str = 'Running';
            end
            % Set text into status region
            % Status: 1:size, 2:rate, 3:num
            this.StatusBar.WidgetHandle.Text = str;
        end

% -----------------------------------------------------------------
        % GET methods for the UIMgr path.
        function h = getPlayMenu(this)
            h = this.UIMgr.findwidget('Menus','Playback','SimMenus','SimControls','Play');
        end
        function h = getPlayButton(this)
            h = this.UIMgr.findwidget('Toolbars','Playback','SimButtons','SimControls','Play');
        end
        function h = getStopMenu(this)
            h = this.UIMgr.findwidget('Menus','Playback','SimMenus','SimControls','Stop');
        end
        function h = getStopButton(this)
            h = this.UIMgr.findwidget('Toolbars','Playback','SimButtons','SimControls','Stop');
        end
        function h = getStepMenu(this)
            h = this.UIMgr.findwidget('Menus','Playback','SimMenus','SimControls','StepFwd');
        end
        function h = getStepButton(this)
            h = this.UIMgr.findwidget('Toolbars','Playback','SimButtons','SimControls','StepFwd');
        end
        function h = getSnapshotMenu(this)
            h = this.UIMgr.findwidget('Menus','Playback','SimMenus','PlaybackModes','Snapshot');
        end
        function h = getSnapshotButton(this)
            h = this.UIMgr.findwidget('Toolbars','Playback','SimButtons','PlaybackModes','Snapshot');
        end
        function h = getHiliteMenu(this)
            h = this.UIMgr.findwidget('Menus','Playback','View','Hilite');
        end
        function h = getHiliteButton(this)
            h = this.UIMgr.findwidget('Toolbars','Playback','SimButtons','PlaybackModes','Hilite');
        end
    end
end

function setEnable( h, ena)
%Disable Enable or disable any control buttons/menus

if numel(h) == 0
    return;
end
if nargin<2, ena=true; end
if ena, s='on'; else s='off'; end
for i=1:numel(h)
    set(h{i},'enable',s);
end
end

% [EOF]

