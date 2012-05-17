%rtw.pil.Config
%
% Syntax: 
%   rtw.pil.Config( model Name, optional args)
%
% Description:
%   Creates a handle to a Config object that allows a model and all referenced 
%   models to be tested for PIL compatibility. This object runs in one of three 
%   modes: default, SaveModel or ReportOnly. In default mode, the object executes 
%   set_param commands for parameters which need to change, but the object 
%   does not save the model.  In SaveModel, the object saves any model it 
%   changes.  In ReportOnly, the object lists the changes, and no changes are 
%   made to the model.
%   Note: The configuration set or the model might still need modifications to execute
%   successfully in the target environment.
% 
% Parameters:
%   Model Name - top model
%   optional args: - optional comma separated parameter and value pairs that modify the
%   operation of the Config object.
%       Default values are listed in parentheses.  Valid pairs are:
%       o 'ComponentType': ('topmodel') | 'modelblock'
%       o 'SaveModel': ('off') | 'on' 
%       o 'ReportOnly': ('off') | 'on' 
%
% Methods
%   configModel() and configModelForSIL(): Update the configuration set.
%   getReportData(): Compares the original and updated configuration sets. 
%       Returns an array of strings with the model name, parameter, previous 
%       parameter value, and recommended or new parameter value.
%   displayReport(): Prints the results of getReportData() to the Command Window.
% 
% Example:
%   c = cgv.Config('vdp', 'componentType', 'modelblock');
%   c.configModel();
%   c.displayReport
%   bdclose vdp
%

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $

classdef Config < handle
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        TopModel;
        ComponentType = 'topmodel';  % Default
        SaveModel = false;
        ReportOnly = false;
