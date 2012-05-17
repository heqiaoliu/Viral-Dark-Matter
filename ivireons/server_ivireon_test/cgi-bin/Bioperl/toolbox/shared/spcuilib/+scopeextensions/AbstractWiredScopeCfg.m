classdef AbstractWiredScopeCfg < uiscopes.AbstractScopeCfg
    %AbstractWiredScopeCfg   Define the AbstractWiredScopeCfg class.
    
    %   Copyright 2008-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.10 $  $Date: 2010/05/20 03:07:34 $
    
    properties
        Block = [];
        Scope = []; % This is WiredScope not Framework.
    end
    
    methods
        
        function this = AbstractWiredScopeCfg(hBlock)
            %AbstractWiredScopeCfg   Construct the AbstractWiredScopeCfg
            %class.
            
            if nargin > 0
                this.Block = hBlock;
            end
        end
    end
    
    methods
        
        %
        % Overloaded from uiscopes.AbstractScopeCfg
        %
        function hiddenTypes = getHiddenTypes(~)
            %getHiddenTypes   Returns the extension types to hide.
            
            hiddenTypes = {'Sources', 'Visuals'};
        end
        
        function dialogTitle = getDialogTitle(this)
            % Get the application name from the block.  Call the
            % getSourceName if the DataSource (SrcWiredSL) is available
            % because the user may have requested to see the full path in
            % the application name.
            hScope = this.Scope;
            if isempty(hScope) || ...
                    isempty(hScope.Framework) || ...
                    isempty(hScope.Framework.DataSource)
                if isempty(this.Block)
                    dialogTitle = 'Unknown';
                else
                    dialogTitle = this.Block.Name;
                end
            else
                dialogTitle = getSourceName(hScope.Framework.DataSource);
            end
            
        end
        
        function showInstanceNumber = getInstanceNumberTitle(~)
            showInstanceNumber = false;
        end
        
        function hiddenExts = getHiddenExtensions(~)
            %getHiddenExtensions Returns the extensions to hide.
            
            hiddenExts = {'Tools:Instrumentation Sets'};
        end
        
        function scopeTitle = getScopeTitle(this, hScope)
            if isempty(hScope.DataSource)
                scopeTitle = getAppName(this);
            else
                scopeTitle = getSourceName(hScope.DataSource);
            end
        end
        
        function crFcn = getCloseRequestFcn(this, ~)
            crFcn = @(h, ev) hideScope(this);
        end
        
        function b = isVisibleAtLaunch(~)
            b = false;
        end
        
        %
        % New interface for wired scopes.
        %
        
        function onModelStart(~)
            %onModelStart Called when the model starts.
        end
        
        function onModelStop(~)
            %onModelStop Called when the model stops.
        end
        
        function setBlockParams(~)
            %setBlockParams Set parameters in the block from the scope.
        end
        
        function setScopeParams(~)
            %syncBlockParams Set parameters in the scope from the block.
        end
        
        function b = getOpenAtMdlStart(~)
            %openAtMdlStart Returns true if the scope should open during mdlStart.
            
            b = true;
        end
        
        function saveScopePosition(~, ~)
            %setScopePosition Sets the HG figure position into the block.
            %   setScopePosition(H, HGPOS) sets the HG figure position into
            %   the block stored in the Block field of H.
            
            % NO OP, we don't know the name of the property that stores the
            % figure position.  It might not exist.  Do nothing, subclasses
            % must overload.
        end
        
        function setScopePosition(~)
            %getScopePosition Gets the HG figure position from the block.
            
            % NO OP, let subclasses define how their positioning works.
        end
        
        function pos = getDefaultPosition(~)
            pos = uiscopes.getDefaultPosition;
        end
        
        function variableVal = evalVarInMdlOrBaseWS(this, variableName)
            %evalVarInMdlOrBaseWS Evaluates the given variable in model
            %   workspace first, and then in base workspace, if needed.
            
            hws = get(bdroot(this.Block.handle), 'ModelWorkspace');
            try
                variableVal = hws.evalin(variableName);
            catch meNotUsed %#ok<NASGU>
                % the variable specified in variableName does not exist in model
                % workspace. Try base workspace now.
                variableVal = evalin('base', variableName);
            end
        end
        
    end
    
    methods (Access = protected)
        function hideScope(this)
            this.Scope.Visible = 'off';
        end
    end
end

% [EOF]
