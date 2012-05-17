classdef WiredScope < sigutils.ApplicationData
    %WiredScope   Define the WiredScope class.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.18 $  $Date: 2010/05/20 03:07:39 $
    
    properties (Hidden)
        ScopeCfg;
        Framework;
        Block;
        RunTimeBlock;
    end
    
    properties (Dependent)
        Position;
        Visible;
    end
    
    properties (Access = private)
        ScopeParamsListener;
        ScopeCloseListener;
        ScopeVisibleListener;
        AllowScopeChanges = true;
        AllowBlockChanges = true;
        IsScopeCfgOld = false;
    end
    
    methods
        
        function value = getScopeParam(this, type, name, propName)
            %getScopeParam Get the scope parameter.
            %   getScopeParam(H, TYPE, NAME, PROPNAME) Get the scope
            %   parameter PROPNAME for the extension specified by TYPE and
            %   NAME.
            
            if isLaunched(this)
                cfgDb = this.Framework.ExtDriver.ConfigDb;
            else
                cfgDb = this.ScopeCfg.CurrentConfiguration;
            end
            
            cfg   = cfgDb.findConfig(type, name);
            prop  = cfg.PropertyDb.findProp(propName);
            value = prop.Value;
        end
        
        function paramValue = getBlockParam(this, paramName)
            %getBlockParam Get the block parameter
            %   getBlockParam(h, ParamName)
            
            paramValue = get(this.Block, paramName);
        end
        
        function setScopeParam(this, type, name, propName, value)
            %setScopeParam Set the scope parameter.
            %   setScopeParam(H, TYPE, NAME, PROPNAME, VALUE) Set the scope
            %   parameter PROPNAME to VALUE for the extension specified by
            %   TYPE and NAME.
            
            if ~isLaunched(this) || ~this.AllowScopeChanges
                return;
            end
            
            % Use try/catch block so that if we are passed bad path info,
            % we can reset the AllowBlockChanges back to true.
            cfgDb = this.Framework.ExtDriver.ConfigDb;
            
            % Get the specified config object.
            cfg = cfgDb.findConfig(type, name);
            
            % Get the specified property object.
            prop = cfg.PropertyDb.findProp(propName);
            prop.Value = value;
            
        end
        
        function setBlockParam(this, paramName, paramValue)
            %setBlockParam Set the block parameter
            %   setBlockParam(h, ParamName, ParamValue)
            
            % Check if we are in a state that allows block changes before
            % proceeding.  This usually happens when we are changing a
            % scope parameter and do not want to double set.
            if ~this.AllowBlockChanges
                return;
            end
            
            set(this.Block, paramName, paramValue);
        end
        
        function setScopeParams(this, varargin)
            %setScopeParams Set all of the scope parameters.
            
            % Only set the scope parameters when the scope is launched and
            % we are allowing scope parameter changes.  We need to make
            % sure that the block does not try to update all of the scope
            % settings at once while we're setting a single parameter.
            if ~isLaunched(this) || ~this.AllowScopeChanges
                return;
            end
            this.AllowBlockChanges = false;
            try
                setScopeParams(this.ScopeCfg, varargin{:});
            catch E
                this.AllowBlockChanges = true;
                rethrow(E);
            end
            this.AllowBlockChanges = true;
        end
        
        function setBlockParams(this, varargin)
            %setBlockParams Set all of the block parameters.
            
            if ~this.AllowBlockChanges
                return;
            end
            % Do not allow scope parameter changes while we are setting
            % block parameters.  This is to avoid issues with the block
            % (sfunction) trying to set scope parameters in response to
            % the scope setting block parameters.
            this.AllowScopeChanges = false;
            try
                
                % Whenever a scope parameter changes, we want to dirty the
                % model even if we do not have a block parameters to set.
                set_param(bdroot(this.Block.Handle), 'Dirty', 'on');
                setBlockParams(this.ScopeCfg, varargin{:});
                this.IsScopeCfgOld = true;
            catch E
                this.AllowScopeChanges = true;
                if strcmp(E.identifier, 'Simulink:Engine:CannotChangeConstTsBlks')
                    return;
                end
                rethrow(E);
            end
            this.AllowScopeChanges = true;
        end
        
        function h = getWidget(this, varargin)
            %getWidget Returns the handle to a UIMGR widget.
            %   getWidget(H, PATH1, PATH2, etc.) returns the handle to a
            %   UIMGR widget specified by the path.
            
            if isLaunched(this)
                h = findchild(this.Framework.getGUI, varargin{:});
            else
                h = [];
            end
        end
        
        function delete(this)
            %delete Clean up the object.
            
            % We do not want to listen to the scope closing when we are
            % shutting down.
            this.ScopeCloseListener = [];
            
            this.Block = [];
            this.RunTimeBlock = [];
            
            % Delete the UI associated with the block when the block is
            % deleted, if there is one.
            if isLaunched(this)
                close(this.Framework);
            end
            delete(this.ScopeCfg);
            
            this.ScopeCfg  = [];
            this.Framework = [];
        end
    end
    
    methods (Static)
        function this = getInstance(hBlock)
            %getInstance Returns the WiredScope instance associated with
            %   the block handle.
            
            hBlock = getBlockObject(hBlock);
            
            % Check the block's user data for a valid WiredScope object.
            ud = hBlock.UserData;
            if isfield(ud, 'Scope') && ~isempty(ud.Scope) && isvalid(ud.Scope) && ...
                    isa(ud.Scope, 'scopeextensions.WiredScope')
                this = ud.Scope;
                this.Block = hBlock;
            else
                this = scopeextensions.WiredScope(hBlock);
            end
        end
        
        function bool = hasInstance(hBlock)
            %hasInstance Returns true if the block has a scope instance
            %   associated with it.
            ud = get(getBlockObject(hBlock), 'UserData');
            if isfield(ud, 'Scope') && ~isempty(ud.Scope) && isvalid(ud.Scope) && ...
                    isa(ud.Scope, 'scopeextensions.WiredScope')
                bool = true;
            else
                bool = false;
            end
        end
        
        function mdlInitializeSizes(hBlock, name)
            
            % If we're passed a configuration name, save it in the block
            % for later use.
            if strcmp(get_param(bdroot(hBlock.Block), 'Lock'), 'on')
                return;
            end
            if nargin > 1
                scopeextensions.WiredScope.setConfigName(hBlock, name);
            end
            
            this = scopeextensions.WiredScope.getInstance(hBlock);
            
            % Specify that the Accelerator should call back into MATLAB file not
            % use the TLC, because there is no TLC for the block.
            hBlock.SetAccelRunOnTLC(false);
            
            % All Wired Scopes are SimViewingDevices.
            hBlock.SetSimViewingDevice(true);% no TLC required
            
            hBlock.RegBlockMethod('Start',     @(block) mdlStart(this, block));
            hBlock.RegBlockMethod('Terminate', @(block) mdlTerminate(this, block));
            hBlock.RegBlockMethod('Disable',   @(block) mdlDisable(this, block));
        end
        
        function setConfigName(hBlock, name)
            %setConfigName Set the configuration constructor name for this block.
            %   setConfigName(hBlock, name) Set the config
            
            hBlock = getBlockObject(hBlock);
            if strcmp(get_param(bdroot(hBlock.Handle), 'Lock'), 'on')
                return;
            end
            ud = get(hBlock, 'UserData');
            ud.ScopeCfgName = name;
            set(hBlock, 'UserData', ud);
        end
    end
    
    % Prevent these Static methods from showing up in the list of methods.
    methods (Static, Hidden)
        function callback(hBlock, callbackFcn, varargin)
            %callback Static gateway method for block callbacks.  This is
            %   done because block callbacks must be strings.
            
            ud = get(hBlock, 'UserData');
            if isfield(ud, 'Scope') && ~isempty(ud.Scope) && isvalid(ud.Scope) && ...
                    isa(ud.Scope, 'scopeextensions.WiredScope')
                feval(callbackFcn, ud.Scope, varargin{:});
            end
        end
        
        function this = loadobj(s)
            %loadobj Load the object from the serialized structure.
            
            % Rebuild the block object based on the name.  This may no
            % longer match the name of the block.  The customer could have
            % changed this in the MDL file itself.
            try
                % If we have a full path instead of just a relative path.
                % Use GCS to make sure that the user did not rename from
                % the command line.
                if ~isequal(s.BlockName(1), '/')
                    [~, s.BlockName] = strtok(s.BlockName, '/');
                end
                hBlock = getBlockObject(s.BlockName);
            catch E %#ok<NASGU>
                hBlock = [];
            end
            
            % Work around for MCOS issue.
            if isempty(s.ScopeCfg.ScopeCLI)
                createScopeCLI(s.ScopeCfg);
            end
            
            % Reconstruct the scope object.
            this = scopeextensions.WiredScope(hBlock, s.ScopeCfg);
            
            try
                this.Visible = s.Visible;
            catch E %#ok<NASGU>
                % NO OP - There are cases where the user has corrupted the
                % model and we cannot get at the block handle until they
                % double click the block or run the model.  This will cause
                % the visible set to fail.
            end
            this.IsScopeCfgOld = false;
        end
    end
    
    methods (Access = protected)
        function this = WiredScope(hBlock, hScopeCfg)
            %WiredScope   Construct the WiredScope class.
            
            % Avoid clear classes warnings.
            mlock;
            
            hBlock = getBlockObject(hBlock);
            if nargin < 2
                ud = get(hBlock, 'UserData');
                if isfield(ud, 'ScopeCfgName')
                    hScopeCfg = ud.ScopeCfgName;
                else
                    DAStudio.error('Spcuilib:scopes:WiredScopeNoScopeCfgName');
                end
            end
            if ischar(hScopeCfg)
                hScopeCfg = feval(hScopeCfg);
            end
            this.ScopeCfg = hScopeCfg;
            this.Block    = hBlock;
            
        end
        
        function launch(this)
            %launch Creates the scope window.
            
            if strcmp(get_param(bdroot(this.Block.Handle), 'Lock'), 'on')
                errordlg(DAStudio.message('Spcuilib:scopes:ScopeInLockedSystem', ...
                    strrep(this.Block.Name, sprintf('\n'), ' ')));
                return;
            elseif ~usejava('awt')
                
                % If we do not have java, return early with a warn, but do
                % not error.
                s = javachk('awt');
                warning(s.message, s.identifier);
                return;
            end
            
            oldDirty = get_param(bdroot(this.Block.Handle), 'Dirty');
            
            % Check if we need to make a new scope instance.
            if ~isLaunched(this)
                
                hFramework = uiscopes.new(this.ScopeCfg);
                                
                % Add a listener to the scope's closing event.
                this.ScopeParamsListener = createPropertyListener(hFramework, ...
                    @(h, ed) setBlockParams(this));
                this.ScopeCloseListener = handle.listener(hFramework, ...
                    'Close', @(h, ed) onScopeClose(this));
                this.ScopeVisibleListener = uiservices.addlistener(hFramework.Parent, ...
                    'Visible', 'PostSet', @(h, ed) onScopeVisibleChange(this));
            end
            
            % If the data source is already set up, do not reconnect.
            if isempty(hFramework.DataSource) || ...
                    hFramework.DataSource.BlockHandle ~= this.Block
                
                % Load the Data Source and establish a connection.
                hSrcSL = hFramework.getExtInst('Sources','WiredSimulink');
                hSrcSL.DataConnectArgs = {this.Block, this.RunTimeBlock};
                connectToDataSource(hFramework, hSrcSL);
            end
            
            if ~isLaunched(this)
                this.Framework = hFramework;
                % Make sure that we have everything set up properly.
                setScopePosition(this.ScopeCfg);
                setScopeParams(this);
            end
            
            visible(hFramework, 'on');
            figure(hFramework.Parent);
            
            set_param(bdroot(this.Block.Handle), 'Dirty', oldDirty);
        end
        
        function mdlDisable(this, hRTBlock)
            %mdlDisable The Disalbe block method.
            
            if isLaunched(this)
                hSource = this.Framework.DataSource;
                mdlDisable(hSource, hRTBlock);
            end
            
        end
        
        function mdlStart(this, hRTBlock)
            %mdlStart The Start block method for the MATLAB file S-Function.
            
            % If we are building RTW and we're not in accelerator, return
            % early, do not setup the object for launch.
            mdlRoot = bdroot(this.Block.Handle);
            if ~strcmp(get_param(mdlRoot, 'simulationmode'), 'accelerator') && ...
                    strcmp(get_param(mdlRoot, 'buildingrtwcode'), 'on')
                return;
            end
            
            % Cache away the RunTimeBlock so that we can set the 'Update'
            % block method when the scope is launched/closed.
            this.RunTimeBlock = hRTBlock;
            
            if getOpenAtMdlStart(this.ScopeCfg)
                this.Visible = 'on';
            elseif strcmp(this.Visible, 'on')
                
                % If we aren't opening it at model start, it might still be
                % open already.  Fire the listener to reinitialize the
                % 'Update' block method.
                setUpdateMethod(this);
            elseif ~isNormalMode(this)
                
                % If we are in externalmode, we always want to attach the
                % mdlUpdate at mdlStart regardless of whether we are
                % launched, because the only time we can attach is at
                % mdlStart time.
                setUpdateMethod(this);
            end
            
            if isLaunched(this)
                hSource = this.Framework.DataSource;
                mdlStart(hSource, hRTBlock);
                
                if strcmp(hSource.ErrorStatus, 'failure')
                    screenMsg(this.Framework, hSource.ErrorMsg)
                    setUpdateMethod(this, false);
                end
            end
            mdlStart(this.ScopeCfg);
        end
        
        function mdlTerminate(this, block)
            %onModelStop implements the 'StopFcn' callback method on the
            %block.  This method sets all of the block parameters.
            
            % Remove the RunTimeBlock because when the model terminates,
            % the value stored becomes invalid.
            if isLaunched(this)
                mdlTerminate(this.Framework.DataSource, block);
            end
            mdlTerminate(this.ScopeCfg);
            this.RunTimeBlock = [];
        end
        
        function b = isLaunched(this)
            b = isa(this.Framework, 'uiscopes.Framework');
        end
        
        function onBlockDelete(this)
            %onBlockDelete implements the callback method 'DeleteFcn' on
            %   the block.
            
            % Delete the scope object.
            delete(this);
        end
        
        function onBlockClose(this)
            %onBlockClose implements the CloseFcn callback method on the
            %block.  This method closes down the scope interface.
            
            % Hide the scope.
            this.Visible = 'off';
        end
        
        function onBlockCopy(this, dBlock)
            %onBlockCopy implements the 'CopyFcn' callback method on the
            %   block. This method clears the UIFramework object from the
            %   block's UserData when a block is copied.
            
            % Remove the Scope field which stores "this" from the new
            % block because it refers to the source block.
            hBlock          = getBlockObject(dBlock);
            hBlock.UserData = rmfield(hBlock.UserData, 'Scope');
            
            % Make sure we get the latest scope configuration.
            updateScopeCfg(this);
            
            % Create a new WiredScope object with a copy of the scope cfg,
            % so that all the settings will be copied over.
            hNew = scopeextensions.WiredScope(hBlock, copy(this.ScopeCfg));
            
            % If we are copying the block out of a library, reset the
            % position to the default scope position.  This will eliminate
            % differences in resolution between computers.
            if isa(this.Block, 'Simulink.MSFunction') && ...
                    strcmpi(get_param(bdroot(this.Block.Handle),'BlockDiagramType'),'library')
                hNew.Position = getDefaultPosition(hNew.ScopeCfg);
            end
            
            % Give the scope cfg object a chance to write the position into
            % the block.
            saveScopePosition(hNew.ScopeCfg, hNew.Position);
        end
        
        function onBlockRename(this)
            %onBlockRename implements the 'NameChangeFcn' callback method
            %   on the block. This method updated the ApplicationName on
            %   the Source object to reflect the new name on the block.
            
            % If the scope is not launched yet, there is nothing to do.
            if isLaunched(this)
                
                % Update the Source information.
                updateSourceName(this.Framework.DataSource);
                
                % Update the title bar to reflect the new name.
                updateTitleBar(this.Framework);
                
                send(this.Framework, 'SourceNameChanged');
            end
        end
        
        function onModelSave(this)
            %onModelSave executes when the model is saved.  This saves the
            %   ScopeCfg object in the block.
            
            % If the scope is launched, we need to get the state every time
            % the model is saved so that the latest scopecfg is saved into
            % the mdl file.
            if isLaunched(this)
                updateScopeCfg(this);
                
                saveScopePosition(this.ScopeCfg, this.Position);
            end
        end
        
        function onScopeClose(this)
            %onScopeClose executes when the scope is closed.
            
            % Saves the scopeCfg object so that the next time we launch the
            % scope we will reproduce the settings.  We need to force an
            % update here even if the scope cfg is not old because the
            % scope cfg might be getting deleted.
            updateScopeCfg(this, true);
            setBlockParams(this);
            
            if isNormalMode(this)
                setUpdateMethod(this, false);
            end
            this.Framework             = [];
            this.ScopeParamsListener   = [];
            this.ScopeCloseListener    = [];
            this.ScopeVisibleListener  = [];
        end
        
        function onScopeVisibleChange(this)
            if strcmpi(this.Visible, 'on')
                setUpdateMethod(this);
            else
                setUpdateMethod(this, false);
            end
        end
        
        function updateScopeCfg(this, force)
            
            if nargin < 2
                force = false;
            end
            
            if ~isLaunched(this) || ~this.IsScopeCfgOld && ~force
                return;
            end
            
            % Update the scope configuration with the latest from the
            % framework.
            this.ScopeCfg = getState(this.Framework);
            
            % These two fields do not get copied.
            this.ScopeCfg.Block = this.Block;
            
            % The latest scope configuration is now saved into this object
            % so we no longer need to update it if save is called again
            % before more changes happen.
            this.IsScopeCfgOld = false;
        end
        
        function setUpdateMethod(this, install)
            if isempty(this.RunTimeBlock) || ...
                    ~isa(this.RunTimeBlock, 'Simulink.RunTimeBlock')
                return;
            end
            
            if nargin < 2 || install
                if isNormalMode(this)
                    cb = makeMdlUpdateCallback(this.Framework.DataSource);
                else
                    cb = makeExternalMdlUpdateCallback(this);
                end
                
                startVisualUpdater(this.Framework.DataSource);

            else
                cb = [];
                stopVisualUpdater(this.Framework.DataSource);
            end
            this.RunTimeBlock.RegBlockMethod('Update', cb);
        end
    end
    
    methods (Hidden)
        function s = saveobj(this)
                        
            s.ScopeCfg   = this.ScopeCfg;
            if isa(this.Block, 'Simulink.MSFunction')
                % Save only the path information so that we can reliably
                % reload models that were renamed from a prompt and not the
                % Simulink model.
                [~, s.BlockName] = strtok([this.Block.Path '/' this.Block.Name], '/');
            else
                s.BlockName = '';
            end
            s.Visible = this.Visible;
            s.Version = 1;
        end
    end
    
    % Accessors
    methods
        
        function set.Block(this, newBlock)
            
            if ~isempty(newBlock) && ...
                    strcmp(get_param(bdroot(newBlock.Handle), 'Lock'), 'off')
                ud = get(newBlock, 'UserData');
                ud.Scope = this;
                set(newBlock, 'UserData', ud, 'UserDataPersistent', 'on');
            end
            
            this.Block = newBlock;
            this.ScopeCfg.Block = newBlock; %#ok<MCSUP>
            
            % Don't try to set the Block callbacks if its [].
            if isempty(newBlock) || isa(newBlock, 'Simulink.Reference')
                return;
            end
            
            % Configure the block callback functions.  Use a static method
            % 'callback' so that we can provide a string as the callback,
            % and it can perform the validity check for all the callbacks.
            methodStr = 'scopeextensions.WiredScope.callback(gcbh, ''%s'');';
            newBlock.DeleteFcn     = sprintf(methodStr, 'onBlockDelete');
            newBlock.NameChangeFcn = sprintf(methodStr, 'onBlockRename');
            newBlock.PreSaveFcn    = sprintf(methodStr, 'onModelSave');
            newBlock.CloseFcn      = sprintf(methodStr, 'onBlockClose');
            newBlock.CopyFcn       = 'scopeextensions.WiredScope.callback(gcbh, ''onBlockCopy'', gcbh);';
        end
        
        function set.ScopeCfg(this, newScopeCfg)
            newScopeCfg.Scope = this;
            this.ScopeCfg = newScopeCfg;
        end
        
        function set.RunTimeBlock(this, newRunTimeBlock)
            this.RunTimeBlock = newRunTimeBlock;
            if isLaunched(this)
                this.Framework.DataSource.RunTimeBlock = newRunTimeBlock; %#ok<MCSUP>
            end
        end
        
        function set.Position(this, newPosition)
            if isLaunched(this) && ...
                    ~strcmp(get(this.Framework.Parent, 'WindowStyle'), 'docked')
                set(this.Framework.Parent, 'Position', newPosition);
            else
                this.ScopeCfg.Position = newPosition;
            end
        end
        
        function position = get.Position(this)
            if isLaunched(this)
                position = get(this.Framework.Parent, 'Position');
            else
                position = this.ScopeCfg.Position;
            end
        end
        
        function visState = get.Visible(this)
            if isLaunched(this)
                visState = get(this.Framework.Parent, 'Visible');
            else
                visState = 'off';
            end
        end
        
        function set.Visible(this, visState)
            if isLaunched(this)
                visible(this.Framework, visState);
            elseif strcmpi(visState, 'on')
                launch(this);
            end
        end
    end
