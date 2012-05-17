classdef DBInvisible < dialogmgr.DialogBorder
    % Abstract class for constructing simple DialogContent objects intended
    % to be used with DPSingleClient DialogPresenter.
    %
    % This DialogBorder style does not show any graphical affordance of the
    % border of the dialog.  It has no border edge, no dialog name, etc.
    %
    % This is useful for embedding within a single-dialog DialogPresenter
    % which uses a figure as the dialog border decoration.
    %
    % The uipanel is kept in pixels units.
    

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:38:58 $


        methods (Access=protected)
        %
        % NOTE: Does NOT override init()
        %       There are no additional graphical widgets needed
        
        function updateImpl(dialogBorder,dialogContent) %#ok<INUSD>
            % Reset position of Panel back to 'pixels' and the default
            % size, in case subclass changed those.  Recalculate height
            % only if requested.
            set(dialogBorder.Panel, ...
                'units','pixels');
            
            % Conceptual layout/parenting of panels in this dialogBorder
            %   Panel
            %      <panel overlapped title text>
            %      gutterTop
            %         [many widgets]
            %      gutterBot
            
            % Get size of dialogContent panel
            ppos = get(dialogBorder.DialogContent.ContentPanel,'pos');
            
            % Indent to move content inside panel etch border
            hPanel = dialogBorder.Panel;
            bw = get(hPanel,'BorderWidth');
            gutter = 2*(bw+1);
            set(hPanel, ...
                'bordertype','none', ...
                'pos',[3 1 ppos(3) gutter+ppos(4)]);
        end
    end
end


