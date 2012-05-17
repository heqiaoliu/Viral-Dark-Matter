function updatedDialogs = resizeChildPanels(dp,forceUpdate)
% Resize hDialogPanel, hBodyPanel, and hBodySplitter.
%
% Does NOT resize the dialogs themselves.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:14 $

% Caller option to force update of dialogs, regardless of whether position
% of dialog panel changed.
if nargin<2
    forceUpdate = false;
end

% Determine key parameters for dialog panel resize
% Does NOT resize anything
setDialogVerticalExtents(dp);

% Reposition dialog panel
%
%  - Keep flush-top within hParent panel
%  - Dialogs will be rendered within info panel
%  - Update hDialogPanel position regardless of visibility.
%     The auto-hide mouse test will stop working otherwise.
%     Issue is when dialog panel is not visible, and figure is resized.
%     The test coordinate for the mouse would be set incorrectly,
%     and we may be unable to bring panel out of auto-hide state.

% Get constants
panelWidth   = dp.PanelWidth;
gutterFig    = dp.GutterInfoFig; % gutter between infopanel and figure edge
gutterBody   = dp.GutterInfoBody;
gutterScroll = dp.ScrollGutter;

% For this to be correct, setDialogVerticalExtents() must be executed
% previous to this call:
scrollWidth = getScrollWidth(dp);

% Get size of Parent panel
hParent = dp.hParent;
ppos = get(hParent,'pos');
parentWidth  = ppos(3);
parentHeight = ppos(4);

% Determine size to render dialog panel
% Gutters are used to shrink info panel, they are NOT used for body panel
infoPanelOnLeft = strcmpi(dp.DockLocation,'left');
if infoPanelOnLeft
    % [<------------------------- parentWidth ------------------------>]
    % 1                                                                N
    % [gutterFig][scroll][gutterScroll][dlgPanel][gutterBody][bodyPanel]
    %                              x0->|
    infopanel_x0 = gutterFig+scrollWidth+gutterScroll+1; % x origin
else % info panel on right
    % [<------------------------- parentWidth ------------------------>]
    % 1                                                                N
    % [bodyPanel][gutterBody][dlgPanel][gutterScroll][scroll][gutterFig]
    %                    x0->|
    infopanel_x0 = max(1,parentWidth-gutterFig-scrollWidth-gutterScroll-panelWidth+1);
end
newPos  = [infopanel_x0 1 max(1,panelWidth) max(1,parentHeight)];
currPos = get(dp.hDialogPanel,'pos');
updatedDialogs = ~isequal(currPos,newPos);
if updatedDialogs || forceUpdate
    % Update position of DialogPanel
    set(dp.hDialogPanel,'pos',newPos);
    
    % Now we need to reestablish vertical shift of dialogs,
    % possibly update dialog widths, etc.
    %
    % Suppress recalc of dialog vertical extents, since we did that above
    updateDialogPositions(dp,false);
    
    % Always update message - in case we must turn it off
    showNoDockedDialogsMsg(dp);
end

% It requires parent panel to have been updated, which would occur if a
% figure size change occurred since resizeParentPanel() calls this.
% It doesn't rely on anything else being changed below.
% Other things below require knowing if scroll bar is visible, however,
% hence the dependency on doing this first.
resizeScrollBar(dp);

% Reposition auto-hide strip
%
resizeBodySplitter(dp);

% Reposition body (application) panel
%
if ~dp.PanelVisible
    % DialogPanel not visible
    % Reset panelWidth so body panel code below knows what to do
    panelWidth = 0;
    gutterFig = 0; % leave gutterBody, it's where the AutoHideBar renders
end
if infoPanelOnLeft
    % [<------------------------- parentWidth ------------------------>]
    % 1                                                                N
    % [gutterFig][scroll][dlgPanel][gutterScroll][gutterBody][bodyPanel]
    %                                                    x0->|
    bodypanel_x0 = gutterFig+scrollWidth+gutterScroll+panelWidth+gutterBody+1;
else % info panel on right, body panel on left
    % [<------------------------- parentWidth ------------------------>]
    % 1                                                                N
    % [bodyPanel][gutterBody][dlgPanel][gutterScroll][scroll][gutterFig]
    % |<-x0
    bodypanel_x0 = 1;
end
bodypanel_y0 = 1;
bodypanel_dx = max(1,parentWidth-gutterFig-scrollWidth-gutterScroll-panelWidth-gutterBody);
bodypanel_dy = max(1,parentHeight);
newPos = [bodypanel_x0 bodypanel_y0 bodypanel_dx bodypanel_dy];
set(dp.hBodyPanel,'pos',newPos);

hideBodyContentIfTooSmall(dp);
