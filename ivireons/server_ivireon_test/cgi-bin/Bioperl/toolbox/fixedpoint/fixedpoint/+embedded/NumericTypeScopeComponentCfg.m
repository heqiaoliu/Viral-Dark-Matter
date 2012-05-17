classdef NumericTypeScopeComponentCfg < scopeextensions.AbstractSystemObjectScopeCfg & ...
        embedded.NumericTypeScopeCfg
%NUMERICTYPESCOPECOMPONENTCFG Defines the configuration for the NumericType Scope

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $ Date:  $

    methods 
        function this = NumericTypeScopeComponentCfg(varargin)
            this@scopeextensions.AbstractSystemObjectScopeCfg(varargin{:});
        end
        
        function configFile = getConfigurationFile(~)
            configFile = 'NumericTypeScopeComponent.cfg';
        end
        
        function scopeTitle = getScopeTitle(this, hScope)
            scopeTitle = getScopeTitle@embedded.NumericTypeScopeCfg(this, hScope);
        end
        
        function serializable = isSerializable(this)
            serializable = isSerializable@scopeextensions.AbstractSystemObjectScopeCfg(this);
        end
        
        function hiddenTypes = getHiddenTypes(this)
            
            hiddenTypes = getHiddenTypes@embedded.NumericTypeScopeCfg(this);
        end
        
        function hiddenExtensions = getHiddenExtensions(this) %#ok
            hiddenExtensions = {'Core:Source UI'};
        end
        
        % Disable the progress bar.
        function showWaitbar = getShowWaitbar(~)
            showWaitbar = false;
        end

        function appName = getAppName(~)
            appName = 'NumericType Scope';
        end
    end
end

% [EOF]
