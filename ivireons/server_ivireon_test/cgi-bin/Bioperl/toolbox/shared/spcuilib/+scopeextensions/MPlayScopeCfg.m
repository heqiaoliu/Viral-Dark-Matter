classdef MPlayScopeCfg < uiscopes.AbstractScopeCfg
    %MPLAYSCOPECFG   Define the MPlayScopeCfg class.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/11/16 22:33:33 $
    
    methods
        
        function this = MPlayScopeCfg(varargin)
            %MPLAYSCOPECFG   Construct the MPlayScopeCfg class.
            
            this@uiscopes.AbstractScopeCfg(varargin{:});
        end
        
        % -----------------------------------------------------------------
        function appName = getAppName(~)
            appName = 'MPlay';
        end
        
        % -----------------------------------------------------------------
        function cfgFile = getConfigurationFile(~)
            cfgFile = 'mplay.cfg';
        end
        
        % -----------------------------------------------------------------
        function helpArgs = getHelpArgs(~, key)
            
            if nargin < 2
                helpArgs = {'mplay'};
            else
                
                mapFileLocation = fullfile('$DOCROOT$', 'toolbox', 'vipblks', 'vipblks.map');
                
                switch lower(key)
                    case 'colormap'
                        helpArgs = {'uiservices.helpview', mapFileLocation, 'mplay_colormap'};
                    case 'framerate'
                        helpArgs = {'uiservices.helpview', mapFileLocation, 'mplay_frame'};
                    case 'overall'
                        helpArgs = {'mplay'};
                    otherwise
                        helpArgs = {};
                end
            end
        end
        
        % -----------------------------------------------------------------
        function hiddenExts = getHiddenExtensions(~)
            hiddenExts = {'Tools:Plot Navigation', 'Visuals:Time Domain'};
        end
        
        % -----------------------------------------------------------------
        function helpMenus = getHelpMenus(~, ~)
            mapFileLocation = fullfile(docroot, 'toolbox', 'vipblks', 'vipblks.map');
            
            mMPlay = uimgr.uimenu('MPlay', 'MPlay &Help');
            mMPlay.Placement = -inf;
            mMPlay.WidgetProperties = {...
                'callback', @(hco,ev) helpview(mapFileLocation, 'mplay')};
            
            mVIPBlks = uimgr.uimenu('VIPBlks', '&Video and Image Processing Blockset Help');
            mVIPBlks.WidgetProperties = {...
                'callback', @(hco,ev) helpview(mapFileLocation, 'vipinfo')};
            
            mDemo = uimgr.uimenu('VIPBlks Demos', 'Video and Image Processing Blockset &Demos');
            mDemo.WidgetProperties = {...
                'callback', @(hco,ev) demo('blockset', 'video and image processing')};
            
            % Want the "About" option separated, so we group everything above
            % into a menugroup and leave "About" as a singleton menu
            mAbout = uimgr.uimenu('About', '&About Video and Image Processing Blockset');
            mAbout.WidgetProperties = {...
                'callback', @(hco,ev) aboutvipblks};
            
            helpMenus = uimgr.uiinstaller( { ...
                mMPlay 'Base/Menus/Help/Application'; ...
                mVIPBlks 'Base/Menus/Help/Application'; ...
                mDemo 'Base/Menus/Help/Demo'; ...
                mAbout 'Base/Menus/Help/About'});
            
        end
    end
end

% [EOF]
