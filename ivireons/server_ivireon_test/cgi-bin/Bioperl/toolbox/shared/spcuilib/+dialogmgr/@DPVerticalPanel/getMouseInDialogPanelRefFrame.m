function [pt_panel,isInside,isPastDeadZone,pt_parent] = getMouseInDialogPanelRefFrame(dp)
% Return current mouse coords, in dialog panel reference frame.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:39:52 $

% Get mouse (x,y) coords in Parent panel reference frame
pt_parent = getMouseInParentRefFrame(dp);

panel_pos = get(dp.hDialogPanel,'pos');      % in parent ref frame
pt_panel = pt_parent - panel_pos(1:2) + [1,1]; % in dialogpanel ref frame

% Test if cursor is within dialog panel x-limit boundaries
if nargout > 1
    pt_x = pt_parent(1);
    panel_xmin = panel_pos(1);
    panel_xmax = panel_xmin + panel_pos(3); % 1 pixel past right edge
    isInside = dp.PanelVisible && (pt_x >= panel_xmin) && (pt_x < panel_xmax);
    
    % Test if cursor is past the dialog panel dock location "dead zone"
    % This is a small horizontal gap beyond the x-limits of the dialog
    % panel.  This gives some room for error by the user who may simply be
    % dragging the dialog panel and not intending to begin a change to the
    % panel dock location.
    if nargout > 2
        isPastDeadZone = dp.PanelVisible && ...
            ((pt_x <  panel_xmin - dp.DockLocationMouseDragDeadZone) || ...
             (pt_x >= panel_xmax + dp.DockLocationMouseDragDeadZone));
    end
end

