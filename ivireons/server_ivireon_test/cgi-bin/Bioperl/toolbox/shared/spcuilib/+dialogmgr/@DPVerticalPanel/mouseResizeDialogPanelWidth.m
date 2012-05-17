function mouseResizeDialogPanelWidth(dp)
% Resize dialog panel width

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:04 $

if dp.PanelVisible && ~dp.PanelLock
    % Get mouse (x,y) coords in Parent panel reference frame
    pt_parent = getMouseInParentRefFrame(dp);
    
    % .ResizePanelWidthMouseCache is initialized to the vector
    % [pt_x dp.PanelWidth] at the start of the panel-width drag operation.
    cache = dp.ResizePanelWidthMouseCache;
    origX     = cache(1);
    origWidth = cache(2);
    
    if strcmpi(dp.DockLocation,'left');
        % info panel is on the left
        delta_x = pt_parent(1)-origX;
    else
        % info panel is on the right
        delta_x = origX-pt_parent(1);
    end
    
    dp.PanelWidth = min(dp.PanelMaxWidth, ...
        max(dp.PanelMinWidth, origWidth+delta_x) );
    
    % Resize child panels
    % xxx call setDialogPanelVisible()?  too heavyweight...
    resizeChildPanels(dp);
end

