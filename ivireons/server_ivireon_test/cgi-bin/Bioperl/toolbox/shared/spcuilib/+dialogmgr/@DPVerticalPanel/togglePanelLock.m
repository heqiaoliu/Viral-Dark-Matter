function togglePanelLock(dp)
% Toggle the DialogPanel lock

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:40:31 $

dp.PanelLock = ~dp.PanelLock;

% Enable optional services on each child DialogBorder
enableDialogBorderServices(dp);


