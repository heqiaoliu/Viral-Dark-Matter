classdef (Hidden = true) ConfigureModelForPILBlock < handle
%CONFIGUREMODELFORPILBLOCK configures a model for PIL
%
%   CONFIGUREMODELFORPILBLOCK(settingsSource) creates an object to configure a
%   model for PIL.
%
%   Input arguments:
%
%   settingsSource  Model name or configuration set to configure.
%
%   Methods:
%
%   configure   Configures the settingsSource for PIL.
%
%   remove      Removes PIL configuration from settingsSource.
%
%   validate    Validates that settings in settingsSource are consistent with
%               those configured by the configure method.
%
%   Static methods:
%
%   getBasePILCheckboxWidget Returns a dynamic dialog widget for the PIL
%                            Checkbox.
% 
%   getBasePILActionWidget   Returns a dynamic dialog widget for the PIL
%                            action Combobox.
%
%   getBasePILGroup          Returns a dynamic dialog group for the PIL 
%                            settings.
%
%   Example:
%      c = rtw.pil.ConfigureModelForPILBlock('rtwdemo_fuelsys')
%      c.configure
%      c.validate
%      c.remove
%
%   Example:
%      widget = ...
%         rtw.pil.ConfigureModelForPILBlock.getBasePILCheckboxWidget('myProp', ...
%                                                                'baseTag', ...
%                                                                'callbackFun', ...
%                                                                true)
%                                                                           
%
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $

properties(SetAccess = 'protected')
    % config set property
    cs;
end

% public methods
methods    
    function this = ConfigureModelForPILBlock(settingsSource)
           % Class constructor
           %
           % check num args
           error(nargchk(1, 1, nargin, 'struct'));
           %
           this.cs = targets_getActiveConfigSet(settingsSource);           
    end
    
    function configure(this)
       %
       % clean up legacy use of TestInterface API if required (call from an
       % update method to upgrade to CodeInfo based PIL)
       %
       if strcmp(get_param(this.cs, 'GenerateTestInterfaces'), 'on')
          set_param(this.cs, 'GenerateTestInterfaces', 'off');
          %
          % Remove the CustomTestInterfaceFile TLC Option
          %
          origTLCOptions = get_param(this.cs, 'TLCOptions');
          % the TLC option to remove
          testInterfaceTLCOption = '-aCustomTestInterfaceFile="pil_gen_interface.tlc"';
          newTLCOptions = strrep(origTLCOptions, testInterfaceTLCOption, '');
          set_param(this.cs, 'TLCOptions', strtrim(newTLCOptions));
       end             
    end

    function remove(this)         %#ok<MANU>
    end    
end

% protected methods
methods (Access = 'protected')    
    function settings = getPropsToValidate(this) %#ok<MANU>
       settings = {'GenerateTestInterfaces'};
    end
    
    function targetName = getTargetName(this) %#ok<MANU>
       % default target name
       targetName = 'Target'; 
    end    
    
    function checkboxName = getCheckboxName(this)  %#ok<MANU>
       % default checkbox name
       checkboxName = 'Configure model to build PIL algorithm object code'; 
    end    
end

% protected sealed methods
methods (Access = 'protected', Sealed = true)
    function isERT = isERT(this)
        % determine if this is an ERT target
        ertTargetStr = get_param(this.cs, 'IsERTTarget');
        switch ertTargetStr
            case 'on'
                % ert
                isERT = true;
            case 'off'
                % grt
                isERT = false;
          otherwise
            rtw.pil.ProductInfo.error('pil', 'InvalidIsERTTarget', ertTargetStr);
        end
    end

    % attempt to set a parameter, but if it is disabled then ignore it
    function setPossiblyDisabledParam(this, param, value)
        %
        try
            set_param(this.cs, param, value);
        catch e
            % match appropriate error message, eg. "Changing property 'GenerateSampleERTMain' is
            % not allowed."
            if strcmp(e.identifier, 'Simulink:Engine:UDD_TEMPLATE_CANNOT_CHANGE_PROP')           
                % ok
            else
                rethrow(e);
            end
        end
    end
end

% public sealed methods
methods (Sealed = true)
    function validate(this)
        % check for correct content in the properties we're interested in
        propsToValidate = this.getPropsToValidate;

        % NOTE: cloning the config set and applying the PIL settings simplifies the
        % task of checking the properties by removing the need to repeat the logic
        % already handled by i_model_configure (e.g. TLCOptions, isERT,
        % updateAllSettings and knowing whether settings should be "on" or "off")

        % store a handle to the original configset
        csOrig = this.cs;
        % clone config set
        csCopy = csOrig.copy;
        try
            % apply "configure" to clone
            this.cs = csCopy;
            this.configure;
            % restore original
            this.cs = csOrig;
        catch e
            % restore original
            this.cs = csOrig;
            rethrow(e);
        end

        for i=1:length(propsToValidate)
            prop = propsToValidate{i};
            % get original property value
            propValue = get_param(csOrig, prop);
            % get potentially updated value
            propCopyValue = get_param(csCopy, prop);
            % compare using isequal to handle strings and logicals
            if ~isequal(propValue, propCopyValue)
              rtw.pil.ProductInfo.error('pil', 'InvalidPILConfigurationSetting', prop, this.getCheckboxName, this.getTargetName, this.getCheckboxName);
            end
        end
    end
end

end
