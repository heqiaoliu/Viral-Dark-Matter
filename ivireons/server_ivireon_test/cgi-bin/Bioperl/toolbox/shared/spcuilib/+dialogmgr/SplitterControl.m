classdef SplitterControl < handle
    % Create a splitter control widget.

    % Copyright 2010 The MathWorks, Inc.
    %  $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:48:52 $
    
    properties
        ArrowCount = 5           % number of arrow symbols in column
        ArrowDirection = 'Right' % Can be set to 'Right' or 'Left'
        %ArrowheadSize = [5 5]   % pixels
        
        % RGB triple, or empty to take background color from parent
        BackgroundColor = []
        
        BarSize = [3 60] % pixels, [width height]
        CallbackFcn = []
        
        % Foreground color of icons
        ForegroundColor = [1 1 1]*.8
        
        % Location to place splitter widget
        % Bottom left origin of icon, in pixels
        Location = [1 1]
        
        % Selects visual indicator
        % Can be set to 'Arrow' or 'Bar'
        Type = 'Arrow'
    end
    
    properties (Access=private)
        Widget  % handle to uicontrol for Arrow (checkbox)
        Parent  % handle to graphical parent
        
        BarIcon
        ArrowR % icon cache for one right arrowhead
        ArrowL % icon cache for one left arrowhead
        ArrowSize % Minimum size needed for arrows
    end
    
    methods
        function h = SplitterControl(hParent)
            if nargin<1
                hParent = gcf;
            end
            init(h,hParent);
        end
        
        function pos = getPosition(h)
            pos = [h.Location getSize(h)];
        end
        
        function sz = getSize(h)
            % Return size of splitter widget, in pixels
            if strcmpi(h.Type,'arrow')
                sz = h.ArrowSize;
            else
                % offset is needed to center bar within arrow width
                sz = h.BarSize+[3 0];
            end
        end
        
        function set.Location(h,val)
            if numel(val)~=2 || size(val,1)~=1
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, 'Location must be a 2-element row vector');
            end
            h.Location = val;
            updateLocation(h);
        end
        
        function set.ArrowCount(h,val)
            if numel(val)~=1 || val~=fix(val) || val<1 || isinf(val)
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidtype');
                error(errID, 'ArrowCount must be an integer > 0');
            end
            h.ArrowCount = val;
            cacheIcons(h);
            if strcmpi(h.Type,'arrow') %#ok<MCSUP>
                show(h);
            end
        end
        
        function set.ArrowDirection(h,val)
            strs = {'Right','Left'};
            if ~ischar(val) || ~any(strcmpi(val,strs))
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidValue');
                error(errID, 'ArrowDirection must be ''Right'' or ''Left''.');
            end
            h.ArrowDirection = val;
            if strcmpi(h.Type,'arrow') %#ok<MCSUP>
                show(h);
            end
        end
        
        function set.Type(h,val)
            strs = {'Arrow','Bar'};
            if ~ischar(val) || ~any(strcmpi(val,strs))
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidType');
                error(errID, 'Type must be ''Arrow'' or ''Bar''.')
            end
            h.Type = val;
            show(h);
        end
        
        function set.ForegroundColor(h,val)
            if ~isequal(size(val),[1 3])
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, 'ForegroundColor must be a 1x3 RGB triple.');
            end
            h.ForegroundColor = val;
            cacheIcons(h);
            show(h);
        end
        
        function set.BackgroundColor(h,val)
            if ~isempty(val) && ~isequal(size(val),[1 3])
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('invalidformat');
                error(errID, 'ForegroundColor must be empty or a 1x3 RGB triple.');
            end
            h.BackgroundColor = val;
            cacheIcons(h);
            show(h);
        end
        
        function splitterCB(h,ev)
            % Invoke callback with two arguments
            cb = h.CallbackFcn;
            if ~isempty(cb)
                feval(cb,h,ev);
            end
        end

    end
    
    methods (Access=private)
        function updateLocation(h)
            if strcmpi(h.Type,'arrow')
                sz = h.ArrowSize;
            else
                sz = h.BarSize;
            end
            set(h.Widget,'pos',[h.Location sz]);
        end
        
        function show(h)
            if strcmpi(h.Type,'arrow')
                showArrow(h);
            else
                showBar(h);
            end
        end
        
        function showBar(h)
            % Change display to a vertical bar
            set(h.Widget, ...
                'cdata',h.BarIcon, ...
                'pos',[h.Location h.BarSize]);
        end
        
        function showArrow(h)
            if strcmpi(h.ArrowDirection,'right')
                cdata = h.ArrowR;
            else
                cdata = h.ArrowL;
            end
            set(h.Widget, ...
                'cdata',cdata, ...
                'pos',[h.Location h.ArrowSize]);
        end
        
        function init(h,hParent)
            % One-time initialization of splitter control
            % Creates widget - do not call multiple times
            
            if ~isempty(h.Parent)
                % Internal message to help debugging. Not intended to be user-visible.
                errID = generatemsgid('emptyParent');
                error(errID, 'Cannot reinitialize SplitterControl.');
            end
            h.Parent = hParent;
            h.Widget = uicontrol( ...
                'parent',hParent, ...
                'style','checkbox', ...
                'enable','inactive', ...
                'buttondownfcn',@(hs,ev)splitterCB(h,ev), ...
                'units','pix', ...
                'tag','splitter_control',...
                'cdata',[]);
            
            cacheIcons(h);
            show(h);
        end
        
        function cacheIcons(h)
            % Create and cache Left and Right Arrows and Bar
            
            if isempty(h.BackgroundColor)
                if strcmpi(get(h.Parent,'type'),'uipanel')
                    prop = 'BackgroundColor';
                else
                    prop = 'Color';
                end
                bg = get(h.Parent,prop);
            else
                bg = h.BackgroundColor;
            end
            fg = h.ForegroundColor;
            
            % Define one left arrow and one right arrow
            
            % 5x5 arrow, 2x5 gutter
            % Vertical size = 7*N-2 (N>1), 5 (N==1)
            %   One arrow: 5x5
            %   Three arrows: 19x5
            %   Five arrows: 33x5
            
            % head = h.ArrowheadSize;
            x = [8 4 0 0 0;
                     8 8 8 4 0;
                     8 8 8 8 8;
                     8 8 8 4 0;
                     8 4 0 0 0] / 8;
            [Nr,Nc] = size(x); % # columns
            
            N = h.ArrowCount;
            if N > 1
                % Add vertical space between adjacent arrows
                % Space is approx. half the vertical height of an arrowhead
                spacer = zeros(ceil(Nr/2),Nc);
                xSpace = [x;spacer];
                x = [repmat(xSpace,N-1,1) ; x];
            end
            
            h.ArrowR = dialogmgr.createIconFromColorFraction(x,bg,fg);
            h.ArrowL = flipdim(h.ArrowR,2);
            
            % set width = 2 pixels wider than icon
            % enable=inactive -> use buttondownfcn for action
            sz = size(h.ArrowR); % 3-dims
            
            % Need to reverse size to create the [dx dy] portion of the
            % rect used for graphical placement
            %
            % Add 2 pixels around size to provide a 1-pixel border
            h.ArrowSize = sz([2 1]) + [2 2];
            
            % Cache bar icon
            x = ones(h.BarSize(2),h.BarSize(1));
            h.BarIcon = dialogmgr.createIconFromColorFraction(x,bg,fg);
        end
    end
end