%       N by 4 Table with the columns: ModelName, Parameter, From, To
        Changes = {};
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        AllMdls;    % Initialized in the constructor
        CurrentModelChanged;
        CsOrig;
        CsModified;        
    end
    
    properties(GetAccess = 'private', SetAccess = 'private')
        CsSILEmulationHWSettings;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function this = Config(TopModel, varargin)
            % Class constructor
            %
            error(nargchk(1, 7, nargin, 'struct'));
            error(nargoutchk(1, 1, nargout, 'struct'));

            validParams = { {'ComponentType', {'modelblock', 'topmodel'}}, ...
                {'SaveModel', {'on', 'off'}}, ...
                {'ReportOnly', {'on', 'off'}}};
            args = cgv.Config.checkArgs( 2, 'rtw.pil.Config', validParams, varargin);

            this.TopModel = TopModel;
            if isfield( args, 'componenttype')
                this.ComponentType = lower(args.componenttype);
            end
            if isfield( args, 'reportonly')
                this.ReportOnly = strcmp( args.reportonly, 'on');
            end
            if isfield( args, 'savemodel')
                this.SaveModel = strcmp( args.savemodel, 'on');
            end

            if this.SaveModel && this.ReportOnly
                DAStudio.error( 'RTW:cgv:SaveAndReportOnly');
            end                        
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function configModel(this)
            error(nargchk(1, 1, nargin, 'struct'));
            % The contents of this function is offloaded to configModelBasic because it needs to
            % be called from derived objects.  If a derived object tries to call
            % configModel, the derived object's configModel is called.  There is no M
            % syntax to call directly to here from a derived object that also has a 
            % configModel method.
            this.configModelBasic();
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This is intentionally hierarchical.  You can call configModel without configModelForSIL,
        % but you if you call configModelForSIL, it will call configModel.  So we call
        % configModel first, but there is no message.
        function configModelForSIL(this)
            error(nargchk(1, 1, nargin, 'struct'));
            this.reset();
            this.initializeSILEmulationHWSettings;
            this.configLoop( @configSingleModelForSIL);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function displayReport(this)
            msg = this.getReportData();
            for i = 1:length(msg)
                disp(msg{i});
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function report = getReportData(this)
            % If not empty, then createReport has been called.
            if isempty( this.Changes)
                this.createReport( );
            end
            % from matlab/toolbox/rtw/rtw/messages/cgv/en/xlate:
            if this.SaveModel
                % "For Model %s, setting configset parameter '%s': from '%s' to '%s'."
                lookup = 'RTW:cgv:SettingConfigSetMsg';
            else
                % "For Model %s, Configset parameter %s: the actual model Configset value is:
                % %s and it should be: %s."
                lookup = 'RTW:cgv:SuggestConfigSetMsg';
            end
            report = {};
            for i=1:length(this.Changes)
                currEntry = this.Changes{i};
                msg = DAStudio.message( lookup, ...
                    currEntry{1}, ...
                    currEntry{2}, ...
                    currEntry{3}, ...
                    currEntry{4});
                report{end + 1} = msg; %#ok<AGROW>
            end
        end                
        
    end     % Public Methods

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % protected methods    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = 'protected')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function reset(this)
            this.AllMdls = find_mdlrefs(this.TopModel, true);
            this.Changes = {};
            this.CsOrig = {};
            this.CsModified = {};                                 
        end

        function configPilSilToAccel(this)
            % First look for models configured as PIL
            status = this.verifyLoaded(this.TopModel);
            mode = get_param( this.TopModel, 'SimulationMode');
            if strcmpi(mode, 'processor-in-the-loop (pil)') || ...
                    strcmpi(mode, 'software-in-the-loop (sil)')
                set_param( this.TopModel, 'SimulationMode', 'normal');
                this.CurrentModelChanged = true;
            end
            % Look for model reference blocks configured as PIL
            pilBlocks = find_system(this.TopModel,'SearchDepth',1,'BlockType','ModelReference');
            if ~isempty(pilBlocks)
                for i = 1:length(pilBlocks)
                    mode = get_param( char(pilBlocks(i)), 'SimulationMode');
                    if strcmpi(mode, 'processor-in-the-loop (pil)') || ...
                            strcmpi(mode, 'software-in-the-loop (sil)')
                        set_param( char(pilBlocks(i)), 'SimulationMode', 'accelerator');
                        this.CurrentModelChanged = true;
                    end
                end
            end
            this.restoreLoaded( this.TopModel, status);
        end

        function createReport(this)
            this.Changes = {};
            for k = 1:length(this.AllMdls)
                thisModel = this.AllMdls{k};
                addToReport( this, thisModel, this.CsOrig{k}, this.CsModified{k})
            end
        end
        function addToReport(this, thisModel, CsOrig, cs)
            [isEqual diffs] = cs.isContentEqual(CsOrig);
            if ~isEqual
                this.CurrentModelChanged = 1;
                for i = 1:length(diffs)
                    param = char(diffs(i));
                    try
                        paramIs = get_param( CsOrig, param);
                    catch ME %#ok<NASGU>
                        paramIs = 'undefined';
                    end
                    try
                        to = get_param( cs, param);
                    catch ME %#ok<NASGU>
                        to = 'deleted';
                    end
                    % Some new parameter is returning a cell array.  Ignore it.
                    if iscell(to)
                        to = 'iscell array';
                    elseif ishandle(to) % ishandle sometimes returns an array.
                        to = 'is handle';
                    elseif isstruct(to)
                        % so we don't lose this, make note that it changed.  If we need
                        % more detail, this will need to be upgraded.
                        to = 'struct';
                    elseif isnumeric(to) || islogical( to)
                        to = sprintf( '%d', to);
                    end
                    if isnumeric(paramIs) || islogical( paramIs)
                        paramIs = sprintf( '%d', paramIs);
                    elseif isstruct( paramIs)
                        paramIs = 'struct';
                    end
                    this.Changes{end+1} = {thisModel, param, paramIs, to};
                    this.CurrentModelChanged = true;
                end            
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function configLoop(this, LoopFcn)

            for k = 1:length(this.AllMdls)
                thisModel = this.AllMdls{k};
                status = this.verifyLoaded(thisModel);
                cs = getActiveConfigSet(thisModel);
                % config set references are not allowed
                if isa(cs, 'Simulink.ConfigSetRef')
                    if this.ReportOnly == false
                        DAStudio.Error('RTW:cgv:ConfigSetRef');
                    end
                end
                if length(this.CsOrig) < k
                    this.CsOrig{end + 1} = cs.copy();
                    this.CsModified{end + 1} = cs.copy();
                end
                if this.ReportOnly
                    LoopFcn( this, thisModel, this.CsModified{k});
                else
                    LoopFcn( this, thisModel, cs);
                    this.CsModified{k} = cs.copy();
                end
                this.restoreLoaded( thisModel, status);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Paired functions verifyLoaded and restoreLoaded will get and restore the status
        % of the model.
        function status = verifyLoaded( this, ModelName)
            % Return one of the two possibilities for the model:
            % 'loaded' - model WAS loaded 
            % 'notloaded' - model was NOT loaded, so load it here
            try
                % attempt to access a well-known field.  If the model is not loaded, it will throw
                get_param( ModelName,'dirty');
                % The model was loaded.  Return the dirty status
                status = 'loaded';
            catch ME %#ok<NASGU>
                % Must not have been loaded
                try     % This is in case the ModelName is not valid
                    load_system( ModelName);
                catch ME2
                    % We can't deal with an invalid tree...
                    DAStudio.error( 'RTW:cgv:CantFindModel', ModelName);
                end
                status = 'notloaded';
            end
            this.CurrentModelChanged = false;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function restoreLoaded(this, ModelName, status)
        % This can be analyzed by [loadedState, mode] or [mode, loadedState]
        %
        % [mode by loadedState] - this is the implementation below
        % In report mode: if the model was loaded, leave it.  Otherwise close it.
        % In SaveModel mode: if the model was changed, save it.  If it was not loaded, close it.
        % In default mode: if the model was not loaded and was not changed, close it

        % [loadedState by mode] - not implemented this way, but these comments are included here for clarity
        % If the model was loaded
        %       In SaveModel mode, if it was changed, save it
        %       In ReportOnly mode, leave it
        %       In default mode, leave it (might be updated, might not)
        % If the model was NOT loaded
        %       In SaveModel mode, if it was changed, save it, otherwise close it
        %       In ReportOnly mode, close it
        %       In default mode, if it was changed, leave it otherwise close it


            if this.ReportOnly
                if strcmp( status, 'notloaded') % It was NOT loaded.
                    close_system( ModelName, 0);
                end
            elseif this.SaveModel
                if this.CurrentModelChanged
                    if strcmp( status, 'notloaded') % It was NOT loaded.
                        close_system( ModelName, 1);
                    else
                        save_system( ModelName);
                    end
                else
                    if strcmp( status, 'notloaded') % It was NOT loaded.
                        close_system( ModelName, 0);
                    end
                end
            else
                % Default mode
                if ~this.CurrentModelChanged && strcmp( status, 'notloaded') % It was NOT changed or loaded.
                    close_system( ModelName, 0);
                end                
            end
        end                            
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function applyParam(this, cs, param, to)
            % apply the new param value to the config set if it's not
            % already set and flag that the model has been changed
            try
                paramIs = get_param( cs, param);
            catch ME %#ok<NASGU>
                % This parameter is not known by this model.
                % File a geck to figure out why this happens.
                paramIs = '';
            end
            if ~isequal( paramIs, to)
                % Set this so restoreLoaded in SaveModel mode knows it should save
                this.CurrentModelChanged = true;
                try
                    set_param( cs, param, to);
                catch ME
                    msg = DAStudio.message( 'RTW:cgv:SetParamError', param);
                    localE = MException('RTW:pil:Config:SetParamError', msg);
                    ME = addCause(localE, ME);
                    throw(ME);
                end
            end
        end       
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        configSingleModel( this, thisModel, cs, ComponentType);
        configSingleModelForSIL( this, thisModel, cs, ComponentType);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function configModelBasic( this)
            this.reset();
            this.configLoop( @configSingleModel);
        end
    end
    
    methods (Access = 'private')
        function initializeSILEmulationHWSettings(this)
            % define emulation hardware SIL workflow settings
            %
            % CsSILEmulationHWSettings will be applied throughout the model
            % hierarchy
            %
            % use production settings from the TopModel
            status = this.verifyLoaded(this.TopModel);
            csTmp = getActiveConfigSet(this.TopModel);
            csTmp = csTmp.copy;
            this.restoreLoaded(this.TopModel, status);            
            % configure host emulation settings
            set_param(csTmp, 'TargetHWDeviceType', 'Generic->MATLAB Host Computer');
            % TargetIntDivRoundTo is not set by default: g624495
            properties = rtw_host_implementation_props();
            set_param(csTmp, 'TargetIntDivRoundTo', properties.IntDivRoundTo);
            this.CsSILEmulationHWSettings = csTmp;
        end
                
        function applySILEmulationHardwareSettings(this, cs)
            % configure emulation hardware SIL workflow
            %
            % emulation hardware and portable word sizes are mutually
            % exclusive
            this.applyParam(cs, 'PortableWordSizes', 'off');
            % apply "Target" (emulation hardware) settings
            prefix = 'Target';
            this.applyHardwareImplementationSettings(this.CsSILEmulationHWSettings, ...
                prefix, ...
                cs);            
            % apply "Prod" (embedded hardware) settings
            prefix = 'Prod';
            this.applyHardwareImplementationSettings(this.CsSILEmulationHWSettings, ...
                prefix, ...
                cs);
        end
                        
        function applyHardwareImplementationSettings(this, ...
                csSource, ...
                prefix, ...
                csTarget)            
            % apply all relevant hardware implementation settings from csSource to csTarget
            %                        
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'HWDeviceType');
            % apply individual sub-properties, which may have been changed
            % from their default values in csSource.
            %
            % word sizes
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'BitPerChar');            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'BitPerShort');            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'BitPerInt');            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'BitPerLong');            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'WordSize');            
            % ProdBitPerPointer not settable (derived)
            % ProdBitPerFloat not settable (fixed at 32)
            % ProdBitPerDouble not settable (fixed at 64)
            %
            % implementation props            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'ShiftRightIntArith');            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'IntDivRoundTo');            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'Endianess');                        
            % atomic sizes
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'LargestAtomicFloat');            
            this.applyHardwareImplementationSetting(csSource, prefix, csTarget, 'LargestAtomicInteger');            
        end
        
        function applyHardwareImplementationSetting(this, csSource, prefix, csTarget, param)
            % apply a single hardware implementation setting specified by
            % prefix and param from csSource to csTarget.
            %
            % apply prefix
            param = [prefix param];
            this.applyParam(csTarget, param, get_param(csSource, param));
        end
    end            
end
        
