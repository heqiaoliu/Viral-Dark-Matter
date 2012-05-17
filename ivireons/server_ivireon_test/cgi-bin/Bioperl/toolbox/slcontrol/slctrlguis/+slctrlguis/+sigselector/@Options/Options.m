classdef Options
    %
    
	% Class definition for @Options - the object that
	% defines the behavior scheme (options) for a selected signal viewer
	% component
    %
    % mode = Simulink.selsigview.Options(param1,val1) creates the mode
    % with manually specified parameter values.
    %
    % Available parameters for selected signal viewer(ssv) mode are:
    %      'InteractiveSelection', whether selected signal viewer updates
    %  upon new signal selections made in the model or works offline with
    %  predefined set of signals (true/false).
    %      'BusSupport', the way selected signal viewer handles bus signals
    %  ('none','wholeonly','elementonly','all').
    %      'MdlrefSupport', the way selected signal viewer handles model
    %  references ('none','normalonly','all').
    %      'SfSupport', whether selected signal viewer updates upon
    %  selections made in stateflow charts (true/false).
    %      'ViewType', the type of front-end view of selected signal viewer
    %  component ('DDG' or 'Java').
    %      'RootName', the string to display as the root node in selected
    %  signal viewer component.
    %      'Model', the name of the root Simulink model that selected
    %  signal viewer component will operate on.
    %      'FilterVisible', visibility of the filtering toolbar
    %  (true/false)
    %      'AutoSelect', automatically select new added signals upon
    %      clicking on the model (true/false)
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:54:10 $
    
    properties
        ViewType = 'DDG';
        RootName = DAStudio.message('Slcontrol:sigselector:OptionsCurrentlySelectedSignals');
        TreeMultipleSelection = true;
        InteractiveSelection = false;
        BusSupport = 'all';
        MdlrefSupport = 'none';
        SfSupport = false;                
        Model = '';
        HideBusRoot = false;
        FilterVisible = true;
        AutoSelect = false;
    end
    
    methods
        %% Constructor
        function obj = Options(varargin)
            for ct = 1:length(varargin)/2
                try
                    obj.(varargin{2*ct-1}) = varargin{2*ct};
                catch Me
                    if strcmp(Me.identifier,'MATLAB:noPublicFieldForClass')
                        % Invalid parameter specified
                        DAStudio.error('Slcontrol:sigselector:OptionsInvalidParam',varargin{2*ct-1});
                    else
                        rethrow(Me);
                    end                    
                end
            end
        end
        %% Set methods for properties
        function obj = set.InteractiveSelection(obj,val)
            if islogical(val)
                obj.InteractiveSelection = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidInteractiveSelection');
            end
        end
        function obj = set.FilterVisible(obj,val)
            if islogical(val)
                obj.FilterVisible = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidFilterVisible');
            end
        end
        function obj = set.AutoSelect(obj,val)
            if islogical(val)
                obj.AutoSelect = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidAutoSelect');
            end
        end
        function obj = set.TreeMultipleSelection(obj,val)
            if islogical(val)
                obj.TreeMultipleSelection = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidTreeMultipleSelection');
            end
        end
        function obj = set.HideBusRoot(obj,val)
            if islogical(val)
                obj.HideBusRoot = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidHideBusRoot');
            end
        end
        function obj = set.BusSupport(obj,val)
            if any(strcmp(val,{'none','wholeonly','elementonly','all'}))
                obj.BusSupport = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidBusSupport');
            end
        end
        function obj = set.MdlrefSupport(obj,val)
            if any(strcmp(val,{'none','normalonly','all'}))
                obj.MdlrefSupport = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidMdlrefSupport');
            end            
        end
        function obj = set.SfSupport(obj,val)
            if islogical(val)
                obj.SfSupport = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidSfSupport');
            end
        end
        function obj = set.RootName(obj,val)
            if ischar(val)
                obj.RootName = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidRootName');
            end
        end
        function obj = set.ViewType(obj,val)
            if any(strcmp(val,{'Java','DDG'}))
                obj.ViewType = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidViewType');                
            end
        end
        function obj = set.Model(obj,val)
            if ischar(val)
                obj.Model = val;
            else
                DAStudio.error('Slcontrol:sigselector:OptionsInvalidModel');
            end
        end
    end
    
end

