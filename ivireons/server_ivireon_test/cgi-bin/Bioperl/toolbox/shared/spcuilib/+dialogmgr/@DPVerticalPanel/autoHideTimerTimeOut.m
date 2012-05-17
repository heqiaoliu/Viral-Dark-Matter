function autoHideTimerTimeOut(dp)
% Hide dialog panel if auto-hide turned on, the panel is visible,
% and the cursor is not inside the figure.  If the cursor WAS inside the
% figure, we would get normal mouse events and would be able to manage the
% visibility directly.  This is here as a "watchdog timer" time-out in case
% the cursor goes outside the figure.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:27 $

if dp.AutoHide && dp.PanelVisible
    % Get mouse position, which is always updated, in screen ref frame
    [ptParent,parentPos] = getPointerLocationInParentRefFrame(dp);
    ptx = ptParent(1);
    pty = ptParent(2);
    parentWidth = parentPos(3);
    parentHeight = parentPos(4);
    
    bodyPos = get(dp.hBodyPanel,'pos'); % in parent ref frame
    bodyWidth = bodyPos(3);
    
    % We need to give ourselves a bit more slack, so that the
    % panel won't close when some slight overshoot of the mouse into
    % the body panel boundaries.
    autoHideSlack = 10; % pixels, around panel perimeter
    
    dlgPanelOnLeft = strcmpi(dp.DockLocation,'left');
    if dlgPanelOnLeft
        % [<------------------------- parentWidth ------------------------>]
        % [gutterFig][scroll][gutterScroll][dlgPanel][gutterBody][bodyPanel]
        x0 = parentWidth-bodyWidth+1;
        outside_x = ptx < 1 || ptx >= x0+autoHideSlack;
    else % dlg panel on right
        % [<------------------------- parentWidth ------------------------>]
        % [bodyPanel][gutterBody][dlgPanel][gutterScroll][scroll][gutterFig]
        x0 = bodyWidth;
        outside_x = ptx <= x0-autoHideSlack || ptx > parentWidth;
    end
    outside_y = pty < 1 || pty > parentHeight;
    
    if outside_x || outside_y
        setDialogPanelVisible(dp,false);
    end
end

