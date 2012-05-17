classdef DBCompact < dialogmgr.DialogBorder
    % Abstract class for constructing simple DialogContent objects intended
    % to be used with DialogPresenter.
    %
    % This is a simple dialog framework using an HG uipanel as the
    % graphical presentation, with title text straddling the top of the
    % uipanel border and no buttons or icons in the title region.
    % It has a particularly compact representation of the dialog title.
    %
    % The uipanel is kept in pixels units.
    
    %   Copyright 2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:38:57 $

        properties (Hidden,Constant)
        % Vertical pixels maintained between highest defined widget in
        % dialog and the dialog panel.  This offset allows for separation
        % between widgets and the uipanel border decoration and panel
        % title, plus a comfortable visual margin.
        ChildGutterInnerTop = 7 % pixels
        
        % Vertical pixels maintained between lowest defined widget in
        % dialog and the dialog panel.  This offset allows for separation
        % between widgets and the uipanel border decoration, plus a
        % comfortable visual margin.
        ChildGutterInnerBottom = 4 % pixels
    end
    
    properties
        % Initial state of rollerShade is to make dialog content visible
        % (turn off rollerShade)
        RollerShadeHide = false
        
        % Height in pixels to keep in a "rolled-up" dialog
        RollerShadeMinHeight = 20;
    end
    
    properties (Access=private)
        % Widget handles
        % The panel holding dialogContent widgets is not .Panel,
        % it's .hContentPanel.  This is in support of RollerShade.
        hContentPanel
        
        RollerShadeLayoutInProgress = false;
    end
    
    methods (Access=protected)
        %
        % NOTE: DBCompact does NOT override init()
        %       There are no additional graphical widgets needed
        
        function createWidgets(dialogBorder)
            % One-time initialization of DialogBorder object
            
            hPanel = dialogBorder.Panel;
            bg = get(hPanel,'backgr');
            [~,ParentWidth] = getDialogPanelAndSize( ...
                dialogBorder.DialogPresenter);
            dialogBorder.hContentPanel = uipanel( ...
                'parent',hPanel, ...
                'BorderType','none', ...
                'background',bg, ...
                'units','pixels', ...
                'pos',[1 1 ParentWidth 1]);
        end
        
        function updateImpl(dialogBorder,dialogContent)
            % Reset position of Panel back to 'pixels' and the default
            % size, in case subclass changed those.  Recalculate height
            % only if requested.
            hPanel = dialogBorder.Panel;
            set(hPanel, ...
                'units','pixels', ...
                'title',dialogContent.Name);
            
            resize(dialogBorder);
            
            if dialogBorder.AutoPanelHeight
                % A very basic attempt to help the subclass
                % - we reset the pixel height, plus a little room at top
                % - we do NOT touch the widget offsets, so we cannot make
                %   room for a bottom gutter
                % - more to do in the future...
                bbox = findChildrenBoundingBox(dialogBorder);
                ppos = get(hPanel,'pos');
                
                % Compute extra vertical height needed for
                % comfortable visual spacing
                panelTextHeight = 10; % pixels
                vertGutter = dialogBorder.ChildGutterInnerTop + ...
                    dialogBorder.ChildGutterInnerBottom;
                yExtra = panelTextHeight + vertGutter;
                
                % Reset height
                ppos(4) = bbox(4) + yExtra;
                set(hPanel,'pos',ppos);
            end
        end
    end
    
    methods
        function h = getDialogContentParent(dialogBorder)
            % Returns the handle to the panel that is the parent of all
            % widgets for this dialog.
            %
            % This is a method override from DialogBorder base class.
            % Needed due to a more complex DialogBorder configuration.
            % Here, the main .Panel panel is not the parent for dialog
            % widgets.
            h = dialogBorder.hContentPanel;
        end
        
        function resize(dialogBorder)
            % Resize after a change in dialog size.
            
            if ~dialogBorder.RollerShadeLayoutInProgress
                
                % Border .Panel is resized by DialogPresenter to proper width
                % Get that width now
                hPanel = dialogBorder.Panel;
                panelPos = get(hPanel,'pos');
                
                % Leave vertical room for panel title text
                % Conceptual layout/parenting of panels in this dialogBorder
                %
                %   Panel
                %      <panel overlapped title text>
                %      gutterTop
                %         [many widgets]
                %      gutterBot
                dc = dialogBorder.DialogContent; % dialogContent uipanel
                cp = dialogBorder.hContentPanel; % dialogBorder uipanel
                borderPanelInvis = strcmpi(get(cp,'vis'),'off');
                
                if isempty(dc) || borderPanelInvis
                    cp_dy = 1; % pixel
                else
                    pos = get(dc.ContentPanel,'pos');
                    cp_dy = pos(4); % vertical extent, pixels
                end
                
                gutterTop = 12;
                dy = cp_dy + gutterTop;
                set(hPanel,'pos',[panelPos(1:3) dy]);
            end
        end
        
        function mouseOpen(dialogBorder)
            % Respond to mouse open (double-click) event from
            % DialogPresenter.  This is mapped to roller-shade action.
            
            if 1 % xxx only execute if roller-shade service enabled
                toggleRollerShade(dialogBorder);
            end
        end
    end
    
    methods (Access=private)
        
        function toggleRollerShade(dialogBorder)
            % Toggle roller-shade state
            setRollerShade(dialogBorder,~dialogBorder.RollerShadeHide);
        end
        
        function setRollerShade(dialogBorder,hide)
            % Optionally sets new rollerShade state.
            %   - hide=true will close (hide) all DialogContent
            %
            % Sends event to notify listeners of final state.
            
            % Optionally change state
            if nargin>1
                dialogBorder.RollerShadeHide = hide;
            end
            % React to new state
            hP = dialogBorder.Panel;
            hCP = dialogBorder.hContentPanel;
            
            % # pixels vertical height to keep in "empty" dialog
            MinHeight = dialogBorder.RollerShadeMinHeight;
                
            dialogBorder.RollerShadeLayoutInProgress = true;
            
            if dialogBorder.RollerShadeHide
                % Hide content of panel
                
                % Hide dialog contents
                set(hCP,'vis','off');
                
                % Get actual height of dialogContent top-level panel
                % We will see height of 1 for the dialogBorder content
                % panel here, if roller-shade is engaged.  We need an
                % actual content height here.  It's simply a matter of
                % which we need, and the timing of when the
                % dialogBorder pos gets set.
                pos = get(dialogBorder.DialogContent.ContentPanel,'pos');
                cp_dy = pos(4) - MinHeight;
                
                % Change position of Panel to bring its bottom upward
                % toward top, effectively rolling it "up"
                pos = get(hP,'pos');
                pos(2) = pos(2)+cp_dy;
                pos(4) = pos(4)-cp_dy;
                set(hP,'pos',pos);
            else
                % Show content of panel
                
                % Change position of Panel to bring its bottom upward
                % toward top, effectively rolling it "up"
                pos = get(dialogBorder.DialogContent.ContentPanel,'pos');
                cp_dy = pos(4) - MinHeight;
                
                pos = get(hP,'pos');
                pos(2) = pos(2)-cp_dy;
                pos(4) = pos(4)+cp_dy;
                set(hP,'pos',pos);
                
                % Change vis of DialogContent uipanel Dialog
                set(hCP,'vis','on');
            end
            
            % Update dialog panel to respond to change in dialog height
            % "true" means to force an update, since this change of content
            % visibility is invisible to resizeChildPanels().
            %
            % updates scroll bar, etc
            resizeChildPanels(dialogBorder.DialogPresenter,true);

            dialogBorder.RollerShadeLayoutInProgress = false;
        end
    end
end

