function installDefaultUserSettings(ntx)
% Default settings for all user-settable properties.
% 
% Only need to address defaults for child objects (objects contained within
% NTX) that are not specific to NTX and therefore may have defaults that
% are not appropriate for NTX.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/04/21 21:21:41 $

% Install defaults for DialogPanel child object
%
dp = ntx.dp;
dp.AutoHide   = false;
dp.PanelLock  = false;
dp.PanelWidth = 189; %168; % initial width of DPVerticalPanel, in pixels
% Ordered list of names of visible dialogs
dp.DockedDialogNamesInit = {'Legend','Resulting Type','Bit Allocation',...
    'Input Data'};
