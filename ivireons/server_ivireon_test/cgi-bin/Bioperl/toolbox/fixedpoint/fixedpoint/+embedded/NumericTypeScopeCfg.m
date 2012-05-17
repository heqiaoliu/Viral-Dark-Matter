classdef NumericTypeScopeCfg < uiscopes.AbstractScopeCfg
%NUMERICTYPESCOPECFG Define the Configuration for the NumericType Scope

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $    $Date: 2010/03/31 18:20:22 $    

    properties (Hidden)
       scopeTitleString; 
    end
    methods
        function this = NumericTypeScopeCfg(varargin)
            this@uiscopes.AbstractScopeCfg(varargin{:});
         end
        
        function appName = getAppName(this) %#ok
            appName = 'NumericType Scope';
        end
        
        function cfgFile = getConfigurationFile(this) %#ok
            cfgFile = 'NumericTypeScope.cfg';
        end
        
        function helpArgs = getHelpArgs(this,key) %#ok
            helpArgs = [];
        end

        % Hide Sources, Visuals and Tools for now.
         function hiddenTypes = getHiddenTypes(this) %#ok
            hiddenTypes = {'Visuals','Sources','Tools'};
        end
        
        % Hide Sources, Visuals and Tools for now.
         function hiddenTypes = getHiddenExtensions(this) %#ok
            hiddenTypes = {'Sources:File', 'Sources:Simulink',...
                           'Tools:Image Navigation Tools',...
                           'Tools:Image Tool', 'Tools:Pixel Region',...
                           'Tools:Instrumentation Sets'};
         end
       
        function hidden = hideStatusBar(this) %#ok
           hidden = true;
        end
        
        % Get the title of the scope based on the configuration.
        function scopeTitle = getScopeTitle(this, hScope)
            scopeTitle = getScopeTitleString(this);
            if isempty(scopeTitle)
                scopeTitle = getAppName(hScope);
                if ~isempty(hScope.DataSource)
                    scopeTitle = sprintf('%s - %s', scopeTitle, ...
                        getSourceName(hScope.DataSource));
                end
                
            end
        end
        
        function helpMenus = getHelpMenus(this,hUI) %#ok
            mapFileLocation = fullfile(docroot, 'toolbox', 'fixedpoint' , 'fixedpoint.map');

            mHistScope = uimgr.uimenu('NumericType Scope', ...
                                      '&NumericType Scope Help');
            mHistScope.Placement = -inf;
            mHistScope.WidgetProperties = {...
                'callback', @(hco,ev) helpview(mapFileLocation, 'NumericTypeScope')};
            
            mFixedPointHelp = uimgr.uimenu('Fixed-Point Toolbox', '&Fixed-Point Toolbox Help');
            mFixedPointHelp.WidgetProperties = {...
                'callback', @(hco,ev) helpview(mapFileLocation, 'fixedpoint_roadmap')};
            
            mFixedPointDemo = uimgr.uimenu('Fixed-Point Toolbox Demos',...
                                           'Fixed-Point Toolbox &Demos');
            mFixedPointDemo.WidgetProperties = {...
                'callback', @(hco,ev) demo('toolbox','fixed-point')};
            
            % Want the "About" option separated, so we group everything above
            % into a menu group and leave "About" as a singleton menu
            mAbout = uimgr.uimenu('About', '&About Fixed-Point Toolbox');
            mAbout.WidgetProperties = {...
                'callback', @(hco,ev) aboutfixedpttlbx};
            
            helpMenus = uimgr.uiinstaller( { ...
                mHistScope 'Base/Menus/Help/Application'; ...
                mFixedPointHelp 'Base/Menus/Help/Application'; ...
                mFixedPointDemo 'Base/Menus/Help/Demo'; ...
                mAbout 'Base/Menus/Help/About'});
        end
                
    end
    
    methods (Hidden)
        function setScopeTitleString(this, val)
            if ischar(val)
                this.scopeTitleString = val;
            end
        end
        
        function scopeTitle = getScopeTitleString(this)
            scopeTitle = this.scopeTitleString;
        end
    end
    
end

