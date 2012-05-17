function toggleDialogPanelVisible(dp)
% Toggle visibility of dialog panel
% Done for explicit open/close

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:40:29 $

% Change dialog visibility
setDialogPanelVisible(dp,~dp.PanelVisible);
