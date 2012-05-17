function init(ntx,hUser,userOpts)
% One-time call to initialize NTX object at construction.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/04/21 21:21:40 $

% Create DPVerticalPanel object that is owned by NTX
% Panel is left invisible until fully populated
dp = dialogmgr.DPVerticalPanel(hUser);

% Configure DialogPanel for minimum body panel size
dp.BodyMinWidth  = 300; % minimum body width, in pixels
dp.BodyMinHeight = 250; % minimum body height, in pixels
dp.BodyMinSizeTitle = 'Histogram'; % name for body size message
%dp.DockLocationMouseDragEnable = false;
dp.DialogHoverHighlight = true;

% NTX will throw an error if figure renderer is painters.
set(dp.hFig,'renderer','zbuffer');

% Cross-couple the NTX and DP objects
ntx.dp = dp;
dp.UserData = ntx;

% Install default and user settings
installDefaultUserSettings(ntx);
if nargin>2
    loadCustomUserSettings(ntx,userOpts);
end
% xxx needed due to custom user settings?  check this!
resizeChildPanels(dp);

createHistogramUI(ntx);
createDTX(ntx);
createAppSpecificDialogs(ntx);
initMainGUIParts(ntx); % makes DialogPanel visible when finished

% Last step: make main panel visible
setVisible(dp);
