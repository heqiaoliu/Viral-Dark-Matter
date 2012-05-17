classdef DCExample1 < dialogmgr.DialogContent
    methods (Access=protected)
        % Dialog widgets should be created in an override of this method.
        %
        % Use the handle in the Panel property as the graphical parent
        % for top-level widgets within this dialog as needed.
        %
        % This method is not in the public interface.
        % It is called by the create() method of DialogContent.
        %
        
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2010/03/31 18:39:02 $

        function createContent(dlg,hPanel) %#ok<INUSD>
            % Widgets within dialog are created in this method
            %
            % All widgets should be parented to hParent, or to a
            % child of hParent.
            
            hPanel = dlg.Panel;
            bg = get(hPanel,'BackgroundColor');
            ppos = get(hPanel,'pos');
            pdx = ppos(3); % initial width of dialog's panel, in pixels
            
            inBorder = 2;
            outBorder = 2;
            x0=4; y0=3; dy=20;
            uicontrol( ...
                'parent', hPanel, ...
                'backgroundcolor',bg, ...
                'horiz','left', ...
                'units','pix', ...
                'pos',[x0 y0 pdx-inBorder-outBorder-10 dy], ...
                'string','Example Dialog', ...
                'style','text');
            
            pdy = y0+dy+4+2*inBorder+10; % final height, add ~1 char for label
            set(hPanel,'pos',[1 1 pdx pdy]);
        end
    end
end

