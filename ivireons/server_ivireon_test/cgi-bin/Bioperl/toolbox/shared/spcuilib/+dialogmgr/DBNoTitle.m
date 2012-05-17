classdef DBNoTitle < dialogmgr.DialogBorder
    % Abstract class for constructing simple DialogContent objects intended
    % to be used with DPSingleClient DialogPresenter.
    %
    % This DialogBorder style does not show the dialog title in the dialog
    % border; the title will be presented by the DialogPresenter in the
    % figure title bar. A simple panel edge is used.
    %
    % The uipanel is kept in pixels units.
    
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:38:59 $
    
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
    
    methods (Access=protected)
        %
        % NOTE: DBCompact does NOT override init()
        %       There are no additional graphical widgets needed
        
        function updateImpl(dialogBorder,dialogContent) %#ok<INUSD>
            % Reset position of Panel back to 'pixels' and the default
            % size, in case subclass changed those.  Recalculate height
            % only if requested.
            hPanel = dialogBorder.Panel;
            set(hPanel, ...
                'units','pixels');
            
            % Conceptual layout/parenting of panels in this dialogBorder
            %   Panel
            %      <panel overlapped title text>
            %      gutterTop
            %         [many widgets]
            %      gutterBot
            
            % Get size of dialogContent panel
            ppos = get(dialogBorder.DialogContent.ContentPanel,'pos');
            
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
                vertGutter = dialogBorder.ChildGutterInnerTop + ...
                    dialogBorder.ChildGutterInnerBottom;
                
                % Reset height
                ppos(4) = bbox(4) + vertGutter;
                set(hPanel,'pos',ppos);
            else
                % Indent to move content inside panel etch border
                bw = get(hPanel,'BorderWidth');
                gutter = 2*(bw+1);
                set(hPanel, ...
                    'pos',[3 1 ppos(3) gutter+ppos(4)]);
            end
        end
    end
end