end

% -------------------------------------------------------------------------
function object = getBlockObject(blkinfo)

if isempty(blkinfo)
    object = [];
elseif isnumeric(blkinfo)
    object = get(blkinfo, 'Object');
elseif ischar(blkinfo)
    if isequal(blkinfo(1), '/')
        % This is only a path, we need to use GCS to build the full path.
        blkinfo = [bdroot(gcs) blkinfo];
    end
    object = get_param(blkinfo, 'Object');
elseif isa(blkinfo, 'Simulink.Block')
    object = blkinfo;
elseif isa(blkinfo, 'Simulink.RunTimeBlock')
    object = get(blkinfo.BlockHandle, 'Object');
else
    error('spcuilib:scopeextensions:WiredScope:InvalidBlock', ...
        'Invalid block information provided to the wired scope.');
end
end

% -------------------------------------------------------------------------
function cb = makeMdlUpdateCallback(hSource)

% Define the anonymous function in a local function with no extraneous
% variables declared.  This will simplify the garbage collection that
% MATLAB must do every time the anonymous function is called.  This greatly
% improves performance of anonymous functions called in a loop.
cb = @(block) mdlUpdate(hSource, block);

end

% -------------------------------------------------------------------------
function cb = makeExternalMdlUpdateCallback(this)

cb = @(block) externalMdlUpdate(this, block);

end

% -------------------------------------------------------------------------
function externalMdlUpdate(this, block)

this.RunTimeBlock = block;
if this.isLaunched
    hSource = this.Framework.DataSource;
    if isDataEmpty(hSource)
        mdlStart(hSource, block);
    end
    
    mdlUpdateExternal(hSource, block);
end

end

% -------------------------------------------------------------------------
function b = isNormalMode(this)

mdlRoot = bdroot(this.Block.Handle);
b = strcmp(get_param(mdlRoot, 'SimulationMode'), 'normal');

end                

% [EOF]

% LocalWords:  sfunction UI scopeextensions Spcuilib awt Disalbe
% LocalWords:  simulationmode buildingrtwcode externalmode uiscopes scopecfg
% LocalWords:  spcuilib
