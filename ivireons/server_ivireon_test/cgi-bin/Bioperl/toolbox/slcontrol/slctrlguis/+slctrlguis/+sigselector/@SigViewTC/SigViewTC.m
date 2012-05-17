classdef SigViewTC < toolpack.AtomicComponent
    % 
    
	% Class definition for @SigViewTC - the object that provides unified
	% API and Data structure for selected signal viewer widget.
    
    %  Author(s): Erman Korkut
    %  Revised:
    % Copyright 1986-2010 The MathWorks, Inc.
    % $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:54:11 $
    
    properties (Access = private)
    end    
    methods
        %% Constructor
        function this = SigViewTC(opts)            
            this = this@toolpack.AtomicComponent();
            this.Database = struct('FilterText','',...
                                   'Items',[],...
                                   'Options',[],...
                                   'DDGTreeData',[],...
                                   'ModelObject',[],...
                                   'ModelListeners',[]);            
            % Read and set the options
            if ~strcmp(class(opts),'slctrlguis.sigselector.Options')
                DAStudio.error('Slcontrol:sigselector:TCInvalidConstruction');
            else
                this.Database.Options = opts;
            end
            % Install listener on the specified model if interactive
            % selection is true
            if opts.InteractiveSelection
                % Get the model object
                try
                    this.Database.ModelObject = get_param(opts.Model,'Object');
                catch Me
                    % Error
                    DAStudio.error('Slcontrol:sigselector:InteractiveRequiresModel');
                end                
                % Get the initial selection
                items = getSelectionOnModel(this,true);
                % Register listener
                this.Database.ModelListeners(1).Model = this.Database.ModelObject;
                this.Database.ModelListeners(1).Listener = ...
                    handle.listener(this.Database.ModelObject,'SelectionChangeEvent',...
                                    @(h,ev) getSelectionOnModel(this,false,h,ev)); 
                % Register listener for referenced models if option is set
                if ~strcmp(opts.MdlrefSupport,'none')
                    mdlrefsup = opts.MdlrefSupport;
                    if strcmp(mdlrefsup,'normalonly')
                        % Find all the normal mode references
                        [~,mdlrefmodels,ref_preloaded] = getNormalModeBlocks(slcontrol.Utilities,opts.Model);                        
                        for ct = 1:numel(mdlrefmodels)
                            % Load if not loaded
                            if ~ref_preloaded(ct)
                                load_system(mdlrefmodels{ct});
                            end
                            % Install listener
                            mdlobj = get_param(mdlrefmodels{ct},'Object');
                            this.Database.ModelListeners(ct+1).Model = mdlobj;
                            this.Database.ModelListeners(ct+1).Listener = ...
                                handle.listener(mdlobj,'SelectionChangeEvent',...
                                    @(h,ev) getSelectionOnModel(this,false,h,ev));                            
                        end
                        
                    end
                end
                % Set the items
                this.setItems(items);
            end            
            % Update the tool component
            update(this);
        end
        function delete(this)
            % Make sure that all model listeners are explicitly deleted
            listeners = this.Database.ModelListeners;
            for ct = 1:numel(listeners)
                delete(listeners(ct).Listener);
            end
        end
        %% PUBLIC GET/SET API
        % Options has get but no set.
        function val = getOptions(this)
            val = this.Database.Options;
        end
        % DDGTreeData has get but no set.
        function val = getDDGTreeData(this)
            val = this.Database.DDGTreeData;
        end
        % FilterText get/set
        function val = getFilterText(this)
            val = this.Database.FilterText;
        end        
        function this = setFilterText(this,val)
            if ischar(val)
                 setChangeSetProperty(this,'FilterText',val);
            else
              DAStudio.error('Slcontrol:sigselector:TCInvalidFilterText');                 
            end
        end
        % Items get/set
        function val = getItems(this)
            val = this.Database.Items;
        end        
        function this = setItems(this,val)
            % Could be empty or a cell of item objects
            if ~isempty(val) && ~iscell(val)
                DAStudio.error('Slcontrol:sigselector:TCInvalidSignals');
            else
                opts = this.getOptions;
                % Make sure HideBusRoot and the new items is compatible
                if opts.HideBusRoot
                    % If HideBusRoot is on, val should be a single bus item
                    if ~(numel(val) == 1 && isa(val{1},'slctrlguis.sigselector.BusItem'))
                        DAStudio.error('Slcontrol:sigselector:TCInvalidItemsWithHideBusRootTrue');                        
                    end
                else
                    % If HideBusRoot is false, all bus signals should have
                    % a non-empty field.
                    for ct = 1:numel(val)
                        if isa(val{ct},'slctrlguis.sigselector.BusItem') && isempty(val{ct}.Name)
                            DAStudio.error('Slcontrol:sigselector:TCInvalidItemsWithHideBusRootFalse'); 
                        end
                    end
                end
                % Add IDs and selected flags
                val = this.addSelectedFlagsAndIDs(val);
                % If it is a DDG view, reset the selections as it is not
                % yet possible to pre-select tree nodes in DDG.                                 
                if strcmp(opts.ViewType,'DDG')
                    val = this.resetSelectedFlags(val);
                end                
                setChangeSetProperty(this,'Items',val);
            end
        end
        %% createView method
        function view = createView(this,varargin)
            % Get the options
            opts = this.getOptions;
            if strcmp(opts.ViewType,'DDG')
                % DDG view                
                view = sigselector.DDGGC(this);
            else
                % Java
                disp('Java view is created');
            end
        end
    end
    methods (Access = protected)
        function props = getIndependentVariables(this) %#ok<MANU>
            % Options & DDGTreeData are not here because they are not
            % allowed to be modified.
            props = {'FilterText','Items'};
        end
        function mUpdate(this)
            % Synchronize independent properties
            props = this.getIndependentVariables;
            for k = 1:length(props)
                p = props{k};
                if isfield(this.ChangeSet, p)
                    this.Database.(p) = this.ChangeSet.(p);
                    % If you are updating "Items" and the view is DDG,
                    % recompute DDG related tree information
                    if strcmp(p,'Items')
                        opts = this.getOptions;
                        if strcmp(opts.ViewType,'DDG')
                            this.Database.DDGTreeData = this.constructDDGTreeData(this.Database.(p),opts.HideBusRoot);                            
                        end
                    end                    
                end
            end
        end
    end
    methods (Sealed, Access = protected)
        function setChangeSetProperty(this, varname, varvalue)
            props = this.getIndependentVariables;
            if isempty(props) || ~any( strcmp(varname, props) )
                ctrlMsgUtils.error('Controllib:toolpack:NotAnIndependentProperty', varname)
            end
            this.ChangeSet.(varname) = varvalue;
        end
    end
    methods (Static = true)
        sigs = addSelectedFlagsAndIDs(insigs);
        sigs = resetSelectedFlags(insigs);
        treedata = constructDDGTreeData(sigs,hidebusroot);
    end
    
    
end



