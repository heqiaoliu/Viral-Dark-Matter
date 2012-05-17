function resizeParentPanel(dp)
% Resize top-level Parent panel, and all its child panels.
% Generally called in response to a change in size of the top-level
% hFigPanel panel.
%
% Actions:
%  - Update hParent panel position
%  - Cache hFigPanel position
%  - Resize child panels (hBodyPanel, hDialogPanel, hBodySplitter)

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:15 $

% Get hFigPanel pos, in pixels
figpanel_pos = getFigPanelPosPixels(dp);

% Update hParent panel position to exactly match parent panel
set(dp.hParent,'pos',[1 1 figpanel_pos(3:4)]);

% Update child panels
resizeChildPanels(dp);

% xxx bug fix:
% Use resize as a time to cure any renderer bugs
% If user re-sizes display, flash the renderer to resolve invisible controls
% in the dialogs
hf = dp.hFig;
origRenderer = get(hf,'renderer');
if strcmpi(origRenderer,'zbuffer')
    altRenderer = 'opengl';
else
    altRenderer = 'zbuffer';
end
set(hf,'renderer',altRenderer);
set(hf,'renderer',origRenderer);

