classdef AbstractPlaybackControls < handle
    %ABSTRACTPLAYBACKCONTROLS Abstract Playback controls class.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.14 $  $Date: 2010/05/20 03:07:41 $
    
    
    % Callbacks may need the Source property, so it must be publicGet.
    properties (Hidden, SetAccess = protected)
        Source    = []; % uiscopes.AbstractSource
        UIMgr     = []; % uimgr.uigroup
    end
    
    properties (Access=protected)
        Installed = false;
        PlugInGUI = []; % uimgr.uiinstaller
    end
    
    methods
        
        function this = AbstractPlaybackControls(hScope, hSource)
            % Initialize base PlaybackControls object
            
            this.Source = hSource;
            this.UIMgr  = hScope.getGUI;
        end
        
        % -----------------------------------------------------------------
        function pause(this)
            send(this.Source.Application, 'PauseEvent')
        end
        
        % -----------------------------------------------------------------
        function resetToStart(~)
            % NO OP, part of the source<->controls interface, called by
            % uiscopes.AbstractSource/activate.
        end
        
        % -----------------------------------------------------------------
        function install(this, vis)
            %INSTALL install plackback controls
            
            if nargin<2, vis=true; end
            
            hUIMgr = this.UIMgr;
            if vis
                % Add plug-in to GUI
                if ~this.Installed
                    hMenu    = hUIMgr.findwidget('Menus', 'Playback');
                    hToolbar = hUIMgr.findwidget('Menus', 'View', 'ViewBars', 'ShowPlaybackToolbar');
                    
                    label = getMenuLabel(this);
                    set(hMenu, 'Label', label);
                    set(hToolbar, 'Labels', {uiscopes.message('ShowToolbarMenuLabel', label)});
                    install(this.PlugInGUI, hUIMgr);
                    
                    renderWidgets(this);
                    
                    
                    this.Installed = true;
                end
            else
                % Remove plug-in from GUI
                if this.Installed
                    uninstall(this.PlugInGUI, hUIMgr);
                    this.Installed = false;
                end
            end
        end
        
        % -----------------------------------------------------------------
        function close(this)
            %CLOSE Cleanup playback object - generic base class implementation
            
            % Delete buttons/menus
            %
            install(this, false);
        end
        
        % -----------------------------------------------------------------
        function enable(~,~)
            %ENABLE Enable or disable playback control buttons and menus
            % implemented in derived classes
        end
        
        % -----------------------------------------------------------------
        function dataInfo = getDataInfo(~)
            dataInfo = {};
        end
    end
    
    methods (Access = protected)
        
        function label = getMenuLabel(~)
            label = uiscopes.message('PlaybackMenuLabel');
        end
        
        function renderWidgets(this)
            %render just the playback menu and toolbar
            hUIMgr = this.UIMgr;
            hToolbar = hUIMgr.findchild('Toolbars', 'Playback');
            hMenu = hUIMgr.findchild('Menus', 'Playback');
            render(hMenu);
            render(hToolbar);
        end
        
        function controlVis(this,vis)
            % Set visibility of all playback controls,
            % including buttons and menus
            
            % parameter s is string, vis is bool
            if ~ischar(vis) %HD
                if vis,s='on'; else s='off'; end
            else
                s = vis;
                if strcmp(s,'on'), vis=true;else vis =false; end
            end
            
            hPlayback = findchild(this.UIMgr, 'Menus', 'Playback');
            
            if isRendered(hPlayback)
                set(hPlayback.WidgetHandle, 'Label', getMenuLabel(this));
            end
            set(hPlayback, 'Visible', s);
            set(hPlayback, 'Enable', s);
            % To remove the playback keybinding, we cannot just set the
            % visible property to 'Off'. We actually have to remove the
            % group when the vis flag is false and then add it again when
            % the flag is true.
            playGrp = this.UIMgr.findchild('KeyMgr', 'Playback');
            
            % framerate is null if not installed
            frameRate = this.UIMgr.findchild('KeyMgr', 'Frame Rate');
            
            % Check if the Playback group has been installed.
            if ~isempty(playGrp)
                KeyMgr = this.UIMgr.findchild('KeyMgr');
                % If the Visible flag is true and the Playback group was
                % previously removed, add it back again, otherwise don't do
                % anything. We can't add the same group twice.
                if vis && strcmpi(playGrp.Visible,'off')
                    KeyMgr.WidgetHandle.addGroup(playGrp.hKeyGroup);
                    if ~isempty(frameRate)
                        KeyMgr.WidgetHandle.addGroup(frameRate.hKeyGroup);
                    end
                elseif ~vis
                    % If the visible flag is false, remove the group.
                    KeyMgr.WidgetHandle.removeGroup('Playback');
                    KeyMgr.WidgetHandle.removeGroup('Frame Rate');
                end
            end
            % Set the Visible property of the playback group to the 'vis' flag.
            % Use this value to figure out if we need to add the group back
            % or not.
            set(this.UIMgr.findchild('KeyMgr', 'Playback'), 'Visible', s);
            drawnow;
        end
    end
    
    methods (Abstract)
        stop(this, forPause)
    end
end

% [EOF]
