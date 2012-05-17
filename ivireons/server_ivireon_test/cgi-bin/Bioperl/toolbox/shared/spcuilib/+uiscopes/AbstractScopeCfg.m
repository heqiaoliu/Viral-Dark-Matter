classdef AbstractScopeCfg < HeterogeneousHandle
    %ABSTRACTSCOPECFG   Define the AbstractScopeCfg class.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.7 $  $Date: 2010/03/31 18:40:56 $
    
    properties (SetObservable)
        CurrentConfiguration = [];
        ScopeCLI = [];
        Position = uiscopes.getDefaultPosition;
        WindowStyle = 'undocked';
    end
    
    methods
        
        function this = AbstractScopeCfg(arguments, argumentNames)
            %ABSTRACTSCOPECFG   Construct the AbstractScopeCfg class.
            
            if nargin < 1
                arguments = {};
            end
            if nargin < 2
                argumentNames = {};
            end
            
            createScopeCLI(this, arguments, argumentNames);
        end

        % -----------------------------------------------------------------
        function dialogTitle = getDialogTitle(this)
            %getDialogTitle Returns the name used as the prefix for the dialogs.
            dialogTitle = getAppName(this);
        end
        
        % -----------------------------------------------------------------
        function hUI = createGUI(this, hScope)
            hUI = getHelpMenus(this, getGUI(hScope));
        end

        % -----------------------------------------------------------------
        function show = getInstanceNumberTitle(~)
            show = true;
        end

        % -----------------------------------------------------------------
        function show = getShowWaitbar(~)
            show = true;
        end

        % -----------------------------------------------------------------
        function scopeTitle = getScopeTitle(~, hScope)
            %getScopeTitle Returns the full string for the title of the scope.
            
            scopeTitle = getAppName(hScope);
            
            if ~isempty(hScope.DataSource)
                scopeTitle = sprintf('%s - %s', scopeTitle, ...
                    getSourceName(hScope.DataSource));
            end
        end
        
        % -----------------------------------------------------------------
        function hiddenTypes = getHiddenTypes(~)
            hiddenTypes = {};
        end
        
        % -----------------------------------------------------------------
        function hiddenExts = getHiddenExtensions(~)
            hiddenExts = {};
        end

        % -----------------------------------------------------------------
        function helpMenus = getHelpMenus(~, ~)
            helpMenus = [];
        end
        
        % -----------------------------------------------------------------
        function b = isDocked(this)
            b = strcmp(this.WindowStyle, 'docked');
        end
        
        % -----------------------------------------------------------------
        function crFcn = getCloseRequestFcn(~, hScope)
            crFcn = @(h, ev) close(hScope);
        end
        
        % -----------------------------------------------------------------
        function hCopy = copy(this)
            hCopy             = feval(class(this));
            hCopy.ScopeCLI    = copy(this.ScopeCLI);
            hCopy.Position    = this.Position;
            hCopy.WindowStyle = this.WindowStyle;
            
            if ~isempty(this.CurrentConfiguration)
                hCopy.CurrentConfiguration = copy(this.CurrentConfiguration, 'children');
            end
        end
        
        % -----------------------------------------------------------------
        function b = isVisibleAtLaunch(~)
            b = true;
        end
        
        % -----------------------------------------------------------------
        function b = isSerializable(~)
            b = true;
        end
    end
    
    methods (Hidden)
        
        function varargout = createScopeCLI(this, varargin)
            hCLI = uiscopes.ScopeCLI(varargin{:});
            if nargout
                varargout = {hCLI};
            else
                this.ScopeCLI = hCLI;
            end
        end
        
        function s = saveobj(this)
            s.class                = class(this);
            s.CurrentConfiguration = this.CurrentConfiguration;
            s.ScopeCLI             = this.ScopeCLI;
            s.Position             = this.Position;
            s.WindowStyle          = this.WindowStyle;
        end
        
        function b = hideStatusBar(~)
            %hideStatusBar - Returns true when we should hide the statusbar
            b = false;
        end
    end
    
    methods (Static, Sealed)
        
        function obj = getDefaultObject
            obj = uiscopes.AbstractScopeCfg.getDefaultScalarElement;
        end
    end
    
    methods (Access = protected, Static, Sealed)
        
        function obj = getDefaultScalarElement
            obj = uiscopes.ScopeCfg;
        end
    end
    
    methods (Static, Hidden)
        
        function this = loadobj(s)
            
            this = feval(s.class);
            
            hCCfg = s.CurrentConfiguration;
            if ~isempty(hCCfg)
                hCCfg = copy(hCCfg, 'children');
            end
            this.CurrentConfiguration = hCCfg;
            this.ScopeCLI             = s.ScopeCLI;
            this.Position             = s.Position;
            this.WindowStyle          = s.WindowStyle;
        end
    end
    
    methods
%         function set.CurrentConfiguration(this, config)
%             sigdatatypes.checkIsA(this, 'CurrentConfiguration', ...
%                 config, 'extmgr.ConfigDb');
%             
%             this.CurrentConfiguration = config;
%         end
%         
%         function set.ScopeCLI(this, hScopeCLI)
%             sigdatatypes.checkIsA(this, 'ScopeCLI', hScopeCLI, 'uiscopes.ScopeCLI');
%             
%             this.ScopeCLI = hScopeCLI;
%         end
        
        function set.Position(this, position)
            sigdatatypes.checkFiniteRealDblMat(this, 'Position', position, [1 4]);
            
            this.Position = position;
        end
        
        function set.WindowStyle(this, wStyle)
            this.WindowStyle = sigdatatypes.checkEnum(this, ...
                'WindowStyle', wStyle, {'docked', 'undocked'});
        end
    end
    
    methods (Abstract)
        appName     = getAppName(this)
        cfgFile     = getConfigurationFile(this)
        helpArgs    = getHelpArgs(this, token)
    end
end

% [EOF]
