classdef DialogContent < HeterogeneousHandle
    % Abstract class for constructing objects that represent dialog
    % contents.  DialogContent instances are intended to be used
    % with DialogPresenter objects to visualize the dialog content.
    %
    % Subclasses must implement:
    %   - getDefaultObject()
    %       must be (Static,Sealed), in support of HeterogeneousHandle
    %   - createContents()
    

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $    $Date: 2010/05/20 03:07:28 $

    properties (Access=private)
        IDStream % Integer ID stream generator
    end
    properties (SetAccess=protected)
        Name = '' % Name of dialog
    end
    properties (SetAccess=private)
        % ID is a unique positive integer assigned to DialogContent
        % when create() is called, identifying a unique instance
        % of dialog content.  Prior to the call to create(), ID=0
        % which means uninitialized.
        ID = 0
    end
    properties (SetAccess=protected)
        % Handle to uipanel that will contain the primary graphical
        % elements of this dialog when it is rendered.
        %
        % This uipanel is allocated/owned by DialogContent.
        ContentPanel
        
        % True if subclass implements buildDialogContextMenu()
        %
        % xxx use introspection to answer this automatically,
        %     and then remove this property.
        CustomContextHandler = false
    end
    properties
        % Application-defined data
        UserData
    end
    
    methods (Static,Sealed)
        function dialogContent = getDefaultObject
            % This method is required for HeterogeneousHandle classes.
            % It must return an instance of a concrete (non-abstract)
            % class implementation.  For DialogContent, we return a handle
            % to a dialog with no content.
            dialogContent = dialogmgr.DCEmpty;
        end
    end
    
    methods (Sealed)
        function initialize(dialogContent,dialogBorder)
            % Create DialogContent by invoking subclass implementation
            % via template method pattern.
            
            contentParent = getDialogContentParent(dialogBorder);
            
            % Protect against repeated calls by checking .ContentPanel
            % Cached property value should be empty at this point.
            if ~isempty(dialogContent.ContentPanel)
                %
                % Reinitialization call
                %
                % Re-parent widgets to new graphical dialogBorder panel
                %
                % Bug fix: turn off visibility while re-parenting content
                %set(contentParent,'vis','off');
                set(dialogContent.ContentPanel,'parent',contentParent);
                %set(contentParent,'vis','on');
            else
                %
                % Initialization call
                %
                
                % Assign a sequential ID for each DialogContent instance
                %  - ID tracks the allocation of .ContentPanel uipanel
                %  - if uipanel is deallocated, ID is cleared
                dialogContent.ID = generate(dialogContent.IDStream);
                
                % Create uipanel owned by DialogContent
                dialogContent.ContentPanel = uipanel( ...
                    'parent', contentParent, ...
                    'bordertype','none', ...
                    'units','pix');
                
                % Now we're ready to create the dialog content
                % This is implemented by subclasses
                createContent(dialogContent);
            end
        end
        
        function update(dialogContent)
            updateContent(dialogContent);
        end
        
        function detach(dialogContent) %#ok<MANU>
            % Separate dialogContent from dialogBorder parent
            %
            % Keep dialogContent panel and widgets intact, since the
            % intent is to attach this dialogContent to a new
            % dialogBorder parent.
            
            % Nothing to do.
        end
        
        function finalize(dialogContent)
            % Tear down dialog content
            
            % Perform any dialogContent-specific finalization tasks
            %finalizeContent(dialogContent);
            
            % Destroy main content uipanel
            delete(dialogContent.ContentPanel);
            dialogContent.ContentPanel = [];
            
            % Clear out ID to indicate uninitialized state
            dialogContent.ID = 0;
        end
    end
    
    methods (Abstract,Access=protected)
        % Create widgets specific to the concrete Dialog subclass.
        % Must be overridden in subclass.
        createContent(dialogContent)
    end
    
    methods (Access=protected)
        function updateContent(dialogContent) %#ok<MANU>
            % Update widgets within dialog.
            % Intended for override in subclass.
            % Default is to take no action.
        end
        
        %{
        function finalizeContent(dialogContent) %#ok<MANU>
            % Tasks to perform before dialog is destroyed.
            % Intended for override in subclass.
            % Default is to take no action.
        end
        %}
        
        %{
        function resizeDialogContent(dialogContent)
            % Resize dialog content widgets, based on change in size of
            % parent panel in the dialogBorder object that contains this
            % dialogContent object.
            
            % Simple reflection of parent panel position
            %
            % NOTE: not only do we reflect the size (dx,dy), we also
            % reflect the offset (x,y).
            contentPanel = dialogContent.ContentPanel;
            parent = get(contentPanel,'parent');
            set(contentPanel,'pos',get(parent,'pos'));
        end
        %}
    end
    
    methods (Sealed)
        % Services that cannot be overridden
        function onPropertyPostSet(dialogContent,propNames,cbFcn)
            % Helper function to set up listeners for dialog property
            % changes.  By default, callback cbFcn is invoked with two
            % arguments for a Property event: eventSource and eventData.
            % Pass an anonymous function handle to remove or replace these
            % two arguments.
            %
            % Ex:
            %    onPropertyPostSet(dlg, {'PropOne','PropTwo'}, ...
            %          @(h,ev)PropChangeHandler(myObj,ev));
            %
            
            % force propnames into a cell
            if ~iscell(propNames)
                propNames = {propNames};
            end
            % Create and attach listeners for each property
            for i = 1:numel(propNames)
                addlistener(dialogContent,propNames{i},'PostSet',cbFcn);
            end
        end
        function onPropertyPreSet(dialogContent,propNames,cbFcn)
            % Helper function to set up listeners for dialog property
            % changes.  By default, callback cbFcn is invoked with two
            % arguments for a Property event: eventSource and eventData.
            % Pass an anonymous function handle to remove or replace these
            % two arguments.
            %
            % Ex:
            %    onPropertyPreSet(dlg, {'PropOne','PropTwo'}, ...
            %          @(h,ev)PropChangeHandler(myObj,ev));
            %
            
            % force propnames into a cell
            if ~iscell(propNames)
                propNames = {propNames};
            end
            % Create and attach listeners for each property
            for i = 1:numel(propNames)
                addlistener(dialogContent,propNames{i},'PreSet',cbFcn);
            end
        end
    end
    
    methods
        function h = DialogContent
            % Construct a DialogContent object.
            
            % Initialize integer stream generator that will produce a
            % unique integer ID for each DialogContent object.
            h.IDStream = dialogmgr.IntegerStreamGenerator( ...
                'dialogmgr_DialogContent', 1);
        end
        
        function buildDialogContextMenu(dc,dp) %#ok<INUSD,MANU>
            % Create context menu content specific to this dialog
            % Intended for override in subclass.
            % Must remain public so DialogPresenter can invoke this.
            % Default is to take no action.
        end
    end
end

% LocalWords:  vis deallocated bordertype MANU dx dy cb dlg ev dialogmgr
