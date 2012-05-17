function setDialogVerticalExtents(dp)
% Record vertical extent of visible Dialog panels, the scroll-bar
% fractional height, and whether scroll bar should be visible.
%
% Generic to DialogPresenter?
%   .DialogsTotalHeight, in pixels
%
% Specific to DPVerticalPanel:
%   .ScrollFraction
%   .ScrollFractionNewlyVisible

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:20 $

if dp.PanelVisible
    % Full panel is visible (not in "closed" auto-hide state)
    
    % Get vertical extent of dialog panel
    % This is defined to be the same as the vertical extent of the parent
    % panel itself
    hParent = dp.hParent;
    ppos = get(hParent,'pos');
    panel_dy = ppos(4);
    
    % Get ordered list of docked Dialog objects
    % First entry is topmost dialog
    visDlgs = dp.DockedDialogs;
    
    % Determine total vertical extent of all docked dialogs
    dialogs_dy = 0;
    N = numel(visDlgs); % # visible dialogs
    for i = 1:N
        pos_i = get(visDlgs(i).DialogBorder.Panel,'pos');
        dialogs_dy = dialogs_dy + pos_i(4);
    end
    
    % We maintain one vertical gutter above each dialog
    % We do NOT include any gutter above top-most dialog.
    % We do NOT add any gutter below bottom-most dialog.
    numGutters = max(0,N-1);
    dialogs_dy = dialogs_dy + numGutters*dp.DialogVerticalGutter;
    
    % Update scroll bar info
    % - what fraction of the dialog is visible?
    %   This gets reflected in the height of the active scroll bar.
    %   This fraction is < 1 if total height of all dialogs exceeds the
    %   panel height.
    %
    % NOTE: We may hide the scroll independent of whether the scroll
    % fraction is < 1, due to auto-hide feature.
    origFrac = dp.ScrollFraction;
    scrollFraction = min(1, panel_dy/dialogs_dy); % fraction in range [0,1]
    newlyVisible = (origFrac>=1) && (scrollFraction<1);
else
    % Dialog panel not visible
    % Reset to indicate this
    dialogs_dy     = 0;
    scrollFraction = 0;
    newlyVisible   = false;
end

dp.DialogsTotalHeight = dialogs_dy; % pixels
dp.ScrollFraction = scrollFraction;
dp.ScrollFractionNewlyVisible = newlyVisible;
