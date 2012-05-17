classdef PlaybackControlsMLStreaming < uiscopes.AbstractPlaybackControls
    %PLAYBACKCONTROLSMLSTREAMING Define the playback controls for the
    % streaming MATLAB source

    % Copyright 2007-2010 The MathWorks, Inc.
    % $Revision: 1.1.6.9 $ $Date: 2010/03/31 18:40:45 $

    properties
        StatusBar = [];
        Snapshot  = false;
        StateStop = true;
    end

    methods
        function this = PlaybackControlsMLStreaming(hApp,srcObj)
            %PLAYBACKCONTROLSMLSTREAMING Constructor for playback controls for
            %SrcMLStreaming

            this@uiscopes.AbstractPlaybackControls(hApp, srcObj);

            % Cache UI plug-in's (don't add/render, just build/cache)
            % Create base UI buttons, menus, statusbar, etc
            createGUI(this);
        end

        % -----------------------------------------------------------------
        function close(this)
            %CLOSE Cleanup playback object

            % Deletes timer object
            disconnectData(this.Source);

            % Delete buttons/menus, if needed
            %  (done automatically when GUI closes)
            install(this, false);
        end

        % -----------------------------------------------------------------
        function stop(this, ~)
            %STOP MLStreaming control stop

            % If the user closes the window while simulation is running we need to
            % disconnect the data and clear the data handler
            if ~isempty(this.Source.DataHandler)
                disconnectData(this.Source);
            end
            send(this.Source.Application,'StopEvent');  % Must send event
        end
        
        % -----------------------------------------------------------------
        function update(this)
            %UPDATE  Update MATLAB Streaming viewer specific playback controls

            if this.Source.DataSpecsLocked
                % set state to play
                this.StateStop = false;
            else
                % set state to stopped
                this.StateStop = true;
            end
            
            hUI = this.UIMgr;
            
            % if the toolbar simbuttons exist, enable them.
            hToolbar = hUI.findchild( {'Toolbars','Playback','SimButtons'});
            %if the simcontrols menu exist, enable them
            hMenu = hUI.findchild( {'Menus','Playback','SimControls'});
            
            if ~isempty(hToolbar) % Playback Toolbar and Menu are present
                % Enable playback toolbar
                hToolbar.Enable = 'on'; 
                
                % Find the snapshot toolbar and menu items
                hSnapshotToolbar = hToolbar.findchild('Snapshot');
                hSnapshotMenu = hMenu.findchild('Snapshot'); 
                
                if this.StateStop
                    hSnapshotToolbar.Enable = 'off';
                    hSnapshotMenu.Enable = 'off';
                else
                    hSnapshotToolbar.Enable = 'on';
                    hSnapshotMenu.Enable = 'on';
                end
            end
            
            hStatusBar = hUI.findwidget('StatusBar');
            %hStatusBar.Txt = '';
            if this.StateStop
              hStatusBar.Text = 'Stopped';
            else
              hStatusBar.Text = 'Processing';
            end
        end
        
        % -----------------------------------------------------------------
        function createGUI(this)
        %CREATEGUI Create the PlaybackControlsMLStreaming GUI.
        %Build and cache GUI menus and buttons for MATLAB streaming
        %source.
            plan = {};
            if this.Source.getPropValue('ShowSnapShotButton')
                [hMenus, hButtons] = createSimControls(this);
                % hKeyPlayback = createKeyBinding(this);
                
                % Create plug-in installer
                plan = {hMenus,'Base/Menus/Playback';
                        hButtons,'Base/Toolbars/Playback'};
            end
            this.PlugInGUI = uimgr.uiinstaller(plan);
            
            % set state to stop
            this.StateStop = true;
        end
        
        % -----------------------------------------------------------------
        function dataInfo = getDataInfo(this) %#ok<MANU>
%             data = this.Source.data;

            dataInfo = [];
%             dataInfo.Widgets = {'Source rate', sprintf('%g fps', data.FrameRate)};
        end
     end

    methods (Access = protected)

        function [hMenus,hButtons] = createSimControls(this)
            % Controls for seamplay simulator controls
                % menus
                m1 = uimgr.uimenu('Snapshot', '&Snapshot (Freeze display)');
                m1.WidgetProperties = {...
                    'BusyAction', 'cancel', ...
                    'callback',@(hco,ev) lclSetSnapshotMode(this)};
                hMenus = uimgr.uimenugroup('SimControls',m1);
                
                % buttons
                b1 = uimgr.spctoggletool('Snapshot'); %placement?
                b1.IconAppData = {'snapshot'};
                b1.WidgetProperties = {...
                    'state', 'off', ...
                    'tooltip', {'Snapshot (Freeze display)'}, ...
                    'click',@(hco,ev) lclSetSnapshotMode(this)};
                hButtons = uimgr.uibuttongroup('SimButtons',b1);

             %-------------------------------------------------------------------------
            function lclSetSnapshotMode(this)
                
                oldSnapshotMode = this.Snapshot;
                this.Snapshot = ~oldSnapshotMode;
                
                if oldSnapshotMode
                    s = 'off';
                    updateVisual(this.Source);
                else
                    s = 'on';
                end
                
                hUI = this.UIMgr;
                set(hUI.findwidget('Toolbars','Playback','SimButtons','Snapshot'), ...
                    'state', s);
                set(hUI.findwidget('Menus','Playback','SimControls','Snapshot'), ...
                    'checked', s);
                
                updateTimeStatus(this.Source);
            end
        end
        %-------------------------------------------------------------------------

%         function hKeyPlayback = createKeyBinding(this)
% 
%             hKeyPlayback = uimgr.spckeygroup('Playback');
%             hKeyPlayback.add(...
%                 uimgr.spckeybinding('Snapshot',{'P', 'Space'},...
%                 @(h,ev)slPlayPause(this), 'Play/pause video'));
%         end
    end
end

% [EOF]

% LocalWords:  UI in's statusbar simbuttons simcontrols CREATEGUI seamplay
% LocalWords:  uimgr ev
