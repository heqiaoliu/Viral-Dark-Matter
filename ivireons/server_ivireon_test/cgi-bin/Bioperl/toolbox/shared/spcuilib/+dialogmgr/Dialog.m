classdef Dialog < handle
    % Concrete class for constructing dialogs.
    % Dialog instances are intended to be used with DialogPresenter objects
    % to visualize the dialog content.  Dialogs combine DialogBorder and
    % DialogContent to provide complete a dialog description.

        
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:48:50 $

    properties (SetAccess=private)
        % Installed at object instantiation
        DialogBorder    % type dialogmgr.DialogBorder
        DialogContent   % type dialogmgr.DialogContent
        Name            % copied from DialogContent
        
        % Installed when create() called
        DialogPresenter % type dialogmgr.DialogPresenter
    end
    
    methods
        function dlg = Dialog(dlgContent,dlgBorder)
            % Dialog(dlgContent,hBorder) creates a Dialog object with
            % DialogContent object hContent and DialogBorder object
            % hBorder.
            %
            % Dialog(dlgContent) uses dialogmgr.DBCompact as the default
            % DialogBorder object.
            
            if nargin<1
                dlgContent = dialogmgr.DCEmpty;
            end
            sigdatatypes.checkIsA(dlg,'DialogContent', ...
                dlgContent,'dialogmgr.DialogContent');
            dlg.DialogContent = dlgContent;
            
            if nargin<2
                dlgBorder = dialogmgr.DBCompact;
            end
            sigdatatypes.checkIsA(dlg,'DialogBorder', ...
                dlgBorder,'dialogmgr.DialogBorder');
            dlg.DialogBorder = dlgBorder;
            
            % Copy name property for convenience
            dlg.Name = dlgContent.Name;
        end
        
        function warn(dlg,warnType)
            % Issue common dialog warnings
            
            switch lower(warnType)
                % Internal message to help debugging. Not intended to be user-visible.
              case 'dialognotregistered'
                msg = 'Dialog "%s" was not registered with DialogPresenter.';
              case 'duplicatedialogname'
                msg = 'Dialog "%s" attempted to register a duplicate dialog name.';
              otherwise
                msg = 'Undocumented warning for dialog "%s"';
            end
            warning(generatemsgid(warnType),msg,dlg.Name);
        end
    end
    
    methods (Sealed)
        % Services that cannot be overridden
        
        function initialize(h,dp)
            % Create dialog and content.
            % Caller must provide a valid DialogPresenter context at the
            % time of widget creation.
            
            % Protect against repeated calls by checking h.DialogPresenter
            % Cached property value should be empty at this point.
            if ~isempty(h.DialogPresenter)
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('dialognotfinalized');
                error(errID, ['Dialog already being managed by another DialogPresenter.' ...
                    'Call finalize() before calling initialize().']);
            end
            
            % Test and cache DialogPresenter
            sigdatatypes.checkIsA(h,'DialogPresenter', ...
                dp,'dialogmgr.DialogPresenter');
            h.DialogPresenter = dp;
            
            % Responsible for creating a top-level panel to which all
            % dialog content will be parented.
            %
            % This is an abstract method implemented by a subclass,
            % typically another abstract class that provides a certain type
            % of graphical dialog (a concrete look-and-feel) but not the
            % content of a particular final dialog.
            initialize(h.DialogBorder,dp);
            
            % Create widgets specific to the Dialog subclass
            %
            % This is an abstract method implemented by a subclass.
            initialize(h.DialogContent,h.DialogBorder);
            
            % Complete dialog border services, such as border name or
            % autosizing of panels.
            %
            % This is NOT abstract, so frameworks that do not need this can
            % choose not to provide an override.
            update(h.DialogBorder,h.DialogContent);
            
            % Register this dialog with the DialogPresenter
            register(dp,h);
        end
        
        function update(h)
            % Update DialogContent within Dialog.
            % Suppresses execution if dialog is not visible.
            %
            N = numel(h);
            if N==1
                % For one dialog, check if it is visible before proceeding
                if isDialogVisible(h.DialogPresenter,h.Name)
                    update(h.DialogContent);
                end
            else
                % for a list, assume they are all visible dialogs
                % for efficiency
                for i=1:N
                    update(h(i).DialogContent);
                end
            end
        end
        
        function finalizeForUndock(h)
            % Finalize Dialog object, but don't touch DialogContent since
            % it will be re-docked to another Dialog and dialogBorder
            % later.
            % Tear down DialogBorder
            finalize(h.DialogBorder);
            h.DialogBorder = [];
            
            % Release handles to DialogPresenter and DialogContent,
            % but do not destroy objects
            h.DialogContent = [];
            h.DialogPresenter = [];
        end
        
        function finalize(h)
            % Free DialogContent and DialogBorder
            finalize(h.DialogContent);
            h.DialogContent = [];
            
            finalize(h.DialogBorder);
            h.DialogBorder = [];
            
            % Release handle to DialogPresenter,
            % but do not destroy object
            h.DialogPresenter = [];
        end
        
        function setVisible(thisDialog,state)
            % state may be 'on' or 'off', or true or false
            if nargin<2
                state='on';
            end
            setVisible(thisDialog.DialogBorder,state);
        end
        
        function disableRollerShadeIfAvailable(dlg)
            % When we close a dialog, we turn off RollerShade if it is enabled
            % This provides a uniform experience when opening dialogs:
            %   they are always "unrolled" when opened.
            %
            dialogBorder = dlg.DialogBorder;
            if hasService(dialogBorder,'DialogRoller')
                % disable roller shade after dialog has been made invisible
                setRollerShade(dialogBorder,false);
            end
        end
        
        function ID = getID(thisDialog)
            % Returns the unique ID assigned to each instance of a
            % DialogContent object.  Works for a vector of dialog objects.
            dc = [thisDialog.DialogContent]; % homog. vector of DC objects
            if isempty(dc)
                ID = [];
            else
                ID = [dc.ID]; % vector of integer IDs
            end
        end
    end
end

