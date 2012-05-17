classdef ScopeCfg < uiscopes.AbstractScopeCfg
    %SCOPECFG   Define the ScopeCfg class.
    
    %   Copyright 2008 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2008/11/18 02:13:35 $
    
    properties
        ConfigurationFile = '';
        AppName = 'Scope';
        HelpMenus = [];
        HiddenTypes = {};
    end
    
    properties (Hidden)
        HelpArgs = [];
    end
    
    methods
        
        function this = ScopeCfg(cfgFile, varargin)
            %SCOPECFG   Construct the ScopeCfg class.
            
            this@uiscopes.AbstractScopeCfg(varargin{:});
            if nargin > 0
                this.ConfigurationFile = cfgFile;
            end
        end
    end
    
    methods
        function addHelpArgs(this, key, value)
            %ADDHELPARGS Add help arguments.
            
            if ~iscell(value)
                value = {value};
            end
            
            helpArgs = this.HelpArgs;
            helpArgs.(genvarname(key)) = value;
            this.HelpArgs = helpArgs;
        end
                
        % -----------------------------------------------------------------
        function appName = getAppName(this)
            
            appName = this.AppName;
        end
        
        % -----------------------------------------------------------------
        function cfgFile = getConfigurationFile(this)
            
            cfgFile = this.ConfigurationFile;
        end
        
        % -----------------------------------------------------------------
        function helpArgs = getHelpArgs(this, key)
            
            if nargin < 2
                key = 'Overall';
            end
            
            helpArgs = this.HelpArgs;
            
            % Use the key to get a single field out of the help arguments.
            key = genvarname(key);
            if isfield(helpArgs, key)
                helpArgs = helpArgs.(key);
            elseif isfield(helpArgs, 'Overall')
                helpArgs = helpArgs.Overall;
            elseif ~ischar(helpArgs)
                helpArgs = '';
            end
        end
        
        % -----------------------------------------------------------------
        function helpMenus = getHelpMenus(this, hUI)
            
            if isempty(this.HelpMenus)
                helpMenus = [];
            else
                helpMenus = feval(this.HelpMenus, hUI);
            end
        end
        
        % -----------------------------------------------------------------
        function hiddenTypes = getHiddenTypes(this)
            hiddenTypes = this.HiddenTypes;
        end
        
        % -----------------------------------------------------------------
        function hCopy = copy(this)
            hCopy = copy@uiscopes.AbstractScopeCfg(this);
            
            hCopy.ConfigurationFile = this.ConfigurationFile;
            hCopy.AppName           = this.AppName;
            hCopy.HelpMenus         = this.HelpMenus;
            hCopy.HelpArgs          = this.HelpArgs;
            hCopy.HiddenTypes       = this.HiddenTypes;
            
        end
    end
    
    methods (Hidden)
        function s = saveobj(this)
            
            s = saveobj@uiscopes.AbstractScopeCfg(this);
            
            s.ConfigurationFile = this.ConfigurationFile;
            s.AppName           = this.AppName;
            s.HelpMenus         = this.HelpMenus;
            s.HelpArgs          = this.HelpArgs;
            s.HiddenTypes       = this.HiddenTypes;
        end
    end
    
    methods (Static, Hidden)
        function this = loadobj(s)
            
            if ~isfield(s, 'class')
                
                % If we do not have the 'class' field, we have an R2007b version of the
                % ScopeCfg.  Try to figure out which ScopeCfg to use based on the
                % HelpArgs.
                if ~isfield(s, 'HelpArgs') || isequal(s.HelpArgs, {'MPlay'})
                    s.class = 'scopeextensions.MPlayScopeCfg';
                elseif isequal(s.HelpArgs, {'implay'})
                    s.class = 'iptscopes.IMPlayScopeCfg';
                else
                    s.class = 'uiscopes.ScopeCfg';
                end
            end

            this = loadobj@uiscopes.AbstractScopeCfg(s);
            
            if ~isa(this, 'uiscopes.ScopeCfg')
                return;
            end
            
            this.ConfigurationFile = s.ConfigurationFile;
            this.AppName           = s.AppName;
            this.HelpMenus         = s.HelpMenus;
            this.HelpArgs          = s.HelpArgs;
            
            if isfield(s, 'HiddenTypes')
                this.HiddenTypes = s.HiddenTypes;
            end
        end
    end
    
    methods
        function set.HiddenTypes(this, hiddenTypes)
            sigdatatypes.checkStringVector(this, 'HiddenTypes', hiddenTypes);
            this.HiddenTypes = hiddenTypes;
        end
        function set.AppName(this, appName)
            sigdatatypes.checkString(this, 'AppName', appName);
            this.AppName = appName;
        end
        function set.ConfigurationFile(this, cfgFile)
            sigdatatypes.checkString(this, 'ConfigurationFile', cfgFile);
            this.ConfigurationFile = cfgFile;
        end
    end
end

% [EOF]
