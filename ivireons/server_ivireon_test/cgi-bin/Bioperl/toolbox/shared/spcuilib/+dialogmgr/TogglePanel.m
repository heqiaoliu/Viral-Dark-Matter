classdef TogglePanel < hgsetget
    % Create a toggle panel widget.

        
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $   $Date: 2010/04/21 21:48:53 $

    properties
        BackgroundColor = get(0,'defaultFigureColor')
    end
    properties (Dependent)
        BorderType
    end
    properties (Dependent)
        Extent % pixels
    end
    properties
        FontSize = 8
        ForegroundColor = [0 0 0] % [R G B]
    end
    properties (Dependent)
        InnerPosition % Position of panel within widget
    end
    properties (SetAccess=private)
        Panel % Handle to inner panel holding content
    end
    properties
        Parent
    end
    properties (Dependent)
        Position % Bounding box around widget
    end
    properties
        Title = 'TogglePanel'
        Tag % Tag for the widget
    end
    properties (Constant)
        Units = 'pixels'
    end
    
    properties (GetAccess=private,Constant)
        InitialCheckboxState = 1 % panel is initially open
        YGutter = 0 % vertical pixels between frame and checkbox
    end
    
    properties (Access=private)
        % Outer position of widgets
        % [x y dx dy], in pixels
        BoundingBox = [20 20 100 100]

        Checkbox        % handle to uicontrol
        IconPanelOpen   % icon for "showing panel content"
        IconPanelClosed % icon for "hiding panel content"
    end
    
    properties (GetAccess=private)
        % Maintain size of the Position (outer bounding box) or
        % InnerPosition (inner panel) when widget is resized, which
        % occurs when FontSize is changed.
        %
        % Property is set to true whenever InnerPosition is set,
        % and false whenever Position is set.
        MaintainInnerPositionOnFontSizeChange = false
    end
    
    methods
        function h = TogglePanel(varargin)
            % Create a TogglePanel object
            pv = parseArgs(h,varargin);
            
            % .Parent property is the only property that may be set during
            % parseArgs().  If it was NOT set, then no parent handle was
            % specified.  In this case, we use gcf:
            if isempty(h.Parent)
                h.Parent = gcf;
            end
            
            % Create the widget
            create(h);
            
            % Set all properties AFTER creating the widget
            set(h,pv{:});
        end
        
        function delete(h)
            % Delete TogglePanel widget.
            
            % Note that underlying widgets may have been deleted without
            % our knowing it during a parent close event.
            if ishghandle(h.Panel)
                delete(h.Panel);
            end
            if ishghandle(h.Checkbox)
                delete(h.Checkbox);
            end
            h.Panel = [];
            h.Checkbox = [];
        end
        
        function set.BackgroundColor(h,val)
            if ~isequal(size(val),[1 3])
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, 'BackgroundColor must be a 1x3 vector.');
            end
            h.BackgroundColor = val;
            set([h.Checkbox h.Panel],'BackgroundColor',val);
        end
        
        function set.BorderType(h,val)
            set(h.Panel,'BorderType',val);
        end
        
        function val = get.BorderType(h)
            val = get(h.Panel,'BorderType');
        end
        
        function y = get.Extent(h)
            % Extent is equal to Position when panel is open, and
            % changes in vertical origin and size when panel is closed.
            isOpen = get(h.Checkbox,'value') == 1;
            if isOpen
                y = h.Position;
            else
                y = get(h.Checkbox,'Position');
            end
        end
        
        function set.FontSize(h,val)
            % A change in FontSize either preserves Position
            % (OuterPosition), and thus shrinks InnerPosition (panel
            % position), or preserves InnerPosition and thus shrinks
            % Position, depending on whether InnerPosition or Position was
            % last set.  By default, Position is maintained.
            sigdatatypes.checkFinitePosDblScalar(h,'FontSize',val);
            h.FontSize = val;
            set(h.Checkbox,'FontSize',val);
            if h.MaintainInnerPositionOnFontSizeChange
                installInnerPosition(h);
            else
                installPosition(h);
            end
        end
        
        function set.ForegroundColor(h,val)
            if ~isequal(size(val),[1 3])
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, 'ForegroundColor must be a 1x3 vector.');
            end
            h.ForegroundColor = val;
            set(h.Checkbox,'Foreground',val);
            [h.IconPanelOpen,h.IconPanelClosed] = ...
                dialogmgr.iconsTogglePanel(h.BackgroundColor,val);
            callbackCheckbox(h);
        end
        
        function set.InnerPosition(h,val)
            % A change in InnerPosition directly sets Panel position,
            % and therefore grows overall Position.
            installInnerPosition(h,val);
            
            % Do this AFTER calling installInnerPosition(), since that
            % method resets the .Maintain... property
            h.MaintainInnerPositionOnFontSizeChange = true;
        end
        
        function val = get.InnerPosition(h)
            val = get(h.Panel,'Position');
        end
        
        function set.Parent(h,val)
            if ~ishghandle(val)
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidParent');
                error(errID, 'Parent must be an HG handle');
            end
            h.Parent = val;
            set([h.Checkbox h.Panel],'Parent',val); %#ok<*MCSUP>
        end
        
        function set.Position(h,bbox)
            % A change in Position sets the bounding box around the entire
            % widget.
            installPosition(h,bbox);
            
            % Position specifies a bounding box around the entire widget,
            % including both the Panel and Checkbox internal widgets.
            h.MaintainInnerPositionOnFontSizeChange = false;
        end
        
        function val = get.Position(h)
            val = h.BoundingBox;
        end
        
        function set.Title(h,val)
            if ~ischar(val)
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, 'Title must be a string');
            end
            set(h.Checkbox,'string',val);
        end
        
        function set.Tag(h,val)
            if ~ischar(val)
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, 'Tag must be a string');
            end
            set(h.Checkbox,'tag',val);
        end
    end
    
    methods (Access = private)
        function callbackCheckbox(h)
            % Checkbox value has been changed
            % React to new checkbox state
            setPanelVisAndIcon(h,get(h.Checkbox,'value'));
        end
        
        function installInnerPosition(h,ppos)
            % Move the widgets based on InnerPosition.
            % InnerPosition is a dependent property, so we do not set the
            % property value.  Instead, we translate to the outer bbox and
            % store that in Position.
            
            if nargin<2
                ppos = get(h.Panel,'Position');
            else
                if ~isequal(size(ppos),[1 4])
                    % Internal message to help debugging. Not intended to be user-visible.
                    errID = generatemsgid('invalidformat');
                    error(errID, 'InnerPosition must be a 1x4 vector.');
                end
                set(h.Panel,'Position',ppos);
            end
            
            % Add gutter and checkbox height to inner position
            cExt = get(h.Checkbox,'extent');
            YCheckbox = cExt(4); % Get checkbox height
            bbox = ppos + [0 0 0 h.YGutter+YCheckbox];
            h.BoundingBox = bbox;
            
            % Determine position of Checkbox
            % Y-coord is one pixel past last Panel pixel, plus gutter
            cpos(1) = ppos(1);
            cpos(2) = ppos(2)+ppos(4)+h.YGutter;
            cpos(3) = ppos(3);
            cpos(4) = YCheckbox;
            set(h.Checkbox,'Position',cpos);
        end
        
        function installPosition(h,bbox)
            % Move the widgets based on Position.
            % Used by set.Position and initialization code
            
            if nargin<2
                bbox = h.BoundingBox;
            else
                if ~isequal(size(bbox),[1 4])
                    % Internal message to help debugging. Not intended to be user-visible.
                    errID = generatemsgid('invalidformat');
                    error(errID, 'Position must be a 1x4 vector.');
                end
                h.BoundingBox = bbox;
            end
            
            % Determine position of Panel
            cExt = get(h.Checkbox,'extent');
            YCheckbox = cExt(4); % Get checkbox height
            ppos = bbox - [0 0 0 h.YGutter+YCheckbox];
            set(h.Panel,'Position',ppos);
            
            % Determine position of Checkbox
            % Y-coord is one pixel past last Panel pixel, plus gutter
            cpos(1) = ppos(1);
            cpos(2) = ppos(2)+ppos(4)+h.YGutter;
            cpos(3) = ppos(3);
            cpos(4) = YCheckbox;
            set(h.Checkbox,'Position',cpos);
        end
        
        function pv = parseArgs(h,cellArgs)
            % Parse arguments and set property values
            %
            % NOTE: Directly sets the .Parent property if 'Parent' is
            % specified as an initial argument, or if it is a
            % parameter/value pair.  'Parent' will appear in the returned
            % pv cell-vector since the parameter has already been applied
            % to the property value.  No other property is set beforehand
            % in this manner.
            
            if isempty(cellArgs)
                pv = {};
            else
                % See if parent handle specified as first arg
                v1 = cellArgs{1};
                if ~ischar(v1)
                    % First arg is a parent handle, all remaining args are
                    % Param/Value pairs
                    h.Parent = v1;
                    pv = cellArgs(2:end);
                else
                    % All args are Param/Value pairs
                    pv = cellArgs;
                end
                % Check for 'Parent' property specification
                % NOTE: Could be specified even when a first-arg parent
                % handle is supplied, in the degenerate case.
                idx = find(strcmpi('parent',pv(1:2:end)));
                if ~isempty(idx)
                    % Set the Parent property and remove pair from pv
                    h.Parent = pv{2*idx};
                    pv(2*idx-1 : 2*idx) = [];
                end
            end
        end
        
        function setPanelVisAndIcon(h,val)
            % Value:
            %    0 = panel closed
            %    1 = panel open
            if val==1
                cdata = h.IconPanelOpen;
                vis = 'on';
            else
                cdata = h.IconPanelClosed;
                vis = 'off';
            end
            set(h.Checkbox,'cdata',cdata,'vis','on'); % Update icon
            set(h.Panel,'vis',vis);        % Update panel
        end
        
        function create(h)
            % Widgets are created in this method.
            
            % Layout:
            %
            % |X|Checkbox
            % |Panel--------------|
            % |                   |  ^
            % |                   |  |
            % |                   |  y
            % |-------------------|  x - >
            
            % Initialize icons
            bg = h.BackgroundColor;
            [h.IconPanelOpen,h.IconPanelClosed] = ...
                dialogmgr.iconsTogglePanel(bg,h.ForegroundColor);
            
            % Create invisible widgets initially, then make them visible
            % by calling setPanelVisAndIcon()
            
            % Panel to contain content
            h.Panel = uipanel( ...
                'Parent',h.Parent, ...
                'Units','pix', ...
                'Backgr',bg, ...
                'tag','toggle_panel',...
                'vis','off');
            
            % Checkbox to control panel visibility
            h.Checkbox = uicontrol( ...
                'parent',h.Parent, ...
                'style','checkbox', ...
                'callback',@(hh,e)callbackCheckbox(h), ...
                'string',h.Title, ...
                'fontsize',h.FontSize, ...
                'backgr',bg, ...
                'cdata',h.IconPanelOpen, ...
                'units','pix', ...
                'value',h.InitialCheckboxState, ...
                'tag','toggle_panel_action',...
                'vis','off');
            
            installPosition(h,h.Position);
            setPanelVisAndIcon(h,get(h.Checkbox,'value'));
        end
    end
end

