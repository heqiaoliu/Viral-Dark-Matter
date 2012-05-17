classdef ConfigRegistry
%CONFIGREGISTRY sl_customization registration class for target connectivity
%
%   CONFIGREGISTRY is an sl_customization registration class for target
%   connectivity. You can use this class to create a custom target connectivity
%   configuration.  To do this, you must edit an sl_customization.m file and
%   write the code that defines your connectivity configuration; you must
%   register the new CONFIGREGISTRY object with a call to registerTargetInfo
%   inside the sl_customization.m file. A connectivity configuration must have a
%   unique name and be associated with a connectivity configuration class (a
%   subclass of RTW.CONNECTIVITY.CONFIG). Properties of the connectivity
%   configuration (e.g. SystemTargetFile) define the set of Simulink models that
%   it is compatible with.
%
%   See also RTW.CONNECTIVITY.CONFIG, RTWDEMO_CUSTOM_PIL


%
%   See also RTW.CONNECTIVITY.CONFIG

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

    % Note: ConfigRegistry does not inherit from handle; it is a value
    % class used to collect property values together. Copying the object
    % copies the property values (this behaviour is required by
    % RTW.TargetRegistry.addConnectivityConfig so that the same handle
    % object doesn't get registered twice)
    
    properties
        % Unique string name for this connectivity configuration.
        ConfigName = 'MyConfigName';
        
        % Full class name of the ConnectivityConfig (e.g.
        % rtw.pil.HostDemoConnectivityConfig) to register.
        %
        % A class is associated with a single connectivity configuration.
        ConfigClass = 'MyConfigClass';
               
        % Cell array of strings listing RTW System Target Files that support
        % this connectivity configuration
        %
        % An empty cell array matches any System Target File
        %
        % A model's "SystemTargetFile" Configuration Parameter will be
        % validated against this cell array to determine if this
        % connectivity configuration is valid for use.
        SystemTargetFile = {};
        
        % Cell array of strings listing RTW Template Makefiles that support
        % this connectivity configuration.
        %
        % An empty cell array matches any Template Makefile and
        % non-makefile based targets (GenerateMakefile: off)
        %
        % A model's "TemplateMakefile" Configuration Parameter will be
        % validated against this cell array to determine if this
        % connectivity configuration is valid for use.
        TemplateMakefile = {};
        
        % Cell array of strings listing RTW Hardware Device Types that
        % support this connectivity configuration.
        %
        % An empty cell array matches any Hardware Device Type
        %
        % A model's "TargetHWDeviceType" Configuration Parameter will be
        % validated against this cell array to determine if this
        % connectivity configuration is valid for use.
        TargetHWDeviceType = {};
    end
    
    properties (Hidden = true)        
        % Function handle that will be evaluated to determine if a model's
        % configuration set is compatible with this connectivity
        % configuration.
        %
        % The function handle should have the following signature:
        %
        % isConfigSetCompatible = HANDLE(configSet)
        %
        % configSet: Simulink.ConfigSet object, giving access
        %            to a model's configuration set.
        %
        % isConfigSetCompatible: logical value indicating whether this
        %                        connectivity configuration is compatible
        %                        with a model's configuration set.
        isConfigSetCompatibleFcn = [];
    end
    
    % property set method validation
    methods        
        function this = set.ConfigName(this, ConfigName)
            this.checkNonEmptyString('ConfigName', ConfigName);
            this.ConfigName = ConfigName;
        end
        
        function this = set.ConfigClass(this, ConfigClass)
            this.checkNonEmptyString('ConfigClass', ConfigClass);
            this.ConfigClass = ConfigClass;
        end
                
        function this = set.SystemTargetFile(this, SystemTargetFile)
            this.checkCellofStrings('SystemTargetFile', SystemTargetFile);
            this.SystemTargetFile = SystemTargetFile;
        end
        
        function this = set.TemplateMakefile(this, TemplateMakefile)
            this.checkCellofStrings('TemplateMakefile', TemplateMakefile);
            this.TemplateMakefile = TemplateMakefile;
        end
        
        function this = set.TargetHWDeviceType(this, TargetHWDeviceType)
            this.checkCellofStrings('TargetHWDeviceType', TargetHWDeviceType);
            this.TargetHWDeviceType = TargetHWDeviceType;
        end        
        
        function this = set.isConfigSetCompatibleFcn(this, isConfigSetCompatibleFcn)            
            propStr = 'isConfigSetCompatibleFcn';
            expectedType = 'a function handle with signature isConfigSetCompatible = HANDLE(configSet)"';            
            if ~isa(isConfigSetCompatibleFcn, 'function_handle')
                this.badProp(propStr, expectedType);                
            end
            this.isConfigSetCompatibleFcn = isConfigSetCompatibleFcn;
        end
    end
       
    methods (Access = 'private')
        function checkNonEmptyString(this, prop, propValue)
            expectedType = 'a non-empty string';
            if isempty(propValue)
                this.badProp(prop, expectedType);
            end
            if ~ischar(propValue)
                this.badProp(prop, expectedType);
            end
        end
        
        function checkCell(this, prop, propValue)
            expectedType = 'a cell array';
            % check we have an empty or non-empty cell array
            if ~iscell(propValue)
                this.badProp(prop, expectedType);
            end
        end
        
        function checkCellofStrings(this, prop, propValue)
            expectedType = 'an empty cell array or a cell array of strings';
            % check we have an empty or non-empty cell array
            if ~iscell(propValue)
                this.badProp(prop, expectedType);
            end
            % if non-empty, check elements are strings
            for i=1:length(propValue)
                propElement = propValue{i};
                if ~ischar(propElement)
                    this.badProp(prop, expectedType);
                end
            end
        end
        
        function badProp(this, prop, expectedType) %#ok<MANU>
            rtw.connectivity.ProductInfo.error('target', ...
                'ConfigRegistryPropertyError', ...
                prop, ...
                expectedType);           
        end
    end
end
