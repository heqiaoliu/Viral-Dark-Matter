function isInside = mouseScrollWheel(dp,ev)
% Processes wheel motion if cursor is over infopanel
% Return true if wheel action handled here

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:05 $

[~,isInside] = getMouseInDialogPanelRefFrame(dp);
if isInside
    % Store dummy entries - key is that this vector must be non-empty
    %   1:dragged outside x-limits of dialog panel
    %   2:original bottom-y-coord of panel
    %   3:original mouse position (relative to dialog)
    %   4:last ydelta of mouse
    dp.MouseOverDialog = [0 0 0 0];
    
    % Wheel motion here is the equivalent of having done
    % shift+click+drag then button-up for each click of the wheel
    %
    % If shift was held down, shift all dialogs together,
    % instead of moving just one dialog
    dp.DialogShiftAction = 1;
    
    % Cache starting positions of all docked dialogs
    % All positions are pixels, in dialog panel reference frame
    dp.DialogShiftStartPos = get( ...
        getDialogBorderPanels(dp,dp.DockedDialogs), ...
        {'pos'} );
    
    % Get wheel motion
    dir = ev.VerticalScrollCount; % direction=+1,-1
    mag = ev.VerticalScrollAmount; % magnitude, appears to be 3 always
    vec = 6*mag * dir;  % 18 pixels per wheel click
    
    % Shift the panel
    doShiftDialogs(dp,vec);
    
    % A mouse-up event is implied
    mouseUp(dp);
end

