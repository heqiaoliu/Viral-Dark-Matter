classdef IMPlayScopeCfg < uiscopes.AbstractScopeCfg
    %IMPlayScopeCfg   Define the IMPlayScopeCfg class.
    %
    %    IMPlayScopeCfg methods:
    %        getConfigurationFile - Returns the configuration file name
    %        getAppName           - Returns the application name
    %        getHelpArgs          - Returns the help arguments for the key
    %        getHelpMenus         - Get the helpMenus.
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/11/16 22:24:54 $
    
    methods
        
        function obj = IMPlayScopeCfg(varargin)
            %IMPlayScopeCfg   Construct the IMPlayScopeCfg class.
            
            obj@uiscopes.AbstractScopeCfg(varargin{:});
            
        end
        
        function cfgFile = getConfigurationFile(~)
            %getConfigurationFile   Returns the configuration file name
            
            cfgFile = 'implay.cfg';
        end
        
        function appName = getAppName(~)
            %getAppName   Returns the application name
            
            appName = 'Movie Player';
        end
        
        function helpArgs = getHelpArgs(~, key)
            %getHelpArgs   Returns the help arguments for the key
            
            mapFileLocation = fullfile(docroot, 'toolbox', 'images', ...
                'images.map');
            
            if nargin < 2
                key = 'overall';
            end
            switch lower(key)
                case 'colormap'
                    helpArgs = {'helpview', mapFileLocation, ...
                        'implay_colormap_dialog'};
                case 'framerate'
                    helpArgs = {'helpview', mapFileLocation, ...
                        'implay_framerate_dialog'};
                case 'overall'
                    helpArgs = {'helpview', mapFileLocation, ...
                        'implay_anchor'};
                otherwise
                    helpArgs = {};
            end
        end
        
        function hMenu = getHelpMenus(~, ~)
            %getHelpMenus Get the helpMenus.
            
            mapFileLocation = fullfile(docroot, 'toolbox', 'images', ...
                'images.map');
            
            implayDoc = uimgr.uimenu('Movie Player', 'Movie Player &Help');
            implayDoc.Placement = -inf;
            implayDoc.WidgetProperties = {...
                'callback', @(varargin) helpview(mapFileLocation, ...
                'implay_anchor')};
            
            iptDoc = uimgr.uimenu('Image Processing Toolbox', ...
                '&Image Processing Toolbox Help');
            iptDoc.WidgetProperties = {...
                'callback', @(varargin) helpview(mapFileLocation, ...
                'ipt_roadmap_page')};
            
            demoDoc = uimgr.uimenu('Image Processing Toolbox Demos ', ...
                'Image Processing Toolbox &Demos');
            demoDoc.WidgetProperties = {...
                'callback', @(varargin) demo('toolbox','image processing')};
            
            % Want the "About" option separated, so we group everything
            % above into a menugroup and leave "About" as a singleton menu
            mAbout = uimgr.uimenu('About', ...
                '&About Image Processing Toolbox');
            mAbout.WidgetProperties = {...
                'callback', @(h,ed) aboutipt};
            
            hMenu = uimgr.uiinstaller({ ...
                implayDoc 'Base/Menus/Help/Application'; ...
                iptDoc    'Base/Menus/Help/Application'; ...
                demoDoc   'Base/Menus/Help/Demo'; ...
                mAbout    'Base/Menus/Help/About'});
        end
        
        function hiddenExts = getHiddenExtensions(~)
            hiddenExts = {'Tools:Plot Navigation', 'Visuals:Time Domain'};
        end
    end
end

% -------------------------------------------------------------------------
function aboutipt

w = warning('off', 'Images:imuitoolsgate:undocumentedFunction');
imuitoolsgate('iptabout');
warning(w);

end

% [EOF]
