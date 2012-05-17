function showDialogPanel(dp)
% Show or hide the Dialog Panel display
% Update visibility of each dialog within docked dialog panel
%
% React to current state of DockedDialogs list, showing or hiding
% dialogs
%
% Calls initHistDisplay()

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2010/03/31 18:40:26 $

show = dp.PanelVisible;

% If dialog panel is turning off, turn off vis as first step
% improves the visual transition
if ~show
    set(dp.hDialogPanel,'vis','off');
    drawnow
end

% Now, show dialog content
if show
    % Update visibilities of all dialog panels
    autoHideTimerReset(dp); % there's much to do, don't let timer expire
    
    [visDlgs,hidDlgs] = getDockedAndHiddenDialogs(dp);

    visPanels = getDialogBorderPanels(dp,visDlgs);
    hidPanels = getDialogBorderPanels(dp,hidDlgs);
    
    set(visPanels,'vis','on');
    set(hidPanels,'vis','off');
    
    % Show/hide dialog border services, based on panel lock status
    enableDialogBorderServices(dp,visDlgs);
    
    % "True" flag forces dialog updates, regardless of whether the
    % dialog panel itself changed position.  This overrides an
    % optimization that gets in our way here.
    resizeChildPanels(dp,true);
    
    updateDialogContent(dp);
    
    % Make info panel visible
    set(dp.hDialogPanel,'vis','on');
    
    autoHideTimerReset(dp);
else
    resizeChildPanels(dp); % xxx does this triggers hist resize?
end

