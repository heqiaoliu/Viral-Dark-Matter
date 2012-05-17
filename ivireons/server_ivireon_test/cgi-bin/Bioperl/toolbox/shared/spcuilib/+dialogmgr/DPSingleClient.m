classdef DPSingleClient < dialogmgr.DialogPresenter
    % Construct a DPSingleClient object, which is a DialogPresenter.
        
    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $    $ Date:  $
        
    properties (SetAccess=private)
        % Handle to parent DialogPresenter, used to coordinate
        % re-dock event.
        ApplicationDP
        
        % figure handle of parent application, used to coordinate
        % closing of DPSingleClient when parent figure closes, etc
        ApplicationFigure
    end
    
    properties
        % Position vector over which the new figure is centered
        % Leave empty to center new figure over ApplicationFigure position,
        % if provided, or over default figure position.
        OpenPosition = []
    end
    
    methods
        function dp = DPSingleClient(parentDP,pos)
            % Construct a DialogPresenter object that presents a single
            % dialog in an HG figure.  DPSingleClient creates its own HG
            % figure in which the dialog is presented.
            %
            % DPSingleClient(parentDP) sets the ApplicationDP handle to
            % parent DialogPresenter handle.  This allows DPSingleClient to
            % manage its position and lifecycle based on the application.
            %
            % Management includes:
            % * DPSingleClient figure will open centered on the application
            %   dialog
            % * DPSingleClient figure will close in response to a close
            %   event of the application
            % * xxx DPSingleClient figure name will be based on an ID
            %   provided by the application figure (TBD)
            %
            % To retrieve this object in an application, use:
            %   dp = dialogmgr.findDialogPresenter(gcf)
            
            if nargin>0
                dp.ApplicationDP = parentDP;
                
                % Cache figure handle of parent DialogPresenter
                dp.ApplicationFigure = parentDP.hFig;
            end
            
            % DialogPanel uses a DBNoTitle DialogBorder style
            %dp.DialogBorderFactory = @dialogmgr.DBNoTitle;
            dp.DialogBorderFactory = @dialogmgr.DBTopBar;
            
            if nargin>1
                dp.OpenPosition = pos;
            end
            
            init(dp);
        end
        
        function success = register(dp,thisDialog)
            % Register a Dialog with the DialogPresenter.
            
            success = false;
            
            if ~isempty(dp.Dialogs)
                % Internal message to help debugging. Not intended to be user-visible.
                warn(thisDialog,'DuplicateDialogName');
                return % EARLY EXIT
            end
            dp.Dialogs = thisDialog;
            
            % Update the figure
            set(dp.hFig, ...
                'name',thisDialog.Name, ...
                'pos',getFigPosition(dp,thisDialog), ...
                'resize','off', ...
                'vis','on');
            
            % Enable dialog title and docking services
            engageServices( ...
                thisDialog.DialogBorder, ...
                {'DialogTitle',[], ...
                'DialogDock',@(h,e)dockUndockedDialog( ...
                dp.ApplicationDP,thisDialog)});
            
            success = true;
        end
    end
    
    methods (Access=private)
        function init(dp)
            % Create a figure and a panel
            % Figure is hidden until register() is called
            
            % If caller initialized the ApplicationDP, use its background
            % color for this figure as well.
            if ~isempty(dp.ApplicationDP)
                bg = get(dp.ApplicationDP.hFigPanel,'backgroundcolor');
            else
                % Unmanaged - make up the color ourselves
                bg = get(0,'defaultfigurecolor');
            end
            
            hFig = figure( ...
                'menubar','none', ...
                'numbertitle','off', ...
                'integerhandle','off', ...
                'name','', ...
                'units','pix', ...
                'vis','off');
            hFigPanel = uipanel('parent',hFig, ...
                'backgroundcolor',bg, ...
                'bordertype','none', ...
                'units','norm', ...
                'pos',[0 0 1 1]);
            
            % initPresenter() sets hFig and hFigPanel base class properties
            initPresenter(dp,hFigPanel); % base class method
            
            % Set size of hParent
            %set(dp.hParent,'pos',[1 1 dp.OpenPosition(3:4)]);
            
            % Setup app-level management, if an application figure handle
            % has been registered.
            %
            % - use figure parent of AppParent handle to determine where
            % this figure should be positioned
            %
            % - listen to AppParent for figure close event
            appFig = dp.ApplicationFigure;
            if ~isempty(appFig)
                addlistener(appFig, ...
                    'ObjectBeingDestroyed',@(h,e)closeDueToAppFig(dp));
            end
            
            % Setup resize
            % Set listener to track position changes in hFigPanel
            %resizePanel(dp);
            %addlistener(dp.hFigPanel,'Resize',@(h,e)resizePanel(dp));
        end
        
        function figPos = getFigPosition(dp,thisDialog)
            
            % Center new figure over specified OpenPosition, if provided
            parentPos = dp.OpenPosition;
            if isempty(parentPos)
                % Determine if this DPSingleClient is going to be managed
                % in response to a parent figure
                appFig = dp.ApplicationFigure;
                if isempty(appFig)
                    % Center new fig over default figure location
                    parentPos = get(0,'DefaultFigurePosition');
                else
                    % Center new fig over app figure location
                    parentPos = get(appFig,'pos');
                end
            end
            
            % Determine size of dialog being registered,
            % based on initial DialogContent
            hPanel = getDialogContentParent(thisDialog.DialogBorder);
            dcPos = get(hPanel,'pos');
            
            % We copy the height of the parent pos to the figure
            % the hPanel comes from dialogBorder, and its height is
            % unlikely to be set
            if dcPos(4)<=1  % xxx really bad idea: threshold test
                dcPos(4)=parentPos(4);
            end
            
            % Final figure size
            figSiz = [dcPos(1)+dcPos(3) dcPos(2)+dcPos(4)];
            
            % Center the new figure over the "parentPos" rectangle
            figPos = centerOverPos(figSiz,parentPos);
        end
    end
end

function closeDueToAppFig(dp)
% Close DPSingleClient figure in response to the closing of a managed
% application figure.

if ishghandle(dp.hFig)
    close(dp.hFig);
end

end

function figPos = centerOverPos(figSiz,parentPos)
% Determine position rectangle for new figure, based on figSiz, that
% centers new figure over parentPos.

figx = max(1,ceil(parentPos(1) + (parentPos(3)-figSiz(1))/2));
figy = max(1,ceil(parentPos(2) + (parentPos(4)-figSiz(2))/2));
figPos = [figx figy figSiz];

end
