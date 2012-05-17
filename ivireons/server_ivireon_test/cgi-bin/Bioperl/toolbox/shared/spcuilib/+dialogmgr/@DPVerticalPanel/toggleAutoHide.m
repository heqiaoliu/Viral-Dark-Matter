function toggleAutoHide(dp)
% Toggle the state of AutoHide
% On: use auto-hide
% Off: use explicit open/close

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:28 $

% Toggle dialog visibility
newHide = ~dp.AutoHide;
dp.AutoHide = newHide;

% If AutoHide is now turned on, turn off panel vis
% (and vice-versa)
setDialogPanelVisible(dp,~newHide);

% Need to nudge the layout when swapping between auto-hide and explicit,
% otherwise the splitter arrows will be off by a pixel
resizeBodySplitter(dp);
updateSplitterBarAction(dp); % update splitter bar


